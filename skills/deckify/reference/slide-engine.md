# Slide engine contract

The generated HTML contains a small JS slide engine. Frontend-design implements it during Phase 1. Behavior below is **required and locked** — frontend-design can style the UI surfaces but must implement every binding and feature.

## DOM shape

Each slide is a `<section>`:

```html
<section class="slide" data-layout="bullets" data-section="Architecture" id="slide-7">
  ...
</section>
```

Slides live inside a single deck container:

```html
<main class="deck">
  <section class="slide" id="slide-1" ...>...</section>
  <section class="slide" id="slide-2" ...>...</section>
  ...
</main>
```

Only one slide is "active" at a time (`.slide.is-active`). The transition is whatever frontend-design chose — slide, fade, custom — applied consistently to every navigation.

## Keyboard bindings

| Key | Action |
|---|---|
| `→` or `Space` or `PageDown` | Next slide |
| `←` or `PageUp` | Previous slide |
| `Home` | First slide |
| `End` | Last slide |
| `o` or `Esc` | Toggle TOC overlay |
| `f` | Toggle fullscreen |
| `?` | Toggle help/shortcuts overlay |
| `1`-`9` | (Optional) jump to that slide number — implement if straightforward |

Inputs (`input`, `textarea`, `[contenteditable]`) must not steal these — bindings should be no-ops while focus is inside one.

## TOC overlay

Toggled with `o` or `Esc`. Shows every slide as a clickable thumbnail, grouped by `data-section`.

- **Thumbnails are live DOM**, CSS-scaled (e.g. `transform: scale(0.18)` inside a fixed-size frame). Not screenshots, not separate renders.
- Sections rendered as headed groups (e.g. an `<h2>` per `data-section` value, slides for that section underneath).
- Clicking a thumbnail closes the overlay and navigates to that slide.
- Current slide is visually marked in the overlay.
- Overlay covers the viewport, has a backdrop, and closes on backdrop click as well as `o`/`Esc`.

## URL hash sync

- Navigation updates `location.hash` to `#slide-<N>`.
- On page load, if `location.hash` matches a slide id, start there.
- Section anchors also work: `#section-<slug>` jumps to the first slide whose `data-section` matches the slug. Slugify by lowercasing and replacing whitespace with `-`.

## Persistent UI

Always visible (frontend-design chooses placement and styling):

- **Slide counter:** `7 / 24`
- **Current section name:** the `data-section` of the active slide

These can be hidden in fullscreen mode if that fits the aesthetic, but must reappear on mouse-move or arrow-press.

## Help overlay

Toggled with `?`. Shows the keyboard binding table above. Closes on `?` or `Esc` or backdrop click.

## Initialization

- Mermaid: call `mermaid.initialize({ startOnLoad: false })` then `mermaid.run({ querySelector: 'pre.mermaid' })` after DOM ready.
- Syntax highlighter: trigger on all `<code>` blocks with a `language-*` class after DOM ready.
- Initial active slide: from `location.hash` if valid, else slide 1.

## What frontend-design owns

- Look of the persistent UI, TOC overlay, help overlay, and active-slide indicator.
- Transition style (one consistent choice across all slides).
- Whether the help/TOC overlays animate in/out.

## What is locked

- All keyboard bindings.
- TOC uses live DOM thumbnails grouped by section.
- URL hash sync.
- Mermaid + syntax highlighting initialized on load.
- Inputs/contenteditable don't steal keys.
