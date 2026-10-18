#!/bin/bash
# Claude Code status line. Symlink to ~/.claude/statusline.sh.
#
# Line 1, where you are: project, branch, working tree, and either the
# GitStack stack position (gitstack repos) or the open PR.
# Line 2, what it costs: model, effort, context, and usage limits, cache
# state only once they cross a threshold.
#
# Runs on every refresh under macOS /bin/bash 3.2, so: no bash 4 features,
# one jq pass over the input, and nothing slow inline. `gs stack --json`
# (network, ~0.7s) runs in the background into a cache.

input=$(cat)

R=$'\033[0m'; DIM=$'\033[2m'
GRN=$'\033[32m'; YEL=$'\033[33m'; RED=$'\033[31m'
CYN=$'\033[36m'; MAG=$'\033[35m'; GRY=$'\033[90m'
SEP="${GRY} · ${R}"
US=$'\x1f'

IFS=$US read -r cwd model effort ctx_pct ctx_tokens \
    h5_pct h5_reset d7_pct d7_reset cache_cold recache \
    pr_num pr_state pr_kind < <(printf '%s' "$input" | jq -r '[
    (.workspace.current_dir // .cwd),
    .model.display_name,
    .effort.level,
    .context_window.used_percentage,
    .context_window.total_input_tokens,
    .rate_limits.five_hour.used_percentage,
    .rate_limits.five_hour.resets_at,
    .rate_limits.seven_day.used_percentage,
    .rate_limits.seven_day.resets_at,
    (if .prompt_cache.caching_observed == true and .prompt_cache.warm == false then "1" else "" end),
    .prompt_cache.recache_tokens_if_cold,
    .pr.number,
    .pr.review_state,
    .pr.kind
  ] | map(. // "" | tostring) | join("\u001f")')

cd "$cwd" 2>/dev/null || cd "$HOME"
export GIT_OPTIONAL_LOCKS=0

# 104000 -> 104k, 1000000 -> 1.0M
fmt_tokens() {
    local n=${1%.*}
    if [ "$n" -ge 1000000 ]; then
        printf "%d.%dM" $((n / 1000000)) $((n % 1000000 / 100000))
    elif [ "$n" -ge 1000 ]; then
        printf "%dk" $((n / 1000))
    else
        printf "%d" "$n"
    fi
}

# Time until an epoch: 34m, 2h10m, or the weekday when over a day away.
fmt_reset() {
    local secs=$(( $1 - $(date +%s) ))
    [ "$secs" -lt 0 ] && secs=0
    if [ "$secs" -ge 86400 ]; then
        date -r "$1" +%a 2>/dev/null || date -d "@$1" +%a
    elif [ "$secs" -ge 3600 ]; then
        printf "%dh%02dm" $((secs / 3600)) $((secs % 3600 / 60))
    else
        printf "%dm" $((secs / 60))
    fi
}

truncate() {
    if [ "${#1}" -gt "$2" ]; then printf "%s…" "${1:0:$(($2 - 1))}"; else printf "%s" "$1"; fi
}

# ---- line 1: where you are -------------------------------------------------

stack_info() {
    local top=$1 branch=$2 head=$3 common=$4
    local manifest="" mf="$top/.gitstack/branch-reviews.json"

    # The working-tree manifest is what gs verbs write locally; the ref is
    # what the last push or sync saw, and can still list reviews the branch
    # no longer has. Trust the file whenever it is for this branch.
    if [ -f "$mf" ] && [ "$(jq -r '.branch' "$mf" 2>/dev/null)" = "$branch" ]; then
        manifest=$(cat "$mf")
    else
        mf=""
        manifest=$(git cat-file -p "refs/gitstack/branches/$branch/manifest" 2>/dev/null)
    fi
    [ -z "$manifest" ] && return

    local ids=() tips=() id tip
    while read -r id tip; do
        ids+=("$id"); tips+=("$tip")
    done < <(printf '%s' "$manifest" | jq -r '.reviews[] | "\(.review_id) \(.tip_sha)"')
    local n=${#ids[@]}
    [ "$n" -eq 0 ] && return

    # Where HEAD sits: on a review tip, inside a review, or above the top
    # review with commits not carved into any review yet.
    local last=$((n - 1)) at=-1 where="" i
    if [ "$head" = "${tips[$last]}" ]; then
        at=$last
    elif git merge-base --is-ancestor "${tips[$last]}" "$head" 2>/dev/null; then
        at=$last
        where="above"
    else
        for ((i = 0; i < n; i++)); do
            if [ "$head" = "${tips[$i]}" ]; then
                at=$i; break
            elif git merge-base --is-ancestor "$head" "${tips[$i]}" 2>/dev/null; then
                at=$i; where="inside"; break
            fi
        done
    fi

    # Checks and threads come from the gs cache, refreshed in the
    # background when it is over a minute old or the manifest changed. Each
    # refresh is one GET to the server. A failed one still touches the cache,
    # so being offline costs one attempt a minute, not one per redraw.
    local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/claude-statusline"
    local key=$(printf '%s:%s' "$top" "$branch" | cksum | cut -d' ' -f1)
    local cache="$cache_dir/gs-$key.json" lock="$cache_dir/gs-$key.lock"
    if command -v gs >/dev/null 2>&1 && mkdir -p "$cache_dir" 2>/dev/null; then
        find "$lock" -maxdepth 0 -mmin +2 -exec rmdir {} \; 2>/dev/null
        if [ -z "$(find "$cache" -mmin -1 2>/dev/null)" ] || { [ -n "$mf" ] && [ "$mf" -nt "$cache" ]; }; then
            if mkdir "$lock" 2>/dev/null; then
                (gs stack --json >"$cache.tmp" 2>/dev/null && mv "$cache.tmp" "$cache" || touch "$cache"
                 rm -f "$cache.tmp"; rmdir "$lock") \
                    </dev/null >/dev/null 2>&1 &
            fi
        fi
    fi

    local failing=0 threads=0
    if [ -s "$cache" ]; then
        read -r failing threads < <(jq -r --arg b "$branch" '
            select(.branch == $b)
            | "\([.reviews[] | select(.checks_state == "failure")] | length) \([.reviews[].open_threads] | add // 0)"' \
            "$cache" 2>/dev/null)
    fi

    local out
    if [ "$at" -lt 0 ]; then
        out="${YEL}off-stack${R}"
    else
        local pos="${ids[$at]} $((at + 1))/$n"
        case $where in
            inside) out="${YEL}in ${pos}${R}" ;;
            *) out="${CYN}${pos}${R}" ;;
        esac
        if [ "$where" = "above" ]; then
            local uncarved=$(git rev-list --count "${tips[$last]}..$head" 2>/dev/null)
            out+=" ${YEL}+${uncarved} uncarved${R}"
        fi
    fi
    plural() { [ "$1" -gt 1 ] && printf "%ss" "$2" || printf "%s" "$2"; }
    [ "${failing:-0}" -gt 0 ] 2>/dev/null && out+=" ${RED}✗${failing} $(plural "$failing" check)${R}"
    [ "${threads:-0}" -gt 0 ] 2>/dev/null && out+=" ${YEL}${threads} $(plural "$threads" thread)${R}"
    printf "%s" "$out"
}

line1() {
    local status
    status=$(git status --porcelain=v2 --branch 2>/dev/null) || {
        printf "${CYN}%s${R}" "${PWD/#$HOME/~}"
        return
    }

    local top gitdir common
    { read -r top; read -r gitdir; read -r common; } \
        < <(git rev-parse --path-format=absolute --show-toplevel --git-dir --git-common-dir 2>/dev/null)
    local project=$(basename "${common%/.git}")

    local head branch ahead behind staged modified untracked conflicts
    read -r head branch ahead behind staged modified untracked conflicts < <(printf '%s\n' "$status" | awk '
        $2 == "branch.oid" { oid = $3 }
        $2 == "branch.head" { br = $3 }
        $2 == "branch.ab" { a = substr($3, 2); b = substr($4, 2) }
        $1 == "1" || $1 == "2" { if (substr($2, 1, 1) != ".") s++; if (substr($2, 2, 1) != ".") m++ }
        $1 == "u" { c++ }
        $1 == "?" { u++ }
        END { printf "%s %s %d %d %d %d %d %d", oid, br, a, b, s, m, u, c }')

    local gitstack=""
    if [ -d "$top/.gitstack" ] || [ -d "$(dirname "$common")/.gitstack" ] \
        || [ -n "$(git for-each-ref --count=1 refs/gitstack/ 2>/dev/null)" ]; then
        gitstack=1
    fi

    # gs checkout mid-stack detaches HEAD; the manifest still names the branch.
    local detached=""
    if [ "$branch" = "(detached)" ]; then
        detached=1
        branch=""
        [ -n "$gitstack" ] && branch=$(jq -r '.branch // empty' "$top/.gitstack/branch-reviews.json" 2>/dev/null)
        [ -z "$branch" ] && branch=${head:0:7}
    fi

    local out=""
    [ -n "$SSH_CONNECTION" ] && out+="${GRY}$(whoami)@$(hostname -s)${R} "
    out+="${CYN}$(truncate "$project" 20)${R} "
    out+="${MAG}⎇ ${R}"
    [ "$gitdir" != "$common" ] && out+="${YEL}wt:${R}"
    out+="${MAG}$(truncate "$branch" 32)${R}"
    [ -n "$detached" ] && out+=" ${GRY}(detached)${R}"
    [ "$conflicts" -gt 0 ] && out+=" ${RED}!${conflicts}${R}"
    [ "$staged" -gt 0 ] && out+=" ${GRN}+${staged}${R}"
    [ "$modified" -gt 0 ] && out+=" ${YEL}~${modified}${R}"
    [ "$untracked" -gt 0 ] && out+=" ${GRY}?${untracked}${R}"
    [ "$ahead" -gt 0 ] && out+=" ${GRY}↑${ahead}${R}"
    [ "$behind" -gt 0 ] && out+=" ${GRY}↓${behind}${R}"

    if [ -n "$gitstack" ]; then
        local stack=$(stack_info "$top" "$branch" "$head" "$common")
        [ -n "$stack" ] && out+="${SEP}${stack}"
    elif [ -n "$pr_num" ]; then
        local label="PR #${pr_num}" color=$GRY
        [ "$pr_kind" = "mr" ] && label="MR !${pr_num}"
        case $pr_state in
            approved) color=$GRN; label+=" ✓ approved" ;;
            changes_requested) color=$YEL; label+=" changes requested" ;;
            draft) label+=" draft" ;;
            *) label+=" ${pr_state:-open}" ;;
        esac
        out+="${SEP}${color}${label}${R}"
    fi
    printf "%s" "$out"
}

