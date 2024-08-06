#!/usr/bin/env bash

set -e -o pipefail

if echo $1| grep "git@" &>/dev/null
then
  dirname=$(echo $1|cut -d'/' -f2)
else
  dirname=$(echo $1| cut -d'/' -f5)
fi

if [ -z $1 ]
then
  echo "usage: fgit https://github.com/repo_owner/repo_name"
else
  git clone --filter=blob:none --no-checkout --depth 1 --sparse $1 &>/dev/null
  cd $dirname
  git sparse-checkout init --cone
  echo
  read -p "get $dirname/" subdir
  echo
  git sparse-checkout add $subdir
  git checkout
  mv $subdir ../ #move requested dir to current dir
  rm -rf ../$dirname #remove useless repo
  cd ..
fi
