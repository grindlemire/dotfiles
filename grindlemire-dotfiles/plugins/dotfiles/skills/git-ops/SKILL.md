---
name: git-ops
description: Perform git operations like add, commit, push, and pull using dotfile aliases. Use when the user wants to stage files, create commits, push to remote, or pull changes.
allowed-tools: Bash
---

# Git Operations Commands

This skill provides access to custom git operation commands from the dotfiles.

## Available Commands

### `gadd` - Git Add All
Stages all changes in the repository.

```bash
gadd
```

Equivalent to `git add .`

### `gcommit` - Git Commit
Creates a commit with an optional message. If no message is provided, it generates one using Claude AI.

```bash
gcommit                    # Auto-generates commit message with AI
gcommit "message"          # Uses provided message
gcommit -m "message"       # Alternative syntax with -m flag
```

The AI-generated messages are concise and descriptive based on the staged diff.

### `gpush` - Git Push
Pushes the current branch to origin.

```bash
gpush              # Pushes current branch
gpush branch-name  # Pushes specified branch
```

### `gpull` - Git Pull
Pulls the current branch from origin.

```bash
gpull              # Pulls current branch
gpull branch-name  # Pulls specified branch
```

## Typical Workflow

1. Make changes to files
2. Run `gs` to see what changed
3. Run `gdiff` to review changes
4. Run `gadd` to stage all changes
5. Run `gdiffs` to review staged changes
6. Run `gcommit` or `gcommit "message"` to commit
7. Run `gpush` to push to remote

## Notes

- `gcommit` without a message uses AI to generate a commit message
- Always review staged changes with `gdiffs` before committing
- Use the git-info skill commands (`gs`, `gdiff`, `gdiffs`) to check status
