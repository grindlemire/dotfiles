---
name: blog-post
description: Use when drafting or revising a blog post or essay in Joel's voice (alethi.dev, gitstack.sh), from the first interview through his review in redline.
---

# Blog post

Joel's long-form writing argues one claim through a causal chain, in his own
voice, with nothing invented on his behalf. This skill is the process for
getting there. GitStack product posts also read
`~/code/alethi/gitstack/marketing/brain/voice.md` and `product-facts.md`.

## 1. Grill before drafting

Interview Joel one question at a time (the `grill-me` skill), giving your
recommended answer with each question. Settle these, in roughly this order:

- **The spine.** One flat sentence he'd defend, and the causal chain behind
  it: each section true only because the previous one happened. A list of
  predictions is the slop shape; push until it becomes a chain.
- **The center of gravity.** The newest, most contestable idea gets the most
  words. Ideas he's already published get a short section and a link.
- **The reader and their decision.** Who acts on this, and what they're
  deciding.
- **The strongest objection** an informed reader raises first, and Joel's
  answer to it.
- **The form.** Bookends are composite scenes built from details Joel
  supplies, with no employer named, opening from something most readers
  share and told in third person. Otherwise pure argument.
- **His firsthand material.** Every concrete example comes from Joel. Where
  you need one he hasn't given, ask.

Done when Joel has confirmed the spine sentence and an outline.

## 2. Draft

Write in the voice in `~/.config/writing/voice.md`, toward these targets
for the post's shape:

- One or two bold thesis sentences per section, each standing on terms the
  post has already set up.
- Sections are ordered by dependency, and the order shows in the content
  itself. A section ends on the need the next one answers; the post never
  announces what's coming.
- A system is defined before its parts; parts get bold run-in leads.
- Limits get their own plain section.
- The ending is a concrete claim that closes a loop the opening started.

## 3. Slop pass

Run the `slop` skill's pass over the draft. Done when that pass's own
completion check holds: lint clean, and a second check finds nothing.

## 4. Fact pass

Check every claim about a product or vendor at its source and link the
source. Products appear as examples of a category, never as the proof of an
argument.

## 5. Hand back through redline

Give Joel the draft with a short list of **lines where you speak for him**:
any sentence about his experience, opinions, or the people he talks to that
he didn't say in the session. Those are the first things he checks.

Joel reviews on the rendered page with redline, which overlays comments and
in-place markdown editing on the site's dev server
(`~/code/personal/redline`, README there). Start it in the background from
the repo or worktree holding the post, and give Joel the URL it prints plus
the post path:

- gitstack.sh: `redline serve --root . --upstream <sandbox URL from mage sandbox status> --content marketing/content`
- alethi.dev: `redline serve --root . --cmd 'ALETHI_DEV=1 PORT=18451 go run ./cmd/site' --upstream http://localhost:18451 --content content`

Then loop until Joel says the post is done: run `redline wait` as a
background command; when it prints a batch, make each change, answer every
thread with `redline reply <id> -m "<what changed>" --resolve` (no
`--resolve` when you need to ask him something), and wait again. Re-read the
lines in any "Joel edited" entry before touching them: those are his hand
edits and his voice.

A thread marked with an action (`[slop]`, `[polish]`) names the skill that
handles it in the batch header; follow that skill's steps for the thread.

## 6. Keep what Joel flags

Every slop pattern Joel flags goes through the `slop` skill's Record step as
it comes up, and its Commit step when he says the post is done. A flag that
isn't recorded will be repeated in the next post.

## alethi.dev mechanics

Posts live in `content/posts/YYYY-MM-DD-slug.md`. Keep `draft: true`
until Joel says to publish; `ALETHI_DEV=1 go run ./cmd/site` shows drafts,
production doesn't. A fresh worktree needs `bun install && bun run
build:islands` before charts render. Figures are d3 components in `src/charts/` registered in
`src/charts/registry.ts` and placed with a ```` ```chart:<name> ```` block.
A figure earns its place when it shows the post's central claim faster than
prose can, with as little text inside it as possible.
