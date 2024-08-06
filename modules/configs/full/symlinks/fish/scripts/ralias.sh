#!/usr/bin/env bash

f1(){
  file=~/.config/fish/config.fish;
  clear
  echo "==================================================="
  echo " WARNING: removes all lines containing the pattern"
  echo "          like 'no' removes '*no*' "
  echo ""
  echo " FILE: $file"
  echo "==================================================="
  echo "CONTENTS: "
  cat -n $file
  echo "==================================================="
  echo ""
  read -p "alias: " alias;
  cp $file $file.bak && cat $file.bak | grep "alias" | grep -v "$alias" > $file;
  echo ""
  echo "removed !";
}

f1
