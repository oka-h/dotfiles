#! /bin/bash

if type zsh > /dev/null 2>&1; then
  zshrc=$(cd $(dirname $0) && pwd)/.zshrc
  ln -s $zshrc ~/.zshenv
fi

