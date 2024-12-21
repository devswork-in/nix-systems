#!/usr/bin/env bash
set -euo pipefail

# Variables
BOOT_SIZE="2GB"
ROOT_SIZE="80GB"
BOOT_LABEL="BOOT"
ROOT_LABEL="ROOT"
HOME_LABEL="HOME"

LOGFILE="$(pwd)/partition_script.log"

# Logging and debugging
exec > >(tee -i "$LOGFILE")
exec 2>&1
set -x

usage() {
    echo "Usage: $0 /dev/sdX [unmount|partition|format|verify|mount|all]"
    exit 1
}

error_exit() {
    echo "Error: $1"
    exit 1
}

confirm_action() {
    local DRIVE="$1"
    echo "The script will perform the following actions on $DRIVE:"
    echo "1. Create a new GPT partition table."
    echo "2. Create a ${BOOT_SIZE} FAT32 boot partition with label $BOOT_LABEL."
    echo "3. Create an ${ROOT_SIZE} ext4 root partition with label $ROOT_LABEL."
    echo "4. Create an ext4 home partition using the remaining space with label $HOME_LABEL."
    echo "5. Format the partitions accordingly."
    echo "6. Verify the partitions."
    echo "7. Mount the partitions to /mnt, /mnt/boot, and /mnt/home."

    read -p "Are you sure you want to proceed? (yes/no): " CONFIRM
    [[ $CONFIRM == "yes" ]] || error_exit "User aborted the operation."
}

unmount_partitions() {
    local DRIVE="$1"
    echo "Unmounting partitions on $DRIVE"
    local PARTS
    PARTS=$(ls "${DRIVE}"* 2>/dev/null | grep -E "${DRIVE}[0-9]+") || true
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

    echo "Verifying partitions"
    blkid "$BOOT_PART" | grep -q 'TYPE="vfat"' || error_exit "Boot partition is not FAT32"
    blkid "$ROOT_PART" | grep -q 'TYPE="ext4"' || error_exit "Root partition is not ext4"
    blkid "$HOME_PART" | grep -q 'TYPE="ext4"' || error_exit "Home partition is not ext4"
}

mount_partitions() {
    local BOOT_PART="$1"
    local ROOT_PART="$2"
    local HOME_PART="$3"

    echo "Mounting partitions"

    # Mount the root partition first
    mount "$ROOT_PART" /mnt || {
        dmesg | tail -n 10
        error_exit "Failed to mount root partition"
    }
    echo "Mounted $ROOT_PART at /mnt"

    # Now create the directories inside the mounted root filesystem
    mkdir -p /mnt/boot /mnt/home

    # Mount the boot partition
    mount "$BOOT_PART" /mnt/boot || {
        dmesg | tail -n 10
        error_exit "Failed to mount boot partition"
    }
    echo "Mounted $BOOT_PART at /mnt/boot"

    # Mount the home partition
    mount "$HOME_PART" /mnt/home || {
        dmesg | tail -n 10
        error_exit "Failed to mount home partition"
    }
    echo "Mounted $HOME_PART at /mnt/home"
}

# Main Script
[[ $# -lt 1 ]] && usage
DRIVE="$1"
ACTION="${2:-all}"

BOOT_PART="${DRIVE}p1"
ROOT_PART="${DRIVE}p2"
HOME_PART="${DRIVE}p3"

if [[ ! -b "$DRIVE" ]]; then
    error_exit "Drive $DRIVE does not exist or is not a block device."
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
echo "Partitioning, formatting, and mounting of $DRIVE completed successfully."
exit 0

