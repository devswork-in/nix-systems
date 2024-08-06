#!/usr/bin/env bash

set -e -o pipefail

# Function to get the audio volume percentage
get_volume_percentage() {
	local volume_info=$(amixer sget Master)
	local volume_percentage=$(echo "$volume_info" | awk -F"[][]" '/Left/ { print $2 }' | cut -d'%' -f1 | xargs)
	echo "$volume_percentage"
}

# Function to check if the audio is muted
is_audio_muted() {
	local toggle_status=$(amixer get Master toggle | xargs | awk '{print $NF}')
	[[ "$toggle_status" = "[off]" ]]
}

if [ -z "$1" ]; then
	if is_audio_muted; then
		printf "󰎊 %s%%" "$(get_volume_percentage)"
	else
		printf "󰽴 %s%%" "$(get_volume_percentage)"
	fi

	# Uncomment this block to include Bluetooth device battery info if connected
	# if bluetoothctl info "$1" | grep -q "Connected: yes"; then
	#   printf ":%s\n" "$(bluetooth_battery "$1" | cut -d' ' -f6)"
	# fi
else
	echo "Usage:"
	echo "audio     : Shows volume percentage + battery info if a Bluetooth device is connected"
fi
