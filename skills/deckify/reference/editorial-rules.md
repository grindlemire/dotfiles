# Editorial rules

The deck must teach the same material the doc teaches. These rules govern what changes from source to slides.

## Core test

For every editorial choice ask: **would a reader walk away with the same understanding from the slide as from the source?** If no, the edit is too aggressive.

## What you may do

- **Convert prose to bullets** when bullets read more clearly than the paragraph did. Don't force it — some paragraphs lose nuance as bullets and should stay as prose (use the `prose` layout).
- **Tighten wording.** Cut filler ("It is important to note that…", "As mentioned earlier…"). Keep substance.
- **Generate slide titles** from H2/H3 headings if the source heading is verbose or unclear. Stay accurate to what the slide actually covers.
- **Split one source section across multiple slides** — strongly preferred over packing everything in. The TOC overlay exists for this reason.
- **Group related sub-bullets onto one slide**, split if there are more than ~6 bullets.
- **Summarize a long passage** when summarization preserves the substantive points. Test against the "same understanding" rule above.
- **Add a continuation marker** for split content: `(1/2)`, `(2/2)` in titles.

## What you may NOT do

- **Drop substantive content** to make a slide cleaner. If something is in the source it earns a place in the deck — possibly on its own slide.
- **Drop edge cases, constraints, tradeoffs, specific values, or caveats.** These are exactly the details an engineering audience needs.
- **Truncate or elide code.** No `...`, no `// snip`, no paraphrasing code into English. Code blocks are verbatim.
- **Invent.** No new examples, opinions, framing, or analogies that aren't in the source.
- **Restructure the doc's argument.** Slide order follows source order. If the source builds A → B → C, the deck does too.
- **Make every slide feel like a marketing slide.** Dense, technical, factual is fine when the source is dense, technical, factual.

## Slide-density heuristics

- **Default to fewer items per slide.** A slide with one strong idea + supporting detail beats a slide with five competing ideas.
- **Bullet lists:** target 3-5 bullets. 6 is the soft cap. >6 → split.
- **Code blocks:** if a block is >25 lines or wider than would fit comfortably, use code-focus layout with scroll OR split into continuation slides. Pick split when the code has natural breakpoints (function boundaries), scroll otherwise.
- **Prose:** if a passage is 2+ paragraphs and resists bulletization without losing nuance, use the `prose` layout and let it read.
- **Mixed content:** if a section has a paragraph + bullets + code, that's almost always 2-3 slides, not one.

## Examples

### Example: prose → bullets is fine

Source:
> The current middleware stores session tokens in plaintext cookies. Legal flagged this in Q1 as a compliance gap. We've had two prior incidents (INC-241 and INC-318) traceable to it.

Slide:
> **Problems with the current middleware**
> - Session tokens stored in plaintext cookies
> - Legal flagged compliance gap in Q1
> - Two prior incidents (INC-241, INC-318) traceable to this gap

Why OK: every fact preserved, format clearer.

### Example: prose → bullets loses nuance, keep prose

Source:
> We considered JWTs but rejected them because the rotation story is fundamentally weak — once a JWT is issued, you can't revoke it without maintaining a denylist, which negates the stateless property that made JWTs attractive in the first place. The team's preference is to keep the session store and add rotation there.

Don't do this:
> - Considered JWTs, rejected
> - Revocation requires denylist
> - Will use session store instead

Why bad: the *reasoning* (the circularity of denylist+stateless) is the point. Bullets lose it. Use `prose` layout and let the passage read.

### Example: long code, split with care

Source: a 60-line Go function.

Bad split: cut at line 30 mid-loop.
Good split: cut at the function boundary, or at a logical block boundary marked by a comment in the source. Continuation slide titled `Implementation (2/2)`.
