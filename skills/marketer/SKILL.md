---
name: marketer
description: Use when Joel asks to draft marketing posts for one of his projects (GitStack or any other in ~/.config/marketer/projects.toml): "draft posts", "draft 3 posts about X", "write a post for Bluesky", asks what's next in marketing ("/marketer next", "marketing", "what's my next marketing step"), wants to record why he rejected or changed a marketing draft, or wants to set marketing up for a new project ("/marketer init"). Reads the project's marketing brain before writing anything. Drafts only; never posts, sends, or publishes.
---

# Marketer

Marketing agent for Joel's projects. Every mode starts by finding the project
and loading its brain. Agents draft; Joel edits, posts, and decides.

## Step 0: find the project and load its brain (every mode)

Projects live in `~/.config/marketer/projects.toml`, one table per project
slug (the file documents its fields). Pick the project:

1. A slug in the request (`/marketer next gitstack`).
2. Else the project whose `repo` contains the current directory.
3. Else the only project in the file.
4. Else ask Joel which one, in one line.

The brain is the `brain` folder in the project's `repo`. When `read_from` is
set (say `origin/main`), local checkouts go stale, so fetch and read the
landed copy from that ref:

```bash
cd <repo> && gs fetch origin main     # vcs = "gs"; plain `git fetch` for vcs = "git"
git -C <repo> ls-tree --name-only -r origin/main <brain>/
git -C <repo> show origin/main:<brain>/README.md
```

(Fetching needs the command sandbox disabled for network. Run gs from the
repo root, never a subdirectory.) If a worktree has unlanded brain edits,
those are newer; use them and say so. With `read_from = ""`, read the working
tree.

Read **`marketer.md` first** when the brain has one: it holds this project's
rules for this skill (links and short links, extra self-checks, how brain
edits land), and it wins over the defaults below. Then read **every** other
file in the README's read order. They are short. Don't skim `rejected.md` or
`voice.md`: they are the rules Joel has already enforced by hand.

## Mode: next (the default)

Trigger: `/marketer next [slug]`, `/marketer` with no request, "marketing",
"what's next". Joel runs `marketing [slug]` in a terminal (in his dotfiles
scripts), which opens Claude Code in the project's repo with
`/marketer next <slug>`. He finds the process hard to keep in his head, so
this mode decides for him: do the next step, then tell him his one next
action in a sentence or two. No menus, no recap of the system.

