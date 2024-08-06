#!/usr/bin/env bash

set -e

device=$(echo "$(bluetoothctl devices | cut -d " " -f3-)" | dmenu -p "Select Bluetooth Device: ")

device_id=$(bluetoothctl devices | grep "$device" | cut -d " " -f2)

notify-send -u normal "Connecting: $device($device_id)"

bluetoothctl connect $device_id
notify-send -u normal "Connected : $device($device_id)"
