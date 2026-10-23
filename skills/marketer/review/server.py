#!/usr/bin/env python3
"""Local review page for marketer drafts, for every project in projects.toml.

Serves each project's drafts (DATA/<slug>/posts/, one JSON file per batch,
YYYY-MM-DD.json) at http://127.0.0.1:8787/?project=<slug>. Joel comments on
selected text, flags it with a redline action (slop, polish), edits the text
in place, and marks drafts posted or skipped. Comments, flags, and edits wait
as drafts until he sends them as a batch. Every change is written back into
the batch file, and each send, posted, and skip is printed as one EVENT line
on stdout so a Claude session can watch the log and respond live.

Stdlib only. Usage: python3 server.py [--config DIR] [--data DIR] [--actions FILE] [--port N]
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
ACTIONS_FILE = None


def actions():
    """The selection actions from redline's actions.toml, so slop and polish work the same on posts as on blog drafts."""
    try:
        with ACTIONS_FILE.open("rb") as f:
            rows = tomllib.load(f).get("action", [])
    except (OSError, tomllib.TOMLDecodeError):
        return []
    keep = ("name", "label", "key", "color", "note")
    return [{k: a[k] for k in keep if k in a} for a in rows if a.get("name") and a.get("label")]


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


# Threads hang off a draft: {"id", "kind": "text" | "edit", "label", "status",
# "anchor": {"quote", "from", "to"}, "messages": [...], "edit": {"before", "after"}}.
# Status runs draft (Joel's, unsent) -> sent (in a batch) -> resolved (Claude
# replied); a hand edit goes draft -> info, since it needs no reply.


def new_thread(draft, **fields):
    draft["next_thread"] = draft.get("next_thread", 0) + 1
    t = {"id": f"t{draft['next_thread']}", "status": "draft", "messages": [], **fields}
    draft.setdefault("threads", []).append(t)
    return t


def reanchor(draft, start, end, delta):
    """Move text threads after an edit of [start, end): later ones shift; ones
    inside find their quote again, nearest where it was, or are detached."""
    text = draft["text"]
    for t in draft.get("threads", []):
        a = t.get("anchor")
        if t.get("kind") != "text" or not a or t.get("detached") or a["to"] <= start:
            continue
        if a["from"] >= end:
            a["from"] += delta
            a["to"] += delta
            continue
        hits = [m.start() for m in re.finditer(re.escape(a["quote"]), text)]
        if not hits:
            t["detached"] = True
            continue
        a["from"] = min(hits, key=lambda i: abs(i - a["from"]))
        a["to"] = a["from"] + len(a["quote"])


