# some more ls aliases
alias ll='ls -alh'
alias la='ls -A'
alias l='ls -CFlh'

alias diskspace="du -S | sort -n -r |more"

alias folders="find . -maxdepth 1 -type d -print | xargs du -sk | sort -rn"

#history
export HISTFILESIZE=20000
export HISTSIZE=10000
#
## Ignore duplicates, ls without options and builtin commands
HISTCONTROL=ignoredups
#
# Prompt
BGREEN='\[\033[1;32m\]'
GREEN='\[\033[0;32m\]'
BRED='\[\033[1;31m\]'
RED='\[\033[0;31m\]'
BBLUE='\[\033[1;34m\]'
BLUE='\[\033[0;34m\]'
NORMAL='\[\033[00m\]'
PS1="${BLUE}(${RED}\w${BLUE}) ${NORMAL}\h ${RED} \$ ${NORMAL}"