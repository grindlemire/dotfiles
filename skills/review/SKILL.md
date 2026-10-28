---
name: review
description: Use when reviewing code in any language or stack — Go, TypeScript, htmx, go-templ, SolidJS, Tailwind, and more — for correctness, security, over-engineering, idioms, design, and maintainability. Applies a language-agnostic core review plus stack-specific reviewer lenses, composed per file. Use for reviewing a PR, a diff, or specific files.
argument-hint: "[PR# | rN | files… | (blank = uncommitted changes, else branch vs main)]"
---

# Review

## Overview

Polyglot code review. Apply one always-on **core** reviewer (security, correctness, over-engineering, readability) plus **stack-specific lenses** detected from the changed files. A single file can activate multiple lenses (a `.templ` file is Go + HTML + htmx + Tailwind). Judge the change against its **intent**: what it claims to do. Report findings severity-first, each with its evidence and a fix, in a shape the `review-comment` skill can assess directly.

## Review protocol

Run these steps in order.

### 1. Determine scope

Figure out what you are reviewing, in this order:
- **Argument is a number** (e.g. `1234`) → a PR: `gh pr diff 1234`. Unless the PR's branch is checked out, the files on disk are a different version: read the surrounding code at the PR head instead (`git fetch origin pull/1234/head`, note the SHA from `git rev-parse FETCH_HEAD`, then `git show <sha>:<path>`).
- **Argument is a GitStack review** (`r3`) → `gs review diff r3`; read surrounding code at that review's tip (`gs review show r3`). Check the repo is GitStack-backed with the detection check in the `gitstack` skill.
- **Argument is one or more paths** → review those files (current working-tree contents).
- **No argument, working tree is dirty** → the uncommitted changes: `git diff HEAD`, plus every untracked file from `git ls-files --others --exclude-standard`, read whole. `git diff HEAD` omits untracked files, and a new file is often the riskiest part of the change. This is the common case: what you're about to commit.
- **No argument, working tree is clean** → the current branch vs its base. Detect the base in this order: the target of `origin/HEAD`, then `main`, then `master`; review `git diff <base>...HEAD`. In a GitStack repo, use `gs diff` for the same range.

Never resolve to an empty scope. If the selected diff is empty, say so and stop. Don't report "no issues" on nothing.

Skip generated and vendored files (lockfiles, `*_templ.go`, `*.pb.go`, minified bundles, `vendor/`, snapshot fixtures) and name them in the report. Review hand-written code that produced them instead. On a large diff, take the riskiest files first: auth, data writes, migrations, concurrency, public APIs.

### 2. State the intent

Write one sentence for what the change is supposed to do, then list the specific behaviors it claims to add, fix, or keep unchanged. Sources, in order:
- Context the caller gave you: acceptance criteria, scrutiny points, what is deliberately unchanged.
- The PR title and body (`gh pr view <N> --json title,body`), a GitStack review's title and the stack description (`gs stack`), or the commit messages on the branch (`git log <base>..HEAD`).
- An issue the change links to.
- For uncommitted work with none of these, the conversation and the diff itself. Mark that intent **inferred**.

Done when you have the sentence and the claims list. Each caller scrutiny point becomes an explicit check in step 5.

### 3. Always load the core lens

Read `reference/core.md`. It applies to every review regardless of language.

### 4. Detect and load lenses

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

Composition: `go-templ → go`, `solidjs → typescript`. `htmx` and `tailwind` are cross-cutting: they ride on whatever host file (HTML, `.templ`, `.tsx`) carries the attributes/classes.

Read `reference/<lens>.md` for every activated lens.

### 5. Review

Work through three passes:

1. **Against the intent.** For each claim from step 2, find the code that delivers it and check it does. Look for the cases the intent implies but the code misses: the empty input, the second call, the error path, the existing user whose data predates the change.
2. **Every changed hunk** through `core` + every active lens. Open the surrounding functions, not just the hunk.
3. **Beyond the diff.** For every changed signature, return value, error, default, or meaning, search for its callers (`grep`, LSP references) and check each still works. For removed code, check what relied on it.

