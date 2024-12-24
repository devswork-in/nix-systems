#!/bin/bash

# Ensure that the required arguments are passed
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <device> <flake>"
    exit 1
fi

# Assign arguments to variables
DEVICE=$1
FLAKE=$2

# Clone the repository to /tmp
echo "Cloning the repository..."
git clone https://github.com/creator54/nix-systems /tmp/nix-systems

# Navigate to the cloned directory
cd /tmp/nix-systems || { echo "Failed to navigate to /tmp/nix-systems"; exit 1; }

# Run mkpart.sh with sudo and automatically confirm with 'yes'
echo "Running mkpart.sh with sudo on $DEVICE..."
echo "yes" | sudo bash mkpart.sh "$DEVICE"

# Run nixos-rebuild switch with sudo and the correct value passed for the flake
echo "Running nixos-rebuild switch with the flake value: $FLAKE"
sudo nixos-rebuild switch --flake /tmp/nix-systems/#"$FLAKE" --impure

