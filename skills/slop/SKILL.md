---
name: slop
description: Use when checking a draft for slop (AI-sounding prose), when Joel flags a phrase as slop (in chat or as a redline [slop] thread), or when recording a slop pattern he flagged.
---

# Slop

Slop is prose that reads as machine-written. This skill finds it, fixes it,
and learns each pattern Joel flags so the next draft doesn't repeat it.

## The voice pack

The rules live in the voice pack at `~/.config/writing/`:

- `slop.md`: every pattern Joel has flagged. Its header defines the entry
  format. This skill is the only writer of that file.
- `voice.md`: how Joel writes. Every rewrite here is in this voice.
- `lint`: the mechanical check, with its rules in `lint.toml`.

No pack means no flagged patterns: the check is the humanizer's patterns
alone, and rewrites match the voice of the surrounding text.

## Check

Report slop without changing anything.

1. Run `~/.config/writing/lint <file>` (or pipe the text to `lint -`).
2. Hold every paragraph against every `slop.md` entry, and against the
   humanizer's patterns.

Report each hit as the entry name and the exact quote. Done when every
entry has been held against every paragraph.

## Pass

Check, then rewrite each hit in `voice.md`'s voice, rewriting the sentence
or passage rather than trimming the phrase. Re-run `lint` on the result.
Done when lint is clean and a second check finds nothing.

## Flag

Joel marked a phrase as slop, with or without a note saying why.

1. Re-read the current file around the flagged lines; Joel hand-edits
   drafts, and his edits are his voice.
2. Rewrite the whole passage the phrase sits in, not just the phrase, in
   `voice.md`'s voice. Check the passage, then write it to the file.
3. Reply with the before and after (from redline:
   `redline reply <id> -m "<before> -> <after>"`).
4. Record the pattern (below), then resolve the thread
   (`redline resolve <id>`).

A flag Joel reopens means the rewrite missed. Fix it, and update the
entry's `rewrite:` line, so every recorded rewrite is one he accepted.

A plain comment that names a pattern as slop goes through these steps too.

## Record

1. Find the entry that already covers the pattern. When one does, add a
   `flagged:` and `rewrite:` pair to it. Otherwise add an entry, in the
   section it fits, in the shape the file's header describes.
2. Fill `from:` with the post's site and slug and the month
   (`alethi.dev/build-for-leverage, 2026-10`).
3. When a regex catches the pattern with no innocent match, add a rule to
   `lint.toml` and name it in the entry's `lint:` field. Run the new rule
   over Joel's published posts (alethi.dev `content/posts/`, gitstack.sh
   `marketing/content/blog/`): a hit in prose he accepted means the rule is
   too broad, so leave it to the check instead.
4. Run `~/.config/writing/lint --self-check`. Done when it prints `ok`.

## Commit

Recorded patterns are uncommitted edits in the repo the pack lives in
(`realpath ~/.config/writing`). When the post is done, or Joel asks, commit
them as one change. For Joel's `dotfiles` that is one gs review, landed
without asking since `dotfiles` deploys nothing:

```sh
cd "$(dirname "$(realpath ~/.config/writing)")"
gs switch -c slop-<slug>
gs add writing/slop.md writing/lint.toml
gs commit -m "slop: patterns from <slug>" --review -t "slop: patterns from <slug>"
gs submit --stack
gs switch main && gs sync && gs cleanup slop-<slug>
```

Start from `main`. If the checkout is on another branch, stop and tell Joel
instead of switching it.
