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
    nvim_dir=$XDG_CONFIG_HOME/nvim
  else
    nvim_dir=~/.config/nvim
  fi

  if [ ! -d $nvim_dir ]; then
    mkdir -p $nvim_dir
  fi

  ln -s $current_dir/.vimrc $nvim_dir/init.vim
fi

