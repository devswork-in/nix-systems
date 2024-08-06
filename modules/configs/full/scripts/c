#!/usr/bin/env bash
#ISSUE: creates a child shell with every $SHELL

set -e -o pipefail

if [ -z $1 ]; then
  cd ..;
elif [ -d $1 ]; then
  cd $1;
elif [ -e $1 ]; then
  filename=$(echo $1 | cut -d/ -f3);
  cd $(echo $1 | sed "s/$filename//");
elif [[ $1 =~ ^[0-9]+$ ]]; then
  if [ $1 = "1" ]; then
    cd ..;
  else
    dir_count=$(pwd | grep -o "/" | wc -l);
    go_back=$(($dir_count - $1 + 2));
    cd $(pwd | awk -F $(pwd | cut -d'/' -f$go_back) '{print $1}');
  fi;
else
  echo "Directory doesn't exit !";
  read -p "Press enter to create ! " ans;
  if [ "$ans" = "y" ] || [ "$ans" = "" ]; then
    mkdir -p $1;
    cd $1;
  fi;
fi;

$SHELL
