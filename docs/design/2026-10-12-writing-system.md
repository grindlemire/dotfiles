# Writing system

Joel's writing tools grew one at a time: the humanizer, improve-writing,
marketer, the blog-post skill with its `slop.md`, and redline. They work, but
they are wired together by file paths written inside each skill. This doc
turns them into one system with a clear owner for each piece, so a change to
how slop is handled, or a new redline button, is an edit in one place.

Everything lives in `dotfiles` for now. The layout keeps Joel's rules apart
from the skills, so the skills can move into their own installable repo later
without a redesign.

## Today

- `slop.md` lives inside `skills/blog-post/`, and humanizer, improve-writing,
  marketer and blog-post each name `~/.claude/skills/blog-post/slop.md`
  directly.
- Joel's prose voice is written into blog-post step 2 and its humanizer
  overrides, so the humanizer and improve-writing can't use it.
- redline hard-codes the `slop` label: its color, its button, and the
  instruction `redline wait` prints (which names Joel inside a generic tool).
  What the agent does with a flag is in the blog-post skill.
- Nothing checks that a flagged pattern was recorded, or that the skills
  still catch patterns they used to.

## Layout

```
dotfiles/
  writing/                  Joel's voice pack (data, no procedures)
    voice.md                how Joel writes
    slop.md                 every pattern Joel has flagged
    lint.toml               the mechanical subset of slop.md
    redline.toml            redline's actions (slop, polish)
    lint                    the lint command
    evals/                  eval runner; cases come from slop.md
  skills/
    humanizer/              general AI-pattern rules
    slop/        (new)      slop pass, flag handling, recording
    polish/      (new)      rewrite a selection in the surrounding voice
    blog-post/              the post process; no rules of its own
    improve-writing/        editing passes
    marketer/               marketing drafts
```

`skills/install.sh` also links `~/.config/writing` to `dotfiles/writing`, the
way marketer reads `~/.config/marketer/`. Skills find the voice pack at
`~/.config/writing/` and never at a path inside another skill.

**The fallback rule.** A skill that reads the voice pack works without it: no
`voice.md` means "match the surrounding text", and no `slop.md` means the
humanizer's general rules only. This is what lets someone else use a skill
with their own pack, or none, once the skills are extracted.

## The voice pack

**`voice.md`** holds what blog-post step 2 lists today (first person for
opinions, sentences that carry their reason, "However," pivots, bold run-in
leads, no invented anecdotes) plus the three humanizer overrides from step 3.
blog-post keeps the process: grill, draft, slop pass, fact pass, hand back.
GitStack's `marketing/brain/voice.md` stays where it is, since it covers
product voice for one project; its first line points at `voice.md` for the
base prose rules.

**`slop.md`** keeps its sections (Words, Constructions, Rhythm, Structure,
Claims and attribution) and its readable bullets. Each entry gains optional
indented fields:

```markdown
- **Colons as emphasis separators.** A colon may introduce a list. Nowhere
  else.
  flagged: "The shape is the same either way: root inside, and a gated network."
  rewrite: "Either way the agent gets root inside the machine and a gated network around it."
  from: <post slug>, 2026-09
  lint: colon-emphasis
```

- `flagged` and `rewrite` are exact lines. An entry with both becomes two
  eval cases (see Evals).
- `from` is the post and month, so a pattern can be traced to where Joel
  flagged it.
- `lint` names the `lint.toml` rule that catches it mechanically, if any.

Most existing entries already quote a flagged line and its rewrite inline;
the migration moves those quotes into the fields and leaves the rest as
rule-only entries.

**`lint.toml`** holds only what a regex can catch without false alarms:

```toml
[[rule]]
id = "em-dash"
pattern = "—|–|--"
message = "Em dash. Use a period, comma, or parentheses."

[[rule]]
id = "real"
pattern = "\\b(real|truly|simply|genuinely)\\b"
message = "Intensifier (slop.md: Words, \"real\")."
```

## Skills

Each skill does one job, and every surface (the CLI, redline, marketer)
reaches that job through the skill, never through its own copy of the
instructions.

**humanizer** stays the general list of AI writing patterns, with its
origin credit. With a voice pack it writes in `voice.md`'s voice and
finishes with the slop skill's check, so `/humanizer` on its own still
catches Joel's patterns.

**slop** owns `slop.md` and has five steps, each usable on its own:

- **Check.** Report hits without changing anything; the evals use this.
- **Pass.** Run `~/.config/writing/lint` on the file, then the humanizer, then
  check every paragraph against every `slop.md` entry. Each hit is rewritten
  in `voice.md`'s voice. Done when lint is clean and every entry has been
  checked against every paragraph. blog-post step 3, improve-writing pass 4
  and marketer's self-check all call this mode.
- **Flag.** Joel marked a phrase as slop (a redline `slop` thread, or in
  chat). Rewrite the whole passage it sits in, reply with the before and
  after, record the pattern, then resolve. A reopened flag means the rewrite
  missed: fix it and update the entry, so every recorded rewrite is one Joel
  accepted.
- **Record.** Add or update the entry with `flagged`, `rewrite` and `from`,
  in the section it fits. When a regex can catch it safely, add a `lint.toml`
  rule and link it with `lint`.
- **Commit.** Land the session's recorded entries (below).

Recording edits `writing/slop.md` in the main `dotfiles` checkout, through
the `~/.config/writing` link. When the post is done, the slop skill commits
the session's entries as one review titled `slop: patterns from <post>` and
lands it. `dotfiles` deploys nothing, so the land is safe to make without
asking.

