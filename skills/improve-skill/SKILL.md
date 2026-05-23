---
name: improve-skill
description: Use when the user invokes /improve-skill (manually only) to critique a skill against the immediately preceding conversation and propose concrete edits. Takes the text after the command as context for what the user wants improved. Always proposes a diff and waits for approval before editing the SKILL.md.
---

# Improve Skill

## Purpose

A meta-skill. After a conversation where another skill was active (or *should* have been active and wasn't), critically review that skill's `SKILL.md` against what actually happened and propose targeted edits that would have produced a better outcome. Always propose first, edit only after the user approves.

## When this fires

Manual invocation only: the user types `/improve-skill` followed by free-form context describing what they want improved. Do **not** auto-fire on phrases like "that skill should have…" — meta-skills that self-trigger risk runaway loops.

## Inputs

- **The user's argument text** — everything after `/improve-skill`. This is the primary signal for what to focus on. It may name a skill, describe a symptom ("the skill kept suggesting X when I wanted Y"), or be vague ("make it better").
- **The preceding conversation** — the immediately prior turns in this session, especially the last user prompt, the assistant's response, and any skill that was invoked.

## Process

### Step 1: Identify the target skill

Determine which skill to improve, in this order:

1. If the user's argument names a skill explicitly (e.g. `/improve-skill remotion-best-practices the dot graphs were too verbose`), use that one.
2. Otherwise, look at the prior turns for a `<command-name>` tag, a Skill tool call, or an obvious skill that was active.
3. If still ambiguous, list the candidates you can see and ask the user which one.

Read the skill's `SKILL.md` in full before doing anything else. User-level skills live in `~/.claude/skills/<name>/SKILL.md`. Project skills live in `.claude/skills/<name>/SKILL.md`.

### Step 2: Reconstruct what happened

Look at the prior turn(s) and write down — for your own reasoning, not necessarily for the user:

- What the user asked for.
- What the skill instructed the assistant to do.
- What the assistant actually did.
- Where the gap is between (b) and (c), and between what the user wanted and what they got.

The user's argument text is the ground truth for what counts as "the gap." If they say "it was too verbose," the gap is verbosity even if other issues exist.

### Step 3: Reflect before rubric

Before grading the skill against the rubric, write down (briefly, for your own reasoning) the answer to two questions:

1. **What's the deepest cause?** Don't stop at the first plausible explanation. If the skill produced verbose output, is that because of an explicit "be thorough" rule, an example that modeled verbosity, a missing length cap, or a structural bias toward checklists? Trace it as far as you can.
2. **Is this an instance of a pattern?** Has the skill probably failed in similar ways before, or will it likely fail in adjacent ways next time? A single fix that addresses the pattern beats three fixes that each address one symptom.

This reflection drives Step 4 — it's how you decide whether to propose a surgical edit or a structural change.

### Step 4: Critique against the rubric

Evaluate the skill along these dimensions. Not every dimension applies to every critique — focus on what the user flagged and what your reflection in Step 3 surfaced.

- **Triggers / when-to-fire** — Did the skill fire when it shouldn't have? Did it fail to fire when it should have? Are the trigger phrases in the `description` too broad, too narrow, or missing important cases?
- **Clarity of rules** — Were the instructions ambiguous? Did the assistant have to guess? Were two rules in tension without guidance on which wins?
- **Missing edge cases** — Did the situation expose a case the skill didn't cover?
- **False-positive guidance** — Are there rules that steered the assistant wrong in this context? Rules that are technically correct but lead to bad outcomes here?
- **Over-firing / scope creep** — Did the skill do more than the user wanted (added structure, sections, ceremony, length)?
- **Examples** — Are the existing examples representative? Would adding an example from this interaction help future runs? Would removing a misleading example help?
- **Output shape** — Did the skill produce the right format, length, and tone for what the user wanted?

### Step 5: Structural health check

Before proposing edits, look at the whole `SKILL.md` and ask:

- **Is it accruing exceptions?** A skill with a long list of "but if X then Y" rules, anti-patterns, or special cases is decaying. Each new edge case adds cognitive load and increases the chance of contradictions. If you're about to add the fifth bullet to a bulleted list of caveats, the underlying rule is probably wrong.
- **Are rules duplicated or in tension?** If two sections say similar things, consolidate. If two rules conflict, surface it.
- **Is there dead weight?** Sections that haven't been triggered in any realistic scenario, examples that no longer match the current rules, anti-patterns that restate the obvious.
- **Could a smaller skill do more?** Often the right edit is *removing* three rules and replacing them with one sharper principle, not adding a sixth.
- **Has structure drifted from purpose?** Re-read the frontmatter `description`. Does the body still serve that purpose, or has it grown into something else?

If the structural health is poor, your proposal in Step 6 should include a **consolidation or removal edit**, not just additions. Sometimes the right answer is "delete section X and replace these three rules with one." Be willing to propose that.

### Step 6: Propose concrete edits

Present the proposal in this format. Be specific — show actual text, not vague directions.

```
## Skill: <name> (<path>)

### What went wrong
[2-4 sentences. Reference the actual user prompt and assistant response.
Tie back to the user's stated complaint.]

### Root cause in the skill
[Which part of SKILL.md produced the bad behavior, or what's missing.
Quote the relevant lines.]

### Proposed edits

**Edit 1:** [one-line summary]
- Location: [section / line range / "frontmatter description"]
- Before: `<exact existing text or "(none)">`
- After: `<exact replacement text>`
- Why: [one sentence]

**Edit 2:** ...

### Net effect on the skill
[1-2 sentences: did the skill get smaller, sharper, more general?
If it got bigger, justify why.]

### Edits I considered but rejected
[Optional. If you thought about a change and decided against it, name it
and say why — keeps the user from having to suggest it.]
```

Keep it tight. Three sharp edits beat ten speculative ones. **Prefer edits that consolidate or remove over edits that add.** If your proposal only ever grows the skill, you're patching, not improving.

### Step 7: Wait for approval, then edit

Do **not** modify the SKILL.md until the user approves. They may accept all, accept some, modify, or reject. After approval, apply the accepted edits with the Edit tool and confirm what was changed.

If the user pushes back on the critique itself (not just the edits), revisit Step 3 — don't double down. The user saw the original interaction; you're inferring it from the transcript.

## Critical mindset rules

**The user's complaint is the brief.** If they said "too verbose," don't propose edits about trigger conditions. Stay on target. You can mention adjacent issues briefly at the end ("I also noticed X, want me to look at that separately?") but don't bury the main work.

**Skills are tuned, not rewritten.** A skill that mostly works needs surgical edits, not a rewrite. Default to small, specific changes. If you genuinely think the skill needs a structural overhaul, say so explicitly and get buy-in before drafting it.

**The interaction is one data point.** A skill optimized for a single past conversation will overfit. When proposing an edit, ask: would this also help (or at least not hurt) a *different* user in a *different* situation? If the fix is too specific to this case, say so and propose a more general framing.

**Don't invent failures.** If the prior interaction actually went fine and the user is being picky about a minor preference, say that — and propose the small tweak. Don't inflate it into a structural problem to justify bigger edits.

**Verify before quoting.** When you reference what the skill currently says, read the file — don't paraphrase from memory. Edits with wrong "before" text waste the user's time.

**Frontmatter is load-bearing.** The `description` field is what causes the skill to fire. If the problem is that the skill fired wrong (or didn't fire), the fix often lives there, not in the body.

## Anti-patterns to avoid

- **Bandaid edits.** Adding a new "but if X then Y" rule for every reported failure. After enough rounds, the skill becomes a junk drawer of exceptions. If you find yourself appending another caveat, ask whether the underlying rule should change instead.
- **Rewriting the skill from scratch** when 1–2 line edits would do.
- **Adding ceremony** — new sections, headers, decision trees — when the skill needs *fewer* rules, not more.
- **Editing before proposing.** Never write to SKILL.md before the user approves.
- **Vague edits.** "Make the trigger clearer" is not an edit. Show the new text.
- **Ignoring what the user typed after the command.** That argument is the brief.
- **Defending the skill.** If the user says it underperformed, your job is to find the fix, not to explain why the skill was right.

## When you can't tell what went wrong

If the prior conversation has been compacted, isn't visible, or doesn't clearly involve a skill, ask the user to:
- Name the skill, and
- Briefly describe what the skill did or failed to do.

Don't guess. A bad critique built on an imagined transcript is worse than asking one question.
