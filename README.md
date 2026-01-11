# dotfiles

Personal shell configuration and utility scripts

## Setup

Place this repository in `~/dotfiles` and symlink the main configuration:

```bash
ln -s ~/dotfiles/zshrc.sh ~/.zshrc
```

## Configuration Files

### Core Shell Configuration

- **`zshrc.sh`** - Main zsh configuration with aliases, functions, and shell settings
- **`zprofile.sh`** - Sources local zprofile configuration for startup scripts

### Platform-Specific

- **`macbook.sh`** - macOS-specific settings including key remapping (Caps Lock ↔ Escape, Escape ↔ Tilde)

### Utility Modules

- **`docker.sh`** - Docker and docker-compose shortcuts and utilities
- **`virtualenv.sh`** - Python virtual environment management
- **`worktree.sh`** - Git worktree utilities for managing multiple branches

## Key Features

### Aliases & Shortcuts

- `ll`, `la`, `lt`, `lla` - Enhanced ls variations
- `cap` & `check` - Capture and check exit codes
- `lc` - Count lines in Go/templ files
- `to_gif` - Convert videos to GIF format

### Git Utilities

- `gcommit [message]` - Add all and commit (auto-timestamps if no message)
- `gpush/gpull [branch]` - Push/pull current or specified branch
- `gprune` - Delete merged branches (use `--dry` for preview)
- `grevert` - Hard reset to previous commit
- `grollback` - Revert last commit
- `clone <user/repo>` - Clone from GitHub
- `git_sign_init <key>` - Setup SSH commit signing

### Docker Shortcuts

- `dssh <container>` - SSH into container
- `dexec <container> <cmd>` - Execute command in container
- `dls`, `dstart`, `dstop`, `drm` - Container management
- `dlog <container>` - Follow container logs
- `dcup`, `dcstop`, `dcrm`, `dclog` - Docker Compose equivalents

### Python Virtual Environments

- `venv` - Create/activate Python 2 virtualenv
- `venv3` - Create/activate Python 3 virtualenv
- `vend` - Deactivate and restore PYTHONPATH

### Git Worktree Management

- `wt` - Unified worktree command (or use individual commands below)
- `wtc <branch>` - Create/switch to worktree (symlinks gitignored files automatically)
- `wtd [-f] [branch|path]` - Delete worktree (defaults to current, `-f` to force unmerged)
- `wtl [-v|-vv]` - List worktrees (`-v` for details, `-vv` to show symlinks)
- `cc [branch]` - Create worktree and launch Claude Code in it

**Symlink sync**: When creating a worktree, gitignored files (e.g., `.env`) are symlinked from the main worktree. Build artifacts like `node_modules`, `vendor`, `dist`, etc. are excluded by default.

**Custom exclusions**: Create `.wtignore` in repo root with patterns to exclude from symlinking:
```
# One pattern per line, supports globs
*.log
my-large-cache/
```

### Shell Enhancement

- Vi mode with custom cursor indicators
- Enhanced history search with ↑/↓ arrows
- Colored prompts showing user, directory, and git branch
- Terminal window title updates with current directory

### Custom Navigation

- `myip` - Show local IP address

## Environment Integration

The configuration automatically sources available modules and handles missing files gracefully. Create `local-zshrc.sh` for machine-specific settings that shouldn't be tracked in git.
