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
    config_dir=$XDG_CONFIG_HOME
  else
    config_dir=~/.config
  fi
  if [ ! -d $config_dir ]; then
    mkdir $config_dir
  fi

  nvim_dir=$config_dir/nvim
  if [ ! -d $nvim_dir ]; then
    mkdir $nvim_dir
  fi

  ln -s $current_dir/.vimrc $nvim_dir/init.vim
fi

