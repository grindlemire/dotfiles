# Get the nice ^r, ^a, and ^e behavior
set -o emacs

# aliases
alias la='ls -a'   # hidden
alias ll='ls -lh'  # long
alias lt='ls -lth' # long time sorted
alias lla='ls -lha' # long and hidden
alias emacs='emacs -nw'
alias cap='ret=$?'
alias check='[ $ret == 0 ] && true || false'
lc() {
    local target="${1:-.}"
    find "$target" -type f \( \( -name '*.go' -a ! -name '*.sql.go' -a ! -name '*_templ.go' \) -o -name '*.templ' \) -print0 | xargs -0 wc -l
}

# ls colors for bsd/linux
ls --color &>/dev/null 2>&1 && alias ls='ls --color=tty' || alias ls='ls -G'

Red="\033[0;31m"
Green='\033[0;32m'
Color_Off='\033[0m'

godir() {
    cd $HOME/go/src/github.com/grindlemire/$@
}

# Installed Apps and scripts added to PATH
export PATH=~/Apps/bin:~/dotfiles/scripts:$PATH
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
export PATH=/opt/homebrew/bin:$PATH
export PATH=~/Library/Python/3.9/bin:$PATH
export PATH=$HOME/.local/bin:$PATH

# editor needs to be set for commits without -m
export EDITOR='vim'

# go stuff
export GOPATH=$HOME/go
export PATH=/usr/local/go/bin:$GOPATH/bin:/usr/local/bin:$PATH

# git signing stuff
git_sign_init() {
    git config --global gpg.format ssh
    git config --global user.signingKey "$(cat ~/.ssh/$1.pub)"
    git config --global commit.gpgsign true
    git config --global tag.gpgsign true
}

has_param() {
    local term="$1"
    shift
    for arg; do
        if [[ $arg == "$term" ]]; then
            return 0
        fi
    done
    return 1
}

gprune() {
    CMD='git branch -D $branch'
    if has_param '--dry' "$@"; then
        CMD='echo "${Green}$branch ${Color_Off}is merged into main and can be deleted"'
    else
        # fetch all the remote branches and remove the deleted branches from autocomplete
        git fetch --prune --all
    fi

    # taken from https://stackoverflow.com/questions/43489303/how-can-i-delete-all-git-branches-which-have-been-squash-and-merge-via-github
    git checkout -q main && git for-each-ref refs/heads/ "--format=%(refname:short)" | \
    while read branch;
        do mergeBase=$(git merge-base main $branch) &&
        [[ $(git cherry main $(git commit-tree $(git rev-parse "$branch^{tree}") -p $mergeBase -m _)) == "-"* ]] &&
        eval "$CMD";
    done
    return 0
}

# turn a video into a gif
to_gif() {
    FNAME="$(echo $1 | xargs -I file basename file .mov)"
    cmd="ffmpeg -i $1 \
        -vf \"fps=12,scale=1280:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse\" \
        -loop 0 ${FNAME}.gif"
    echo -e "${Green} Running Cmd:\n    ${cmd}${Color_Off}\n"
    eval "$cmd"
}

###############################################################################
# zsh stuff
###############################################################################

myip() {
    ifconfig en0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'
}

# set window title and share pwd accross sessions
update_terminal_cwd() {
    local PWD_URL="file://$HOSTNAME${PWD// /%20}"
    printf '\e]7;%s\a' "$PWD_URL"
}

clone() {
	git clone git@github.com:$1
}

fixssh() {
	. ensure-ssh-agent
}

gbranch() {
        printf "%s" "$(git branch 2>/dev/null | grep \* | awk -F '\\* ' '{$0=$2}1')"
}

# alias git pull and git push from the current branch
gpull() {
    BRANCH=$(gbranch)
    if [ -n "$1" ]; then
        BRANCH=$1
    fi

    CMD="git pull origin ${BRANCH}"
    echo -e "${Green} Running Cmd:\n    ${CMD} ${Color_Off}\n"
    eval "$CMD"
}

gpush() {
    BRANCH=$(gbranch)
    if [ -n "$1" ]; then
        BRANCH=$1
    fi

    CMD="git push origin ${BRANCH}"
    echo -e "${Green} Running Cmd:\n    ${CMD} ${Color_Off}\n"
    eval "$CMD"
}

gadd() {
    CMD="git add ."
    echo -e "${Green} Running Cmd:\n    ${CMD} ${Color_Off}\n"
    eval "$CMD"
}

gcommit() {
    if [ -n "$1" ] && [ "$1" = "-m" ]; then
        # Skip -m and use remaining arguments as message
        shift
        MSG="$@"
    elif [ -n "$1" ]; then
        MSG="$@"
    else
        MSG="snapshot $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
    fi

    gadd
    CMD="git commit -m \"$MSG\""
    echo -e "${Green} Running Cmd:\n    ${CMD} ${Color_Off}\n"
    fixssh > /dev/null 2>&1
    eval "$CMD"
}

