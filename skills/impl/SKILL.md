---
name: impl
description: Use when given a batch of independent work items (issues, bugs, a task list, or ad-hoc requests) to implement concurrently with independent staged review — "impl these", "run a wave on these issues", "do these with the pipeline" — or a single item that deserves the full implement/review/assess/resolve treatment.
---

# Impl: staged multi-agent implementation pipeline

## Overview

Each work item runs through four sequential stages, **each in a fresh subagent**, with you (the orchestrator) gating every transition. Fresh context per stage is the point: the reviewer has no implementer bias, the assessor has no reviewer bias. Items run in parallel; stages within an item never do.

**You orchestrate; you do not implement, review, or merge.** Merging/landing always parks for explicit human approval.

## When NOT to use

- One trivial or exploratory task (just do it directly).
- The user hasn't asked for this scale of rigor — each item spawns up to 4 subagents (2 when the review is clean).

## The pipeline

| Stage | Subagent role | Must invoke | May write |
|---|---|---|---|
| 1 Implement | Build to acceptance criteria, verify, commit, open the review | repo's VCS/commit skill if one exists | code + VCS |
| 2 Review | Critically review the diff; post anchored findings | `review` skill (mandatory, first action) | review comments ONLY |
| 3 Assess | Judge each finding: does acting on it improve the code? | `review-comment` skill (mandatory, first action) | thread replies ONLY |
| 4 Resolve | Execute assessor verdicts verbatim; reply + resolve threads; re-verify; push | — | code + VCS |

- **Review medium** (decide before stage 1): the repo's native review system if it has one (its VCS skill tells you); else a GitHub PR — the implementer opens it, the reviewer posts PR review comments; else stages exchange structured findings through their reports and "resolve" means the resolver addresses each finding in its own report.
- **Skip logic**: stage 2 posts zero findings → skip stages 3-4, item parks ready-to-merge. If the assessor's verdicts require no code change (all DISAGREE/DEFER), the resolver still runs — replies, thread resolution, and follow-up filing are its job.

## Orchestrator duties

1. **Select items**: 2-3 concurrent max, with disjoint code areas. Items that overlap run serially inside the wave (either order; pick the riskier one first so its review informs the other). Big refactors get a dedicated wave.
2. **Isolate workspaces**: one branch + worktree per item off a freshly synced base (use the repo's VCS tooling/skill). The orchestrator removes worktree + branch after merge; for a declined/no-go item, record the analysis (see stage 1), then remove immediately.
3. **Track**: one task per item (TaskCreate); update at each stage boundary.
4. **Gate**: read each stage's report before spawning the next. A bad implementation must not flow into review.
5. **Tailor stage-2 scrutiny**: generic "review this" wastes the stage. From the implementer's report, write item-specific scrutiny points (the concurrency hazard, the API surface, the test that could be vacuous, the doc that could go stale).
6. **Recover stalls**: you're notified when a subagent fails or stalls. Resume it once via SendMessage (state where it left off; tell it to skip-and-note anything that hangs). If the resume also dies, spawn a fresh agent seeded with the last good report.
7. **Park at ready-to-merge**: report per-item outcomes; surface any DEFER-TO-LANDING decision to the human; merge only on their explicit word. Land sequentially — the base branch moves as each item (or unrelated work) lands, so expect rebase conflicts against it; resolve them yourself and re-verify the merged result before completing that land.

## Prompt construction (what makes stages work)

Every stage prompt contains: absolute workspace path (+ "cd explicitly in every command"), the stage's write restrictions from the table, a required report-back format, and honesty framing ("be honest about failures"; "a no-go report is a success outcome").

- **Implementer**: full item content inline (don't make it fetch), acceptance criteria, required verification commands, commit conventions, and a *feasibility gate* for risky items (check toolchain/design soundness FIRST; declining with reasoning beats forcing it). A declined item's analysis gets recorded by the orchestrator on the issue/tracker before it closes.
- **Reviewer**: "You did NOT write this code." Post only findings it verified itself; zero findings is legitimate *but must be earned* (state what was checked). Anchor comments to file:line.
- **Assessor**: verdict vocabulary — AGREE / AGREE-WITH-REDUCED-SCOPE / DISAGREE / DEFER (follow-up issue) / DEFER-TO-LANDING (product call for the human). It posts its verdict reasoning as a reply on each thread AND ends each verdict with the *exact* resolver action (file, precise change, test to add, reply-and-resolve rationale, or follow-up-issue content). Disagreeing is a legitimate outcome.
- **Resolver**: executes the verdict list verbatim — no reinterpretation; fixes go at the right point in the branch history; files any DEFER follow-up issues; posts one closing reply per thread stating what was done; confirms zero unresolved threads + clean tree + green verification before reporting.

## Common mistakes

| Mistake | Reality |
|---|---|
| Skipping the assessor ("reviewer said fix it") | Reviewers overstate. Assessed waves have rejected fixes that would deadlock or were provably no-ops. The assessor exists to prevent blind implementation. |
| One agent doing two stages | Kills the independence that makes stages 2-3 worth anything. |
| Merging because everything is green | Green ≠ authorized. Landing is the human's call, always. |
| Vague resolver instructions | The resolver executes verbatim; ambiguity becomes wrong code. Include thread ids, files, exact wording. |
| >3 concurrent items | Gating quality collapses; conflicts multiply. |
| Implementer prompt without verification commands | "Done" claims arrive untested. Name the exact commands that must pass. |
