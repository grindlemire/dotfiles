# Pipeline detail

Four phases. Each produces an explicit artifact for the next. Don't skip phases or merge them — separation of concerns is what keeps quality up.

## Phase 0 — Doc analysis

**Input:** the raw markdown file.

**Output:** a `doc-profile` you hold in your context. Example:

```yaml
title: "Auth Rewrite Design"
section_count: 7
content_signals:
  has_code: true
  code_languages: [go, sql]
  has_mermaid: true
  has_tables: false
  has_images: false
  long_paragraphs: 4     # >100 words each
  bullet_lists: 12
  total_word_count: 3400
density_hint: mixed      # one of: sparse | mixed | dense
estimated_slide_count: 22
tone_hint: "technical design doc"
required_layouts:
  - title
  - section-divider
  - bullets
  - code-focus
  - diagram-focus
  - prose
  - two-column
```

**How to build it:** read the markdown once. Count headings, code blocks, paragraph lengths, list items. Pick `density_hint` from how content reads: a roadmap with mostly bullets = `sparse`, a design doc mixing prose + code + diagrams = `mixed`, a deeply technical spec with paragraph-heavy explanations = `dense`. The `required_layouts` list drives Phase 1 — only ask for layouts the content actually needs.

**Estimating slide count:** roughly one slide per H2 plus continuation slides for sections with long code, multiple sub-concepts, or dense prose. Err high — more slides is good.

## Phase 1 — Design system (invoke frontend-design)

**Invoke the `frontend-design` skill.** Pass it the brief below. Do not try to do this yourself.

**The brief** (template — fill in from the doc-profile):

> Produce a single HTML file that defines a slide deck design system for a `{density_hint}` `{tone_hint}` titled "{title}".
>
> Aesthetic direction: engineering-focused, beautiful, thoughtful. Default to a **monospace-forward** typographic voice — a beautiful variable-weight mono (Geist Mono, JetBrains Mono, IBM Plex Mono, Berkeley Mono, or similar) used for headings, body, and code, with weight + size carrying hierarchy. Mono everywhere makes the deck feel like an engineering artifact, not a sales deck. Use a sans or serif as a secondary accent only if it earns its place (e.g. a single elegant italic for emphasis); never as the default body font. Prioritize legibility — use narrower measure (~62ch), generous line-height (~1.6), and softer weight (300-400) for body prose to avoid mono fatigue. Pick a color system and one consistent slide-transition style.
>
> The file must contain:
>
> 1. A `<style>` block defining the design system (CSS variables for colors, fonts, spacing, code styling, transition timing).
> 2. One `<section class="slide" data-layout="X">` per required layout below, filled with realistic placeholder content (NOT lorem ipsum — write plausible content that exercises the layout). Layouts to produce: `{required_layouts}`. See `reference/layouts.md` for what each layout's slots are.
> 3. A `<script>` implementing the slide engine per `reference/slide-engine.md`. Every binding and feature in that spec is required. You may style the TOC overlay and persistent UI however you like; behavior is locked.
> 4. CDN imports in `<head>` for: a web font of your choice, Prism (or Highlight.js) for code, and Mermaid 10+ for diagrams. Initialize mermaid in the script.
>
> Constraints:
>
> - Self-contained except for the three CDN imports above.
> - Slides must accommodate dense content gracefully (long code, multi-paragraph prose, 8+ bullet lists) without breaking the layout — when content overflows the slide viewport, the slide body scrolls vertically (the slide chrome and transitions stay put).
> - One transition style applied consistently to all slides.
> - The TOC overlay must show live DOM thumbnails (CSS-scaled), not screenshots, grouped by section.

**Output:** a single HTML file you keep in context as the **template**. It IS the contract Phase 2 fills.

## Phase 2 — Content fitting

**Step A — Slide plan.** Walk the markdown and build an ordered list of slide-plan entries. Each entry: `{layout, title, slots: {...}}`. Apply editorial rules from `reference/editorial-rules.md`. Use the layout catalog in `reference/layouts.md` to pick the right layout per slide.

Example slide plan entries:

```yaml
- layout: title
  title: "Auth Rewrite"
  subtitle: "Design doc — 2026-05-23"

- layout: section-divider
  title: "Why now"
  eyebrow: "Section 1"

- layout: bullets
  title: "Problems with the current middleware"
  bullets:
    - "Session tokens stored in plaintext cookies — flagged by legal Q1"
    - "Token rotation missing — manual mitigation required during incidents"
    - "Two prior incidents (INC-241, INC-318) traceable to this gap"

- layout: code-focus
  title: "Current token handling"
  language: go
  code: |
    func issue(...) { ... }
  caption: "Note: no rotation, no expiry check"

- layout: diagram-focus
  title: "Proposed flow"
  mermaid: |
    sequenceDiagram
      ...
  caption: "Token rotation happens on every refresh"

- layout: prose
  title: "Why we considered then rejected JWTs"
  body: |
    Two-paragraph explanation that resists bulletization without losing nuance...
```

**Step B — Fill the templates.** For each slide-plan entry, clone the matching `<section class="slide" data-layout="X">` from Phase 1's template, fill its slots with the entry's content. Concatenate all filled sections into the final HTML body. Preserve the template's `<head>`, `<style>`, `<script>`.

**Section structure:** add `data-section="<section-name>"` and `id="slide-<N>"` to each slide so the TOC can group and link.

**Output:** the final HTML file, written to the output path.

## Phase 3 — Verify

**Step A — Load and screenshot** using Playwright MCP:

1. `browser_navigate` to `file://<absolute-output-path>`
2. `browser_take_screenshot` of: title slide (slide 1), slide 2, a slide ~halfway through, the last slide.
3. Press `o` (`browser_press_key`), screenshot the TOC overlay, press `o` again to close.

**Step B — Auto-checks:**

- No horizontal body scroll
- No slide whose content overflows visibly outside the slide chrome (intentional vertical scroll inside code-focus slides is fine)
- Web font loaded (not falling back to serif/sans-serif default)
- Mermaid diagrams rendered as SVG (not still showing source)
- Code blocks highlighted (not plain text)
- TOC overlay shows all slides

**Step C — Fix once if broken.** If any check fails: identify whether it's a design system issue (regenerate the relevant CSS in Phase 1's template) or a content-fitting issue (regenerate the specific slides in Phase 2). Make one round of targeted fixes. Re-screenshot. Stop and report regardless of result.

**Step D — Open and report:**

```
open <absolute-output-path>
```

Print: `Deckified <input> → <output>. <N> slides. Opened in browser.` If anything was left broken after the one fix round, list it.
