# Doc profile (Phase 0 output)

A small structured snapshot of the input markdown. You hold it in context for use by Phase 1 (briefing frontend-design) and Phase 2 (planning slides).

## Schema

```yaml
title: string                  # from first H1, or filename stem if no H1
section_count: int             # count of top-level H1+H2 boundaries
content_signals:
  has_code: bool
  code_languages: [string]     # languages present (go, sql, python, etc.)
  has_mermaid: bool
  has_tables: bool
  has_images: bool
  long_paragraphs: int         # paragraphs >100 words
  bullet_lists: int            # count of <ul>/<ol> blocks
  total_word_count: int
density_hint: enum             # sparse | mixed | dense
estimated_slide_count: int
tone_hint: string              # free-text, e.g. "technical design doc", "product roadmap"
required_layouts: [string]     # subset of layouts in reference/layouts.md
```

## Picking `density_hint`

- **sparse:** mostly headings + short bullets. Roadmaps, summaries, exec briefs. Slides will have lots of whitespace; design system should lean toward spacious typography.
- **mixed:** typical design doc. Prose paragraphs + bullets + occasional code/diagrams. Most common case.
- **dense:** technical spec with paragraph-heavy explanations, lots of code, detailed reasoning. Slides will carry more per surface area; design system needs tighter typography and a layout that handles overflow gracefully.

The hint is a signal to frontend-design about *visual density*, not permission to cram content. The editorial rules in `reference/editorial-rules.md` still govern.

## Picking `required_layouts`

Only include layouts the content needs:

| Always | When triggered |
|---|---|
| `title` | always |
| `bullets` | always (you'll have some) |
| `section-divider` | when `section_count >= 3` |
| `prose` | when `long_paragraphs >= 2` |
| `code-focus` | when `has_code` |
| `diagram-focus` | when `has_mermaid` |
| `two-column` | when source has explicit comparisons (X vs Y, before/after) — scan headings + first lines |
| `table` | when `has_tables` |
| `callout` | when source has block quotes OR you anticipate emphasis moments |

When in doubt, include — having an unused layout is cheap, missing one is expensive (forces a redo).

## Estimating `estimated_slide_count`

Rough formula:

```
1 (title)
+ section_count (one section-divider each, if section_count >= 3)
+ ceil(bullet_lists * 1.2)         # some lists split
+ long_paragraphs                  # each long para likely gets its own prose slide
+ ceil(code_blocks * 1.3)          # some code splits across continuations
+ mermaid_blocks
+ tables
```

Err high. The deck is allowed to be long; the TOC overlay makes long decks navigable.

## Example

Source: a 3,400-word auth-rewrite design doc with 7 sections, 12 bullet lists, 4 long paragraphs of reasoning, 6 code blocks (Go + SQL), 2 mermaid diagrams, no tables, no images.

```yaml
title: "Auth Rewrite Design"
section_count: 7
content_signals:
  has_code: true
  code_languages: [go, sql]
  has_mermaid: true
  has_tables: false
  has_images: false
  long_paragraphs: 4
  bullet_lists: 12
  total_word_count: 3400
density_hint: mixed
estimated_slide_count: 27
tone_hint: "technical design doc"
required_layouts: [title, section-divider, bullets, prose, code-focus, diagram-focus, two-column, callout]
```
