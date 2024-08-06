#!/usr/bin/env bash

set -e -o pipefail

temp=0
cores=0
loadavg=$(grep -o "^[^ ]*" /proc/loadavg)
cpu_temps=$(sensors | awk '/Tctl:/ {print $2}' | grep -oE '[0-9]+')

for x in $cpu_temps; do
	cores=$((cores + 1))
	temp=$((temp + x))
done

if [ "$cores" -ne 0 ]; then
	temp=$((temp / cores))
fi

echo "$loadavg/$temp°C"
