#! /bin/bash

for file in `dirname $0`/*; do
  if [ -f $file/link.sh ]; then
    $file/link.sh
  fi
done

