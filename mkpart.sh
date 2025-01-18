#!/usr/bin/env bash
# Script to partition, format and mount drives for a Linux installation
# Usage: ./mkpart.sh /dev/sdX|/dev/nvmeXnY [unmount|partition|format|verify|mount|all]
#
# This script handles:
# - Creating GPT partition table
# - Creating and formatting boot (FAT32), root (ext4) and home (ext4) partitions
# - Mounting partitions in the correct order for installation
# - Verification of partition types and mount points
#
# The script creates:
# - A 2GB boot partition (FAT32)
# - An 80GB root partition (ext4) 
# - A home partition using remaining space (ext4)
#
# Supports both traditional SATA drives (/dev/sdX) and NVMe drives (/dev/nvmeXnY)
#
# Safety features:
# - Strict error checking with set -euo pipefail
# - Confirmation prompt before destructive operations
# - Full logging to partition_script.log
# - Unmounting of existing partitions
# - Verification of partition types

set -euo pipefail

# Partition size and label configuration
BOOT_SIZE="2GB"
ROOT_SIZE="80GB"
BOOT_LABEL="BOOT"
ROOT_LABEL="ROOT"
HOME_LABEL="HOME"

# Set up logging to capture all output
LOGFILE="$(pwd)/partition_script.log"
exec > >(tee -i "$LOGFILE")
exec 2>&1
set -x

usage() {
    echo "Usage: $0 /dev/sdX|/dev/nvmeXnY [unmount|partition|format|verify|mount|all]"
    echo
    echo "Device naming:"
    echo "  SATA drives: /dev/sda, /dev/sdb, etc."
    echo "  NVMe drives: /dev/nvme0n1, /dev/nvme1n1, etc."
    echo
    echo "Actions:"
    echo "  unmount   - Unmount all partitions on the specified drive"
    echo "  partition - Create new GPT partition table and partitions"
    echo "  format    - Format the partitions with appropriate filesystems"
    echo "  verify    - Verify partition types and labels"
    echo "  mount     - Mount partitions to /mnt for installation"
    echo "  all       - Perform all above actions in sequence (default)"
    exit 1
}

error_exit() {
    echo "Error: $1" >&2
    exit 1
}

confirm_action() {
    local DRIVE="$1"
    echo "WARNING: This will DESTROY ALL DATA on $DRIVE"
    echo
    echo "The script will perform the following actions on $DRIVE:"
    echo "1. Create a new GPT partition table (destroying existing partitions)"
    echo "2. Create a ${BOOT_SIZE} FAT32 boot partition with label $BOOT_LABEL"
    echo "3. Create an ${ROOT_SIZE} ext4 root partition with label $ROOT_LABEL"
    echo "4. Create an ext4 home partition using the remaining space with label $HOME_LABEL"
    echo "5. Format all partitions (destroying any existing data)"
    echo "6. Verify the partition types and labels"
    echo "7. Mount the partitions to /mnt, /mnt/boot, and /mnt/home"
    echo
    echo "A log file will be created at: $LOGFILE"
    echo

    read -p "Are you sure you want to proceed? (yes/no): " CONFIRM
    [[ $CONFIRM == "yes" ]] || error_exit "User aborted the operation"
}

unmount_partitions() {
    local DRIVE="$1"
    echo "Unmounting any existing partitions on $DRIVE"
    local PARTS
    PARTS=$(ls "${DRIVE}"* 2>/dev/null | grep -E "${DRIVE}[0-9p]+") || true
    for PART in $PARTS; do
        if mountpoint -q "$PART"; then
            umount "$PART" && echo "Unmounted $PART" || echo "Failed to unmount $PART"
        fi
    done
}

create_partitions() {
    local DRIVE="$1"
    echo "Creating a new GPT partition table on $DRIVE"
    parted -s "$DRIVE" mklabel gpt || error_exit "Failed to create GPT partition table on $DRIVE"

    echo "Creating boot partition (${BOOT_SIZE}, FAT32)"
    parted -s -a optimal "$DRIVE" mkpart primary fat32 0% "$BOOT_SIZE" || error_exit "Failed to create boot partition"
    parted -s "$DRIVE" set 1 boot on || error_exit "Failed to set boot flag on boot partition"

    echo "Creating root partition (${ROOT_SIZE}, ext4)"
    parted -s -a optimal "$DRIVE" mkpart primary ext4 "$BOOT_SIZE" "$(( ${BOOT_SIZE%GB} + ${ROOT_SIZE%GB} ))GB" || error_exit "Failed to create root partition"

    echo "Creating home partition (remaining space, ext4)"
    parted -s -a optimal "$DRIVE" mkpart primary ext4 "$(( ${BOOT_SIZE%GB} + ${ROOT_SIZE%GB} ))GB" 100% || error_exit "Failed to create home partition"
}