grevert() {
    git reset --hard HEAD~1
}

grollback() {
    git revert --no-edit HEAD
}

grelease() {
    local version_type="${1:-patch}"
    
    # Validate version type
    if [[ ! "$version_type" =~ ^(patch|minor|major)$ ]]; then
        echo -e "${Red}Error: Version type must be patch, minor, or major${Color_Off}"
        return 1
    fi
    
    # Fetch latest tags from remote
    echo -e "${Green}Fetching latest tags...${Color_Off}"
    git fetch --tags --quiet
    
    # Get the latest version tag (vX.X.X format)
    local latest_tag=$(git tag -l 'v*' | sort -V | tail -n 1)
    
    # If no tags exist, start at v0.0.1
    if [ -z "$latest_tag" ]; then
        latest_tag="v0.0.0"
        echo -e "${Green}No existing tags found, starting from v0.0.0${Color_Off}"
    else
        echo -e "${Green}Current latest tag: ${latest_tag}${Color_Off}"
    fi
    
    # Extract version numbers (remove 'v' prefix)
    local version="${latest_tag#v}"
    local major minor patch
    
    # Parse version into components
    IFS='.' read -r major minor patch <<< "$version"
    
    # Ensure we have valid numbers (handle missing components)
    major=${major:-0}
    minor=${minor:-0}
    patch=${patch:-0}
    
    # Increment based on version type
    case "$version_type" in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
    esac
    
    local new_version="v${major}.${minor}.${patch}"
    
    echo -e "${Green}New version: ${new_version}${Color_Off}"
    
    # Check if tag already exists
    if git rev-parse "$new_version" >/dev/null 2>&1; then
        echo -e "${Red}Error: Tag ${new_version} already exists${Color_Off}"
        return 1
    fi
    
    # Create and push the tag
    CMD="git tag -a ${new_version} -m \"Release ${new_version}\""
    echo -e "${Green}Running Cmd:\n    ${CMD}${Color_Off}\n"
    eval "$CMD"
    
    if [ $? -ne 0 ]; then
        echo -e "${Red}Error: Failed to create tag${Color_Off}"
        return 1
    fi
    
    CMD="git push origin ${new_version}"
    echo -e "${Green}Running Cmd:\n    ${CMD}${Color_Off}\n"
    eval "$CMD"
    
    if [ $? -ne 0 ]; then
        echo -e "${Red}Error: Failed to push tag${Color_Off}"
        return 1
    fi
    
    echo -e "${Green}Successfully released ${new_version}${Color_Off}"
    return 0
}


setopt PROMPT_SUBST
# prompt
PROMPT='%(?^%F{green}[%n@%m] [%1~] [$(gbranch)]%f^%F{red}[%n@%m] [%1~] [$(gbranch)]%f)$ '

# in-place delete
bindkey '^[[3~'  delete-char
# zsh history
HISTFILE=$HOME/.zhistory
HISTSIZE=50000
SAVEHIST=50000
# setopt APPEND_HISTORY
setopt SHARE_HISTORY
history() { builtin history 1 }
# up/down searching
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down
# cmd line completion
autoload -U compinit && compinit
zstyle ':completion:*' menu select
# batch rename
autoload -U zmv
# extended globbing but don't error on no match
setopt EXTENDED_GLOB
unsetopt NOMATCH
autoload -U add-zsh-hook
add-zsh-hook precmd update_terminal_cwd
add-zsh-hook preexec update_terminal_cwd
add-zsh-hook chpwd update_terminal_cwd

# set vi mode and make the cursor a block underline cursor if we are in cmd mode
bindkey -v
# I like these bindings and use them all the time. Make sure they stay the same
bindkey "^R" history-incremental-search-backward
bindkey "^E" end-of-line
bindkey "^A" beginning-of-line
function zle-keymap-select zle-line-init zle-line-finish {
  case $KEYMAP in
    vicmd)      echo -ne "\e[4 q";; # block underline cursor for cmd
    viins|main) echo -ne "\e[5 q";; # line cursor
  esac

  zle reset-prompt
  zle -R
}
zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select

HOMEBREW_AUTO_UPDATE_SECS=2629746

# source in the worktree helpers
. ~/dotfiles/worktree.sh 2>/dev/null
# source in the macbook specific config
. ~/dotfiles/macbook.sh &>/dev/null
# source in the virtualenv helpers
. ~/dotfiles/virtualenv.sh 2>/dev/null
# source in the docker-compose helpers
. ~/dotfiles/docker.sh 2>/dev/null
# source in the untracked environment specific configuration
. ~/dotfiles/local-zshrc.sh 2>/dev/null

. "$HOME/.local/bin/env"

# Added by Antigravity
export PATH="/Users/joelholsteen/.antigravity/antigravity/bin:$PATH"
