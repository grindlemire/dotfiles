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
  flagged: "the real card"
  lint: intensifier
- **"whole"**. Cut it, and rewrite the sentence around the specific thing.
  flagged: "shows the whole problem in one place"
  flagged: "ban the whole tool"
  flagged: "Restoring one tenant's database means restoring the whole server and copying that database out"
  rewrite: "To restore one tenant's database, you restore the server, with every tenant on it, to a new server and copy that one database out"
- **"in one place"**, **"everything after it"**. Vague totalizers that point
  at nothing. Name the place or the thing.
  lint: totalizer
- **"open"** for unresolved questions. Name the concrete limitation instead
  (see "Sections that argue against the idea").
  flagged: "What's still open"
  flagged: "The repos don't say, so it's an open question for the team"
  rewrite: "The repos don't say, so I'll ask the team"
- **"holds" / "can hold"** for an argument or decision. Say what the reader
  should expect.
  flagged: "why I think that can hold"
- **"settle"** in any form, for what evidence or a check would decide. Say what it would show.
  flagged: "This settles what breaks first."
  flagged: "These settle what breaks first."
  rewrite: "Metrics for connections, CPU and storage on the shared database server, and for node pool use, would show which limit growth hits first."
  flagged: "The contract may settle all of this."
  rewrite: "The code doesn't show who owns the app itself, and the contract may say something different, which makes it the first thing to read."
  lint: settle
- **"never" / "always"** as rhetoric. Keep them only when literally true of
  a fact ("the reviewers never saw that reasoning").
  flagged: "Zero risk was never on offer"
  rewrite: "No setup removes the risk entirely."
- **"still matters"**, **"The X matters"**. Say what the thing does and why.
  flagged: "The visual layer still matters"
  flagged: "Each pull request in a GitHub stack gets a branch of its own, and that matters once a reviewer asks for a change low in the stack."
  lint: still-matters
- **Vague verdicts** like "weren't good enough", and their positive twins:
  "sound", "works" or "is working", "in good shape", "good patterns". Say
  what the thing does or fails to deliver; a heading over good things says
  what to do with them ("What to keep").
  flagged: "I realized multi-thousand-line PRs weren't good enough."
  rewrite: "I realized multi-thousand-line PRs weren't leading to sustainable, reliable software."
  flagged: "The application is built on sound patterns"
  flagged: "the application code follows good patterns in several places, listed under What is working"
  rewrite: "Each customer's data sits in its own databases and storage account, and every tenant is built by the same Terraform module."
  flagged: "Each customer's data is separated and much of the code is sound"
  flagged: "Several parts are in good shape"
  rewrite: "Keep these as the platform changes"
  flagged: "Delivery was slow until last spring and mostly steady since."
  rewrite: "For six months the vendor delivered about a quarter of its later monthly output, and delivery has been mostly steady since."
- **Overclaiming superlatives.**
  flagged: "the most trusted machine an organization owns"
  rewrite: "one of the most trusted machines"
- **Vague durations.** Use the actual span when you know it.
  flagged: "for years"
  rewrite: "for a while"
- **Idioms standing in for an argument.** State the mechanism.
  flagged: "That leverage cuts both ways"
  rewrite: "it multiplies a bad change as easily as a good one."
- **"cost" as drama** ("starts to cost something", "shows what that costs")
  when nothing is being priced. Say what starts to behave differently.
  flagged: "It starts to cost something"
