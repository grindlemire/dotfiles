---
name: triage
description: Use when the user asks to triage, examine, root cause, or fix a GitHub issue or pasted bug report end to end, especially when the issue proposes a fix or the user says "don't reflexively agree". Runs from issue intake through verified fix, agent review, and PR.
---

# Issue Triage

## Purpose

Take a reported issue from claim to merged-ready PR with independent verification at every step. The reporter's diagnosis and proposed fix are hypotheses, never instructions. Your job is to confirm the problem exists, find the real boundaries of it, fix it properly, and ship a reviewed PR that sounds like the user wrote it. Implementation never starts without the user's explicit go-ahead on your verdict (phase 7).

## Process

Work through the phases in order. Do not skip the reproduction phase even when the diagnosis looks obviously correct. Under deadline or authority pressure ("it looks right to me, just apply it"), compress phases, never skip them; an endorsement is another unverified hypothesis, and the PR can go up while agent review is still landing. The one phase that can never be compressed is the confirmation gate (phase 7): it is a hard stop that blocks on user input, regardless of pressure or autonomous mode.

### 1. Read the issue

- Fetch it (`gh issue view N --json title,body,author,comments`). Parse three things: the claimed symptom, the claimed root cause, and any proposed fix.
- Treat each as a separate claim to verify independently. Issues are often right about the symptom and wrong (or incomplete) about the cause or fix.

### 2. Ground yourself in the codebase

- Read the actual code paths involved. Never rely on the reporter's characterization of the code.
- Find the in-repo precedent: how does the rest of the codebase handle this concern? A sibling component or helper that does it correctly is both evidence the behavior is a bug and a template for the fix.
- Check CLAUDE.md for conventions (commit format, test style, lint commands) before writing anything.

### 3. Build the problem from first principles

- Derive what the code actually does at the reported site, then decide: is this a real problem, intended behavior, or a misread? "Not a bug" is a valid triage outcome; say so with evidence.
- Trace consumers of anything you plan to change. List what stays consistent and what breaks.

### 4. Confirm by reproducing

- Write a failing test that demonstrates the symptom before touching the fix. Prefer evidence at the level the user experiences it (rendered output, real API responses), not just internal state.
- Watch it fail for the right reason. If you cannot reproduce, return to phase 3; do not fix what you have not seen.

### 5. Judge the proposed fix

- Evaluate the issue's suggested fix against your own root cause. Verify its claims yourself (especially "no other changes needed" claims) by tracing every consumer.
- Decide: accept, extend, or replace. It is common to accept the direction but find the fix incomplete (wrong width, missed config combination, missed caller).
- Even when accepting, re-derive the change through your own failing test rather than applying the diff verbatim (issue patches drift against current code). Credit the patch author in the PR body.

### 6. Look under the surface

- Actively hunt for siblings: the same bug class in adjacent components, the same flawed assumption elsewhere, a deeper root problem the symptom hangs off.
- Scope deliberately. Fix what belongs to this issue; name the rest as follow-up issues rather than growing the PR. State the split and the reasoning in your report and the PR body.

### 7. Report and confirm with the user (mandatory gate)

- Hard stop. Before any implementation action (creating a branch, editing non-test code, making the reproduction test pass), report your verdict to the user and wait for their explicit go-ahead. The original "triage this issue" or "fix this bug" request authorizes the investigation, not the fix: the bug might not be real, the user might not want it fixed, or they might disagree with your approach.
- The report covers three things in plain language:
  1. **The situation, simply.** What is actually happening and why, in a few sentences a teammate could repeat without reading the code. Include your verdict: real bug, not a bug, intended behavior, or symptom of a deeper problem.
  2. **End-user experience impact.** Who hits this, what it looks like from their side, and how bad it is in practice. "Cosmetic flicker on resize" and "data loss on save" demand different urgency; say which this is.
  3. **Fix complexity.** The rough size and shape of the change: files touched, risk of regression, what you would deliberately not change, follow-ups you would file. End with your recommended approach.
