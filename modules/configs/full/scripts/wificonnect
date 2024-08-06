#!/usr/bin/env bash

get_current_network() {
	nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2
}

disconnect_current_network() {
	local current_network="$1"
	nmcli connection down "$current_network"
}

connect_to_network() {
	local network_name="$1"
	local password="$2"

	nmcli device wifi connect "$network_name" password "$password"
}

list_available_networks() {
	nmcli -t -f ssid,signal dev wifi | sort -k2 -nr | uniq | awk -F: '{print $1" ("$2"%)"}'
}

main() {
	if [ "$#" -eq 0 ]; then
		current_network=$(get_current_network)
		disconnect_current_network "$current_network"
		nmcli connection up "$current_network"
	elif [ "$1" == "-l" ]; then
		networks=$(list_available_networks)
		selected_network=$(echo "$networks" | dmenu -p "Select a WiFi network:")

		if [ -n "$selected_network" ]; then
			network_name="${selected_network%% (*}"
			saved_networks=$(nmcli -t -f name connection show)

			if echo "$saved_networks" | grep -q "$network_name"; then
				disconnect_current_network "$(get_current_network)"
				nmcli connection up "$network_name"
			else
				password=$(echo | dmenu -p "Enter password for $network_name:")

				if [ -n "$password" ]; then
					disconnect_current_network "$(get_current_network)"
					connect_to_network "$network_name" "$password"
				else
					echo "Password not provided. Aborting."
				fi
			fi
		else
			echo "No network selected. Aborting."
		fi
	fi
}

main "$@"
