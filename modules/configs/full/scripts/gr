#!/usr/bin/env bash

if [[ "$1" = "-u" || "$1" = "--update" ]]; then
	url=$(git remote -v | grep origin | awk '{print $2}' | sed -e 's/https:\/\//git@/g' -e 's/\//:/' -e '/\.git/! s/$/.git/' | head -n 1 | xargs)
	echo $url
	gr remove origin
	git remote add origin $url
else
	git remote $@
fi
