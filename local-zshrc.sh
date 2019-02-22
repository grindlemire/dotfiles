# Configure Vagrant to work from anywhere 
export VAGRANT_CWD=~/go/src/github.com/logrhythm/autobot/vagrant
alias bvagrant='VAGRANT_CWD=~/go/src/github.com/logrhythm/bicycle/vagrant vagrant'

# update alias for logrhythm and my github
alias lgodir='cd $HOME/go/src/github.com/grindlemire'
alias godir='cd $HOME/go/src/github.com/logrhythm'

# Installed Apps added to PATH
export PATH=~/Apps/bin:$PATH

# Jenv for manipulating the version of java
export PATH=~/.jenv/bin:$PATH
eval "$(jenv init -)"

# Google Cloud 

export PATH=~/google-cloud-sdk/bin:$PATH

# The next line updates PATH for the Google Cloud SDK.
if [ -f '$HOME/google-cloud-sdk/path.zsh.inc' ]; then . '$HOME/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '$HOME/google-cloud-sdk/completion.zsh.inc' ]; then . '$HOME/google-cloud-sdk/completion.zsh.inc'; fi
