# Slop patterns

Every pattern here was flagged by Joel in a real draft. Each entry pairs the
flagged line with the rewrite he accepted. The slop pass checks every
paragraph against every entry. When Joel flags something new, add it here
with the same shape, in the section it fits.

## Words

- **Promotional adjectives**: powerful, seamless, robust, vibrant,
  game-changing. Joel may use them in his own sign-offs; drafts don't.
- **"real"** as a descriptor, in any form. "guards against a real risk" →
  "guards against a risk". Same family as "truly", "simply", "genuinely".
- **"whole"**. "shows the whole problem in one place", "ban the whole tool".
  Cut it, and rewrite the sentence around the specific thing.
- **"in one place"**, **"everything after it"**. Vague totalizers that point
  at nothing. Name the place or the thing.
- **"open"** for unresolved questions ("What's still open"). Name the
  concrete limitation instead (see "Sections that argue against the idea").
- **"holds" / "can hold"** for an argument or decision ("why I think that can
  hold"). Say what the reader should expect.
- **"never" / "always"** as rhetoric ("Zero risk was never on offer"). Keep
  them only when literally true of a fact ("the reviewers never saw that
  reasoning"). Otherwise: "No setup removes the risk entirely."
- **"still matters"**, **"The X matters"**. "The visual layer still matters"
  → say what the thing does and why.
- **Overclaiming superlatives.** "the most trusted machine an organization
  owns" → "one of the most trusted machines".
- **Vague durations.** "for years" → "for a while", or the actual span.
- **Idioms standing in for an argument.** "That leverage cuts both ways" →
  state the mechanism: "it multiplies a bad change as easily as a good one."
- **"part" / "parts"** to refer to the argument's own structure ("I'm
  building GitStack for this part", "it has three parts"). → "to address
  this", "it needs three things".
- **"enterprise"** repeated. Say "organization".
- Incidental brand names (Drive) when any equivalent would do. Write
  "internal docs" so the brand doesn't become the focus.
- **Unneeded dates** on things you cite ("which TypeSafe announced in
  October 2026"). Cite the thing; drop the date.

## Constructions

- **Colons as emphasis separators.** "The shape is the same either way: root
  inside, and a gated network." → "Either way the agent gets root inside the
  machine and a gated network around it." A colon may introduce a list ("comes
  down to two things: X, and Y"). Nowhere else.
- **"What changes is X" / "What's left is X" / "What they're missing is X".**
  Pseudo-cleft reveals. Fold into the sentence before or state X directly:
  "They just haven't put those pieces together this way yet."
- **"Both did X."** "Both drew the line at the network." Say who built what
  and what it shows: "Model providers have already built similar controls
  into their own agents, which says something about the approach."
- **"X is Y that nobody can Z."** "a denylist nobody can audit". Say the
  concrete limit: "a denylist covers only the tools someone thought to list."
- **Abstract subjects deciding abstract quantities.** "The box and its
  delegated identity make that context reachable", "the systems around it
  decide how much of it reaches the work." These sound meaningful and say
  nothing. Say what happens: "An agent gives an engineer a lot of leverage,
  and most organizations waste much of it."
- **"X follows from Y"** for an idea or rule ("The rule follows from how a
  stack lands."). It announces a justification instead of giving one, and
  the justification usually isn't needed. Cut it and say something the
  reader can use: "Those approvals don't all fall on one person, though,
  since each review in the stack can go to a different reviewer."
- **"Now X do Y"** as a dramatic turn. Write the claim at normal speed with a
  connective.
- **"the part X"** ("the part nobody wrote down"). Name the things: "things
  that aren't written down anywhere, like why the architecture looks the way
  it does…"
- **"not X, the goal is Y"** and every other "not X but Y" reveal. State Y.
- **"No X, Y" openers** and "Code shifted. Pull requests didn't." State the
  positive thing plainly.
- **"The hard part is…"**, **"X can't Y that"** ("A human can't review
  that"). Say who does what, concretely.
- **Throat-clearing** ("Here's the thing", "There's a simple test for
  this."). A sentence that only announces the next sentence gets deleted.
- **Honesty announcements** ("I don't want to oversell this"). State the
  limitation; the reader sees the honesty.
- **Fragment answers.** "Why is the laptop such a bad place? Because of what
  the engineer can do from it." Answer a question with a full sentence: "An
  engineer's laptop is one of the most trusted machines an organization
  owns, since a person with judgment sits in front of it."
- **Symmetrical, lyrical sentences** that repeat a noun for rhythm. "the tool
  is the only place to draw the line, so the line lands on the tool, and the
  harmless uses get banned along with the dangerous ones" → "The laptop gives
  a security team no other place to enforce a rule, so they ban the tool
  outright, harmless uses included."
- **Naming sentences.** "I'll call that machine the box." Introduce the term
  in use: "Give the agent its own box."
- **Unanchored references.** "The reverse also holds", "and organizations
  handle it differently" (it = the agent or the risk?). Name what you mean.
- **Odd metaphors.** "code was how that thinking reached the machine" →
  "Engineering has always been about thinking clearly and communicating
  intent, and for most of its history that intent was written in code."
- **Backwards framing.** "those fundamentals are where an engineer's time
  goes" describes what should happen as if it already does. → "an engineer
  should spend more time on those fundamentals and less on the mechanics of
  the code itself."
- **Awkward appositives.** "Unit and integration tests are a start, and one
  we've relied on" → "are a good start, and engineers have relied on them for
  a long time."

## Rhythm

- **Short dramatic sentences**, alone or in stutter runs. "The order
  matters." "Fix the environment and the agent gets fast. Then the code
  arrives in volume." Merge them into a sentence that carries its reason.
- **Juxtaposed pivots.** "Engineering is still here." reads as drama; open
  with "However," or "That said," so the turn is conversational.
- **Over-dramatic endings to a contrast.** Join the two halves with "but".
- **Dramatic time claims** ("a decision they made ten years ago"). Make the
  comparison without the flourish: "the same kind of decision."
- **Rule-of-three padding.** Three items only when there are three things.
- **Em dashes**, anywhere a person reads. Use a period, comma, or
  parentheses.

## Structure

- **Opening on "you" in a scene.** "You ask the agent to read the design
  doc…" as the first words puts the reader in a role they may not hold. Open
  from something most readers share (the demo everyone has seen), then tell
  the scene in third person. Keep the closing scene in the same person.
- **Wordy titles.** "Engineering after hand-written code" → "After
  hand-written code". Cut every word the title still works without.
- **Announcing what comes next**, in any form: roadmap paragraphs ("The
  boundary comes first. Then the agent's experience."), "I'll start with X,
  since Y", "which I'll come back to below". Start the next section; the
  heading and the first sentence carry the transition.
- **Referring to the post or design from inside it.** "nothing in this design
  works", "below", "this post". State the consequence directly: "every token
  the agent reads leaves the organization, which is a much bigger problem
  than any web request."
- **Sections that argue against the idea.** "What's still open", "Where this
  falls short". Name the concrete limitation as the heading ("No filter is
  perfect") and treat each item as a problem to work on.
- **Invented taxonomies.** "a proxy, which sorts each request into a tier"
  frames options as a formal system. → "There are a few strategies for
  handling traffic that leaves the box, and an organization will likely mix
  them."
- **Options split by commentary.** When presenting a choice, put the options
  in adjacent sentences, then comment. When the post proposes its own path,
  name the existing options first and then the third way ("Some restrict
  their agents… Others restrict almost nothing… I think there's a third
  option").
- **Parts before the whole.** Define the system before listing its parts,
  and give each part a bold run-in lead so it stands out.
- **Forward references.** A sentence or bold line that leans on a concept
  the post hasn't introduced yet ("If the guardrail lives at the network…"
  before the network comes up; "None of the hardware is new" when hardware
  was never discussed). End on the need ("The guardrail needs to live
  somewhere the agent can't reach") and introduce the concept where it
  belongs.
- **Citations dropped in as framing.** "Donella Meadows called the places…
  leverage points, and finding them is how I think about this work." A quote
  needs to say plainly what it means for the argument.
- **Evidence detours that stall the spine.** A section of bolded examples
  (kernel, Gerrit, Phabricator, LLVM) proving a side point "gets off the
  path." → one paragraph, a clause and a link per example, then back to the
  chain.
- **"How to read this post" boxes.** Joel removed them. Don't add one.
- **Out-of-audience asides.** "For a solo developer it might be a Mac mini
  in a closet" in a post for organizations. Cut what doesn't serve the
  reader the post is for.
- **Generic summary sentences** ("The box puts them in one place where you
  can watch them."). Replace with the specific mechanism.
- **Section wrap-ups that add a new mechanism.** "Review also covers the
  write path out of the box…" A closing paragraph summarizes what the
  section's pieces achieve together: "With changes structured, agents taking
  the first passes, and risk scores routing attention, the firehose becomes
  manageable."
- **Sentences that trail off** without finishing their thought. Finish them.
- **Weak endings** that gesture at earliness or open problems. End on a
  concrete claim, ideally one that closes a loop the opening started.
- **A call to action Joel didn't ask for.** Propose one; drop it if he isn't
  sold.

## Claims and attribution

- **Overclaiming a tool.** "Classifiers solve this" when the point is that a
  system checks outbound traffic. Describe the category (block, or allow with
  an audit record), then name products as examples among several, including
  build-your-own.
- **Strong guarantee sentences** ("…make it a gate worth trusting"). Describe
  the mechanism and let the reader judge it.
- **Equating the agent with the engineer.** "an agent that can't do more
  damage than the engineer it works for." An engineer stops to think before
  something expensive; an agent may not. → "The goal is to give the agent
  free rein inside the box without letting anything harmful leave it."
- **False justifications.** "it gets root because there's nothing inside
  worth protecting" when the box holds source code. Give the actual reason:
  "the agent gets root because the protection sits at the network."
- **An example stated as universal.** "because any URL can carry data and a
  patient attacker can split it across many requests" → "For example, a
  patient attacker could split data across many requests that each look
  harmless."
- **Imprecise measures.** "could answer the agent's question in a minute"
  when the point is that the answer can be looked up. → "If someone on the
  team could answer the agent's question by looking it up, the agent should
  be able to look it up too."
- **Rules readers will dispute.** "Cheap layers should run constantly, and
  expensive layers should run rarely" invites an argument about what's
  expensive. State the aim instead: "fast, reliable checks on the business
  logic that don't depend on the UI."
- **Only the dramatic failure.** "If a poisoned README talked the author
  into something" when the common failure is mundane. Lead with the common
  case: "If the author agent talked itself into an overengineered design, or
  a poisoned README talked it into something worse…"
- **Weak or repeated analogies.** "can email the source code to anyone in
  the world", used twice. Cut an analogy that doesn't carry the argument.
- **Points that don't matter.** "with every request that leaves the box on
  record" when everything should be logged anyway. Cut it.
- **Overstated scenes.** "it reads the design doc, the code, the dashboards,
  and last month's incident review" implies dumping all context in. → "As the
  engineer describes what they want, the agent pulls in the supporting
  material it needs."
- **Autonomy framed as abandonment.** "Then the engineer leaves it alone." →
  "During implementation the agent works with more autonomy, building to the
  spec it designed with the engineer." Quality problems at that stage point
  to gaps in tooling or skills.
- **Asserting a contested claim for agreement.** Ground it in what Joel has
  observed: "From the engineers I talk to… it looks like we've already
  started signing off on code we haven't fully read."
- **Veiled former-employer anecdotes.** "At a previous job, at a large
  company, we stacked changelists" reads as dodging a name readers can
  guess. Make the point as general argument with no first-person story:
  "each review lands as its own commit and can be reverted without touching
  the others, so each one gets its own sign-off."
- **Inventing events in Joel's life** ("Teams tell me their app can't be
  verified"), including anecdotes, feelings, incidents, testimonials, and
  stats. Write it as a general example, untied to him, or leave
  `[ANECDOTE: what kind]` and ask.
- **Credential waving** ("I've seen why from the inside"). State the reason;
  the reader doesn't need the credential.
- **Aggressive generalizations about people** ("Most engineers are weaker at
  one of them than they realize"). Cut or soften to Joel's own experience.
- **Over-specific mechanics that misstate the idea.** "three agents, three
  boxes" when the point is that more work gets more machines: "an engineer
  whose agents need more compute gets more boxes."
