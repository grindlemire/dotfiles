---
name: worktree
description: Manage git worktrees for working on multiple branches simultaneously. Use when the user wants to create, list, switch between, or delete git worktrees.
allowed-tools: Bash
---

# Git Worktree Management

This skill provides access to the unified `wt` command for managing git worktrees. Worktrees allow you to have multiple branches checked out simultaneously in different directories.

## Main Command: `wt`

The `wt` command is a unified interface with subcommands for all worktree operations.

## Listing Worktrees

### `wt` or `wt list` or `wt ls` or `wt l`
Lists all worktrees in the repository.

```bash
wt              # Basic list (default)
wt -v           # Verbose: shows path, commit subject, ahead/behind
wt -vv          # Very verbose: includes symlink details
wt list         # Explicit list command
wt ls           # Short alias
```

Output shows:
- Branch name (color-coded: green=main, yellow=other, red=detached)
- Commit hash
- Dirty status (if uncommitted changes)
- Symlink count

## Creating Worktrees

### `wt create <branch>` or `wt c <branch>`
Creates a new worktree or switches to an existing one for the specified branch.

```bash
wt c feature-branch           # Create/switch to worktree for feature-branch
wt create feature-branch      # Same as above
wt c feature-x "npm test"     # Create worktree and run command in it
```

Features:
- Creates the branch if it doesn't exist
- Automatically syncs ignored files via symlinks from main worktree
- Can optionally run a command in the new worktree directory

Worktrees are created in a `.worktrees` directory at the repository root.

## Deleting Worktrees

### `wt delete <branch>` or `wt d <branch>` or `wt rm <branch>`
Deletes a worktree after verifying the branch is merged.

```bash
wt d feature-branch           # Delete worktree (checks if merged first)
wt delete feature-branch      # Same as above
wt rm feature-branch          # Same as above
wt d feature-branch -f        # Force delete (skip merge check)
wt d feature-branch --force   # Same as above
```

Safety features:
- Checks if branch is merged into main/master before deleting
- Handles both regular merges and squash merges
- Auto-navigates to repo root if you're currently in the worktree being deleted
- Use `-f` or `--force` to bypass merge check

## Typical Workflow

1. Start a new feature:
   ```bash
   wt c my-feature
   ```

2. Work on the feature in the new worktree directory

3. Check all worktrees:
   ```bash
   wt -v
   ```

4. Switch between worktrees by navigating to their directories

5. When done and merged, delete the worktree:
   ```bash
   wt d my-feature
   ```

## Notes

- Worktrees share the same `.git` directory, so commits are shared
- The `.worktrees` directory contains all worktrees
- Ignored files (from .gitignore) are automatically symlinked from main worktree
- Use `.wtignore` file to exclude directories from symlink sync