- Then ask. Use AskUserQuestion or a direct question, offering at minimum: proceed with the fix, take a different approach, or do not fix. Do not proceed on silence, and do not treat deadline pressure, a P1 label, autonomous mode, or "fix it end to end" phrasing as implied consent. This checkpoint is the one place this skill mandates blocking on user input.
- If the verdict is "not a bug", this report is the deliverable; stop here unless the user redirects you.
- If the user disagrees with the diagnosis, return to phase 3 with their input rather than defending the verdict.

### 8. Implement

- TDD: the reproduction tests from phase 4 go green; add edge-case tests that pin boundaries (degenerate sizes, disabled modes, unchanged-behavior cases that prove what you did NOT change).
- Branch first; follow the repo's commit conventions exactly. Revert unrelated drive-by changes that formatters or `go fix` sneak in; the diff should contain only the fix.
- If the fix intentionally changes expectations in existing tests, update them and call that out explicitly in the PR body.

### 9. Agent review pipeline

1. Spawn a subagent that invokes the `review` skill on the branch diff vs main. Give it full context: what the fix does, what is deliberately unchanged and why, repo conventions. Ask for severity-tagged findings.
2. Spawn a second subagent that invokes the `review-comment` skill on those findings. It must read the code itself and return AGREE / PARTIAL / DISAGREE per finding with reasoning. Tell it not to modify the working tree.
3. Apply only the agreed changes. For agreed behavior changes, write the failing test first (a reviewer-claimed panic or bug gets a red reproduction before the guard goes in). Rejected findings get recorded with the reason, not silently dropped.
4. After any subagent runs, check `git branch --show-current` and `git status`; review agents sometimes switch branches or leave probe files. Restore before continuing.

### 10. Pull request

- Title in conventional commit format (CI enforces it).
- Body: invoke the `humanizer` skill and write in the user's voice. Read 1-2 of their recent merged PR bodies first and match the shape: `## Summary`, then symptom, mechanism, fix, tests as plain narrative prose, first person where natural, a before/after block if it earns its place, `Fixes #N` at the end.
- No test plan section. No em dashes anywhere (mechanically scan the final body for `—`, `–`, `--` before submitting). Concise: trim anything the reader does not need to evaluate the change.
- Watch CI in the background until all checks land, including bot reviewers.

### 11. Bot review comments

- Triage any bot comments (Greptile etc.) through the `review-comment` skill. Disagreeing and ignoring is a normal outcome; present the verdict with reasoning instead of auto-applying. A finding the agent pipeline already adjudicated does not get relitigated just because a bot repeats it.

### 12. Summarize

- Lead with the outcome: PR link, CI state. Then: what the root cause was, what the issue got right and wrong, which review findings were applied vs rejected and why, and the named follow-ups. Plain prose, no codenames from your own investigation.

## Red flags

- Implementing before reproducing ("the diagnosis is obviously right")
- Branching or writing fix code before the user confirmed the verdict ("they said fix it end to end, that's consent")
- Treating autonomous mode, a P1 label, or deadline pressure as permission to skip the phase 7 gate
- A phase 7 report written in code-level jargon instead of plain situation, user impact, and fix complexity
- Skipping phases because someone senior endorsed the patch or standup is in 40 minutes
- Accepting "no other functions need changing" without tracing the functions
- Applying every review finding without the critical-assessment pass
- A PR body that describes your process instead of the change
- Growing the PR with adjacent fixes that deserve their own issue
- Skipping the branch/status check after a subagent ran

## Outcome states

| Triage verdict | Action |
|----------------|--------|
| Real bug, fix correct | Confirm at the gate, extend with tests, implement, note anything incomplete |
| Real bug, fix incomplete or wrong | Confirm at the gate, implement the proper fix, explain the divergence in the PR |
| Real bug, but symptom of deeper problem | Confirm at the gate, fix the root or scope explicitly, file follow-ups |
| Not a bug | Report the evidence; no code change |
| User declines or redirects at the gate | Stop or adjust per their decision; record the verdict in the summary |

Every implementing row passes through the phase 7 confirmation gate first; only "not a bug" and a user decline end the process without code changes.
