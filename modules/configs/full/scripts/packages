#!/usr/bin/env bash

set -e -o pipefail

# Function to list unique executables in a directory
list_executables() {
	ls -1 "$1" 2>/dev/null | awk '!seen[$0]++'
}

# Function to show notification
show_notification() {
	notify-send "$1" "$2"
}

# Check if the quickemu command is available
check_quickemu() {
	if ! command -v quickemu &>/dev/null; then
		show_notification "Error" "quickemu is not installed. Install it to use VMs."
		exit 1
	fi
}

# List unique executables in directories from $PATH and additional locations
selected_package=$( (
	IFS=: read -ra PATH_DIRS <<<"$PATH"
	for dir in "${PATH_DIRS[@]}"; do
		list_executables "$dir"
	done
	list_executables ~/.config/fish/functions/
	list_executables ~/.config/fish/scripts/ | grep -v "README.md"
	echo "windows10"
	echo "windows11"
	echo "macos-catalina"
) | dmenu -p "Packages:")

if [ -n "$selected_package" ]; then
	cd /home/$USER/VMS/
	check_quickemu

	case $selected_package in
	"windows10")
		vm_conf="windows-10.conf"
		;;
	"windows11")
		vm_conf="windows-11.conf"
		;;
	"macos-catalina")
		vm_conf="macos-catalina.conf"
		;;
	*.fish | *.sh)
		selected_package=$(echo "$selected_package" | sed 's/\(.fish\|\.sh\)//') # remove .fish/.sh extensions
		if [ "$selected_package" == "cdev" ]; then
			exec "$selected_package" &
		else
			$TERMINAL -e $SHELL -c "$selected_package; read -p 'Press Enter to exit!!' key"
		fi
		exit 0
		;;
	*)
		exec "$selected_package" &
		exit 0
		;;
	esac

	if ! [[ -e $vm_conf ]]; then
		show_notification "VM Config Not Found" "Create VM using quickget $selected_package."
	else
		show_notification "Launching VM" "Starting $selected_package VM..."
		quickemu --vm "$vm_conf" --screen 0
	fi
fi

exit 0
