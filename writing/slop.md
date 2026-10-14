# Slop patterns

Every pattern here was flagged by Joel in a real draft. The slop check holds
every paragraph against every entry. The `slop` skill owns this file: it
adds and updates entries, in this shape, in the section each one fits.

An entry is a bullet: the pattern in bold, then the rule. Indented fields
under it are optional:

- `flagged:` a line Joel flagged, exactly as written (repeatable).
- `rewrite:` the rewrite he accepted, exactly as written. Pairs with the
  `flagged:` line above it.
- `lint:` the id of the `lint.toml` rule that catches it mechanically.

The evals turn each `flagged:` line into a case the check must catch, and
each `rewrite:` line into a case it must leave alone, so keep both exact.

## Words

- **Promotional adjectives**: powerful, seamless, robust, vibrant,
  game-changing. Joel may use them in his own sign-offs; drafts don't.
  lint: promotional
- **"real"** as a descriptor, in any form. Same family as "truly", "simply",
  "genuinely".
  flagged: "guards against a real risk"
  rewrite: "guards against a risk"
  lint: intensifier
- **"whole"**. Cut it, and rewrite the sentence around the specific thing.
  flagged: "shows the whole problem in one place"
  flagged: "ban the whole tool"
- **"in one place"**, **"everything after it"**. Vague totalizers that point
  at nothing. Name the place or the thing.
  lint: totalizer
- **"open"** for unresolved questions. Name the concrete limitation instead
  (see "Sections that argue against the idea").
  flagged: "What's still open"
- **"holds" / "can hold"** for an argument or decision. Say what the reader
  should expect.
  flagged: "why I think that can hold"
- **"never" / "always"** as rhetoric. Keep them only when literally true of
  a fact ("the reviewers never saw that reasoning").
  flagged: "Zero risk was never on offer"
  rewrite: "No setup removes the risk entirely."
- **"still matters"**, **"The X matters"**. Say what the thing does and why.
  flagged: "The visual layer still matters"
  lint: still-matters
- **Vague verdicts** like "weren't good enough". Say what the thing fails
  to deliver.
  flagged: "I realized multi-thousand-line PRs weren't good enough."
  rewrite: "I realized multi-thousand-line PRs weren't leading to sustainable, reliable software."
- **Overclaiming superlatives.**
  flagged: "the most trusted machine an organization owns"
  rewrite: "one of the most trusted machines"
- **Vague durations.** Use the actual span when you know it.
  flagged: "for years"
  rewrite: "for a while"
- **Idioms standing in for an argument.** State the mechanism.
  flagged: "That leverage cuts both ways"
  rewrite: "it multiplies a bad change as easily as a good one."
- **"part" / "parts"** to refer to the argument's own structure.
  flagged: "I'm building GitStack for this part"
  rewrite: "to address this"
  flagged: "it has three parts"
  rewrite: "it needs three things"
- **"enterprise"** repeated. Say "organization".
- **Incidental brand names** (Drive) when any equivalent would do. Write
  "internal docs" so the brand doesn't become the focus.
- **Unneeded dates** on things you cite. Cite the thing; drop the date.
  flagged: "which TypeSafe announced in October 2026"
- **Relative dates** ("this week", "recently"). Posts are read long after
  they're written, so give the month and year.
  lint: relative-date

## Constructions

