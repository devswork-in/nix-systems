#!/usr/bin/env bash

WORKDIR=/tmp/cdev

kittyConfig=$(
	cat <<EOF
layout tall

# first kitty window
launch --title "Source" vim "+5 normal $" code.cpp

# second kitty window
launch --title "Input" vim  inputs

# third kitty window
launch --title "Output" bash -c "ls code.cpp inputs | entr sh -c 'clear;printf \"Output:\";echo;echo; g++ code.cpp -o temp;./temp<inputs>output;cat output;rm -rf temp'"
EOF
)

if [[ -z "$1" ]]; then
	mkdir -p $WORKDIR
	cd $WORKDIR
	touch $WORKDIR/code.cpp $WORKDIR/inputs $WORKDIR/output
	printf '#include<bits/stdc++.h>\nusing namespace std;\n\nint main(){\n  cout<<"Hello World";\n}' >$WORKDIR/code.cpp

	configFile=$(mktemp)

	# Save the commands to a temporary file
	echo "$kittyConfig" >"$configFile"

	# Print the content of the temporary file
	kitty --session "$configFile"

	rm -rf $WORKDIR
else
	src=$(echo $(pwd)/$1)
	if echo $src | grep -E ".cpp|.cxx" &>/dev/null; then
		ls $src | entr -c sh -c 'printf "Output :\n\n" && g++ $src -o temp && ./temp && rm -rf temp'
	else
		ls $src | entr -c sh -c 'printf "Output :\n\n" && gcc $src -o temp && ./temp && rm -rf temp'
	fi
fi