**polish** rewrites a selection so it says the same idea in the voice of the
paragraphs around it. The selection may be finished prose or a rough note
Joel typed. Inputs are the selection, the block it sits in, and the blocks
on either side. It writes the rewrite in `voice.md`'s voice, then runs the
slop pass on just that passage. The rewrite keeps every claim in the
selection and adds none: a rough note that lacks a claim the voice wants
gets a `[NEEDS: ...]` placeholder, never an invented detail.

**blog-post** keeps the process and drops the rules it held. Step 2 points at
`voice.md`, step 3 calls the slop pass, and step 5's redline loop says to
handle each thread with the skill its action names (below).

**improve-writing** and **marketer** replace their `slop.md` paths with a
call to the slop pass.

## redline actions

redline stays a generic tool: it knows how to show, send and track an
action, and the voice pack says what each action is. The `slop` label turns
into the first configured action, and polish is the second.

redline reads `--actions <file>`, defaulting to
`~/.config/redline/actions.toml`; `install.sh` links that to
`writing/redline.toml`. With no file, redline offers plain comments only.

```toml
[[action]]
name = "slop"
label = "Slop"
key = "mod+shift+s"
color = "#7c3aed"
send = "batch"        # waits for Send batch, like a comment
note = "optional"     # none | optional | required
skill = "slop"

[[action]]
name = "polish"
label = "Polish"
key = "mod+shift+p"
color = "#0e7490"
send = "now"          # goes to the agent at once
note = "none"
revert = true
skill = "polish"
```

`skill` names the skill that does the work, and that skill is the only
place its instructions live. `instruction` is for an action with no skill
behind it (someone's own "tighten" button, say): one sentence the agent gets
in place of a skill.

**What changes in redline:**

- The selection toolbar shows Comment plus one button per action, with its
  key. The chip and the wavy highlight take the action's color, so the
  violet slop styling becomes data.
- A thread stores its action name where it stores `label` today. Threads
  written by the slop-flag build still read, since `label = "slop"` matches
  the action of that name.
- `redline wait` prints `[<name>]` per thread, and for each action present in
  the batch, one header line: `[<name>] threads: use the <skill> skill`, or
  the action's `instruction` when it has no skill. The hard-coded slop text
  and Joel's name leave the binary.
- An action with `send = "now"` skips the draft state. Selecting inside an
  open editor commits the editor first, so a rough note Joel just typed is
  on disk before the agent reads it. The block shows a working state until
  the agent replies.

**Revert.** For an action with `revert = true`, redline saves the whole file
when it sends the thread and again when the agent replies. The thread shows
the before and after with a Revert button. Revert finds the agent's new text
in the current file and puts the old text back, if that new text still
appears exactly once; otherwise it says the block has changed since and does
nothing. Revert is an edit like any other, so it's logged to the thread and
the agent sees it on the next batch.

**Latency.** Polish goes through the agent rather than redline calling a
model itself, because the agent already holds the skills and the voice pack.
A direct call would be a second copy of the rules that drifts. The cost is
about 10 to 30 seconds per polish.

## Checks

**Lint.** `writing/lint <file>...` is one Python file using only the
standard library (`tomllib`). It skips frontmatter, code fences and inline
code, prints `file:line: id: message` per hit, and exits non-zero on any.
The slop pass runs it first, so the model spends its attention on what a
regex can't catch.

**Evals.** `writing/evals/run` builds its cases from `slop.md`:

- Each `flagged` line, placed in a neutral paragraph, must be reported by
  the slop pass as a hit on its own entry.
- Each `rewrite` line must pass clean. This catches the pass growing so
  strict it flags Joel's accepted prose.

It runs the pass through `claude -p` and prints a table of misses and false
hits. Joel runs it by hand after editing a skill or `slop.md`; it isn't in
any automatic path because each run costs tokens.

**Flag audit (later).** `redline flags --since <date>` lists resolved slop
threads with their quotes. The slop skill can compare that against `slop.md`
`from` fields to find flags that were fixed but never recorded. This waits
until the rest is in use, since it's only worth building if flags actually
go unrecorded.

## Order of work

1. **Voice pack.** Create `writing/`, move `slop.md` there with its fields
   migrated, extract `voice.md` from blog-post, add the `~/.config/writing`
   link to `install.sh`, and repoint the four skills. Joel's three
   uncommitted edits to humanizer, improve-writing and marketer touch the
   same lines, so they land first or get folded into this step with his ok.
2. **Skills.** Add slop and polish; slim blog-post, improve-writing and
   marketer to call them.
3. **Lint.** `lint` and `lint.toml`, seeded from the mechanical entries.
4. **redline.** Land the slop-flag stack (R20-R23), then add actions in
   place of the hard-coded label, then polish with `send = "now"` and
   Revert.
5. **Evals.**
6. **Flag audit**, if flags turn out to slip through.

## Extracting later

When the skills move to their own repo, `skills/{humanizer,slop,polish,
blog-post}` move as they are, packaged as one plugin each, and `writing/`
stays in `dotfiles` as Joel's pack. Two things change then:

- Installed plugin skills are named `<plugin>:<skill>`, so the `skill`
  fields in `redline.toml` and the cross-references between skills take the
  new names. Joel can keep symlinking the folders to keep the bare names.
- The fallback rule is what makes the extracted skills useful to someone
  without Joel's pack, so it should be tested then with
  `~/.config/writing` absent.
