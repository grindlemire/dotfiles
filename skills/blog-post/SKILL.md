---
name: blog-post
description: Use when drafting, revising, or slop-checking a blog post or essay in Joel's voice (alethi.dev, gitstack.sh), or when Joel flags a slop pattern in a draft and it should be recorded.
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

Write toward these targets:

- First person for opinions. Observations attributed to what Joel has seen or
  heard, so contested claims read as reports, not demands for agreement.
- Medium-length sentences that carry their reason ("because", "since").
  Commas and periods do the joining. Pivots open with "However," or "That
  said," so turns stay conversational.
- One or two bold thesis sentences per section, each standing on terms the
  post has already set up.
- Concrete specifics: the command, the risk, the number Joel gave you.
  Incidental vendors stay generic ("internal docs").
- Sections are ordered by dependency, and the order shows in the content
  itself. A section ends on the need the next one answers; the post never
  announces what's coming.
- A system is defined before its parts; parts get bold run-in leads.
- Limits get their own plain section.
- The ending is a concrete claim that closes a loop the opening started.
- Joel loves the craft of code and has written it long before agents. His own
  projects are never described as agent-written, and former employers stay
  unnamed.

## 3. Slop pass

Run the `humanizer` skill over the draft, then read [`slop.md`](slop.md) and
check every paragraph against every entry. The humanizer catches general AI
patterns (meta-commentary, Wh- starters, metronomic parallel sentences)
that Joel hasn't had to flag yet. `slop.md` wins wherever the two disagree.

Joel overrides the humanizer on these, so keep them when they appear:

- A question that opens a section by asking what the reader is wondering,
  answered by the next sentence in full (never a "Because…" fragment),
  despite §33.
- Bold run-in leads on list items and on a system's parts, despite §15.
- Third person in scenes. §26 and §27 suggest "you" to put the reader in the
  scene; Joel's openings don't.

Then make the checks neither file covers:

- Every pronoun has one clear referent. When "it" could mean two nouns,
  name the one you mean.
- No relative dates ("this week", "recently"). Posts are read long after
  they're written, so give the month and year.
- No phrase used more than twice; repetition past that reads as a tic.
- Grep for em dashes, colons, and the words in `slop.md`.

Done when the humanizer pass is complete, every `slop.md` entry has been
checked against every paragraph, and each hit is rewritten, not trimmed.

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

A `[slop]` thread is Joel flagging a phrase as slop. Rewrite the whole
passage it sits in, not just the phrase, against the humanizer rules and
`slop.md`. Reply with the before and after, record the pattern as step 6
says, then resolve. If he reopens it, the rewrite missed: fix it and update
that `slop.md` entry, so every recorded rewrite is one he accepted. A plain
comment that names a slop pattern also goes through step 6.

## 6. Record what Joel flags

When Joel flags a pattern as slop, add it to `slop.md` in the matching
section, with the flagged line and the rewrite he accepted. A flag that isn't
recorded will be repeated in the next post.

## alethi.dev mechanics

Posts live in `content/posts/YYYY-MM-DD-slug.md`. Keep `draft: true`
until Joel says to publish; `ALETHI_DEV=1 go run ./cmd/site` shows drafts,
production doesn't. A fresh worktree needs `bun install && bun run
build:islands` before charts render. Figures are d3 components in `src/charts/` registered in
`src/charts/registry.ts` and placed with a ```` ```chart:<name> ```` block.
A figure earns its place when it shows the post's central claim faster than
prose can, with as little text inside it as possible.
