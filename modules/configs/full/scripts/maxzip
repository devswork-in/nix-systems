#!/usr/bin/env bash

# maxzip: A script to compress/decompress directories using tar and brotli

# Default compression level
level=6

# Function to display help
show_help() {
	echo "Usage: maxzip [OPTIONS]... [FILE|DIRECTORY]..."
	echo "Compress or decompress files or directories using tar and brotli."
	echo
	echo "Options:"
	echo "  -l, --level [0-11]    Set the brotli compression level (default is $level, the highest)."
	echo "  -d, --decompress      Decompress the given .tar.br file."
	echo "  -h, --help            Display this help and exit."
	echo "  -b, --brotli-options  Additional options to pass to brotli (e.g., -#9 -v)."
	echo
	echo "Examples:"
	echo "  maxzip -l 5 my_directory"
	echo "  maxzip --decompress my_file.tar.br"
}

# Temp directory for compression
tmp_dir="/tmp"

# Work directory from where the script is invoked
work_dir=$(pwd)

# Brotli additional options
brotli_options=""

# Parse command-line options
while [[ $# -gt 0 ]]; do
	case $1 in
	-l | --level)
		level="$2"
		shift # past argument
		shift # past value
		;;
	-d | --decompress)
		decompress=1
		shift # past argument
		;;
	-h | --help)
		show_help
		exit 0
		;;
	-b | --brotli-options)
		brotli_options="$2"
		shift # past argument
		shift # past value
		;;
	*) # file or directory to compress/decompress
		target=$1
		shift # past argument
		;;
	esac
done

# Check if target is provided
if [ -z "$target" ]; then
	echo "Error: No target file or directory specified."
	show_help
	exit 1
fi

# Determine the output filename
if [ -n "$decompress" ]; then
	# Decompress
	if [ -f "$target" ]; then
		# If the user didn't specify an output name, remove ".tar.br" from the original filename
		output="${target%.tar.br}"
	else
		echo "Error: File $target not found."
		exit 1
	fi
else
	# Compress
	if [ -d "$target" ]; then
		# If it's a directory, append ".tar.br" to the directory name
		output="$target.tar.br"
	elif [ -f "$target" ]; then
		# If it's a file, append ".tar.br" to the file name
		output="${target}.tar.br"
	else
		echo "Error: File or directory $target not found."
		exit 1
	fi
fi

# Create a temporary directory in /tmp for the operation
temp_dir=$(mktemp -d "$tmp_dir/maxzip_tmp.XXXXXXXXXX" || mktemp -d -t "maxzip_tmp")

# Copy the target file or directory to the temporary directory
cp -r "$target" "$temp_dir"
if [ $? -ne 0 ]; then
	echo "Error: Failed to copy $target to temporary directory."
	exit 1
fi

# Change to the temporary directory
cd "$temp_dir" || exit 1

# Compose the brotli command with additional options
brotli_command="brotli $brotli_options"

if [ -n "$decompress" ]; then
	# Decompress
	$brotli_command --decompress "$target" -o "$output" | pv -pte -s "$(du -sb "$target" | awk '{print $1}')" >/dev/null
	if [ $? -ne 0 ]; then
		echo "Error: Decompression failed."
		exit 1
	fi
	tar -xf "$output" -C "$work_dir"
	if [ $? -ne 0 ]; then
		echo "Error: Failed to extract tar file."
		exit 1
	fi
	rm "$output"
	if [ $? -ne 0 ]; then
		echo "Error: Failed to remove temporary file."
		exit 1
	fi
else
	# Compress
	tar -cf - "$target" | $brotli_command -c | pv -pte -s "$(du -sb "$target" | awk '{print $1}')" >"$output"
	if [ $? -ne 0 ]; then
		echo "Error: Compression failed."
		exit 1
	fi
	# Move the compressed/decompressed file to the original location
	mv "$temp_dir/$output" "$work_dir"
fi

# Clean up the temporary directory in /tmp
rm -rf "$temp_dir"
