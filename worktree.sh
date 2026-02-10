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

_wt_skip_patterns() {
    local repo_root="$1"

    # Default directories to skip (build artifacts, dependencies, caches)
    local defaults=(
        'node_modules'
        'vendor'
        '.venv'
        'venv'
        '__pycache__'
        '.pytest_cache'
        'dist'
        'build'
        'target'
        '.next'
        '.nuxt'
        '.output'
        '.cache'
        '.parcel-cache'
        '.turbo'
        'coverage'
        '.nyc_output'
        '*.log'
        '.DS_Store'
        '.worktrees'
    )

    # Add patterns from .wtignore if it exists
    local wtignore="${repo_root}/.wtignore"
    if [[ -f "$wtignore" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            # Skip comments and empty lines
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            [[ -z "${line// }" ]] && continue
            defaults+=("$line")
        done < "$wtignore"
    fi

    # Output patterns
    printf '%s\n' "${defaults[@]}"
}

_wt_build_exclude_pattern() {
    local repo_root="$1"
    local patterns
    patterns=$(_wt_skip_patterns "$repo_root")

    local exclude_pattern=""
    while IFS= read -r p; do
        # Convert glob pattern to regex: escape dots, convert * to .*
        p="${p//./\\.}"
        p="${p//\*/.*}"
        [[ -n "$exclude_pattern" ]] && exclude_pattern="${exclude_pattern}|"
        exclude_pattern="${exclude_pattern}${p}"
    done <<< "$patterns"

    printf '%s' "$exclude_pattern"
}

_wt_sync_ignored() {
    local src_root="$1"
    local dest_root="$2"

    local exclude_pattern
    exclude_pattern=$(_wt_build_exclude_pattern "$src_root")

    # Get ignored files from source, excluding skip patterns
    local ignored_files
    ignored_files=$(git -C "$src_root" ls-files --others --ignored --exclude-standard 2>/dev/null | grep -v -E "^(${exclude_pattern})(/|$)" | grep -v -E "/(${exclude_pattern})(/|$)")

    [[ -z "$ignored_files" ]] && return 0

    local count=0
    while IFS= read -r file; do
        local src_file="${src_root}/${file}"
        local dest_file="${dest_root}/${file}"

        # Skip if source doesn't exist or dest already exists
        [[ ! -e "$src_file" ]] && continue
        [[ -e "$dest_file" ]] && continue

        # Create parent directory if needed
        local dest_dir=$(dirname "$dest_file")
        [[ ! -d "$dest_dir" ]] && mkdir -p "$dest_dir"

        # Symlink the file
        ln -s "$src_file" "$dest_file" && ((count++))
    done <<< "$ignored_files"

    if [[ $count -gt 0 ]]; then
        printf '\033[0;32m✓ Symlinked %d ignored file(s) from main worktree\033[0m\n' "$count"
    fi
}

_wt_list_symlinks() {
    local wt_path="$1"

    # Find symlinks in the worktree (excluding .git)
    local symlinks
    symlinks=$(find "$wt_path" -type l ! -path '*/.git/*' 2>/dev/null)

    [[ -z "$symlinks" ]] && return 0

    while IFS= read -r link; do
        local relative="${link#$wt_path/}"
        local target=$(readlink "$link")
        printf '      \033[0;36m%s\033[0m → \033[2m%s\033[0m\n' "$relative" "$target"
    done <<< "$symlinks"
}

_wt_is_merged() {
    local branch="$1"
    local upstream="$2"

    # Try remote main/master first, fall back to local if not specified
    if [[ -z "$upstream" ]]; then
        if git show-ref --verify --quiet refs/remotes/origin/main; then
            upstream="origin/main"
        elif git show-ref --verify --quiet refs/remotes/origin/master; then
            upstream="origin/master"
        elif git show-ref --verify --quiet refs/heads/main; then
            upstream="main"
        elif git show-ref --verify --quiet refs/heads/master; then
            upstream="master"
        else
            return 1
        fi
    fi

    # Method 1: Direct ancestor check (handles regular merges)
    if git merge-base --is-ancestor "$branch" "$upstream" 2>/dev/null; then
        return 0
    fi

    # Method 2: Check for squash merge by comparing trees
    local merge_base branch_tree temp_commit cherry_result

    merge_base=$(git merge-base "$upstream" "$branch" 2>/dev/null) || return 1
    branch_tree=$(git rev-parse "${branch}^{tree}" 2>/dev/null) || return 1
    temp_commit=$(git commit-tree "$branch_tree" -p "$merge_base" -m "_" 2>/dev/null) || return 1

    # If cherry says "-", the changes are already applied to upstream
    cherry_result=$(git cherry "$upstream" "$temp_commit" 2>/dev/null)
    [[ "$cherry_result" == "-"* ]]
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
    local created_new=0
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
        created_new=1
    fi

    # Sync ignored files from main worktree to new worktree
    if [[ $created_new -eq 1 ]]; then
        local main_worktree
        main_worktree=$(_wt_repo_root)
        _wt_sync_ignored "$main_worktree" "$worktree_path"
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

    local target="$1"

    # Default to current worktree if no target specified
    if [ -z "$target" ]; then
        target=$(pwd)
    fi
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

    # Get the branch name for this worktree
    local branch_name
    branch_name=$(git worktree list --porcelain | awk -v path="$worktree_path" '
        BEGIN { RS=""; FS="\n" }
        {
            wt_path=""; branch="";
            for (i=1; i<=NF; i++) {
                if ($i ~ /^worktree /) wt_path=substr($i,10)
                else if ($i ~ /^branch /) {
                    branch=substr($i,8)
                    sub(/^refs\/heads\//, "", branch)
                }
            }
            if (wt_path == path) { print branch; exit }
        }
    ')

    # Never delete main or master
    if [[ "$branch_name" == "main" || "$branch_name" == "master" ]]; then
        printf '\033[0;31mwtd: refusing to delete %s worktree\033[0m\n' "$branch_name" >&2
        return 1
    fi

    # Check if branch is merged (unless force flag is set)
    if [[ "$force_flag" -eq 0 && -n "$branch_name" ]]; then
        if ! _wt_is_merged "$branch_name"; then
            printf '\033[0;31mwtd: branch "%s" is not merged into main\033[0m\n' "$branch_name" >&2
            echo "use -f to force deletion" >&2
            return 1
        fi
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
        git worktree remove --force "$worktree_path" || return 1
    else
        git worktree remove "$worktree_path" || return 1
    fi

    # Delete the branch if it was merged
    if [[ -n "$branch_name" ]] && _wt_is_merged "$branch_name"; then
        git branch -d "$branch_name" 2>/dev/null && \
            printf '\033[0;32m✓ Deleted branch %s\033[0m\n' "$branch_name"
    fi
}

wtl() {
    _wt_require_repo wtl || return 1

    local verbose=0
    case "$1" in
        -vv) verbose=2 ;;
        -v|--verbose) verbose=1 ;;
    esac

    # Colors
    local c_reset='\033[0m'
    local c_green='\033[0;32m'
    local c_yellow='\033[0;33m'
    local c_red='\033[0;31m'
    local c_blue='\033[0;34m'
    local c_cyan='\033[0;36m'
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
    local wt_path wt_head wt_branch short_hash is_current display_name
    local dirty_count status_str status_color indicator branch_color
    local subject upstream ahead_behind counts behind ahead symlinks relative
    local symlink_count

    for i in {1..${#paths[@]}}; do
        wt_path="${paths[$i]}"
        wt_head="${heads[$i]}"
        wt_branch="${branches[$i]}"
        short_hash="${wt_head:0:7}"

        # Check if this is current worktree
        is_current=0
        [[ "$current_path" == "$wt_path" || "$current_path" == "$wt_path"/* ]] && is_current=1

        # Determine display name (short path)
        if [[ "$wt_path" == "$repo_root" ]]; then
            display_name="(main)"
        else
            display_name="$(basename "$wt_path")"
        fi

        # Get dirty status
        dirty_count=$(git -C "$wt_path" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$dirty_count" -gt 0 ]]; then
            status_str="${dirty_count} modified"
            status_color="$c_red"
        else
            status_str="clean"
            status_color="$c_green"
        fi

        # Count symlinks (exclude .worktrees directory from main worktree only)
        if [[ "$wt_path" != *"/.worktrees/"* ]]; then
            # Main worktree - exclude .worktrees subdirectory
            symlink_count=$(find "$wt_path" -type l ! -path '*/.git/*' ! -path '*/.worktrees/*' 2>/dev/null | wc -l | tr -d ' ')
        else
            # Inside a worktree - show all symlinks
            symlink_count=$(find "$wt_path" -type l ! -path '*/.git/*' 2>/dev/null | wc -l | tr -d ' ')
        fi

        # Current indicator
        indicator=" "
        [[ $is_current -eq 1 ]] && indicator="*"

        # Branch color
        branch_color="$c_yellow"
        [[ "$wt_branch" == "main" || "$wt_branch" == "master" ]] && branch_color="$c_green"
        [[ "$wt_branch" == "(detached)" ]] && branch_color="$c_red"

        # Print main line
        printf "${c_bold}%s${c_reset} ${branch_color}%-${max_branch}s${c_reset}  ${c_dim}%s${c_reset}  ${status_color}%-12s${c_reset}" \
            "$indicator" "$wt_branch" "$short_hash" "$status_str"
        if [[ "$symlink_count" -gt 0 ]]; then
            printf "  ${c_cyan}%s symlinked${c_reset}" "$symlink_count"
        fi

        if [[ $verbose -ge 1 ]]; then
            # Get commit subject
            subject=$(git -C "$wt_path" log -1 --format='%s' 2>/dev/null | cut -c1-50)
            [[ ${#subject} -eq 50 ]] && subject="${subject}..."

            # Get ahead/behind vs main/master
            upstream="main"
            git show-ref --verify --quiet refs/heads/master && upstream="master"
            ahead_behind=""
            if [[ "$wt_branch" != "$upstream" && "$wt_branch" != "(detached)" ]]; then
                counts=$(git -C "$wt_path" rev-list --left-right --count "${upstream}...${wt_branch}" 2>/dev/null)
                if [[ -n "$counts" ]]; then
                    behind=$(echo "$counts" | cut -f1)
                    ahead=$(echo "$counts" | cut -f2)
                    [[ "$ahead" -gt 0 ]] && ahead_behind="${c_green}↑${ahead}${c_reset}"
                    [[ "$behind" -gt 0 ]] && ahead_behind="${ahead_behind}${c_red}↓${behind}${c_reset}"
                fi
            fi

            printf "\n    ${c_dim}%s${c_reset}" "$wt_path"
            [[ -n "$subject" ]] && printf "\n    ${c_blue}%s${c_reset}" "$subject"
            [[ -n "$ahead_behind" ]] && printf "  %b" "$ahead_behind"

            # Show symlinks in -vv mode
            if [[ $verbose -ge 2 ]]; then
                if [[ "$wt_path" != *"/.worktrees/"* ]]; then
                    # Main worktree - exclude .worktrees subdirectory
                    symlinks=$(find "$wt_path" -type l ! -path '*/.git/*' ! -path '*/.worktrees/*' 2>/dev/null)
                else
                    # Inside a worktree - show all symlinks
                    symlinks=$(find "$wt_path" -type l ! -path '*/.git/*' 2>/dev/null)
                fi
                if [[ -n "$symlinks" ]]; then
                    printf "\n    ${c_dim}symlinks:${c_reset}"
                    while IFS= read -r link; do
                        relative="${link#$wt_path/}"
                        printf "\n      ${c_cyan}%s${c_reset}" "$relative"
                    done <<< "$symlinks"
                fi
            fi
            printf "\n"
        else
            printf "\n"
        fi
    done
}

wt() {
    local cmd="${1:-list}"
    shift 2>/dev/null

    # Handle case where current directory no longer exists (deleted worktree)
    # If we're in a .worktrees subdirectory and git doesn't work, cd to main worktree
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local current_path="$PWD"
        if [[ "$current_path" == *"/.worktrees/"* ]]; then
            local main_path="${current_path%%/.worktrees/*}"
            if [[ -d "$main_path" ]]; then
                echo "wt: current worktree no longer exists, returning to main worktree" >&2
                cd "$main_path" || return 1
                # If user just ran 'wt' or 'wt list', show the list after recovering
                if [[ "$cmd" == "list" || "$cmd" == "ls" || "$cmd" == "l" ]]; then
                    wtl "$@"
                    return $?
                fi
            else
                echo "wt: not inside a git repository" >&2
                return 1
            fi
        else
            echo "wt: not inside a git repository" >&2
            return 1
        fi
    fi

    case "$cmd" in
        c|create)
            wtc "$@"
            ;;
        d|delete|rm|remove)
            wtd "$@"
            ;;
        l|list|ls)
            wtl "$@"
            ;;
        -v|-vv)
            # Allow wt -v or wt -vv as shorthand for wt list -v/-vv
            wtl "$cmd" "$@"
            ;;
        -h|--help|help)
            echo "usage: wt <command> [args]"
            echo ""
            echo "commands:"
            echo "  list, ls, l      List worktrees (default)"
            echo "  create, c        Create/switch to worktree"
            echo "  delete, rm, d    Delete worktree"
            echo ""
            echo "examples:"
            echo "  wt               List all worktrees"
            echo "  wt -v            List with details"
            echo "  wt c feature-x   Create and cd to feature-x worktree"
            echo "  wt d feature-x   Delete feature-x worktree"
            echo "  wt d             Delete current worktree"
            echo ""
            echo "symlink sync:"
            echo "  When creating a worktree, gitignored files from the main worktree are"
            echo "  automatically symlinked (e.g., .env, config files). Build artifacts and"
            echo "  dependencies are excluded by default (node_modules, vendor, dist, etc.)."
            echo ""
            echo "  Create .wtignore in repo root to add custom exclusions (one pattern per"
            echo "  line, supports globs like *.log, lines starting with # are comments)."
            ;;
        *)
            # Assume it's a branch name for create
            wtc "$cmd" "$@"
            ;;
    esac
}
