#!/usr/bin/env bash

f1(){
    echo 'from f1';
}

f2(){
    echo 'from f2';
}

"$@"
