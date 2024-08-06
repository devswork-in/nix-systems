#!/usr/bin/env bash

set -e -o pipefail

TMP_FILE="/tmp/.battery_info"
acpi -i >"$TMP_FILE"

case "$1" in
"state")
	awk '{print $3}' "$TMP_FILE" | head -n 1 | cut -d',' -f1
	;;
"%")
	battery_percent=$(awk '{print $4}' "$TMP_FILE" | head -n 1 | cut -d',' -f1)
	echo "$battery_percent"
	if [ "$battery_percent" -le 50 ] && [ "$battery_percent" -gt 30 ] && [ ! -f "/tmp/.battery_notif_50" ]; then
		notify-send -u normal "Battery at $battery_percent%" "Battery level is getting low."
		touch "/tmp/.battery_notif_50"
	elif [ "$battery_percent" -le 30 ] && [ "$battery_percent" -gt 10 ] && [ ! -f "/tmp/.battery_notif_30" ]; then
		notify-send -u critical "Battery at $battery_percent%" "Battery level is critically low. Please save your work and connect to a power source."
		touch "/tmp/.battery_notif_30"
	elif [ "$battery_percent" -le 10 ] && [ ! -f "/tmp/.battery_notif_10" ]; then
		notify-send -u critical "Battery at $battery_percent%" "Battery level is critically low. Please connect to a power source immediately."
		touch "/tmp/.battery_notif_10"
	fi
	;;
"rem")
	rem=$(awk '{print $5}' "$TMP_FILE" | head -n 1)
	rem_check=$(awk '{print $5}' "$TMP_FILE" | head -n 1 | cut -d':' -f1)
	if [ ! -z "$rem" ]; then
		if [ "$rem_check" -eq 0 ]; then
			rem=$(echo "$rem" | cut -d':' -f2,3 | sed 's/:/m:/;s/$/s/')
		elif [[ "$rem_check" =~ ^[0-9]+$ ]]; then
			rem=$(echo "$rem" | sed 's/:/h:/;s/:/m:/2;s/$/s/')
		fi

		if ! [[ "$rem" =~ discharging|unknown ]]; then
			printf "[%s]" "$(echo "$rem" | cut -d':' -f1,2)"
		fi
	fi
	;;
"fancy")
	state=$($0 state)
	if [ "$state" = "Discharging" ]; then
		icon=" "
		if [ -f "/tmp/.battery_notif_charge" ] || [ -f "/tmp/.battery_notif_full" ]; then
			rm "/tmp/.battery_notif_charge" || rm "/tmp/.battery_notif_full"
		fi
		if [ ! -f "/tmp/.battery_notif_discharge" ]; then
			touch "/tmp/.battery_notif_discharge"
			#notify-send -u normal "Battery: $($0)" "Discharging, running on Battery !"
		fi
	elif [ "$state" = "Full" ]; then
		icon=" "
		rem="full"
		if [ ! -f "/tmp/.battery_notif_full" ]; then
			touch "/tmp/.battery_notif_full"
			notify-send -u normal "Battery: $($0)" "Battery fully charged !"
		fi
	else
		icon="⚡️"
		if [ ! -f "/tmp/.battery_notif_charge" ]; then
			touch "/tmp/.battery_notif_charge"
			#notify-send -u normal "Battery: $($0)" "Charging, connected to Power Supply !"
			if [ -f "/tmp/.battery_notif_discharge" ]; then
				rm "/tmp/.battery_notif_discharge"
			fi
		fi
	fi
	printf "%s %s %s\n" "$icon" "$($0 %)" "$($0 rem)"
	;;
"info")
	cat $TMP_FILE
	;;
"")
	$0 fancy
	;;
*)
	echo "usage: $0 {state|%|rem|fancy|info}"
	echo
	echo "state   :  charging/discharging"
	echo "%       :  battery left"
	echo "rem     :  time left to charge/discharge"
	echo "fancy   :  fancy battery info"
	echo "info    :  battery info verbose"
	;;
esac