- **Physical idioms for how software parts relate** ("hang off", "sit on
  top of"). Say what the relationship is.
  flagged: "and its diff, threads, approvals, and merge button all hang off that pair of branches"
  flagged: "The concerns are in the shared layers under every customer"
  rewrite: "Most of the problems are in what every customer shares, such as the database server, the ingress controller and the message broker"
  flagged: "A few shared pieces carry every customer."
  rewrite: "Every customer depends on a few shared components."
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
- **Dates and provenance written like a log header**: a day-first date
  ("18 November 2026"), an ISO date in a sentence ("from 2025-12-01 to
  2026-11-18"), or the file and commits a claim came from ("at the commits
  pinned in the pins file"). Nobody talks that way. Write the date the way
  you'd say it ("as it stood on November 18", "between December 2025 and
  mid-November"), and leave commit lists to the file or table that holds
  them.
  flagged: "I read every repo at the pinned commits on 18 November 2026, without access to Azure or any running system."
  rewrite: "I worked from the code alone, going through every repo as it stood on November 18. I couldn't see Azure or anything running, so where production differs from what I describe, production is right."
  flagged: "There were 120 prod tags from 2025-12-01 to 2026-11-18."
  rewrite: "Production got 120 tags between December 2025 and mid-November 2026."
  lint: formal-date
- **"X for me"** as a hedge ("isn't a replacement for me"). State the
  claim and its reason, and let the first person elsewhere in the post
  carry whose view it is.
  flagged: "Dia isn't a replacement for me, with AI integrations I can't turn off."
  rewrite: "Dia isn't a suitable replacement, with AI integrations you can't turn off."
  lint: for-me
- **"choke points"** for shared limits in a system. Say "bottlenecks for
  growth or reliability".
  flagged: "Choke points: shared pieces that limit growth, or that one failure would take down for every site, and what 2x and 5x growth would test."
- **Announcing how a list is processed** ("ranked", "prioritized",
  "categorized") when the reader doesn't need the method. Name the thing
  and what it gives them.
  flagged: "A ranked risk list and a suggested order of work."

## Constructions

- **Colons as emphasis separators.** A colon may introduce a list ("comes
  down to two things: X, and Y"). Nowhere else, including a colon that sets
  up a restatement of the noun before it.
  flagged: "The shape is the same either way: root inside, and a gated network."
  rewrite: "Either way the agent gets root inside the machine and a gated network around it."
  flagged: "What helped most was having the agent build each feature as a stack: a few small reviews in order, each doing one thing."
  rewrite: "I have the agent build each feature as a stack of small reviews that go in order and each do one thing."
  flagged: "Vendor: what was delivered over time and how much the platform depends on them."
  flagged: "and in how the platform is run: by hand, from laptops, by very few people."
  rewrite: "and in how the platform is run, which is by hand, from laptops, by a few people."
  flagged: "once per worker pod: over a hundred runs of each midnight job today"
  A bold run-in lead ends with a period, not a colon, and the sentence after it stands on its own.
  flagged: "The product is one Django and React app, deployed once per customer: 60 copies in production."
  rewrite: "The product is one Django and React app, and production runs 60 copies of it, one per customer."
  flagged: "**Customer data exposure: one leaked credential can reach every customer.**"
  rewrite: "**Customer data exposure.** One leaked credential can reach every customer."
  flagged: "**Load and cost:** connections, CPU and storage on the shared database server, and node pool use."
  rewrite: "**Load and cost.** Metrics for connections, CPU and storage on the shared database server, and for node pool use, would show which limit growth hits first."
  rewrite: "once per worker pod, which is over a hundred runs of each midnight job today"
  flagged: "exist only because of a bug: the entrypoint treats"
  rewrite: "exist only because of a bug, since the entrypoint treats"
- **"What changes is X" / "What's left is X" / "What they're missing is X".**
  Pseudo-cleft reveals. Fold into the sentence before or state X directly.
  rewrite: "They just haven't put those pieces together this way yet."
  lint: pseudo-cleft
- **"Doing X means doing Y" for what a product makes you do.** It turns a
  step into an equation. Say who does what ("you search your tabs by typing
  %"). Defining a term this way is fine ("Stacking means splitting a change
  into…"), so there's no lint rule.
  flagged: "searching your tabs means typing % in the address bar"
  rewrite: "you search your tabs by typing % in the address bar"
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
  flagged: "One failure or one heavy tenant reaches every customer, and growth reaches the database server and the node pools first."
  rewrite: "If the database server fails, the 50 tenants whose apps use it go down, and if the ingress controller fails, 55 of the 60 do."
  flagged: "Whether they still work needs a check in the live environment"
  rewrite: "Someone with live access needs to check whether they still work"
  flagged: "Isolation inside the BI tool rests on row-level security that only some release paths re-apply, a write-capable DB credential, and one shared secret key"
  rewrite: "Inside the BI tool, separation between accounts depends on row-level security that only some release paths re-apply."
- **"X follows from Y"** for an idea or rule. It announces a justification
  instead of giving one, and the justification usually isn't needed. Cut it
  and say something the reader can use.
  flagged: "The rule follows from how a stack lands."
  flagged: "and most of the trouble with GitHub's stacks comes from that choice."
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
  flagged: "The hotfix box and the bypass note go together."
  flagged: "Steps 7 and 8 together show two problems."
- **Honesty announcements.** State the limitation; the reader sees the
  honesty.
  flagged: "I don't want to oversell this"
- **Fragment answers.** Answer a question with a full sentence.
  flagged: "Why is the laptop such a bad place? Because of what the engineer can do from it."
  rewrite: "An engineer's laptop is one of the most trusted machines an organization owns, since a person with judgment sits in front of it."
  The same goes for opening an answer with a bare verdict ("No.", "Yes.", "It can."): fold it into the sentence that follows.
  flagged: "Actual load, cost, whether the running environment matches the code, and whether backups restore."
  rewrite: "The code can't show actual load or cost, whether the running environment matches it, or whether backups restore, and each needs someone with access to check."
  flagged: "Only partly. 40 of its 52 tenants are in Terraform mode"
  rewrite: "Only partly, since 40 of its 52 tenants are in Terraform mode"
  flagged: "Not today. Per-site configuration is split across five places"
  rewrite: "Not easily, because per-site configuration is split across five places"
- **Verbless fragments** standing as sentences ("Cheapest first.", "Four steps, then the ask."). Every sentence needs a subject and a verb, unless the structure requires a label, such as a title, heading, table cell or bold lead.
  flagged: "Four steps, cheapest first. None needs a decision about the target architecture."
  rewrite: "The four steps below start with the cheapest, and none of them waits on a decision about the target architecture."
  flagged: "Cheapest first. None depends on a decision about the target architecture."
  Telegraphic report openers are the same pattern: a noun phrase with no subject, then a colon and more fragments. Give the sentence a subject and a verb, and say who did what.
  flagged: "Code-only review of the platform as of 2026-11-18: every repo pinned to a commit, no access to Azure or any running system."
  rewrite: "I worked from the code alone, going through every repo as it stood on November 18. I couldn't see Azure or anything running, so where production differs from what I describe, production is right."
- **Symmetrical, lyrical sentences** that repeat a noun for rhythm.
  flagged: "the tool is the only place to draw the line, so the line lands on the tool, and the harmless uses get banned along with the dangerous ones"
  rewrite: "The laptop gives a security team no other place to enforce a rule, so they ban the tool outright, harmless uses included."
  flagged: "The vendor built most of the platform, and the platform depends on it."
  rewrite: "The vendor built most of the platform, and the client still depends on it for the base code and UI packages."
  flagged: "a key shared by every tenant reaches every tenant if it leaks"
  rewrite: "a leaked shared key works in every tenant"
- **Naming sentences.** Introduce the term in use.
  flagged: "I'll call that machine the box."
  rewrite: "Give the agent its own box."
  lint: naming
- **Unanchored references.** Every pronoun has one clear referent; when "it"
  could mean two nouns, name the one you mean.
  flagged: "The reverse also holds"
  flagged: "and organizations handle it differently"
  flagged: "Each new site adds to that load, and several limits are reached at 5x growth."
  rewrite: "Each new site adds manual work, and by 5x growth the worker and batch node pools run out of room on declared requests."
  flagged: "Customer data leaving through bearer links and outside vendors, each of which needs a data agreement"
  rewrite: "The red edges carry customer data and the dashed ones may, and each vendor that receives it needs a data agreement"
  flagged: "The integration vendor, top left, is a third-party platform that scripts hand BI tokens to, and the agent prompts name a demo host"
  rewrite: "The integration vendor, top left, is a third-party platform. Scripts in the client's repos hand it BI tokens, and prompt files in those repos name a demo host"
- **Odd metaphors.**
  flagged: "code was how that thinking reached the machine"
  rewrite: "Engineering has always been about thinking clearly and communicating intent, and for most of its history that intent was written in code."
- **Backwards framing** describes what should happen as if it already does.
  flagged: "those fundamentals are where an engineer's time goes"
  rewrite: "an engineer should spend more time on those fundamentals and less on the mechanics of the code itself."
- **"X only happens when Y"** as a conditional verdict that sets up the
  product as the answer. State the aim and what was done about it.
  flagged: "We want golfers to keep using the method, and that only happens when tracking takes almost no effort."
- **A "since" or "because" clause that explains nothing in its sentence.**
  The reason has to answer why the main clause is true. When it supports a
  different point, give that point its own sentence.
  flagged: "built for teams whose coding agents write most of their code, since a multi-thousand-line pull request is too big for anyone to review carefully"
  rewrite: "GitStack (gitstack.sh) is a Git host and code review tool for teams whose coding agents write most of their code."
- **Awkward appositives.**
  flagged: "Unit and integration tests are a start, and one we've relied on"
  rewrite: "are a good start, and engineers have relied on them for a long time."
- **Comparatives with no comparison** ("weaker controls", "less protected").
  Say what the thing is or where it goes.
  flagged: "Customer data and credentials sit in places with weaker controls."
  rewrite: "Credentials are in git, and customer data is copied into logs, error tracking and laptop dumps."
- **Vague verbs that have to be decoded** ("has lasted"). Say what is
  measurably true.
  flagged: "and more of the 2025 work has lasted"
  rewrite: "and more of the code written in 2025 is still in the codebase"
- **Compressed adjectives** that land on the wrong noun ("the cheapest
  copies" when the fix is cheap, not the copies). Spell out the relation.
  flagged: "Stop the cheapest copies"
  rewrite: "Stop the copies that are easiest to stop"
- **An assertion right after a disclaimer.** If the sentence before says it
  can't be known, don't state it as fact; hedge it in the same sentence.
  flagged: "Code can't measure it. Most of the time goes into the manual steps"
  rewrite: "Commit dates don't show when an apply ran, so code can't measure it, though the manual steps are the likely bulk of the time"

## Rhythm

- **Alliteration** in titles and thesis lines. Name the subject plainly,
  in the words a reader would search for.
  flagged: "A pile of pull requests"
  rewrite: "GitStack vs. GitHub stacked pull requests"
- **Short dramatic sentences**, alone or in stutter runs. Merge them into a
  sentence that carries its reason.
  flagged: "The order matters."
  flagged: "Fix the environment and the agent gets fast. Then the code arrives in volume."
  flagged: "So we built one together."
  rewrite: "My brother [name] is a student in the Scoring Method community, and he and I built TSM Caddie (tsmcaddie.com) because he wanted a faster way to keep his Scorecard and Practice Card than filling them in by hand."
  flagged: "It rests on a few people."
  rewrite: "A release is dozens of hand-run steps, and one author made almost every release commit."
  flagged: "It is the cheapest fix on the list."
  rewrite: "Run each tenant's scheduled jobs once instead of once per pod, which is a small change to how Celery beat runs."
  flagged: "Git measures delivered code. Specs, designs, support and work in the vendor's own repos don't show in it."
  rewrite: "Git counts only delivered code, so specs, designs, support and work in the vendor's own repos don't show in these numbers."
- **One-line product closers** like "X is built around that." or "Y is
  built for that." A short declarative that lands the product as the
  answer reads as an ad. End on the idea, and when the product comes up,
  say in a full sentence what it was built on and why.
  flagged: "GitStack is built around that."
  lint: built-around-that
- **Juxtaposed pivots** read as drama. Open with "However," or "That said,"
  so the turn is conversational.
  flagged: "Engineering is still here."
- **Over-dramatic endings to a contrast.** Join the two halves with "but".
- **Dramatic time claims.** Make the comparison without the flourish.
  flagged: "a decision they made ten years ago"
  rewrite: "the same kind of decision."
- **Rule-of-three padding.** Three items only when there are three things.
  flagged: "that logic cannot be reviewed, tested or rebuilt from code"
  rewrite: "that mapping exists only inside the engine, so it can't be rebuilt from code"
- **Repeated phrases.** No phrase more than twice in a post; past that it
  reads as a tic.
  flagged: "Code can't answer that."
  rewrite: "Time per tenant and failure rate live in Argo history, which is kept for 30 days"
- **Em dashes**, anywhere a person reads. Use a period, comma, or
  parentheses.
  lint: em-dash

## Structure

- **Restating what the reader already knows.** In a message, an opening
  that spells out what the writer is obviously doing (what they're
  reviewing, which document they're following) when the context implies it.
  Start with why you're writing.
  flagged: "What I'm reviewing: the client's code and infrastructure definitions (all repos, Terraform, CI and deployment config), following the SOW."
  The same goes for an intro that explains where content came from, its
  caveats, or how to use the page, when the reader can tell.
  flagged: "Drawn from the application and infrastructure repos. They show what the code declares, which may not match what runs. Click any diagram to zoom in."
  flagged: "These are the declared sources, and what a pod has actually loaded can lag behind them"
  flagged: "so the diagram shows the declared path and this review could not check the running state"
  rewrite: "Which build each tenant runs is visible only in the cluster, not in git."
  A scope note written as a label and passive report ("Scope. This review covers…") reads as a form. When the caveat is needed, say it directly, and tell the reader what to do about it.
  flagged: "Scope. This review covers the code only: every repo as of 18 November 2026. It had no access to Azure or to anything running, so each point describes what the code declares. The running system may differ."
  rewrite: "Everything here comes from the code in the repos as they stood on November 18, not from Azure or the running system. Where production differs from the code, production is right, so flag any difference you know of."
  A caveat that earns its place in a brief is filler on a cover, landing page or page subtitle, where it has no job. Cut it there, along with subtitles that restate the page title.
  flagged: "A code-only review of every repo as of 18 November 2026. Where production differs from the code, production is right, so flag any difference you know of."
- **"What I'll present"** framing when the message is a preview asking for
  steer. Say what you're looking into so the reader can redirect it.
  flagged: "What I'll present:"
- **Formal organizing phrases** that name a document's structure instead of
  the subject ("By SOW area", "Per section 3"). Name the areas themselves in
  plain words.
  flagged: "By SOW area (architecture, Azure and scaling, releases, site configuration, security and compliance): where common industry practice isn't being followed, and where things are in good shape."
- **Decorative label lines** above a title: a small product name and date
  (an "eyebrow"), or a date stamp and footer the reader doesn't need. Start
  with the title.
  flagged: "Atlas · 20 November 2026"
  A label that categorizes the title under it ("Architecture review · Findings") is the same pattern, since it reads as a byline.
  flagged: "Architecture review · Preliminary findings"
- **Questions to the reader as bullet points.** Ask them in a sentence or
  two of prose.
  flagged: "- Is there anything you expected that isn't on this list?"
- **Opening on "you" in a scene** without setting it up puts the reader in a
  role they may not hold. Open with "Suppose you are…" so the role is an
  invitation, tell the scene in "you", and keep the closing scene in the
  same person.
  flagged: "You ask the agent to read the design doc…"
  rewrite: "Suppose you are an engineer at an organization with something to protect, and you sit down with a coding agent to build a feature from a design doc."
- **Opening on "the demos"** or another contrast with how things look
  elsewhere. Start in the scene the post is about, and end the opening on
  what the post shows is possible.
  flagged: "The demos show a coding agent with free rein over a fresh project, turning a prompt into a working feature in a few minutes."
  rewrite: "Suppose you are an engineer at an organization with something to protect, and you sit down with a coding agent to build a feature from a design doc."
- **Teaser descriptions** that promise a demonstration ("One small feature,
  followed through both tools, shows…"). Say what the post compares and
  what it covers.
  flagged: "One small feature, followed through both tools, shows what that costs."
- **Wordy titles.** Cut every word the title still works without.
  flagged: "Engineering after hand-written code"
  rewrite: "After hand-written code"
- **"What I ran into" titles** and their kin ("What I learned"). They
  announce that the post holds findings instead of giving one. Put the
  finding itself in the title.
  flagged: "What I ran into building an Arc-style tab switcher as a Chrome extension"
  rewrite: "I made an Arc-style tab switcher for Chrome, and since chrome.commands doesn't tell you when Cmd is released, the overlay listens for it inside the page"
  lint: teaser-title
- **Clean-cut one-line hooks**, in a title or an opening line: a tidy "I
  made X for Y", or a flat news fact ("X shuts down on <date>, and…") put
  first for effect. They read as copy. Start the way a person would say it,
  from their own situation.
  flagged: "I made an Arc-style recent-tab switcher for Firefox and Zen"
  rewrite: "Coming from Arc, I made a Cmd+J recent-tab switcher that works in Firefox and Zen"
  flagged: "Arc shuts down on December 22, and its tab switcher was the main thing keeping me on it."
  rewrite: "I was one of the last few people holding onto Arc even after The Browser Company stopped developing it, because I couldn't give up Cmd+J to jump between my recent tabs."
- **Status text that narrates what a control already says.** In UI copy, a
  line beside a button that restates its state. Let the button carry the
  state, and keep labels short and literal.
  flagged: "Edits since R1684, not published"
  rewrite: "Update review"
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
- **One-word bold label openers** ("**Purpose.**") that tag a paragraph
  like a form field. Run-in leads belong to a list of parts; elsewhere, open
  with the sentence itself.
  flagged: "**Purpose.** TSM Caddie is a companion for The Scoring Method, on the course and in practice."
  flagged: "**What it means.**"
- **Bold for emphasis.** In a long document for a busy reader, bold marks the
  sentences that carry the gist, so reading only the bold gives the point of
  each section. Bold whole sentences, about one per paragraph or item, and
  never a word or phrase for emphasis. Run-in IDs and labels that tell a
  skimmer nothing ("**12. F-1.2-04**") stay plain.
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
  flagged: "The vendor is high-value and a dependency. The contract terms on ownership, history access and exit are part of the platform's risk."
  rewrite: "The client relies on the vendor for most of its code and the base platform, so if the relationship ends, the client keeps only what the contract gives it on code ownership, history and exit."
- **Section wrap-ups that add a new mechanism.** A closing paragraph
  summarizes what the section's pieces achieve together.
  flagged: "Review also covers the write path out of the box…"
  rewrite: "With changes structured, agents taking the first passes, and risk scores routing attention, the firehose becomes manageable."
- **Sentences that trail off** without finishing their thought. Finish them.
- **Weak endings** that gesture at earliness or open problems. End on a
  concrete claim, ideally one that closes a loop the opening started.
- **A call to action Joel didn't ask for.** Propose one; drop it if he isn't
  sold.
- **Every list item built as an "X, Y, and Z" triple.** Read aloud, a list
  where each item has three clauses sounds templated. Keep the one or two
  facts that matter and leave the rest to the detail.
  flagged: "The database server, networking and backups are outside Terraform, changes are applied from laptops, and nothing in code recovers the platform in another region."
  rewrite: "The database server and networking are outside Terraform, and nothing in code recovers the platform in another region."
- **Templated verdict blocks.** A repeated "what it means" paragraph after
  each section that restates the bullets in the same shape. Give a concrete
  consequence for a person, or cut it.
  flagged: "Nobody can show from code what the database and network look like, a bad apply reaches every tenant at once, and recovery depends on steps that have not been tested."
  rewrite: "A bad apply from one laptop can change every tenant at once, and if the database server is lost, nobody has tested the way back."
- **Answers that don't answer.** When a question has a yes or no answer,
  give it first in the sentence, then the facts.
  flagged: "Can we fail over to another region? The code declares one region per workspace,"
  rewrite: "Not from anything in code, which declares one region per workspace,"
- **A bullet that tacks on an unrelated point.** Give the second point its
  own bullet.
  flagged: "Offboarding has no procedure for a customer's data"

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
- **A document as the one who did the work** ("this review read", "the review
  couldn't see", "the report found"). A review or report doesn't read,
  see or check anything; a person did. Say who did it, usually "I", or state
  the fact about the code ("Running state isn't in the code").
  flagged: "This review read every repo at the pinned commits on 18 November 2026, without access to Azure or any running system."
  rewrite: "I worked from the code alone, going through every repo as it stood on November 18. I couldn't see Azure or anything running, so where production differs from what I describe, production is right."
  flagged: "The review couldn't see running state, such as resources made by hand"
  rewrite: "Running state isn't in the code, such as resources made by hand"
  lint: document-actor
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
- **Citing the research behind the post** ("in our test", "we saw both"). The
  reader wasn't there, and Joel writes as "I", not a research "we". State
  what the research found as the fact it is. "We" stays fine for walkthrough
  steps the reader follows.
  flagged: "In our test the endpoint's pull request ran CI twice on the same commit"
  rewrite: "Sometimes the endpoint's pull request can run CI twice on the same commit"
  flagged: "We saw both in our test."
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
- **Stating the default** as if it were a selling point ("free on every
  plan"). Readers assume a feature is free unless told it's paid.
  flagged: "It's free on every plan, and a stack merges in one step."
- **Over-specific mechanics that misstate the idea.**
  flagged: "three agents, three boxes"
  rewrite: "an engineer whose agents need more compute gets more boxes."
