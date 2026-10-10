#!/usr/bin/env bash
# Symlink every skill in this directory into Claude and Codex skill dirs.
# Existing symlinks are replaced; existing real directories are left alone (with a warning).

set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-all}"

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
  *)
    echo "usage: $0 [all|claude|codex]" >&2
    exit 2
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
    rm "$target"
  elif [ -e "$target" ]; then
    echo "skip: $target exists and is not a symlink (remove it manually to replace)"
    return
  fi

  ln -s "$skill_path" "$target"
  echo "linked: $target"
}

for dest_dir in "${DEST_DIRS[@]}"; do
  mkdir -p "$dest_dir"
done

for skill_path in "$SRC_DIR"/*/; do
  for dest_dir in "${DEST_DIRS[@]}"; do
    link_skill "$skill_path" "$dest_dir"
  done
done

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
    CLAUDE_CONFIG_DIR="${HOME}/.claude-test" claude plugin marketplace add "$TRIAL_MARKETPLACE_REPO"
    CLAUDE_CONFIG_DIR="${HOME}/.claude-test" claude plugin install "$TRIAL_PLUGIN"
  fi
fi
if { [ "$TARGET" = "all" ] || [ "$TARGET" = "codex" ]; } && command -v codex >/dev/null; then
  if ! CODEX_HOME="${HOME}/.codex-test" codex plugin list 2>/dev/null | grep -q "$TRIAL_PLUGIN"; then
    CODEX_HOME="${HOME}/.codex-test" codex plugin marketplace add "$TRIAL_MARKETPLACE_REPO"
    CODEX_HOME="${HOME}/.codex-test" codex plugin add "$TRIAL_PLUGIN"
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
    mkdir -p "${HOME}/.claude-test/skills"
    link_skill "$skill_path" "${HOME}/.claude-test/skills"
  fi
  if [ "$TARGET" = "all" ] || [ "$TARGET" = "codex" ]; then
    mkdir -p "${HOME}/.codex-test/skills"
    link_skill "$skill_path" "${HOME}/.codex-test/skills"
  fi
done
