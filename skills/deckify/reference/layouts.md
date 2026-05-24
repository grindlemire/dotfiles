# Layout catalog

Every slide uses one of these layouts. Phase 1's frontend-design pass produces one styled `<section class="slide" data-layout="X">` per layout below. Phase 2 picks a layout per slide and fills the slots.

Only request the layouts the doc actually needs (from `doc-profile.required_layouts`).

## Layouts

### `title`
Opening slide. The deck's title and a subtitle/date.

**Slots:**
- `.slot-title` — deck title
- `.slot-subtitle` — subtitle, date, author, version (any combination)

**When to use:** first slide, always.

### `section-divider`
Marks a major section break (typically one per H1 or top-level H2 in the source).

**Slots:**
- `.slot-eyebrow` — "Section 3" or similar small label
- `.slot-title` — section name
- `.slot-summary` — optional one-line section blurb

**When to use:** between major sections, to give the reader breathing room and signal a topic shift.

### `bullets`
The most common content slide. A title and a bullet list.

**Slots:**
- `.slot-title` — slide title
- `.slot-bullets` — `<ul>` with 1-6 `<li>` items

**When to use:** lists of distinct points. Default when content is naturally enumerable.

### `prose`
A title and one or more paragraphs of readable text.

**Slots:**
- `.slot-title` — slide title
- `.slot-body` — `<div>` containing one or more `<p>` elements

**When to use:** passages where bulletization would lose nuance. Reasoning chains, justifications, explanations of subtle tradeoffs.

### `code-focus`
A title, optional caption, and a code block that dominates the slide.

**Slots:**
- `.slot-title` — what this code shows
- `.slot-language` — language tag (e.g. "go", "sql") used by syntax highlighter
- `.slot-code` — `<pre><code>` element with the code
- `.slot-caption` — optional one-line note about the code

**Behavior:** if the code is taller than the slide content area, the code block scrolls vertically inside the slide (not the whole slide).

**When to use:** showing a specific function, query, config snippet, or example. The code is the focus.

### `diagram-focus`
A title, a Mermaid diagram, and an optional caption.

**Slots:**
- `.slot-title` — what the diagram shows
- `.slot-mermaid` — `<pre class="mermaid">` containing mermaid source
- `.slot-caption` — optional one-line note

**When to use:** flow diagrams, sequence diagrams, architecture sketches.

### `two-column`
Two side-by-side panels under a shared title.

**Slots:**
- `.slot-title` — slide title
- `.slot-left-heading` — left column heading
- `.slot-left-body` — left column content (bullets or prose)
- `.slot-right-heading` — right column heading
- `.slot-right-body` — right column content

**When to use:** comparisons (before/after, option A/option B, problem/solution), parallel structures.

### `callout`
A single emphasized statement, often a quote or key takeaway.

**Slots:**
- `.slot-eyebrow` — optional small label ("Key insight", "Decision")
- `.slot-statement` — the statement itself, prominently styled
- `.slot-attribution` — optional attribution

**When to use:** sparingly, for moments that deserve emphasis. A pull-quote, a decision, a conclusion.

### `table`
A title and a table.

**Slots:**
- `.slot-title` — slide title
- `.slot-table` — `<table>` element

**When to use:** structured comparisons, data, matrices.

## Layout selection guide

| Source content | Use |
|---|---|
| Doc title + metadata | `title` |
| H1 or top-level H2 boundary | `section-divider` |
| List of 3-6 items | `bullets` |
| Multi-paragraph explanation | `prose` |
| Code block (with or without prose context) | `code-focus` |
| Mermaid block | `diagram-focus` |
| "X vs Y" or before/after | `two-column` |
| Markdown table | `table` |
| A single emphasized statement worth its own slide | `callout` |

## Slot conventions

- Slot class names are stable. Frontend-design styles them; Phase 2 fills them.
- Empty optional slots: leave the element in place but empty, OR omit entirely — the layout's CSS should handle either.
- Don't introduce new slot names in Phase 2. If a slide needs something a layout doesn't have, pick a different layout, or split into multiple slides.
