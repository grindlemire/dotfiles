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

# Experimental skills (mattpocock trial set) — only for the `tc` sandbox Claude
# (`CLAUDE_CONFIG_DIR=~/.claude-test`), never the regular ~/.claude or Codex.
# See ../experimental_skills.
EXP_DIR="$(cd "$SRC_DIR/.." && pwd)/experimental_skills"
EXP_DEST="${HOME}/.claude-test/skills"
if [ -d "$EXP_DIR" ] && { [ "$TARGET" = "all" ] || [ "$TARGET" = "claude" ]; }; then
  mkdir -p "$EXP_DEST"
  for skill_path in "$EXP_DIR"/*/; do
    link_skill "$skill_path" "$EXP_DEST"
  done
fi
