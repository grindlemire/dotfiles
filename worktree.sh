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
        echo "usage: wtc <branch> [path]" >&2
        return 1
    fi

    local branch="$1"
    local worktree_path="$2"
    local default_parent
    default_parent=$(_wt_default_dir) || return 1

    if [ -z "$worktree_path" ]; then
        worktree_path="${default_parent}/${branch}"
    fi

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

    cd "$worktree_path" || return 1
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

    git worktree list --porcelain | awk '
        BEGIN { RS=""; FS="\n" }
        {
            path=""; head=""; branch="";
            for (i=1; i<=NF; i++) {
                if ($i ~ /^worktree /) {
                    path=substr($i,10)
                } else if ($i ~ /^HEAD /) {
                    head=substr($i,6)
                } else if ($i ~ /^branch /) {
                    branch=substr($i,8)
                    sub(/^refs\/heads\//,"",branch)
                }
            }
            if (branch == "") {
                branch="(detached)"
            }
            printf "%-40s %-25s %s\n", path, branch, head
        }
    '
}
