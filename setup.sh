#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# setup.sh
#
# This script performs the following tasks:
# 1. Dependency checks for required commands.
# 2. Clone nix-systems into /tmp and run partitioning from there.
# 3. Clone nix-systems into /mnt/etc/nixos after mounts are ready.
# 4. Fix permissions.
# 5. Running nixos-install against the specified flake.
#
# Usage: ./setup.sh <device> <flake>
#-------------------------------------------------------------------------------

set -o errexit
set -o nounset
set -o pipefail

#---------------------------------------
# Logging Functions
#---------------------------------------
log() {
  echo "[INFO]  $(date +'%F %T')  $*"
}

warn() {
  echo "[WARN]  $(date +'%F %T')  $*" >&2
}

err() {
  echo "[ERROR] $(date +'%F %T')  $*" >&2
  exit 1
}

#---------------------------------------
# Usage / Help
#---------------------------------------
usage() {
  echo "Usage: $0 <device> <flake>"
  exit 1
}

#---------------------------------------
# Check script arguments
#---------------------------------------
if [[ $# -ne 2 ]]; then
  usage
fi

DEVICE="$1"
FLAKE="$2"

#---------------------------------------
# Dependency Checks
#---------------------------------------
check_dependency() {
  local dep="$1"
  command -v "$dep" >/dev/null 2>&1 || err "Missing required command: '$dep' is not installed or not in PATH."
}

log "Performing dependency checks..."

DEPENDENCIES=("sudo" "git" "bash" "nixos-install")
for dep in "${DEPENDENCIES[@]}"; do
  check_dependency "$dep"
done

log "All dependencies are present."

#---------------------------------------
# Clone repo into /tmp for partitioning
#---------------------------------------
TMP_DIR="/tmp/nix-systems"

log "Cloning nix-systems repository into $TMP_DIR for partitioning..."

sudo rm -rf "$TMP_DIR"
if ! sudo git clone https://github.com/devswork-in/nix-systems "$TMP_DIR"; then
  err "Cloning of nix-systems into /tmp failed!"
fi

log "Repository cloned into /tmp successfully."

#---------------------------------------
# Run mkpart.sh from /tmp
#---------------------------------------
log "Running mkpart.sh on device: $DEVICE"

if ! echo "yes" | sudo bash "$TMP_DIR/mkpart.sh" "$DEVICE"; then
  err "mkpart.sh failed."
fi

log "Partitioning with mkpart.sh completed."

#---------------------------------------
# Clone repo into /mnt/etc/nixos
#---------------------------------------
sudo mkdir -p "/mnt/etc"
TARGET_DIR="/mnt/etc/nixos"

log "Copy nixos config to $TARGET_DIR..."

sudo rm -rf "$TARGET_DIR"
if ! sudo cp -r $TMP_DIR "$TARGET_DIR"; then
  err "Copying to /mnt/etc/nixos failed!"
fi

log "Repository copied to /mnt/etc/nixos successfully."

#---------------------------------------
# Run nixos-install
#---------------------------------------
log "Running nixos-install with flake: $FLAKE"

export NIX_CONFIG_DIR="/etc/nixos"

if ! sudo -E nixos-install --flake "$TARGET_DIR"#"$FLAKE" --impure; then
  err "nixos-install failed!"
fi

#---------------------------------------
# Fix permissions so user can edit later
#---------------------------------------
log "Fixing permissions for the repo..."
sudo chown -R 1000:100 "$TARGET_DIR"

log "nixos-install completed successfully."

if ! sudo chown -R 1000:100 /mnt/home/*/.*; then
  err "Failed to fix permissions for dotfiles."
fi

log "Permissions fixed for dotfiles."
log "Setup completed successfully!"

exit 0

