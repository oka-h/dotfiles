#! /bin/bash

if type zsh > /dev/null 2>&1; then
  zshenv=$(cd $(dirname $0) && pwd)/.zshenv
  ln -s $zshenv ~/.zshenv
fi

