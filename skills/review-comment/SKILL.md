---
name: review-comment
description: Use when the user pastes code review comments (e.g. from Greptile, reviewers, or AI tools) and wants a critical assessment before making changes. Analyzes the suggestion holistically, evaluates whether it actually improves the code, and presents a recommendation with justification. Does NOT implement changes until the user agrees.
---

# Review Comment Triage

## Purpose

When a code review comment is pasted in, your job is to be the user's senior engineering advisor: think critically about whether the suggestion is actually correct, whether it addresses a real problem, and whether the proposed fix is the right one. Do NOT reflexively implement suggestions.

## Process

```dot
digraph triage {
    rankdir=TB;
    node [shape=box];

    understand [label="1. Understand the comment"];
    read [label="2. Read the actual code"];
    assess [label="3. Assess the real problem (if any)"];
    evaluate [label="4. Evaluate the suggestion"];
    recommend [label="5. Present recommendation"];
    wait [label="6. Wait for user decision"];

    understand -> read -> assess -> evaluate -> recommend -> wait;
}
```

### Step 1: Understand the comment

Parse what the reviewer is actually saying. Identify:
- What file/function/line they're referring to
- What they think the problem is
- What they're suggesting as a fix (if anything)

### Step 2: Read the actual code

Read the relevant code thoroughly. Do not rely on the reviewer's characterization of it. Reviewers (especially automated ones) often misunderstand context, miss surrounding code, or misread intent.

### Step 3: Assess the real problem

Ask yourself:
- **Is there actually a problem here?** Sometimes reviewers flag code that is correct and intentional.
- **Is the problem what the reviewer thinks it is?** The reviewer might identify a symptom but misdiagnose the cause.
- **What is the broader context?** How does this code fit into the larger system? What are the design constraints? What tradeoffs were made and why?
- **What would break if we changed this?** Consider downstream effects, test implications, API contracts.

### Step 4: Evaluate the suggestion

If the reviewer proposed a specific fix, evaluate it critically:
- **Does the suggestion actually solve the problem?** Sometimes fixes are cosmetic or address the wrong thing.
- **Does it introduce new problems?** Over-engineering, breaking existing behavior, performance regressions, increased complexity.
- **Is there a better solution?** The right fix might be different from what was suggested.
- **Is the juice worth the squeeze?** Some suggestions are technically correct but the improvement is marginal and the churn is real.

### Step 5: Present recommendation

Present your analysis to the user in this format:

```
## Comment: [brief summary of what the reviewer said]

### The actual situation
[Your assessment of the code and whether there's a real problem. Be specific, reference actual code.]

### Assessment of the suggestion
[Whether the suggestion is correct, partially correct, or misguided. Explain why.]

### Recommendation: [AGREE / PARTIALLY AGREE / DISAGREE / ALTERNATIVE]

[1-3 sentences on what you recommend doing and why.]

[If AGREE or PARTIALLY AGREE or ALTERNATIVE: brief description of the specific changes you'd make]
```

### Step 6: Wait for the user

Do NOT implement any changes until the user explicitly agrees. If you have multiple comments to triage, present all recommendations first, then wait for the user to decide which ones to act on.

## Critical Mindset Rules

**Automated reviewers are often wrong.** AI code review tools like Greptile pattern-match against common issues but lack deep understanding of the codebase's design intent. Treat their suggestions as hypotheses to verify, not instructions to follow.

**Not every comment requires a code change.** Valid responses include: "This is intentional and correct as-is," "This is a known tradeoff we've accepted," or "The suggestion would make things worse."

**Complexity is not free.** If a suggestion adds abstraction, indirection, or generality, it needs to earn its place. The bar for adding complexity is higher than the bar for keeping simple code.

**Context matters more than rules.** A suggestion might follow a best practice in general but be wrong for this specific codebase, architecture, or situation. Always evaluate in context.

**Scope creep is a red flag.** If addressing a comment would require touching many files or changing an API, that's a signal to push back or propose it as a separate piece of work, not to do it inline.

**Preserve the author's intent.** The code was written a certain way for a reason. Before changing it, make sure you understand that reason. If you can't figure out why, say so; don't just change it.

## When multiple comments are pasted

Process each comment independently through the full pipeline. Group your recommendations at the end so the user can make decisions on all of them at once. Look for interactions between comments: sometimes two suggestions conflict with each other, or one makes another unnecessary.

## Anti-patterns to avoid

- **Agreeing with everything.** If every comment gets "AGREE," you're not thinking critically.
- **Implementing before recommending.** Never write code before presenting your assessment.
- **Ignoring the suggestion's downsides.** Every change has costs. Name them.
- **Being contrarian for its own sake.** Disagree when you have a real reason, not to prove independence.
- **Lengthy explanations.** Be direct. The user needs a decision, not an essay.
