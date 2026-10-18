#!/usr/bin/env bash
# Symlink every skill in this directory into Claude and Codex skill dirs.
# Existing symlinks are replaced; existing real directories are left alone (with a warning).
# Skills listed in disabled.txt are not linked, and their existing links are removed.
# Also links the writing voice pack and the Claude Code status line.
# -n / --dry-run prints what would change without touching anything.

set -euo pipefail

usage() {
  echo "usage: $0 [-n|--dry-run] [all|claude|codex]" >&2
  exit 2
}

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="all"
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    -n | --dry-run) DRY_RUN=1 ;;
    all | claude | codex) TARGET="$arg" ;;
    *) usage ;;
  esac
done

# act runs a command that changes something, unless this is a dry run;
# say reports it either way.
act() {
  [ "$DRY_RUN" = 1 ] || "$@"
}
say() {
  if [ "$DRY_RUN" = 1 ]; then
    echo "(dry run) $*"
  else
    echo "$*"
  fi
}

case "$TARGET" in
  all)
    DEST_DIRS=("${HOME}/.claude/skills" "${HOME}/.agents/skills")
    ;;
  claude)
    DEST_DIRS=("${HOME}/.claude/skills")
    ;;
  codex)
    DEST_DIRS=("${HOME}/.agents/skills")
    ;;
esac

link_skill() {
  local skill_path="$1"
  local dest_dir="$2"
  local skill
  local target

  skill="$(basename "$skill_path")"
  target="$dest_dir/$skill"

  if [ -L "$target" ]; then
    act rm "$target"
  elif [ -e "$target" ]; then
    say "skip: $target exists and is not a symlink (remove it manually to replace)"
    return
  fi

  act ln -s "$skill_path" "$target"
  say "linked: $target"
}

disabled=" "
if [ -f "$SRC_DIR/disabled.txt" ]; then
  while read -r name _; do
    case "$name" in "" | \#*) continue ;; esac
    if [ ! -d "$SRC_DIR/$name" ]; then
      echo "warn: disabled skill '$name' not found in $SRC_DIR" >&2
    fi
    disabled="$disabled$name "
  done <"$SRC_DIR/disabled.txt"
fi

# Remove the link to a disabled skill. Only a link that resolves to this
# skill is removed, so a same-named skill installed some other way survives.
unlink_skill() {
  local skill_path="$1"
  local dest_dir="$2"
  local target

  target="$dest_dir/$(basename "$skill_path")"
  [ -L "$target" ] || return 0
  if [ "$(cd "$target" 2>/dev/null && pwd -P)" = "$(cd "$skill_path" && pwd -P)" ]; then
    act rm "$target"
    say "unlinked (disabled): $target"
  fi
}

install_skill() {
  case "$disabled" in
    *" $(basename "$1") "*) unlink_skill "$1" "$2" ;;
    *) link_skill "$1" "$2" ;;
  esac
}

for dest_dir in "${DEST_DIRS[@]}"; do
  act mkdir -p "$dest_dir"
done

