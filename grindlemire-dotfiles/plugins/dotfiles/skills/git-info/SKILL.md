---
name: git-info
description: View git repository status, history, and diffs using dotfile aliases. Use when the user asks about git status, commit history, diffs, or changes in the repository.
allowed-tools: Bash
---

# Git Information Commands

This skill provides access to custom git information commands from the dotfiles.

## Available Commands

### `gs` - Git Status (Short)
Shows a compact git status with branch info.

```bash
gs
```

Output format: Short status with branch indicator (`-sb` flags).

### `glog` - Git Log (Pretty)
Shows a formatted git log with graph visualization.

```bash
glog        # Shows last 10 commits by default
glog 20     # Shows last 20 commits
```

Output includes:
- Commit graph with branch visualization
- Abbreviated commit hash (yellow)
- Commit message
- Author name (green)
- Relative time (blue)

### `gdiff` - Git Diff (Unstaged)
Shows diff of unstaged changes with syntax highlighting.

```bash
gdiff
```

Uses delta or bat for syntax highlighting if available, falls back to less.

### `gdiffs` - Git Diff (Staged)
Shows diff of staged changes with syntax highlighting.

```bash
gdiffs
```

Same output format as `gdiff` but for staged changes only.

## When to Use

- Use `gs` to quickly check repository state
- Use `glog` to see recent commit history
- Use `gdiff` to review unstaged changes before staging
- Use `gdiffs` to review staged changes before committing
