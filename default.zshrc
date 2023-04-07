HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=100000

zstyle :compinstall filename '/home/$(whoami)/.zshrc'

autoload -Uz compinit
compinit

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Common environment variables
export AWS_SDK_LOAD_CONFIG=1
export AWS_DEFAULT_PROFILE=sand
export AWS_DEFAULT_REGION=us-west-2
export AWS_PROFILE=$AWS_DEFAULT_PROFILE
export AWS_REGION=$AWS_DEFAULT_REGION