for skill_path in "$SRC_DIR"/*/; do
  for dest_dir in "${DEST_DIRS[@]}"; do
    install_skill "$skill_path" "$dest_dir"
  done
done

# The writing voice pack (dotfiles/writing): skills read it at
# ~/.config/writing, and redline reads its actions from
# ~/.config/redline/actions.toml.
link_config() {
  local src="$1"
  local target="$2"
  act mkdir -p "$(dirname "$target")"
  if [ -L "$target" ]; then
    act rm "$target"
  elif [ -e "$target" ]; then
    say "skip: $target exists and is not a symlink (remove it manually to replace)"
    return
  fi
  act ln -s "$src" "$target"
  say "linked: $target"
}
WRITING_DIR="$(cd "$SRC_DIR/../writing" && pwd)"
link_config "$WRITING_DIR" "${HOME}/.config/writing"
link_config "$WRITING_DIR/redline.toml" "${HOME}/.config/redline/actions.toml"

# The Claude Code status line (dotfiles/claude/statusline.sh), and the
# statusLine entry in settings.json that runs it. Only that one key is set;
# the rest of settings.json is left as it is.
if [ "$TARGET" = "all" ] || [ "$TARGET" = "claude" ]; then
  link_config "$(cd "$SRC_DIR/../claude" && pwd)/statusline.sh" "${HOME}/.claude/statusline.sh"

  SETTINGS="${HOME}/.claude/settings.json"
  STATUS_LINE='{"type":"command","command":"bash ~/.claude/statusline.sh"}'
  if ! jq -e --argjson s "$STATUS_LINE" '.statusLine == $s' "$SETTINGS" >/dev/null 2>&1; then
    say "set statusLine in $SETTINGS"
    if [ "$DRY_RUN" != 1 ]; then
      updated=$( { cat "$SETTINGS" 2>/dev/null || echo '{}'; } | jq --argjson s "$STATUS_LINE" '.statusLine = $s')
      # Write through rather than mv, so a symlinked settings.json stays a symlink.
      printf '%s\n' "$updated" >"$SETTINGS"
    fi
  fi
fi

# Trial plugins — only for the test sandboxes, never the regular ~/.claude or
# ~/.codex installs. Installed from the author's own marketplace so they track
# upstream HEAD (the claude-plugins-official entry pins an old commit).
# `tc`  (CLAUDE_CONFIG_DIR=~/.claude-test)
# `tcx` (CODEX_HOME=~/.codex-test)
TRIAL_MARKETPLACE_REPO="mattpocock/skills"
TRIAL_MARKETPLACE="mattpocock"
TRIAL_PLUGIN="mattpocock-skills@${TRIAL_MARKETPLACE}"

if { [ "$TARGET" = "all" ] || [ "$TARGET" = "claude" ]; } && command -v claude >/dev/null; then
  if ! CLAUDE_CONFIG_DIR="${HOME}/.claude-test" claude plugin list 2>/dev/null | grep -q "$TRIAL_PLUGIN"; then
    say "installing plugin: $TRIAL_PLUGIN into ${HOME}/.claude-test"
    act env CLAUDE_CONFIG_DIR="${HOME}/.claude-test" claude plugin marketplace add "$TRIAL_MARKETPLACE_REPO"
    act env CLAUDE_CONFIG_DIR="${HOME}/.claude-test" claude plugin install "$TRIAL_PLUGIN"
  fi
fi
if { [ "$TARGET" = "all" ] || [ "$TARGET" = "codex" ]; } && command -v codex >/dev/null; then
  if ! CODEX_HOME="${HOME}/.codex-test" codex plugin list 2>/dev/null | grep -q "$TRIAL_PLUGIN"; then
    say "installing plugin: $TRIAL_PLUGIN into ${HOME}/.codex-test"
    act env CODEX_HOME="${HOME}/.codex-test" codex plugin marketplace add "$TRIAL_MARKETPLACE_REPO"
    act env CODEX_HOME="${HOME}/.codex-test" codex plugin add "$TRIAL_PLUGIN"
  fi
fi

# Selected stable skills (from skills/) that should ALSO appear in the test
# sandboxes, alongside the trial plugins above. e.g. humanizer lives in the
# stable set but is wanted in tc / tcx too.
STABLE_TEST_SKILLS=(humanizer)
for skill in "${STABLE_TEST_SKILLS[@]}"; do
  skill_path="$SRC_DIR/$skill"
  if [ ! -d "$skill_path" ]; then
    echo "warn: stable skill '$skill' not found at $skill_path" >&2
    continue
  fi
  if [ "$TARGET" = "all" ] || [ "$TARGET" = "claude" ]; then
    act mkdir -p "${HOME}/.claude-test/skills"
    install_skill "$skill_path" "${HOME}/.claude-test/skills"
  fi
  if [ "$TARGET" = "all" ] || [ "$TARGET" = "codex" ]; then
    act mkdir -p "${HOME}/.codex-test/skills"
    install_skill "$skill_path" "${HOME}/.codex-test/skills"
  fi
done
