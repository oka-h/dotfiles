# ------------------------------------------------------------------------------
# dotfiles/shell/.bashrc
# ------------------------------------------------------------------------------

source $(dirname $(readlink ~/.bashrc))/shellrc

export HISTFILE=~/.bash_history

user='\[\033[38;05;173m\]\u@\H'
cdir='\[\033[38;05;242m\]\w'
multi_line='\[\033[38;05;226m\]>'
restore_color='\[\033[0m\]'
mark='\$'

export PS1="
$user $cdir$restore_color
$mark "
export PS2="$multi_line$restore_color $mark "

unset user
unset cdir
unset multi_line
unset restore_color
unset mark


set share_history        
set hist_ignore_dups
set bell-style none
set -o vi

bind '"\C-p": history-search-backward'
bind '"\C-n": history-search-forward'

cd-upper() {
  echo \$ cd ..
  cd ..
  pwd
}

bind -x '"\C-k": cd-upper'

[ -f ~/.shellrc_local ] && source ~/.shellrc_local
