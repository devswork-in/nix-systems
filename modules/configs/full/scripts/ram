#!/usr/bin/env bash

# Get memory usage in MB
used_mb=$(free -m | awk '/^Mem:/{print $3}')

# Check if memory usage is 1024 MB or more
if [ "$used_mb" -ge 1024 ]; then
	# Convert to GB and display
	used_gb=$(echo "scale=2; $used_mb / 1024" | bc)
	echo "$used_gb GB"
else
	# Display in MB
	echo "$used_mb MB"
fi
