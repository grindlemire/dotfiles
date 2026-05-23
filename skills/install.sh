#!/usr/bin/env bash
# Symlink every skill in this directory into ~/.claude/skills/.
# Existing symlinks are replaced; existing real directories are left alone (with a warning).

set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="${HOME}/.claude/skills"

mkdir -p "$DEST_DIR"

for skill_path in "$SRC_DIR"/*/; do
  skill="$(basename "$skill_path")"
  target="$DEST_DIR/$skill"

  if [ -L "$target" ]; then
    rm "$target"
  elif [ -e "$target" ]; then
    echo "skip: $target exists and is not a symlink (remove it manually to replace)"
    continue
  fi

  ln -s "$skill_path" "$target"
  echo "linked: $skill"
done
