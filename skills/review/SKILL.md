---
name: review
description: Use when reviewing code in any language or stack — Go, TypeScript, htmx, go-templ, SolidJS, Tailwind, and more — for correctness, security, over-engineering, idioms, design, and maintainability. Applies a language-agnostic core review plus stack-specific reviewer lenses, composed per file. Use for reviewing a PR, a diff, or specific files.
argument-hint: "[PR# | files… | (blank = uncommitted changes, else branch vs main)]"
---

# Review

## Overview

Polyglot code review. Apply one always-on **core** reviewer (security, correctness, over-engineering, readability) plus **stack-specific lenses** detected from the changed files. A single file can activate multiple lenses (a `.templ` file is Go + HTML + htmx + Tailwind). Report findings severity-first, tagged by the lens that caught them. Be concise: flag the issue, explain why it matters, move on.

## Review protocol

Run these steps in order.

### 1. Determine scope

Figure out what you are reviewing, in this order:
- **Argument is a number** (e.g. `1234`) → a PR: `gh pr diff 1234`.
- **Argument is one or more paths** → review those files (current working-tree contents).
- **No argument, working tree is dirty** → the uncommitted changes: `git diff HEAD`. This is the common case — what you're about to commit.
- **No argument, working tree is clean** → the current branch vs its base. Detect the base in this order: the target of `origin/HEAD`, then `main`, then `master`; review `git diff <base>...HEAD`.

Never resolve to an empty scope. If the selected diff is empty, say so and stop — don't report "no issues" on nothing.

Read the actual changed code, not just the diff hunks — open the surrounding functions so findings are grounded.

### 2. Always load the core lens

Read `reference/core.md`. It applies to every review regardless of language.

### 3. Detect active lenses

Inspect the changed files and the project. Activate a lens when any signal matches; take the union; resolve composition edges.

| Signal | Activate |
|---|---|
| `*.go` file | `go` |
| `*.templ` file | `go-templ` **+ `go`** |
| `*.ts` / `*.tsx` file | `typescript` |
| `solid-js` in `package.json`, or Solid patterns (`createSignal`, `solid-js/web`) in a `.tsx` | `solidjs` **+ `typescript`** |
| `hx-` attribute (`hx-get`, `hx-post`, `hx-swap`, …) in any reviewed file | `htmx` |
| `tailwind.config.*` in the repo, `@tailwind`, or Tailwind-shaped class tokens (`md:`/`hover:` prefixes, arbitrary `[…]`, scale utilities) — not bare `class="…"` | `tailwind` |
| `*.css` / `*.scss` with no Tailwind signal | generic CSS (use `core` only) |

Composition: `go-templ → go`, `solidjs → typescript`. `htmx` and `tailwind` are cross-cutting — they ride on whatever host file (HTML, `.templ`, `.tsx`) carries the attributes/classes.

### 4. Load each active lens

Read `reference/<lens>.md` for every activated lens.

### 5. Review

Examine each changed hunk through `core` + every active lens. **Verify before flagging**: trace the surrounding code; do not report a leak, race, or bug you have not confirmed by reading the relevant code. A wrong finding costs more than a missed nitpick.

### 6. Report

Emit the report in the format below.

## Report format

Group by severity, tag each finding with the lens that caught it:

```
## Critical
- [go] SQL injection in GetUser — string interpolation into query (handlers.go:42)

## High
- [solid] Destructured props in <Card> break reactivity (Card.tsx:7)

## Medium
- [tailwind] Arbitrary value h-[37px]; use a spacing token (nav.templ:18)

## Low
- [ts] any on the API boundary; parse into a typed shape (client.ts:12)
```

**Rules:**
- Lead with the most severe. Severity order: Critical → High → Medium → Low.
- Tag every finding with `[lens]` (`go`, `ts`, `solid`, `go-templ`, `htmx`, `tailwind`, `core`).
- Reference `file:line` and the symbol.
- Explain *why* it's a problem, not just *what*.
- 1–3 sentences per finding. If you need more, split it.
- Group related instances (e.g. "SQL injection in GetUser, CreateUser, DeleteUser").
- No praise padding. Skip "good job on X."
- Skip any severity section with no findings.

## Common mistakes in reviews

- **Too verbose.** A 20-paragraph review won't be read. Be surgical.
- **Suggesting over-engineering as a fix.** Don't recommend interfaces, abstractions, or patterns without a concrete need.
- **Nitpicking style amid bugs.** If there's an injection, don't spend equal time on naming.
- **Flagging without verifying.** Read the surrounding code first.

## Adding a lens

Drop a `reference/<stack>.md` following the lens template (Perspective / Composes with / Red flags / What good looks like / Don't over-correct), then add one detection row to the table in step 3. No other change needed.
