#!/usr/bin/env bash

# Ensure that the required arguments are passed
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <device> <flake>"
    exit 1
fi

# Assign arguments to variables
DEVICE=$1
FLAKE=$2

# Run mkpart.sh with sudo and automatically confirm with 'yes'
echo "Running mkpart.sh with sudo on $DEVICE..."
echo "yes" | sudo bash /mnt/nix-systems/mkpart.sh "$DEVICE" || { echo "mkpart.sh failed!"; exit 1; }

sleep 1

# Check if the repository has already been cloned
if [ ! -d "/mnt/nix-systems" ]; then
    # Clone the repository to /mnt/nix-systems if it does not exist
    echo "Cloning the repository into /mnt/nix-systems..."
    git clone https://github.com/creator54/nix-systems /mnt/nix-systems || { echo "Cloning failed!"; exit 1; }
else
    echo "/mnt/nix-systems already exists. Skipping clone."
fi

# Run nixos-install with sudo and the correct value passed for the flake
echo "Running nixos-install with the flake value: $FLAKE"
sudo nixos-install --flake /mnt/nix-systems/#"$FLAKE" --impure || { echo "nixos-install failed!"; exit 1; }

# Move nix-systems to the home directory of the user with UID 1000
echo "Moving nix-systems to the home directory of the user with UID 1000..."

# Assuming the home directory is under /mnt/home/ and the user with UID 1000 is the first user
USER_HOME="/mnt/home/*"

# Ensure the home directory exists
if [ -d "$USER_HOME" ]; then
    sudo mv /mnt/nix-systems "$USER_HOME/nix-systems" || { echo "Moving nix-systems failed!"; exit 1; }
    echo "Changing ownership of nix-systems directory..."
    sudo chown -R 1000:1000 "$USER_HOME/nix-systems" || { echo "Failed to change ownership!"; exit 1; }
else
    echo "Home directory for user with UID 1000 not found!"
    exit 1
fi

echo "Setup completed successfully!"

