# ------------------------------------------------------------------------------
# dotfiles/bash/.bashrc
# ------------------------------------------------------------------------------

[ -f /etc/bashrc ] && source /etc/bashrc

set bell-style none

bashrc_user='\[\033[32m\]\u@\H\[\033[0m\]'
bashrc_cdir='\[\033[33m\]\w\[\033[0m\]'
bashrc_multi_line='\[\033[32m\]>\[\033[0m\]'
bashrc_mark='\$'

PS1="
$bashrc_user $bashrc_cdir
$bashrc_mark "

PS2="$bashrc_multi_line $bashrc_mark "


HISTFILE=~/.bash_history
HISTSIZE=10000
SAVEHIST=10000

set hist_ignore_dups

set share_history        

# Set vi keybind.
set -o vi

bind '"\C-p": history-search-backward'
bind '"\C-n": history-search-forward'

case "${OSTYPE}" in
  freebsd*|darwin*)
    alias ls="ls -G -w"
    ;;
  linux*|cygwin)
    alias ls="ls --color"
    ;;
esac

alias la="ls -a"
alias ll="ls -l"
alias lal="ls -al"
alias lla="ls -al"

alias javac='javac -J-Dfile.encoding=UTF-8'
alias java='java -Dfile.encoding=UTF-8'


[ -f ~/.shellrc_local ] && source ~/.shellrc_local
[ -f ~/.bashrc_local ] && source ~/.bashrc_local

