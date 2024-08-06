#!/usr/bin/env bash

f1(){
    read -p "Give file name: " file;
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
    read -p "pattern: " pattern;
    cp $file $file.bak && cat $file.bak | grep -v "$pattern" > $file;
    echo ""
    echo "removed !";
}

f1
