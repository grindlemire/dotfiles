---
name: deckify
description: Transform a markdown design doc or plan into a beautiful, self-contained HTML slide deck with transitions, keyboard nav, and a TOC overlay. The deck is engineering-focused — built for understanding hard technical concepts, not high-level talks. Triggered by `/deckify <input.md> [output.html]` or by phrases like "deckify this", "turn this doc into slides", "make a slide deck from this plan".
argument-hint: "<input.md> [output.html]"
---

# Deckify

Transform a markdown doc into a beautiful, self-contained HTML slide deck.

## Arguments

- `$1` (required) — path to input markdown file
- `$2` (optional) — output HTML path. Default: same dir/basename as input with `.html` extension (`foo.md` → `foo.html`)

If `$1` is missing, ask the user for the input path.

## What you produce

A single HTML file the user can open in a browser or host statically. Contains a bespoke design system, a tiny hand-rolled slide engine (keyboard nav, transitions, TOC overlay), and all slide content inline. Fonts and rendering libs (mermaid, syntax highlighter) load from CDN — everything else is inline.

## Non-negotiable principles

**These override your defaults. Read them before touching the doc.**

1. **Detail over polish.** This deck exists to teach hard technical material. Spirit and ideas must be preserved — every substantive point, constraint, tradeoff, and caveat from the source survives. Summarization is allowed when it aids comprehension, but you may NOT drop real content to make a slide look cleaner. Test: "would a reader walk away with the same understanding?"
2. **More slides over denser slides.** Density hurts comprehension. If a concept has five things to say, that's 2-3 slides. Dense slides used sparingly, only when splitting would genuinely fragment a tight logical unit. The TOC overlay exists precisely so a deck-with-many-slides is still navigable.
3. **Code is first-class.** Code blocks are never truncated, elided to `...`, or paraphrased. Long blocks scroll inside their slide or split across continuation slides (`Foo (1/2)`, `Foo (2/2)`).
4. **No invention.** You can rewrite a sentence for clarity. You cannot add facts, examples, opinions, or framing that aren't in the source.
5. **Read `reference/editorial-rules.md`** before starting Phase 2.

## The pipeline

Four phases, each producing a small artifact for the next. Full detail in `reference/pipeline.md` — read it.

```
Phase 0  Doc analysis        → doc-profile (content signals, density, required layouts)
Phase 1  Design system       → styled empty template (invoke frontend-design skill)
Phase 2  Content fitting     → final HTML (slide plan + layout filling)
Phase 3  Verify              → Playwright screenshots, one round of fixes, open in browser
```

## How to execute

1. **Read the input markdown** and `reference/editorial-rules.md`.
2. **Phase 0:** Build a `doc-profile` (see `reference/doc-profile.md`). Decide which layouts the deck needs based on actual content.
3. **Phase 1:** Invoke the `frontend-design` skill with the doc-profile and a brief asking for a slide template. The brief and the layout contract are in `reference/pipeline.md` and `reference/layouts.md`. Frontend-design must return one HTML file containing the design system, one `<section class="slide" data-layout="X">` per required layout (with placeholder content), and the slide engine JS that conforms to `reference/slide-engine.md`.
4. **Phase 2:** Produce a slide plan (ordered list of `{layout, title, content}` entries) by walking the markdown with editorial rules applied. Then clone the matching layout `<section>` from the template per slide and fill its slots, concatenating into the final HTML body. Write to output path.
5. **Phase 3:** Verify with Playwright MCP — load `file://<output>`, screenshot title slide, slide 2, a middle slide, the last slide, and the TOC overlay. Check for overflow / layout breaks / unloaded fonts / unrendered mermaid. If a check fails, do ONE round of fixes (regenerate just the broken slides or tweak the design system), re-screenshot, then report regardless. Open the file in the user's browser (`open <path>` on macOS).

## Critical invariants

- **Self-contained** for content. Inline all CSS, all JS, all slide content. Only fonts and rendering libs are external (CDN).
- **Consistent template.** Phase 2 never invents new layouts or restyles inline — it fills slots in the templates Phase 1 produced. If a slide needs a layout that wasn't generated, go back to Phase 1 and have frontend-design add it. Don't fake it inline.
- **Slide engine contract is locked.** Frontend-design can style the engine but must implement every keyboard binding, the TOC overlay, the URL hash sync, and the persistent counter — see `reference/slide-engine.md`.
- **One round of fixes max** in Phase 3. Report what was broken if anything remains.

## Edge cases

- **Empty/trivial input (<50 words):** produce a 1-2 slide deck, don't error.
- **Huge input (>15k tokens of markdown):** warn the user about token cost before starting Phase 1; ask whether to proceed.
- **Raw HTML in markdown:** pass through inside slides.
- **Relative image paths:** resolve relative to the input file. Embed as data URIs if small (<200KB), otherwise copy alongside the output and reference. Warn if unreachable.
- **Mermaid syntax errors:** render the source as a code block with an inline warning. Don't abort.
- **Output path exists:** overwrite without prompting. It's a generated artifact.

## Reference files

Read these as needed during execution:

- `reference/pipeline.md` — full per-phase execution detail and the frontend-design brief
- `reference/editorial-rules.md` — what to preserve, what to summarize, with examples
- `reference/layouts.md` — the layout catalog and selection guide
- `reference/doc-profile.md` — what Phase 0 extracts
- `reference/slide-engine.md` — required JS behavior of the generated deck

## When done

Print the absolute output path and a one-line summary (`Deckified <input> → <output>. <N> slides. Opened in browser.`). If Phase 3 left any known issues, list them.
