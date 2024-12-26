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
if [[ ! -d "/tmp/nix-systems" ]]; then
  log "/tmp/nix-systems does not exist. Cloning repository..."
  if ! git clone https://github.com/creator54/nix-systems /tmp/nix-systems; then
    err "Cloning of nix-systems failed!"
  fi
  log "Repository cloned successfully."
else
  # Optional: Pull the latest changes if directory exists
  log "/tmp/nix-systems already exists. Updating repository..."
  (
    cd /tmp/nix-systems || err "Could not enter /tmp/nix-systems directory."
    git fetch --all && git pull --rebase || warn "Could not update repository. Proceeding with existing contents."
  )
fi

#---------------------------------------
# Run mkpart.sh
#---------------------------------------
log "Running mkpart.sh on device: $DEVICE"
if ! echo "yes" | sudo bash /tmp/nix-systems/mkpart.sh "$DEVICE"; then
  err "mkpart.sh failed."
fi

log "Partitioning with mkpart.sh completed."

#---------------------------------------
# Run nixos-install
#---------------------------------------
log "Running nixos-install with flake: $FLAKE"
if ! sudo nixos-install --flake /tmp/nix-systems/#"$FLAKE" --impure; then
  err "nixos-install failed!"
fi
log "nixos-install completed successfully."
log "Setup completed successfully!"
exit 0

