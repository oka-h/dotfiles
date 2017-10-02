#! /bin/bash

if type bash > /dev/null 2>&1; then
  bashrc=$(cd $(dirname $0) && pwd)/.bashrc
  ln -s $bashrc ~/.bashrc
fi

