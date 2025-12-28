#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# setup.sh
#
# This script performs the following tasks:
# 1. Dependency checks for required commands.
# 2. Partitioning using mkpart.sh (with sudo).
# 3. Cloning or updating the nix-systems repository.
# 4. Running nixos-install against the specified flake.
# 5. Moving the nix-systems repository into the user’s home directory.
#
# Usage: ./setup.sh <device> <flake>
#-------------------------------------------------------------------------------

set -o errexit  # Exit immediately on command failure
set -o nounset  # Treat unset variables as an error
set -o pipefail # Pipeline fails on the first command which fails

#---------------------------------------
# Logging Functions
#---------------------------------------
log() {
  # Prints a log message with a date/time prefix
  # Usage: log "This is a log message"
  echo "[INFO]  $(date +'%F %T')  $*"
}

warn() {
  # Prints a warning message
  # Usage: warn "This is a warning message"
  echo "[WARN]  $(date +'%F %T')  $*" >&2
}

err() {
  # Prints an error message and exits
  # Usage: err "This is an error message"
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
# Clone or update the nix-systems repository
#---------------------------------------
TARGET_DIR="/mnt/etc/nixos"

if [[ ! -d "$TARGET_DIR" ]]; then
  log "$TARGET_DIR does not exist. Cloning repository..."
  # Create directory if it doesn't exist (git clone will create the last component if needed, 
  # but here we want to clone contents INTO /mnt/etc/nixos if we want the repo root to be nixos)
  # Actually standard practice: git clone <url> /mnt/etc/nixos
  if ! sudo git clone https://github.com/devswork-in/nix-systems "$TARGET_DIR"; then
    err "Cloning of nix-systems failed!"
  fi
  log "Repository cloned successfully."
else
  # Optional: Pull the latest changes if directory exists
  log "$TARGET_DIR already exists. Updating repository..."
  (
    cd "$TARGET_DIR" || err "Could not enter $TARGET_DIR directory."
    sudo git fetch --all && sudo git pull --rebase || warn "Could not update repository. Proceeding with existing contents."
  )
fi

# Fix permissions so user can edit later
log "Fixing permissions on cloned repo..."
sudo chown -R 1000:100 "$TARGET_DIR"

#---------------------------------------
# Run mkpart.sh
#---------------------------------------
log "Running mkpart.sh on device: $DEVICE"
if ! echo "yes" | sudo bash "$TARGET_DIR/mkpart.sh" "$DEVICE"; then
  err "mkpart.sh failed."
fi

log "Partitioning with mkpart.sh completed."

#---------------------------------------
# Run nixos-install
#---------------------------------------
log "Running nixos-install with flake: $FLAKE"
# We export NIX_CONFIG_DIR=/etc/nixos so the flake (running in host) generates 
# paths pointing to /etc/nixos (where they will be on the target system).
export NIX_CONFIG_DIR="/etc/nixos"

if ! sudo -E nixos-install --flake "$TARGET_DIR"#"$FLAKE" --impure; then
  err "nixos-install failed!"
fi
log "nixos-install completed successfully."
if ! sudo chown -R 1000:100 /mnt/home/*/.*; then
  err "Failed to fix permissions for dotfiles."
fi
log "Permissions fixed for dotfiles."
log "Setup completed successfully!"
exit 0