def waiting(draft):
    """Whether a sent thread still has no answer from Claude."""
    return any(t.get("status") == "sent" for t in draft.get("threads", []))


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
        if url.path == "/api/actions":
            self.send_json(200, {"actions": actions()})
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
            thread = next((t for t in draft.get("threads", []) if t.get("id") == req.get("thread")), None)
            if self.path == "/api/comment":
                # A comment on the whole post. Joel's waits for the next send; Claude's
                # answers what Joel sent.
                text = str(req.get("text", "")).strip()
                if not text:
                    self.send_json(400, {"error": "empty comment"})
                    return
                c = {"who": who, "text": text, "at": now}
                if who == "joel":
                    c["draft"] = True
                else:
                    draft["needs_claude"] = waiting(draft)
                draft.setdefault("comments", []).append(c)
            elif self.path == "/api/thread":
                # Joel's comment or action on selected text: {anchor: {quote, from, to}, label?, text?}.
                a, label = req.get("anchor") or {}, req.get("label") or None
                text = str(req.get("text", "")).strip()
                try:
                    start, end = int(a["from"]), int(a["to"])
                except (KeyError, TypeError, ValueError):
                    self.send_json(400, {"error": "need anchor from and to"})
                    return
                if draft.get("text", "")[start:end] != a.get("quote") or end <= start:
                    self.send_json(409, {"error": "the text changed under that selection; select it again"})
                    return
                if not text and not label:
                    self.send_json(400, {"error": "empty comment"})
                    return
                msgs = [{"who": "joel", "text": text, "at": now}] if text else []
                t = new_thread(draft, kind="text", label=label, anchor={"quote": a["quote"], "from": start, "to": end}, messages=msgs)
                save(path, data)
                self.send_json(200, {"ok": True, "thread": t["id"]})
                return
            elif self.path == "/api/reply":
                text = str(req.get("text", "")).strip()
                if thread is None or not text:
                    self.send_json(400, {"error": "need thread and text"})
                    return
                thread["messages"].append({"who": who, "text": text, "at": now})
                # Joel's reply reopens the thread for the next send; Claude's answers it.
                thread["status"] = "draft" if who == "joel" else "resolved"
                if who != "joel":
                    draft["needs_claude"] = waiting(draft)
            elif self.path == "/api/delete":
                # Drop an unsent thread, or Joel's unsent whole-post comment {comment: index}.
                if thread is not None and thread["status"] == "draft":
                    draft["threads"].remove(thread)
                elif isinstance(req.get("comment"), int):
                    cs, i = draft.get("comments", []), req["comment"]
                    if not (0 <= i < len(cs) and cs[i].get("draft")):
                        self.send_json(400, {"error": "only an unsent comment can be deleted"})
                        return
                    cs.pop(i)
                else:
                    self.send_json(400, {"error": "only an unsent thread can be deleted"})
                    return
            elif self.path == "/api/edit":
                # Joel's hand edit of [from, to) (a paragraph, or the whole post) to text.
                text = str(req.get("text", ""))
                old = draft.get("text", "")
                start, end = req.get("from", 0), req.get("to", len(old))
                if not (isinstance(start, int) and isinstance(end, int) and 0 <= start <= end <= len(old)) or old[start:end] != req.get("before", old[start:end]):
                    self.send_json(409, {"error": "the post changed while you were editing; your text is still in the box"})
                    return
                new = old[:start] + text + old[end:]
                if not new.strip():
                    self.send_json(400, {"error": "empty text"})
                    return
                if new == old:
                    self.send_json(200, {"ok": True})
                    return
                # Keep Claude's first version so Joel's edits can be learned from.
                draft.setdefault("claude_text", old)
                draft["text"] = new
                draft["edited_at"] = now
                # An edit while Claude has the batch is Joel's, not Claude's: keep it out of what the page marks as revised.
                if draft.get("sent_text") == old:
                    draft["sent_text"] = new
                reanchor(draft, start, end, len(text) - (end - start))
                new_thread(draft, kind="edit", edit={"before": old[start:end], "after": text})
            elif self.path == "/api/send":
                # Everything Joel left on this draft goes to Claude as one batch.
                n = draft.get("sends", 0) + 1
                counts = {"threads": 0, "comments": 0, "edits": 0}
                for t in draft.get("threads", []):
                    if t["status"] == "draft":
                        t["status"] = "info" if t.get("kind") == "edit" else "sent"
                        t["sent_in"] = n
                        counts["edits" if t.get("kind") == "edit" else "threads"] += 1
                for c in draft.get("comments", []):
                    if c.pop("draft", False):
                        c["sent_in"] = n
                        counts["comments"] += 1
                if not any(counts.values()):
                    self.send_json(200, {"ok": True})
                    return
                draft["sends"] = n
                draft["needs_claude"] = True
                draft["sent_at"] = int(time.time())  # the page shows Claude working until a reply, or a few minutes
                draft["sent_text"] = draft["text"]  # the page marks what Claude rewrote against this
                save(path, data)
                event("send", slug, batch, draft_id, f"n={n} " + " ".join(f"{k}={v}" for k, v in counts.items()))
                self.send_json(200, {"ok": True})
                return
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
                        draft["sent_at"] = int(time.time())
                if status == "posted" and "url" in req:
                    draft["post_url"] = note
                save(path, data)
                if who == "joel":
                    event(status, slug, batch, draft_id, note)
                self.send_json(200, {"ok": True})
                return
            else:
                self.send_json(404, {"error": "not found"})
                return
            save(path, data)
        self.send_json(200, {"ok": True})


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", default="~/.config/marketer", help="holds projects.toml, me.json, avatar.jpg")
    ap.add_argument("--data", default="~/Documents/marketing", help="drafts live in DATA/<slug>/posts/")
    ap.add_argument("--actions", default="~/.config/redline/actions.toml", help="redline's selection actions (slop, polish)")
    ap.add_argument("--port", type=int, default=8787)
    args = ap.parse_args()
    global CONFIG_DIR, DATA_DIR, ACTIONS_FILE
    ACTIONS_FILE = Path(args.actions).expanduser()
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
