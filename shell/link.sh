#! /bin/bash

if type bash > /dev/null 2>&1; then
  bashrc=$(cd $(dirname $0) && pwd)/.bashrc
  ln -s $bashrc ~/.bashrc
fi

if type zsh > /dev/null 2>&1; then
  zshenv=$(cd $(dirname $0) && pwd)/.zshenv
  ln -s $zshenv ~/.zshenv
fi