# ---- line 2: what it costs -------------------------------------------------

# Usage limits stay hidden under 50%; the reset time shows from 80%.
limit() {
    local name=$1 pct=${2%.*} reset=$3
    [ -z "$pct" ] || [ "$pct" -lt 50 ] && return
    local color=$YEL
    [ "$pct" -ge 80 ] && color=$RED
    printf "%s%s %d%%%s" "$SEP" "$color$name" "$pct" "$R"
    [ "$pct" -ge 80 ] && [ -n "$reset" ] && printf " ${GRY}↺%s${R}" "$(fmt_reset "$reset")"
}

line2() {
    local out="${model% (*}"
    [ -n "$effort" ] && out+=" ${DIM}${effort}${R}"

    if [ -n "$ctx_pct" ]; then
        local pct=$(printf "%.0f" "$ctx_pct") color=$GRN
        [ "$pct" -ge 40 ] && color=$YEL
        [ "$pct" -ge 70 ] && color=$RED
        out+="${SEP}${color}ctx ${pct}%${R}"
        [ -n "$ctx_tokens" ] && out+=" ${GRY}$(fmt_tokens "$ctx_tokens")${R}"
        [ "$pct" -ge 80 ] && out+=" ${RED}compact soon${R}"
    fi

    out+=$(limit 5h "$h5_pct" "$h5_reset")
    out+=$(limit 7d "$d7_pct" "$d7_reset")

    if [ -n "$cache_cold" ]; then
        out+="${SEP}${YEL}cache cold${R}"
        [ -n "$recache" ] && [ "${recache%.*}" -gt 0 ] && out+=" ${GRY}next turn re-caches $(fmt_tokens "$recache")${R}"
    fi
    printf "%s" "$out"
}

printf "%s\n%s" "$(line1)" "$(line2)"
