---
name: research
description: Use when the user wants to record AI research interactions (prompts, answers, context URLs) into organized markdown files. Triggered by /research command or when user mentions logging research, saving AI conversations, or organizing prompt/answer pairs.
---

# Research Logger

## Overview

Organize AI research interactions into structured markdown files. Each file contains a context table (URLs that were in the AI's context window) followed by prompt/answer pairs, all in clean markdown.

## Workflow

1. **File Selection**: Ask user to choose an existing `.md` file from the target directory or name a new one
2. **Recording Loop**: Accept entries as `PROMPT ... ANSWER ...` or `CONTEXT ...` and persist them
3. **File Structure**: Context table always stays at the top; Q&A entries append below

## Step 1: File Selection

When invoked as `/research [optional-directory]`:

- If a directory argument is provided, use that directory. Otherwise use the current working directory.
- Use Glob to find all `*.md` files in the target directory (non-recursive).
- Present the user with AskUserQuestion listing the found markdown files plus an option to create a new file.
- If user picks "Create new file", ask for a filename (append `.md` if they omit it).
- If the chosen file already exists, read it to preserve existing content.

## Step 2: Recording Entries

After file selection, tell the user they can now provide entries. Accept input in these formats:

### PROMPT / ANSWER

User provides:
```
PROMPT <their prompt text>
ANSWER <the AI's answer text>
```

The prompt and answer may be multi-line. The `PROMPT` keyword starts the prompt section and `ANSWER` keyword starts the answer section. Everything between `PROMPT` and `ANSWER` is the prompt. Everything after `ANSWER` until the end of the message is the answer.

### CONTEXT

User provides:
```
CONTEXT <url>
```

Adds a URL to the context table. The URL is a file path or web URL that was in the AI's context window during the research.

### Processing

When the user provides an entry:

1. Read the current file content (if any exists)
2. Parse existing content to identify the context table and Q&A sections
3. For CONTEXT entries: add the URL to the context table
4. For PROMPT/ANSWER entries: append a new Q&A section after all existing content
5. Write the updated file

## File Format

The output markdown file follows this structure:

```markdown
# Research: <filename without extension>

## Context

| # | Source |
|---|--------|
| 1 | `<url-or-path>` |
| 2 | `<url-or-path>` |

---

## Q&A

### Q1

**Prompt:**

<prompt text>

**Answer:**

<answer text>

---

### Q2

**Prompt:**

<prompt text>

**Answer:**

<answer text>

---
```

### Format Rules

- The `## Context` table is always present, even if empty (show just the header row)
- Context URLs are displayed in backticks (inline code) in the table
- Each Q&A entry gets an incrementing header (`### Q1`, `### Q2`, etc.)
- A horizontal rule (`---`) separates each Q&A entry
- Prompt and answer text are preserved exactly as provided (including line breaks and formatting)

## Step 3: Persisting Changes

After each entry:

1. Read the existing file to get current state
2. Parse the context table rows and Q&A entries
3. Add the new entry (context row or Q&A pair)
4. Regenerate the full file using the format above
5. Write the file using the Write tool
6. Confirm to the user what was added (e.g., "Added Q3 to research.md" or "Added context URL #4")

When regenerating, always rebuild from parsed data to keep formatting consistent.

## Parsing Existing Files

To parse a file that already has content:

- **Context table**: Look for rows matching `| N | \`...\` |` pattern between `## Context` and the first `---` after the table
- **Q&A entries**: Look for `### QN` headers. Content between `**Prompt:**` and `**Answer:**` is the prompt; content after `**Answer:**` until the next `---` or `### QN` is the answer

If the file exists but doesn't match the expected format (e.g., user chose a pre-existing markdown file), prepend the research structure at the top and leave existing content at the bottom under a `## Previous Content` section.

## Common Mistakes

- Forgetting to re-read the file before each write (another tool or the user may have edited it)
- Numbering Q&A entries from 0 instead of 1
- Losing existing content when regenerating the file
- Not handling multi-line prompts or answers (preserve all whitespace and formatting)