- **Colons as emphasis separators.** A colon may introduce a list ("comes
  down to two things: X, and Y"). Nowhere else, including a colon that sets
  up a restatement of the noun before it. Joel: "slop basically every time
  we use a colon like that."
  flagged: "The shape is the same either way: root inside, and a gated network."
  rewrite: "Either way the agent gets root inside the machine and a gated network around it."
  flagged: "What helped most was having the agent build each feature as a stack: a few small reviews in order, each doing one thing."
  rewrite: "I have the agent build each feature as a stack of small reviews that go in order and each do one thing."
- **"What changes is X" / "What's left is X" / "What they're missing is X".**
  Pseudo-cleft reveals. Fold into the sentence before or state X directly.
  rewrite: "They just haven't put those pieces together this way yet."
  lint: pseudo-cleft
- **"Both did X."** Say who built what and what it shows.
  flagged: "Both drew the line at the network."
  rewrite: "Model providers have already built similar controls into their own agents, which says something about the approach."
- **"X is Y that nobody can Z."** Say the concrete limit.
  flagged: "a denylist nobody can audit"
  rewrite: "a denylist covers only the tools someone thought to list."
- **Abstract subjects deciding abstract quantities.** These sound
  meaningful and say nothing. Say what happens.
  flagged: "The box and its delegated identity make that context reachable"
  flagged: "the systems around it decide how much of it reaches the work."
  rewrite: "An agent gives an engineer a lot of leverage, and most organizations waste much of it."
- **"X follows from Y"** for an idea or rule. It announces a justification
  instead of giving one, and the justification usually isn't needed. Cut it
  and say something the reader can use.
  flagged: "The rule follows from how a stack lands."
  rewrite: "Those approvals don't all fall on one person, though, since each review in the stack can go to a different reviewer."
  lint: follows-from
- **"Now X do Y"** as a dramatic turn. Write the claim at normal speed with a
  connective.
- **"the part X"**. Name the things.
  flagged: "the part nobody wrote down"
  rewrite: "things that aren't written down anywhere, like why the architecture looks the way it does…"
- **"not X, the goal is Y"** and every other "not X but Y" reveal. State Y.
- **"No X, Y" openers** and paired verdicts. State the positive thing
  plainly.
  flagged: "Code shifted. Pull requests didn't."
- **"The hard part is…"**, **"X can't Y that"**. Say who does what,
  concretely.
  flagged: "A human can't review that"
  lint: hard-part
- **Throat-clearing.** A sentence that only announces the next sentence gets
  deleted.
  flagged: "Here's the thing"
  flagged: "There's a simple test for this."
  lint: throat-clearing
- **Honesty announcements.** State the limitation; the reader sees the
  honesty.
  flagged: "I don't want to oversell this"
- **Fragment answers.** Answer a question with a full sentence.
  flagged: "Why is the laptop such a bad place? Because of what the engineer can do from it."
  rewrite: "An engineer's laptop is one of the most trusted machines an organization owns, since a person with judgment sits in front of it."
- **Symmetrical, lyrical sentences** that repeat a noun for rhythm.
  flagged: "the tool is the only place to draw the line, so the line lands on the tool, and the harmless uses get banned along with the dangerous ones"
  rewrite: "The laptop gives a security team no other place to enforce a rule, so they ban the tool outright, harmless uses included."
- **Naming sentences.** Introduce the term in use.
  flagged: "I'll call that machine the box."
  rewrite: "Give the agent its own box."
  lint: naming
- **Unanchored references.** Every pronoun has one clear referent; when "it"
  could mean two nouns, name the one you mean.
  flagged: "The reverse also holds"
  flagged: "and organizations handle it differently"
- **Odd metaphors.**
  flagged: "code was how that thinking reached the machine"
  rewrite: "Engineering has always been about thinking clearly and communicating intent, and for most of its history that intent was written in code."
- **Backwards framing** describes what should happen as if it already does.
  flagged: "those fundamentals are where an engineer's time goes"
  rewrite: "an engineer should spend more time on those fundamentals and less on the mechanics of the code itself."
- **Awkward appositives.**
  flagged: "Unit and integration tests are a start, and one we've relied on"
  rewrite: "are a good start, and engineers have relied on them for a long time."

## Rhythm

- **Short dramatic sentences**, alone or in stutter runs. Merge them into a
  sentence that carries its reason.
  flagged: "The order matters."
  flagged: "Fix the environment and the agent gets fast. Then the code arrives in volume."
- **Juxtaposed pivots** read as drama. Open with "However," or "That said,"
  so the turn is conversational.
  flagged: "Engineering is still here."
- **Over-dramatic endings to a contrast.** Join the two halves with "but".
- **Dramatic time claims.** Make the comparison without the flourish.
  flagged: "a decision they made ten years ago"
  rewrite: "the same kind of decision."
- **Rule-of-three padding.** Three items only when there are three things.
- **Repeated phrases.** No phrase more than twice in a post; past that it
  reads as a tic.
- **Em dashes**, anywhere a person reads. Use a period, comma, or
  parentheses.
  lint: em-dash

## Structure

- **Opening on "you" in a scene** puts the reader in a role they may not
  hold. Open from something most readers share (the demo everyone has
  seen), then tell the scene in third person. Keep the closing scene in the
  same person.
  flagged: "You ask the agent to read the design doc…"
- **Wordy titles.** Cut every word the title still works without.
  flagged: "Engineering after hand-written code"
  rewrite: "After hand-written code"
- **Announcing what comes next**, in any form: roadmap paragraphs, "I'll
  start with X, since Y", "which I'll come back to below". Start the next
  section; the heading and the first sentence carry the transition.
  flagged: "The boundary comes first. Then the agent's experience."
  lint: announce
- **Referring to the post or design from inside it.** State the consequence
  directly.
  flagged: "nothing in this design works"
  rewrite: "every token the agent reads leaves the organization, which is a much bigger problem than any web request."
  lint: self-reference
- **Sections that argue against the idea.** Name the concrete limitation as
  the heading ("No filter is perfect") and treat each item as a problem to
  work on.
  flagged: "What's still open"
  flagged: "Where this falls short"
- **Invented taxonomies** frame options as a formal system.
  flagged: "a proxy, which sorts each request into a tier"
  rewrite: "There are a few strategies for handling traffic that leaves the box, and an organization will likely mix them."
- **Options split by commentary.** When presenting a choice, put the options
  in adjacent sentences, then comment. When the post proposes its own path,
  name the existing options first and then the third way ("Some restrict
  their agents… Others restrict almost nothing… I think there's a third
  option").
- **Parts before the whole.** Define the system before listing its parts,
  and give each part a bold run-in lead so it stands out.
- **Forward references.** A sentence or bold line that leans on a concept
  the post hasn't introduced yet. End on the need and introduce the concept
  where it belongs.
  flagged: "If the guardrail lives at the network…"
  flagged: "None of the hardware is new"
  rewrite: "The guardrail needs to live somewhere the agent can't reach"
- **Citations dropped in as framing.** A quote needs to say plainly what it
  means for the argument.
  flagged: "Donella Meadows called the places… leverage points, and finding them is how I think about this work."
- **Evidence detours that stall the spine.** A section of bolded examples
  (kernel, Gerrit, Phabricator, LLVM) proving a side point "gets off the
  path." Use one paragraph, a clause and a link per example, then back to
  the chain.
- **"How to read this post" boxes.** Joel removed them. Don't add one.
  lint: how-to-read
- **Out-of-audience asides.** Cut what doesn't serve the reader the post is
  for.
  flagged: "For a solo developer it might be a Mac mini in a closet"
- **Generic summary sentences.** Replace with the specific mechanism.
  flagged: "The box puts them in one place where you can watch them."
- **Section wrap-ups that add a new mechanism.** A closing paragraph
  summarizes what the section's pieces achieve together.
  flagged: "Review also covers the write path out of the box…"
  rewrite: "With changes structured, agents taking the first passes, and risk scores routing attention, the firehose becomes manageable."
- **Sentences that trail off** without finishing their thought. Finish them.
- **Weak endings** that gesture at earliness or open problems. End on a
  concrete claim, ideally one that closes a loop the opening started.
- **A call to action Joel didn't ask for.** Propose one; drop it if he isn't
  sold.

## Claims and attribution

- **Overclaiming a tool** when the point is that a system checks outbound
  traffic. Describe the category (block, or allow with an audit record),
  then name products as examples among several, including build-your-own.
  flagged: "Classifiers solve this"
- **Strong guarantee sentences.** Describe the mechanism and let the reader
  judge it.
  flagged: "…make it a gate worth trusting"
- **Equating the agent with the engineer.** An engineer stops to think
  before something expensive; an agent may not.
  flagged: "an agent that can't do more damage than the engineer it works for."
  rewrite: "The goal is to give the agent free rein inside the box without letting anything harmful leave it."
- **False justifications.** Give the actual reason.
  flagged: "it gets root because there's nothing inside worth protecting"
  rewrite: "the agent gets root because the protection sits at the network."
- **An example stated as universal.**
  flagged: "because any URL can carry data and a patient attacker can split it across many requests"
  rewrite: "For example, a patient attacker could split data across many requests that each look harmless."
- **Imprecise measures**, when the point is that the answer can be looked
  up.
  flagged: "could answer the agent's question in a minute"
  rewrite: "If someone on the team could answer the agent's question by looking it up, the agent should be able to look it up too."
- **Rules readers will dispute.** State the aim instead.
  flagged: "Cheap layers should run constantly, and expensive layers should run rarely"
  rewrite: "fast, reliable checks on the business logic that don't depend on the UI."
- **Only the dramatic failure**, when the common failure is mundane. Lead
  with the common case.
  flagged: "If a poisoned README talked the author into something"
  rewrite: "If the author agent talked itself into an overengineered design, or a poisoned README talked it into something worse…"
- **Weak or repeated analogies.** Cut an analogy that doesn't carry the
  argument.
  flagged: "can email the source code to anyone in the world"
- **Points that don't matter**, like logging when everything should be
  logged anyway. Cut it.
  flagged: "with every request that leaves the box on record"
- **Overstated scenes** that imply dumping all context in.
  flagged: "it reads the design doc, the code, the dashboards, and last month's incident review"
  rewrite: "As the engineer describes what they want, the agent pulls in the supporting material it needs."
- **Autonomy framed as abandonment.** Quality problems at that stage point
  to gaps in tooling or skills.
  flagged: "Then the engineer leaves it alone."
  rewrite: "During implementation the agent works with more autonomy, building to the spec it designed with the engineer."
- **Asserting a contested claim for agreement.** Ground it in what Joel has
  observed.
  rewrite: "From the engineers I talk to… it looks like we've already started signing off on code we haven't fully read."
- **Veiled former-employer anecdotes** read as dodging a name readers can
  guess. Make the point as general argument with no first-person story.
  flagged: "At a previous job, at a large company, we stacked changelists"
  rewrite: "each review lands as its own commit and can be reverted without touching the others, so each one gets its own sign-off."
- **Inventing events in Joel's life**, including anecdotes, feelings,
  incidents, testimonials, and stats. Write it as a general example, untied
  to him, or leave `[ANECDOTE: what kind]` and ask.
  flagged: "Teams tell me their app can't be verified"
- **Credential waving.** State the reason; the reader doesn't need the
  credential.
  flagged: "I've seen why from the inside"
- **Aggressive generalizations about people.** Cut or soften to Joel's own
  experience.
  flagged: "Most engineers are weaker at one of them than they realize"
- **Over-specific mechanics that misstate the idea.**
  flagged: "three agents, three boxes"
  rewrite: "an engineer whose agents need more compute gets more boxes."
