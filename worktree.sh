_wt_require_repo() {
    local cmd="$1"
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "${cmd}: not inside a git repository" >&2
        return 1
    fi
}

_wt_repo_root() {
    git rev-parse --show-toplevel 2>/dev/null
}

_wt_default_dir() {
    local root
    root=$(_wt_repo_root) || return 1
    local parent
    parent=$(dirname "$root")
    local name
    name=$(basename "$root")
    printf "%s/.worktrees" "$root"
}

_wt_lookup_path() {
    local target="$1"
    git worktree list --porcelain | awk -v target="$target" '
        BEGIN { RS=""; FS="\n" }
        {
            path=""; branch="";
            for (i=1; i<=NF; i++) {
                if ($i ~ /^worktree /) {
                    path=substr($i,10)
                } else if ($i ~ /^branch /) {
                    branch=substr($i,8)
                    sub(/^refs\/heads\//,"",branch)
                }
            }
            if (path == target || branch == target) {
                print path
                exit
            }
        }
    '
}

wtc() {
    _wt_require_repo wtc || return 1

    if [ -z "$1" ]; then
        echo "usage: wtc <branch> [command...]" >&2
        return 1
    fi

    local branch="$1"
    shift
    local command=("$@")

    # First check if a worktree already exists for this branch
    local existing_path
    existing_path=$(_wt_lookup_path "$branch")
    local worktree_path="$existing_path"

    # No existing worktree, create a new one
    if [ -z "$worktree_path" ]; then
        local default_parent
        default_parent=$(_wt_default_dir) || return 1
        worktree_path="${default_parent}/${branch}"

        if [ -e "$worktree_path" ]; then
            echo "wtc: target path already exists: $worktree_path" >&2
            return 1
        fi

        local parent_dir
        parent_dir=$(dirname "$worktree_path")
        mkdir -p "$parent_dir" || return 1

        if git show-ref --verify --quiet "refs/heads/${branch}"; then
            git worktree add "$worktree_path" "$branch" || return 1
        else
            git worktree add -b "$branch" "$worktree_path" || return 1
        fi
    fi

    # Execute based on command presence
    if [ ${#command[@]} -eq 0 ]; then
        cd "$worktree_path" || return 1
    else
        (cd "$worktree_path" && eval "${command[@]}")
    fi
}

wtd() {
    _wt_require_repo wtd || return 1

    local force_flag=0
    case "$1" in
        -f|--force)
            force_flag=1
            shift
            ;;
    esac

    if [ -z "$1" ]; then
        echo "usage: wtd [-f|--force] <path-or-branch>" >&2
        return 1
    fi

    local target="$1"
    local worktree_path=""

    if [ -d "$target" ]; then
        worktree_path="$target"
    else
        worktree_path=$(_wt_lookup_path "$target")

        if [ -z "$worktree_path" ]; then
            local default_parent
            default_parent=$(_wt_default_dir) || return 1
            local candidate="${default_parent}/${target}"
            if [ -d "$candidate" ]; then
                worktree_path="$candidate"
            fi
        fi
    fi

    if [ -z "$worktree_path" ]; then
        echo "wtd: no worktree found for '$target'" >&2
        return 1
    fi

    # If we're currently in the worktree or a subdirectory of it, cd to repo root
    if [ -n "$worktree_path" ] && [ -d "$worktree_path" ]; then
        local current_pwd="$(pwd)"
        # Check if current directory is the worktree or a subdirectory of it
        if [[ "$current_pwd" == "$worktree_path" || "$current_pwd" == "$worktree_path"/* ]]; then
            local repo_root
            repo_root=$(_wt_lookup_path main)
            if [ -n "$repo_root" ]; then
                cd "$repo_root"
            fi
        fi
    fi

    if [ "$force_flag" -eq 1 ]; then
        git worktree remove --force "$worktree_path"
    else
        git worktree remove "$worktree_path"
    fi
}

wtl() {
    _wt_require_repo wtl || return 1

    local verbose=0
    if [[ "$1" == "-v" || "$1" == "--verbose" ]]; then
        verbose=1
    fi

    # Colors
    local c_reset='\033[0m'
    local c_green='\033[0;32m'
    local c_yellow='\033[0;33m'
    local c_red='\033[0;31m'
    local c_blue='\033[0;34m'
    local c_dim='\033[2m'
    local c_bold='\033[1m'

    local repo_root
    repo_root=$(_wt_repo_root)
    local current_path
    current_path=$(pwd)

    # Parse worktree list
    local worktrees=()
    local paths=()
    local heads=()
    local branches=()

    while IFS= read -r line; do
        if [[ "$line" =~ ^worktree\ (.+)$ ]]; then
            paths+=("${match[1]}")
        elif [[ "$line" =~ ^HEAD\ (.+)$ ]]; then
            heads+=("${match[1]}")
        elif [[ "$line" =~ ^branch\ refs/heads/(.+)$ ]]; then
            branches+=("${match[1]}")
        elif [[ -z "$line" && ${#paths[@]} -gt ${#branches[@]} ]]; then
            branches+=("(detached)")
        fi
    done < <(git worktree list --porcelain)

    # Handle last entry if no trailing newline
    if [[ ${#paths[@]} -gt ${#branches[@]} ]]; then
        branches+=("(detached)")
    fi

    # Find max branch length for alignment
    local max_branch=0
    for branch in "${branches[@]}"; do
        (( ${#branch} > max_branch )) && max_branch=${#branch}
    done
    (( max_branch < 10 )) && max_branch=10

    # Print each worktree
    for i in {1..${#paths[@]}}; do
        local idx=$((i-1))
        local wt_path="${paths[$i]}"
        local wt_head="${heads[$i]}"
        local wt_branch="${branches[$i]}"
        local short_hash="${wt_head:0:7}"

        # Check if this is current worktree
        local is_current=0
        [[ "$current_path" == "$wt_path" || "$current_path" == "$wt_path"/* ]] && is_current=1

        # Determine display name (short path)
        local display_name
        if [[ "$wt_path" == "$repo_root" ]]; then
            display_name="(main)"
        else
            display_name=$(basename "$wt_path")
        fi

        # Get dirty status
        local dirty_count
        dirty_count=$(git -C "$wt_path" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
        local status_str
        local status_color
        if [[ "$dirty_count" -gt 0 ]]; then
            status_str="${dirty_count} modified"
            status_color="$c_red"
        else
            status_str="clean"
            status_color="$c_green"
        fi

        # Current indicator
        local indicator=" "
        [[ $is_current -eq 1 ]] && indicator="*"

        # Branch color
        local branch_color="$c_yellow"
        [[ "$wt_branch" == "main" || "$wt_branch" == "master" ]] && branch_color="$c_green"
        [[ "$wt_branch" == "(detached)" ]] && branch_color="$c_red"

        # Print main line
        printf "${c_bold}%s${c_reset} ${branch_color}%-${max_branch}s${c_reset}  ${c_dim}%s${c_reset}  ${status_color}%s${c_reset}" \
            "$indicator" "$wt_branch" "$short_hash" "$status_str"

        if [[ $verbose -eq 1 ]]; then
            # Get commit subject
            local subject
            subject=$(git -C "$wt_path" log -1 --format='%s' 2>/dev/null | cut -c1-50)
            [[ ${#subject} -eq 50 ]] && subject="${subject}..."

            # Get ahead/behind vs main/master
            local upstream="main"
            git show-ref --verify --quiet refs/heads/master && upstream="master"
            local ahead_behind=""
            if [[ "$wt_branch" != "$upstream" && "$wt_branch" != "(detached)" ]]; then
                local counts
                counts=$(git -C "$wt_path" rev-list --left-right --count "${upstream}...${wt_branch}" 2>/dev/null)
                if [[ -n "$counts" ]]; then
                    local behind=$(echo "$counts" | cut -f1)
                    local ahead=$(echo "$counts" | cut -f2)
                    [[ "$ahead" -gt 0 ]] && ahead_behind="${c_green}↑${ahead}${c_reset}"
                    [[ "$behind" -gt 0 ]] && ahead_behind="${ahead_behind}${c_red}↓${behind}${c_reset}"
                fi
            fi

            printf "\n    ${c_dim}%s${c_reset}" "$wt_path"
            [[ -n "$subject" ]] && printf "\n    ${c_blue}%s${c_reset}" "$subject"
            [[ -n "$ahead_behind" ]] && printf "  %b" "$ahead_behind"
            printf "\n"
        else
            printf "\n"
        fi
    done
}
