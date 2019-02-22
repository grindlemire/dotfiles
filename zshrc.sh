# activate venv, otherwise create and activate
# This also rewrites the PYTHONPATH to be inside the virtualenv
venv() {
    # If we are already in a venv then end it and return early
    if [ "$PYTHONPATH" == $(pwd) ]; then
        vend
        return
    fi 

    # If a venv is not configured then create it
    if [ ! -d venv ]; then
        virtualenv venv
    fi

    # With an existing venv enter into it
    export _OLD_VIRTUAL_PYTHONPATH=${PYTHONPATH}
    export PYTHONPATH=`pwd`
    source venv/bin/activate
}

vend() {
    deactivate
    export PYTHONPATH=${_OLD_VIRTUAL_PYTHONPATH}
    unset _OLD_VIRTUAL_PYTHONPATH
}

# Get the nice ^r, ^a, and ^e behavior
set -o emacs

# aliases
alias la='ls -a'   # hidden
alias ll='ls -lh'  # long
alias lt='ls -lth' # long time sorted
alias lla='ls -lha' # long and hidden
alias emacs='emacs -nw'

# ls colors for bsd/linux
ls --color &>/dev/null 2>&1 && alias ls='ls --color=tty' || alias ls='ls -G'

alias godir='cd $HOME/go/src/github.com/grindlemire'


# Installed Apps added to PATH
export PATH=~/Apps/bin:$PATH

# editor needs to be set for commits without -m
export EDITOR='vim'

# go stuff
export GOPATH=$HOME/go
export PATH=/usr/local/go/bin:$GOPATH/bin:$PATH


###############################################################################
# zsh stuff
###############################################################################

# set window title and share pwd accross sessions
update_terminal_cwd() {
    local PWD_URL="file://$HOSTNAME${PWD// /%20}"
    printf '\e]7;%s\a' "$PWD_URL"
}

dssh() {
    if [ -n "$1" ]
    then
            docker exec -it $@ /bin/bash
    fi
}
dexec() {
    if [ -n "$1" ]
    then
            docker exec -it $@
    fi
}

git_branch() {
        printf "[%s]" "$(git branch 2>/dev/null | grep \* | cut -d ' ' -f2)"
}
setopt PROMPT_SUBST
# prompt
PROMPT='%(?^%F{green}[%n@%m] [%1~] $(git_branch)%f^%F{red}[%n@%m] [%1~] $(git_branch)%f)$ '

# in-place delete
bindkey '^[[3~'  delete-char
# zsh history
HISTFILE=$HOME/.zhistory
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
# setopt SHARE_HISTORY
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

# add in the untracked environment specific configuration
. ~/dotfiles/local-zshrc.sh 2>/dev/null