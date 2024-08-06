#!/usr/bin/env bash

if [ $# -ne 2 ]; then
	echo "Swap files/folders"
	echo "Usage: swap <source> <destination>"
	exit 1
fi

source="$1"
destination="$2"

if [ ! -e "$source" ]; then
	echo "Source file/directory '$source' does not exist."
	exit 1
fi

if [ ! -e "$destination" ]; then
	echo "Destination file/directory '$destination' does not exists."
	exit 1
fi

tempDir=$(mktemp -d -t tempdir_XXXXXXXX)

mv "$source" "$tempDir/$source"
mv "$destination" "$source"
mv "$tempDir/$source" "$destination"

echo "Swapped files/directories successfully."
