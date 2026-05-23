---
name: clip
version: 1.1.0
description: |
  Copy text to the macOS clipboard via stdin so paragraph breaks and literal
  newlines survive (no terminal line-wrap mangling, no temp files). Triggered
  by the /clip slash command or when the user says "copy to clipboard", "copy
  this to my clipboard", "put that on the clipboard", "pbcopy this", or
  otherwise asks to get a chunk of conversation text onto their clipboard for
  manual editing or pasting elsewhere.
allowed-tools:
  - Bash
---

# clip

## When to use

Trigger when the user runs `/clip` or asks to copy text to their clipboard.
Common phrasings:

- "/clip"
- "copy to clipboard"
- "copy this to my clipboard"
- "put it on the clipboard"
- "pbcopy this"

## What text to copy

Unless the user specifies otherwise, copy the most recently proposed chunk of
text from the assistant (e.g., a draft message, a code snippet, a response
they're about to send). If `/clip <text>` is invoked with explicit text after
it, copy that text. If ambiguous, ask which block.

## Procedure

Pipe the text directly to `pbcopy` via a quoted heredoc in a single `Bash`
call. No temp file, no cleanup step. The single-quoted `'CLIPEOF'` delimiter
prevents shell expansion of backticks, `$`, etc. inside the content:

```
pbcopy <<'CLIPEOF'
<exact text to copy, preserving paragraph breaks>
CLIPEOF
echo "Copied to clipboard"
```

Then confirm to the user in one short line that the text is on the clipboard.

## Platform fallbacks

The heredoc-to-stdin pattern is identical on every platform; only the command
changes:

- **macOS (default):** `pbcopy`
- **Linux Wayland:** `wl-copy`
- **Linux X11:** `xclip -selection clipboard` or `xsel --clipboard --input`
- **Windows (WSL / Git Bash):** `clip.exe`

Detect via `uname` if the platform is unclear.

## Notes

- If `pbcopy` fails inside the sandbox with "Operation not permitted",
  re-run the same command with `dangerouslyDisableSandbox: true`. This is
  expected; the sandbox blocks clipboard syscalls.
- If the content contains the literal string `CLIPEOF`, switch to a different
  unique delimiter (e.g. `CLIPEOF_2`).
- Never echo the full text back to the user as part of confirmation; they
  already have it in the conversation. Just confirm the copy succeeded.
- Do not write the text to a file as an intermediate step. The whole point of
  this skill is to keep the copy atomic and side-effect-free.
