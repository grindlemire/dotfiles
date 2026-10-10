#!/usr/bin/env python3
"""Local review page for marketer drafts, for every project in projects.toml.

Serves each project's drafts (DATA/<slug>/posts/, one JSON file per batch,
YYYY-MM-DD.json) at http://127.0.0.1:8787/?project=<slug>. Joel comments and
marks drafts posted or skipped from the page; every change is written back
into the batch file, and each action Joel takes is printed as one EVENT line
on stdout so a Claude session can watch the log and respond live.

Stdlib only. Usage: python3 server.py [--config DIR] [--data DIR] [--port N]
"""

import argparse
import html
import json
import os
import re
import sys
import threading
import time
import tomllib
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlparse, urlunparse

HERE = Path(__file__).resolve().parent
LOCK = threading.Lock()

STATIC = {}
for font in (HERE / "fonts").glob("*.woff2"):
    STATIC[f"/fonts/{font.name}"] = (f"fonts/{font.name}", "font/woff2")

# Set from the command line in main().
CONFIG_DIR = None
DATA_DIR = None


def projects():
    """projects.toml, read on every call so a new project shows up without a restart."""
    with (CONFIG_DIR / "projects.toml").open("rb") as f:
        return tomllib.load(f)


def project(slug):
    """The named project, or the only one when no name is given. None if unknown."""
    all_ = projects()
    if not slug and len(all_) == 1:
        slug = next(iter(all_))
    if not slug or "/" in slug or slug not in all_:
        return None
    return {**all_[slug], "slug": slug}


def posts_dir(proj):
    d = DATA_DIR / proj["slug"] / "posts"
    d.mkdir(parents=True, exist_ok=True)
    return d


def card_hosts(proj):
    # Link-card data for previews: only the project's own site. This is a
    # preview of our own links, not a general fetcher.
    host = urlparse(proj.get("site", "")).hostname or ""
    host = host.removeprefix("www.")
    return {host, "www." + host} if host else set()


CARDS = {}
META_RE = re.compile(r'<meta\s+property="og:(title|description|image)"\s+content="([^"]*)"', re.I)


def link_card(proj, target):
    u = urlparse(target)
    if u.scheme != "https" or u.hostname not in card_hosts(proj):
        return {"error": f"previews only fetch {proj.get('site', 'the project site')} links"}
    clean = urlunparse(u._replace(query="", fragment=""))
    if clean not in CARDS:
        try:
            req = urllib.request.Request(clean, headers={"User-Agent": "marketer-post-queue"})
            with urllib.request.urlopen(req, timeout=5) as r:
                page = r.read(200_000).decode("utf-8", "replace")
            CARDS[clean] = {k.lower(): html.unescape(v) for k, v in META_RE.findall(page)}
            CARDS[clean]["domain"] = u.hostname
        except OSError as e:
            return {"error": str(e)}
    return CARDS[clean]


IMAGES = {}


def card_image(proj, target):
    """Fetch a card image from the project's site once and serve it from here,
    so the preview doesn't depend on the browser reaching the CDN directly."""
    u = urlparse(target)
    if u.scheme != "https" or u.hostname not in card_hosts(proj):
        return None
    if target not in IMAGES:
        try:
            req = urllib.request.Request(target, headers={"User-Agent": "marketer-post-queue"})
            with urllib.request.urlopen(req, timeout=5) as r:
                IMAGES[target] = (r.headers.get_content_type(), r.read(5_000_000))
        except OSError:
            return None
    return IMAGES[target]


def batch_files(posts_dir):
    return sorted(posts_dir.glob("*.json"), reverse=True)


def load(path):
    with path.open() as f:
        return json.load(f)


def save(path, data):
    tmp = path.with_suffix(".json.tmp")
    with tmp.open("w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")
    os.replace(tmp, path)


def event(kind, slug, batch, draft_id, text=""):
    line = " ".join(text.split())
    print(f"EVENT {kind} project={slug} batch={batch} draft={draft_id} {line}".rstrip(), flush=True)