format_partitions() {
    local BOOT_PART="$1"
    local ROOT_PART="$2"
    local HOME_PART="$3"

    echo "Formatting $BOOT_PART as FAT32 with label $BOOT_LABEL"
    mkfs.vfat -F 32 -n "$BOOT_LABEL" "$BOOT_PART" || error_exit "Failed to format boot partition as FAT32"

    echo "Formatting $ROOT_PART as ext4 with label $ROOT_LABEL"
    mkfs.ext4 -L "$ROOT_LABEL" "$ROOT_PART" || error_exit "Failed to format root partition as ext4"

    echo "Formatting $HOME_PART as ext4 with label $HOME_LABEL"
    mkfs.ext4 -L "$HOME_LABEL" "$HOME_PART" || error_exit "Failed to format home partition as ext4"
}

display_partition_table() {
    local DRIVE="$1"
    echo "Displaying partition table of $DRIVE"
    parted "$DRIVE" print || error_exit "Failed to display partition table of $DRIVE"
}

verify_partitions() {
    local BOOT_PART="$1"
    local ROOT_PART="$2"
    local HOME_PART="$3"

    echo "Verifying partition types and labels"
    blkid "$BOOT_PART" | grep -q 'TYPE="vfat"' || error_exit "Boot partition is not FAT32"
    blkid "$ROOT_PART" | grep -q 'TYPE="ext4"' || error_exit "Root partition is not ext4"
    blkid "$HOME_PART" | grep -q 'TYPE="ext4"' || error_exit "Home partition is not ext4"
}

mount_partitions() {
    local BOOT_PART="$1"
    local ROOT_PART="$2"
    local HOME_PART="$3"

    echo "Mounting partitions in correct order for installation"

    # Mount root partition first
    mount "$ROOT_PART" /mnt || {
        echo "Failed to mount root partition. Last 10 lines of dmesg:"
        dmesg | tail -n 10
        error_exit "Failed to mount root partition"
    }
    echo "Mounted $ROOT_PART at /mnt"

    # Create mount points in the correct order
    mkdir -p /mnt/boot /mnt/home

    # Mount boot partition
    mount "$BOOT_PART" /mnt/boot || {
        echo "Failed to mount boot partition. Last 10 lines of dmesg:"
        dmesg | tail -n 10
        error_exit "Failed to mount boot partition"
    }
    echo "Mounted $BOOT_PART at /mnt/boot"

    # Mount home partition
    mount "$HOME_PART" /mnt/home || {
        echo "Failed to mount home partition. Last 10 lines of dmesg:"
        dmesg | tail -n 10
        error_exit "Failed to mount home partition"
    }
    echo "Mounted $HOME_PART at /mnt/home"
}

# Main Script
[[ $# -lt 1 ]] && usage
DRIVE="$1"
ACTION="${2:-all}"

# Define partition names based on drive type
if [[ $DRIVE =~ ^/dev/nvme ]]; then
    # NVMe drives use 'p' suffix for partitions (e.g., nvme0n1p1)
    BOOT_PART="${DRIVE}p1"
    ROOT_PART="${DRIVE}p2"
    HOME_PART="${DRIVE}p3"
else
    # SATA drives just append numbers (e.g., sda1)
    BOOT_PART="${DRIVE}1"
    ROOT_PART="${DRIVE}2"
    HOME_PART="${DRIVE}3"
fi

# Verify drive exists and is a block device
if [[ ! -b "$DRIVE" ]]; then
    error_exit "Drive $DRIVE does not exist or is not a block device"
fi

confirm_action "$DRIVE"

case "$ACTION" in
    unmount)
        unmount_partitions "$DRIVE"
        ;;
    partition)
        unmount_partitions "$DRIVE"
        create_partitions "$DRIVE"
        ;;
    format)
        format_partitions "$BOOT_PART" "$ROOT_PART" "$HOME_PART"
        ;;
    verify)
        verify_partitions "$BOOT_PART" "$ROOT_PART" "$HOME_PART"
        ;;
    mount)
        mount_partitions "$BOOT_PART" "$ROOT_PART" "$HOME_PART"
        ;;
    all)
        unmount_partitions "$DRIVE"
        create_partitions "$DRIVE"
        format_partitions "$BOOT_PART" "$ROOT_PART" "$HOME_PART"
        display_partition_table "$DRIVE"
        verify_partitions "$BOOT_PART" "$ROOT_PART" "$HOME_PART"
        mount_partitions "$BOOT_PART" "$ROOT_PART" "$HOME_PART"
        ;;
    *)
        usage
        ;;
esac

set +x
echo "Partitioning, formatting, and mounting of $DRIVE completed successfully"
echo "Log file available at: $LOGFILE"
exit 0
