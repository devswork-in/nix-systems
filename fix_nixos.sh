#!/usr/bin/env bash
set -e

echo "Applying fixes to /etc/nixos..."

# 1. Ensure directories exist
sudo mkdir -p /etc/nixos/modules/core/configs/common/scripts
sudo mkdir -p /etc/nixos/modules/core/configs/common/env

# 2. Copy the Scripts
echo "Installing management scripts..."

# Ensure /etc/nixos destination is clean (remove broken symlinks)
sudo rm -f /etc/nixos/modules/core/configs/common/scripts/sys*

# Copy fresh scripts from home dir to /etc/nixos
sudo cp -Lf /home/creator54/nix-systems/modules/core/configs/common/scripts/sys* /etc/nixos/modules/core/configs/common/scripts/
sudo chmod +x /etc/nixos/modules/core/configs/common/scripts/sys*

# Symlink to user's local bin
mkdir -p /home/creator54/.local/bin
chown creator54:users /home/creator54/.local/bin

# Force remove existing files/links
rm -f /home/creator54/.local/bin/sysrebuild
rm -f /home/creator54/.local/bin/sysupdate
rm -f /home/creator54/.local/bin/sysedit

# Copy valid scripts (NO SYMLINKS)
echo "Copying scripts to ~/.local/bin..."
cp -f /etc/nixos/modules/core/configs/common/scripts/sysrebuild /home/creator54/.local/bin/sysrebuild
cp -f /etc/nixos/modules/core/configs/common/scripts/sysupdate /home/creator54/.local/bin/sysupdate
cp -f /etc/nixos/modules/core/configs/common/scripts/sysedit /home/creator54/.local/bin/sysedit

chown creator54:users /home/creator54/.local/bin/sys*
chmod +x /home/creator54/.local/bin/sys*

# 3. Copy the Clean Aliases
echo "Updating aliases..."
sudo cp /home/creator54/nix-systems/modules/core/configs/common/aliases /etc/nixos/modules/core/configs/common/aliases

# 4. Copy the Variable Logic (Activation Script)
echo "Updating variable logic..."
sudo cp /home/creator54/nix-systems/modules/core/vars/default.nix /etc/nixos/modules/core/vars/default.nix
sudo cp /home/creator54/nix-systems/profiles/base.nix /etc/nixos/profiles/base.nix

echo "Fix applied."
echo "Please restart your terminal."
