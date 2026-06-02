---
name: clip
version: 1.2.0
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
prevents shell expansion of backticks, `$`, etc. inside the content.

Run this with `dangerouslyDisableSandbox: true`. The command sandbox blocks the
clipboard syscall **silently**: `pbcopy` is prevented from writing but still
exits 0, so a blind `echo "Copied"` reports false success. Disable the sandbox
and verify with `pbpaste` instead of trusting the exit code:

```
pbcopy <<'CLIPEOF'
<exact text to copy, preserving paragraph breaks>
CLIPEOF
echo "--- exit: $? ---"; pbpaste | head -1
```

Confirm the `pbpaste` output matches the start of what you copied, then tell the
user in one short line that the text is on the clipboard.

## Platform fallbacks

The heredoc-to-stdin pattern is identical on every platform; only the command
changes:

- **macOS (default):** `pbcopy`
- **Linux Wayland:** `wl-copy`
- **Linux X11:** `xclip -selection clipboard` or `xsel --clipboard --input`
- **Windows (WSL / Git Bash):** `clip.exe`

Detect via `uname` if the platform is unclear.

## Notes

- Always run the copy with `dangerouslyDisableSandbox: true`. The sandbox blocks
  the clipboard write silently (no error, exit 0), so without this the copy
  appears to succeed but nothing lands on the clipboard. The user can allow
  clipboard writes via `/sandbox` to avoid the per-command override.
- If the content contains the literal string `CLIPEOF`, switch to a different
  unique delimiter (e.g. `CLIPEOF_2`).
- Never echo the full text back to the user as part of confirmation; they
  already have it in the conversation. Just confirm the copy succeeded.
- Do not write the text to a file as an intermediate step. The whole point of
  this skill is to keep the copy atomic and side-effect-free.