1. Make sure the review server is up and watched (see "Output: the local
   review page", steps 1 and 2).
2. Fetch `/api/drafts?project=<slug>` and pick the first row that applies:

| State | Do |
|---|---|
| Any draft has `needs_claude` | Handle them (see "Catch up first"), then go on down this table. |
| Any draft is still `draft` | Open the page for him (`open "http://127.0.0.1:8787/?project=<slug>"`, sandbox disabled). Say: "N posts are waiting. Click Open in X/Bluesky/LinkedIn, post it, then click Posted. Skip any you don't like and say why." Then stay and respond to his events. |
| Every draft is posted or skipped (or none exist) | Draft a new batch (Mode: draft posts), open the page, and say the same line as above. |

3. If posted drafts exist and it's been a week since the last summary, say
   in one line that the weekly summary isn't built yet and offer to build it.
   Don't block on it.

## Mode: draft posts

Trigger: "draft posts", "draft N posts", "draft a post about <topic>",
"draft posts for <channel>".

### Inputs (ask nothing; use defaults)

- **Count:** default 4.
- **Angle:** default alternates the current angles in `playbook.md`. Use a
  parked angle only if Joel names it.
- **Channel:** default a mix of X, Bluesky, and LinkedIn. Reddit only when
  asked. Hacker News: don't draft unless asked; Joel times HN himself.
- **Topic:** optional. If Joel names a changelog entry or blog post, read it
  (`marketer.md` says where they live) and verify any product claim in
  `product-facts.md` or the code.

### Building each draft

1. **Open with a trigger moment** from `playbook.md` or a real quote from
   `customer-language.md`. The reader should recognize their own week. Real
   customer words beat Joel's paraphrase. Joel's own voice stays curious and
   observant: the frustration belongs to the people quoted or described,
   never to Joel.
2. **Say one idea.** One angle per post.
3. **Product claims only from `product-facts.md`.** Every claim in the draft
   maps to a line there.
4. **Joel's opinions** come from `founder-opinions.md`, in his words. Respect
   each entry's usage note (private, own-name only, false): `marketer.md` or
   the file itself lists them.
5. **Close with one ask** and the right link:
   - X and Bluesky: a soft ask only ("Give it a try", "Here's how it works",
     or just the link). Joel finds "Try it" salesy on short posts.
   - LinkedIn: a plain direct ask is fine.
   - Which pages to link (trying it vs seeing it) is in `marketer.md`.
   Every link carries UTM tags:
   `?utm_source=<x|bluesky|linkedin|reddit>&utm_medium=social&utm_campaign=<angle>&utm_content=<YYYYMMDD>-<n>`
   If `marketer.md` sets up short links, the post shows the short link and
   the tagged path goes in `target`; follow its steps for minting and landing
   them. Otherwise `link` is the full tagged URL.
   Reddit replies usually carry no link at all; follow the sub's rules and
   say Joel is the founder when the project comes up.
6. **Channel shape:**
   - X: under 280 characters, or a thread of at most 4 posts.
   - Bluesky: under 300 characters.
   - LinkedIn: up to 3,000 characters (LinkedIn's cap, about 500 words),
     short paragraphs. Joel is fine with long ones (2026-10-14); let the idea
     set the length. Past the cap means a LinkedIn article, so ask
     first. The link rides in the
     preview card, not the text (leave `{link}` out). Joel pastes it, waits
     for the card, then deletes the URL text (2026-10-10, he asked to hide it).
   - Reddit: a helpful answer to the thread's actual question first; the
     project only if it genuinely answers it.

### Self-check before showing Joel (every draft)

Fail the draft and rewrite it if any of these hit:

- Any hit from the `slop` skill's check, run on every post: the lint plus
  every pattern Joel has flagged.
- A number, stat, user count, or testimonial without a source in the brain.
- Anything in `rejected.md`, or in the extra checks in `marketer.md`.

Mechanical checks: after writing the batch JSON, `grep -c '—' <file>` must
print 0. The review page shows each post's length against the channel limit
(X counts a link as 23 characters; a Bluesky link-card link isn't counted)
and turns red when over; check `/api/drafts` or the page rather than guessing
by eye.

### Output: the local review page

Joel reviews drafts on a local page, not in chat and not as a claude.ai
artifact (he finds artifacts noisy). Write each batch as JSON to
`~/Documents/marketing/<slug>/posts/YYYY-MM-DD.json` (use the Write or Edit
tool; the command sandbox can't write there). If the file exists, add to its
`drafts` array.

```json
{
  "note": "one line on what this batch tries",
  "drafts": [
    {
      "id": "YYYYMMDD-n",
      "channel": "x | bluesky | linkedin | reddit",
      "angle": "<angle from playbook.md>",
      "text": "Post text exactly as posted. Put {link} where an inline link goes; leave it out when the link rides in a Bluesky link card.",
      "link": "https://<site>/<short link or tagged path>",
      "target": "/<path>?utm_source=...&utm_content=YYYYMMDD-n (only with short links)",
      "post_on": "Tue Oct 13, morning",
      "sources": "customer-language quote, founder-opinions #s, product-facts lines",
      "flags": "anything Joel must decide, or none",
      "status": "draft",
      "comments": []
    }
  ]
}
```

Give every draft a `post_on` day so Joel never has to plan: spread a batch
over about a week of weekdays, at most one post per channel per day, X posts
at least two days apart, mornings US time (Tue to Thu are best for
LinkedIn). With several projects, keep Joel's own accounts from posting
twice on one channel the same day across projects. The page shows it as a
"post <day>" pill.

Then make sure the review page is running and watched. One server serves
every project.

1. `curl -s 127.0.0.1:8787/api/projects` (sandbox disabled). If it fails,
   start the server as a background Bash command (sandbox disabled):
   `python3 ~/.claude/skills/marketer/review/server.py 2>&1 | tee -a ~/Documents/marketing/review-events.log`
   It rereads `projects.toml` on every request, so a new project needs no
   restart.
2. Start a Monitor (max timeout, re-arm on expiry while Joel is reviewing):
   `tail -n 0 -F ~/Documents/marketing/review-events.log | grep --line-buffered -E '^EVENT \S+ project=<slug> |Traceback|Error'`
3. Tell Joel in one line: the batch is up at
   `http://127.0.0.1:8787/?project=<slug>`, plus which angle each draft tests.

The page shows each draft beside a live preview drawn at the feed's real
width with Joel's avatar and names (Bluesky measured from bsky.app; X and
LinkedIn follow their layouts but aren't checked live), including the real
link card fetched from the project's `site`, its character count against the
channel limit, an "Open in <channel>" button that fills the real composer
(nothing posts until Joel presses Post), Copy, Edit, Posted (with an optional
live-post URL) and Skip (with an optional reason) buttons, and a comment
thread. Who the previews post as lives in `~/.config/marketer/me.json` and
`avatar.jpg`, plus the project's `headline`. It refreshes every 2 seconds, so
edits to the JSON show up live.

### Catch up first (every run)

The live watch lapses (30-minute Monitor, and it dies with the session), so
before drafting anything, fetch `/api/drafts?project=<slug>` and handle every
draft with `"needs_claude": true`. That flag is set by each of Joel's
comments, edits, and skips with a reason, and cleared by your reply in its
thread. Handle them exactly like the live events below, oldest batch first.

### Responding to Joel live

Each Monitor line is `EVENT <kind> project=<slug> batch=<b> draft=<id> <text>`:

- **comment**: revise the draft's `text` in the JSON if he asked for a change
  (run the self-check again) and record any reason (Mode: record feedback).
- **edit**: Joel rewrote the post himself. `claude_text` holds your original
  and `text` his version. Compare them, name what he changed (cut a phrase,
  softened the ask, reordered), and if it's a pattern, add it to `voice.md` or
  `rejected.md` in his words where possible. Never overwrite his text.
- **skipped** with a reason: add the draft and his reason to `rejected.md`.
  A skip with no reason needs nothing.
- **posted**: nothing to reply. The text after the id is the live post URL
  when he gave one (stored as `post_url`; the Monday memo reads it).

For comment, edit, and skip-with-reason, reply in the draft's thread. That
clears `needs_claude` and shows Joel what you did:

```bash
python3 -c 'import json,sys,urllib.request as u; u.urlopen(u.Request("http://127.0.0.1:8787/api/comment", json.dumps({"project":sys.argv[1],"batch":sys.argv[2],"id":sys.argv[3],"who":"claude","text":sys.argv[4]}).encode(), {"Content-Type":"application/json"}))' '<slug>' '<batch>' '<id>' '<one or two plain sentences>'
```

(sandbox disabled). To change a draft's text yourself, edit the JSON file
directly; don't use `/api/edit`, which records Joel's edits.

## Mode: record feedback

Trigger: Joel cuts, rewrites, or reacts to a draft ("too salesy", "I don't
like this hook", edits a draft and posts it), or says which drafts he posted.

1. **Posted:** Joel marks drafts posted on the review page, which writes
   `status` and `status_at` into the batch JSON. If he tells you in chat
   instead, set them yourself. The Monday memo uses this to tie
   `utm_content` to a post.
2. **Rejected or rewritten:** add an entry to the brain's `rejected.md`
   with the before, the after (if any), and Joel's reason **in his words**.
   If the reason is a general rule (a pattern, not a one-off), also add it to
   `voice.md` hard rules, and tell Joel you did.
3. Brain edits land the way `marketer.md` says. Without one: for
   `vcs = "gs"`, a gs worktree off fresh main, one review titled
   `marketing brain: <what changed>`, landed once checks pass (follow the
   gitstack skill, never raw git); for `vcs = "git"`, ask Joel once how he
   wants them landed and write the answer into `marketer.md`.

## Mode: init (set up a new project)

Trigger: `/marketer init`, "set up marketing for <project>".

1. From the current repo (or the one Joel names), propose a registry entry:
   slug, name, repo, `brain = "marketing/brain"`, `read_from` (the remote's
   main branch if there is one), `vcs` (`gs` if the repo is gitstack-backed),
   `site`, `headline`, and `mark` if the repo has a logo SVG. Show it in one
   block, apply Joel's corrections, and append it to
   `~/.config/marketer/projects.toml`.
2. Scaffold the brain with short starter files, each with a one-paragraph
   header saying what goes in it: `README.md` (read order, the one rule, the
   hard limits: copy them from an existing project's brain README and swap
   the names), `marketer.md`, `product-facts.md`, `playbook.md`,
   `customer-fit.md`, `objections.md`, `founder-opinions.md`, `voice.md`,
   `rejected.md`, `customer-language.md`, `competitors.md`, `inbox.md`.
3. Fill `product-facts.md` from the code and docs, every line verified.
   Fill `marketer.md` with what you can see (site, docs and signup links,
   changelog location, how brain edits land) and mark the rest `TODO`.
4. Ask Joel only the `playbook.md` questions, as a short list: who it's for,
   the one ask (sign up, install, star, waitlist), which channels, and two
   or three angles to test first. Leave voice, opinions, and customer
   language empty until real drafts and rejections fill them; never invent
   them.
5. Land the brain the way step 3 of record feedback says, then offer the
   first batch.

## Modes not built yet

Customer language miner, search and LLM visibility check, Monday memo. If
Joel asks for one, say it isn't built yet and offer to build it next.