**Every finding carries evidence**: the code path you traced (file:line steps), or a command or test that shows the failure. When a quick probe settles a claim (a test, a one-off script), run it, then delete it and confirm the working tree matches how you found it. A claim you could not confirm by reading or running stays out, unless confirming needs something you can't do here (load, production data, a platform you don't have); then report it with confidence `suspected` and name the check that would settle it. A wrong finding costs more than a missed nitpick.

Done when every claim from step 2 is checked, every changed hunk has been read through every active lens, and every caller of changed behavior has been looked at.

### 6. Report

Emit the report in the format below.

## Severity

Rank by **impact**: what breaks, for whom, and how likely. A lens's category suggests a starting point; impact decides.

| Severity | Meaning |
|---|---|
| **Critical** | Exploitable security hole, data loss or corruption, or a core path broken in normal use. Must fix before merge. |
| **High** | Wrong behavior on a realistic path (an edge case users will hit, a broken caller, a leak under normal load), or the change doesn't do what it claims. Fix before merge. |
| **Medium** | No wrong behavior today, but a real cost: new behavior with no test, complexity the next change will trip on, a misleading name or comment. Fix now if cheap. |
| **Low** | Idiom, style, polish. |

An abstraction with one caller is Medium or Low unless it hides a bug. A missing test for a new branch that can fail is at least Medium.

## Report format

```
Intent: Adds per-user rate limiting to the upload endpoint. (inferred)

## Critical

### F1 [go] SQL injection in GetUser (handlers.go:42)
Why: `id` from the query string is formatted into the SQL text, so any caller can read other tables.
Evidence: handlers.go:38 reads `r.URL.Query().Get("id")`; line 42 builds the query with `fmt.Sprintf`.
Fix: pass `id` as a `$1` parameter to `db.QueryRow`.

## High

### F2 [solid] Destructured props in <Card> never update (Card.tsx:7)
Why: Solid tracks reads of `props.x`; destructuring reads once, so the title freezes after first render.
Evidence: Card.tsx:7 destructures `title`; Page.tsx:31 passes a signal-backed `title` that changes on save.
Fix: read `props.title` inside the JSX.

## Medium

### F3 [core] Retry loop has no test for the give-up path (upload.go:88, suspected)
Why: after 3 failures the handler returns 200 with an empty body; nothing pins that.
Evidence: upload.go:88-97; upload_test.go covers only success. Suspected: confirm by stubbing the client to fail 3 times.
Fix: add a test that stubs 3 failures and asserts a 502.

Skipped: package-lock.json, components/icons_templ.go (generated).
```

**Rules:**
- Start with the `Intent:` line, marked `(inferred)` when it is.
- Lead with the most severe. Skip any severity section with no findings.
- Number findings `F1`, `F2`, … in report order. Downstream skills and agents refer to findings by these IDs.
- Tag every finding with `[lens]` (`go`, `ts`, `solid`, `go-templ`, `htmx`, `tailwind`, `core`) and reference `file:line` and the symbol. Add `, suspected` inside the parentheses when confidence is suspected.
- `Why` says what goes wrong and for whom. `Evidence` is what you traced or ran. `Fix` is the smallest change that solves it, concrete enough to apply without rereading the review. One or two sentences each.
- Group related instances under one ID (e.g. "SQL injection in GetUser, CreateUser, DeleteUser").
- End with a `Skipped:` line when you skipped files.
- No praise padding.

## Common mistakes in reviews

- **Reviewing the diff without the intent.** Pattern-matching hunks finds smells; checking claims finds the bugs that matter.
- **Too verbose.** A 20-paragraph review won't be read. Be surgical.
- **Suggesting over-engineering as a fix.** Recommend interfaces, abstractions, or patterns only for a concrete, present need.
- **Nitpicking style amid bugs.** If there's an injection, don't spend equal time on naming.
- **Stopping at the diff's edge.** A changed return value breaks callers the diff never shows.

## Adding a lens

Drop a `reference/<stack>.md` following the lens template (Perspective / Composes with / Red flags / What good looks like / Don't over-correct), then add one detection row to the table in step 4. No other change needed.
