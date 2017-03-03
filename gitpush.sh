#! /bin/bash

echo "git add *"
git add *
# git reset HEAD $0

echo -n "git commit -m "
read message
git commit -m "$message"

echo git push origin master
git push origin master