class Handler(BaseHTTPRequestHandler):
    def log_message(self, *args):
        pass

    def send_json(self, status, payload):
        body = json.dumps(payload).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def send_file(self, path, ctype, cache="max-age=86400"):
        body = path.read_bytes()
        self.send_response(200)
        self.send_header("Content-Type", ctype)
        self.send_header("Cache-Control", cache)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        url = urlparse(self.path)
        query = parse_qs(url.query)
        if url.path in ("/", "/index.html"):
            body = (HERE / "index.html").read_bytes()
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return
        if url.path == "/favicon.ico":
            self.send_response(204)
            self.end_headers()
            return
        static = STATIC.get(url.path)
        if static:
            name, ctype = static
            self.send_file(HERE / name, ctype)
            return
        if url.path == "/avatar.jpg":
            avatar = CONFIG_DIR / "avatar.jpg"
            if avatar.is_file():
                self.send_file(avatar, "image/jpeg", "max-age=3600")
            else:
                self.send_json(404, {"error": f"no {avatar}"})
            return
        if url.path == "/api/me":
            try:
                self.send_json(200, load(CONFIG_DIR / "me.json"))
            except (OSError, json.JSONDecodeError) as e:
                self.send_json(200, {"error": str(e)})
            return
        if url.path == "/api/projects":
            try:
                rows = [{"slug": slug, "name": p.get("name", slug), "headline": p.get("headline", ""),
                         "site": p.get("site", ""), "mark": bool(p.get("mark"))}
                        for slug, p in projects().items()]
            except (OSError, tomllib.TOMLDecodeError) as e:
                self.send_json(500, {"error": f"projects.toml: {e}"})
                return
            self.send_json(200, {"projects": rows})
            return
        # Everything below is per project.
        proj = project(query.get("project", [""])[0])
        if proj is None:
            self.send_json(404, {"error": "unknown project; pass ?project=<slug> from projects.toml"})
            return
        if url.path == "/mark.svg":
            mark = Path(proj["repo"]).expanduser() / proj.get("mark", "")
            if proj.get("mark") and mark.is_file():
                self.send_file(mark, "image/svg+xml", "max-age=3600")
            else:
                self.send_json(404, {"error": "no mark"})
            return
        if url.path == "/api/og":
            self.send_json(200, link_card(proj, query.get("url", [""])[0]))
            return
        if url.path == "/api/ogimg":
            img = card_image(proj, query.get("url", [""])[0])
            if img is None:
                self.send_json(404, {"error": "no image"})
                return
            self.send_response(200)
            self.send_header("Content-Type", img[0])
            self.send_header("Cache-Control", "max-age=3600")
            self.send_header("Content-Length", str(len(img[1])))
            self.end_headers()
            self.wfile.write(img[1])
            return
        if url.path == "/api/drafts":
            with LOCK:
                batches = []
                for p in batch_files(posts_dir(proj)):
                    try:
                        data = load(p)
                    except (OSError, json.JSONDecodeError) as e:
                        data = {"error": str(e), "drafts": []}
                    data["batch"] = p.stem
                    batches.append(data)
            self.send_json(200, {"project": proj["slug"], "batches": batches})
            return
        self.send_json(404, {"error": "not found"})

    def do_POST(self):
        try:
            length = int(self.headers.get("Content-Length", 0))
            req = json.loads(self.rfile.read(length) or b"{}")
            batch, draft_id = req["batch"], req["id"]
        except (ValueError, KeyError):
            self.send_json(400, {"error": "need batch and id"})
            return
        proj = project(str(req.get("project", "")))
        if proj is None:
            self.send_json(404, {"error": "unknown project"})
            return
        slug = proj["slug"]
        path = posts_dir(proj) / f"{batch}.json"
        if not path.is_file() or "/" in batch:
            self.send_json(404, {"error": "no such batch"})
            return
        with LOCK:
            data = load(path)
            draft = next((d for d in data.get("drafts", []) if d.get("id") == draft_id), None)
            if draft is None:
                self.send_json(404, {"error": "no such draft"})
                return
            who = req.get("who", "joel")
            now = time.strftime("%Y-%m-%d %H:%M")
            if self.path == "/api/comment":
                text = str(req.get("text", "")).strip()
                if not text:
                    self.send_json(400, {"error": "empty comment"})
                    return
                draft.setdefault("comments", []).append({"who": who, "text": text, "at": now})
                # A Claude reply answers whatever Joel left; a Joel comment needs one.
                draft["needs_claude"] = who == "joel"
                save(path, data)
                if who == "joel":
                    event("comment", slug, batch, draft_id, text)
            elif self.path == "/api/edit":
                text = str(req.get("text", "")).rstrip()
                if not text.strip():
                    self.send_json(400, {"error": "empty text"})
                    return
                if text == draft.get("text"):
                    self.send_json(200, {"ok": True})
                    return
                # Keep Claude's first version so Joel's edits can be learned from.
                draft.setdefault("claude_text", draft.get("text", ""))
                draft["text"] = text
                draft["edited_at"] = now
                if who == "joel":
                    draft["needs_claude"] = True
                save(path, data)
                if who == "joel":
                    event("edit", slug, batch, draft_id, text)
            elif self.path == "/api/status":
                status = req.get("status")
                if status not in ("draft", "posted", "skipped"):
                    self.send_json(400, {"error": "status must be draft, posted or skipped"})
                    return
                draft["status"] = status
                draft["status_at"] = now
                note = str(req.get("reason") or req.get("url") or "").strip()
                if status == "skipped":
                    draft["skip_reason"] = note
                    if note and who == "joel":
                        draft["needs_claude"] = True
                if status == "posted" and "url" in req:
                    draft["post_url"] = note
                save(path, data)
                if who == "joel":
                    event(status, slug, batch, draft_id, note)
            else:
                self.send_json(404, {"error": "not found"})
                return
        self.send_json(200, {"ok": True})


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", default="~/.config/marketer", help="holds projects.toml, me.json, avatar.jpg")
    ap.add_argument("--data", default="~/Documents/marketing", help="drafts live in DATA/<slug>/posts/")
    ap.add_argument("--port", type=int, default=8787)
    args = ap.parse_args()
    global CONFIG_DIR, DATA_DIR
    CONFIG_DIR = Path(args.config).expanduser()
    DATA_DIR = Path(args.data).expanduser()
    names = ", ".join(projects())  # fail fast on a missing or broken projects.toml
    srv = ThreadingHTTPServer(("127.0.0.1", args.port), Handler)
    print(f"READY http://127.0.0.1:{args.port} data={DATA_DIR} projects={names}", flush=True)
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        sys.exit(0)


if __name__ == "__main__":
    main()
