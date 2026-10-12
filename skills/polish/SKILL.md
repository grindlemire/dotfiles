---
name: polish
description: Use when Joel asks to polish a selection or a rough note (a redline [polish] thread, or in chat) so it says the same idea in the voice of the text around it.
---

# Polish

Polish rewrites a selection so it reads as if Joel wrote it alongside the
paragraphs around it. The selection may be finished prose or a rough note
he typed into the draft.

## Inputs

- **The selection**, exactly as it stands in the file now. From redline,
  the thread gives the quote, file and lines; re-read the file there, since
  Joel may have typed the note seconds ago.
- **Its surroundings**: the block it sits in and the blocks on either side.
- **The voice pack** at `~/.config/writing/`: `voice.md` for how Joel
  writes, and the `slop` skill's check. Without a pack, the surroundings
  are the only voice to match.

## Rewrite

1. List the claims the selection makes. The rewrite carries every one of
   them and adds none. A claim the passage needs that Joel didn't give
   becomes `[NEEDS: what]`, never an invented detail.
2. Write it in `voice.md`'s voice and the surroundings' register: their
   person and tense, their terms for things, their sentence length. Join it
   to the sentences before and after so the paragraph reads as one piece.
3. Keep the markdown: links, code spans, emphasis, and the file's line
   wrap width.
4. Run the `slop` skill's check on the rewritten passage and fix each hit.

Done when the claim list matches, the check is clean, and the passage reads
straight through from the sentence before it to the sentence after it.

## Hand back

Replace only the selection in the file, plus any connecting words the join
needed. From redline, reply with the rewrite and resolve:
`redline reply <id> -m "<after>" --resolve`. redline shows Joel the before
and after with a Revert button, so no confirmation step is needed. In chat,
show the before and after.

A polish Joel reverts or reopens missed his voice. Ask what was off before
trying again, and when his answer names a pattern, it goes through the
`slop` skill's Record step.
