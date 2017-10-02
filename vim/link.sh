#! /bin/bash

current_dir=$(cd $(dirname $0) && pwd)

if type vim > /dev/null 2>&1; then
  ln -s $current_dir/.vimrc ~/.vimrc
fi

if type gvim > /dev/null 2>&1; then
  ln -s $current_dir/.gvimrc ~/.gvimrc
fi

if type nvim > /dev/null 2>&1; then
  if [ -n "$XDG_CONFIG_HOME" ]; then
    init_vim=$XDG_CONFIG_HOME/nvim/init.vim
  else
    init_vim=~/.config/nvim/init.vim
  fi
  ln -s $current_dir/.vimrc $init_vim
fi

