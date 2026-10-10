#!/usr/bin/env bash
# Copy the skills listed in upstream.txt from their upstream repos into this
# directory, where install.sh links them like any other skill.
#
# Each synced skill gets a .upstream marker recording repo, path and the last
# upstream commit that touched it. Synced skills are overwritten wholesale, so
# never hand-edit one: fork it under a new name instead. Skills dropped from
# upstream.txt are deleted; directories without a marker are never touched.
#
# If SYNC_SUMMARY is set, a Markdown list of upstream commits per changed skill
# is written there (the weekly GitHub Action uses it as the PR body).

set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="${SYNC_MANIFEST:-$SRC_DIR/upstream.txt}"
SUMMARY="${SYNC_SUMMARY:-/dev/null}"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/sync-upstream.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

: >"$SUMMARY"
wanted=" "

while read -r repo path _; do
  case "$repo" in "" | \#*) continue ;; esac

  name="$(basename "$path")"
  dest="$SRC_DIR/$name"
  clone="$WORK/${repo//\//__}"

  if [ -e "$dest" ] && [ ! -f "$dest/.upstream" ]; then
    echo "error: $dest is a local skill; rename one of them" >&2
    exit 1
  fi
  if [ ! -d "$clone" ]; then
    git clone -q --filter=blob:none "https://github.com/$repo.git" "$clone"
  fi
  if [ ! -d "$clone/$path" ]; then
    echo "error: $repo has no $path (removed or renamed upstream?)" >&2
    exit 1
  fi

  wanted="$wanted$name "
  sha="$(git -C "$clone" log -1 --format=%H -- "$path")"
  old=""
  if [ -f "$dest/.upstream" ]; then
    old="$(awk '$1 == "sha" { print $2 }' "$dest/.upstream")"
  fi
  [ "$old" = "$sha" ] && continue

  rm -rf "$dest"
  cp -R "$clone/$path" "$dest"
  printf 'repo %s\npath %s\nsha %s\n' "$repo" "$path" "$sha" >"$dest/.upstream"

  if [ -n "$old" ] && ! git -C "$clone" cat-file -e "$old^{commit}" 2>/dev/null; then
    echo "updated: $name (old commit $old no longer upstream)"
    printf '### `%s` (updated; previous commit %s is gone from upstream history)\n\n' "$name" "$old" >>"$SUMMARY"
  elif [ -n "$old" ]; then
    echo "updated: $name"
    {
      echo "### \`$name\` ([diff](https://github.com/$repo/compare/${old:0:12}...${sha:0:12}))"
      git -C "$clone" log --format="- [\`%h\`](https://github.com/$repo/commit/%H) %s" "$old..$sha" -- "$path"
      echo
    } >>"$SUMMARY"
  else
    echo "added: $name"
    printf '### `%s` (new, from %s)\n\n' "$name" "$repo/$path" >>"$SUMMARY"
  fi
done <"$MANIFEST"

for marker in "$SRC_DIR"/*/.upstream; do
  [ -f "$marker" ] || continue
  dir="$(dirname "$marker")"
  name="$(basename "$dir")"
  case "$wanted" in *" $name "*) continue ;; esac
  rm -rf "$dir"
  echo "removed: $name"
  printf '### `%s` (removed from upstream.txt)\n\n' "$name" >>"$SUMMARY"
done
