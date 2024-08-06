#!/usr/bin/env bash

function show_help {
	echo "Usage: "
	echo "v *.jpg/png/svg                   : opens in sxiv,mark to delete !"
	echo "v *.mp4/mkv/mp3/opus/webm/gif     : opens in mpv"
	echo "v *.pdf                           : opens in zathura"
	echo "v *.iso                           : path copied to clipboard"
	echo "v *.md                            : preview using glow and bat "
	echo "v *.v                             : passes to the V lang Compiler "
	echo "v repl                            : V lang repl "
	echo "v run *.v                         : run the v program "
	echo "v dir/                            : cd dir/"
	echo "v http/https://*                  : proceeds as get function"
	echo "v -r                              : tries v on the most recent file on $PWD"
	echo "v -p                              : force bat preview"
	echo "v -h                              : help"
}

if [ $# -eq 0 ]; then
	show_help
	exit 0
fi

while [ $# -gt 0 ]; do
	case $1 in
	-p)
		shift
		bat --style=numbers,changes --color=always "$@"
		exit 0
		;;
	-r)
		shift
		v "$(ls --time birth | head -n 1)"
		exit 0
		;;
	-h)
		show_help
		exit 0
		;;
	*.jpg | *.png | *.svg)
		sxiv -o "$@" && commandline -f repaint
		exit 0
		;;
	*.mp4 | *.mkv | *.mp3 | *.opus | *.webm | *.gif)
		mpv "$@"
		exit 0
		;;
	*.pdf)
		zathura "$@" &>/dev/null
		exit 0
		;;
	*.iso)
		echo "Copied PATH=$1 to clipboard"
		echo "$1" | xclip -selection clipboard
		exit 0
		;;
	*.md)
		glow "$@" -p bat 2>/dev/null
		exit 0
		;;
	*.v | repl | run | install)
		bash v "$@"
		exit 0
		;;
	http* | https*)
		get "$@"
		exit 0
		;;
	dir/*)
		cd "$@"
		exit 0
		;;
	*)
		$PAGER "$@"
		exit 0
		;;
	esac
done
