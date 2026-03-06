#!/usr/bin/env bash
# Partition Samsung 990 PRO 2TB (nvme1n1) for Guix System
# WARNING: This will WIPE ALL DATA on nvme1n1!
# Run as root: sudo bash partition-samsung.sh
set -euo pipefail

DISK=/dev/nvme1n1
PART1="${DISK}p1"  # EFI
PART2="${DISK}p2"  # Btrfs root

echo "=== Guix System Partitioning ==="
echo "Target disk: $DISK"
echo ""
lsblk "$DISK"
echo ""
echo "WARNING: This will DESTROY all data on $DISK!"
read -p "Type YES to continue: " confirm
[[ "$confirm" == "YES" ]] || { echo "Aborted."; exit 1; }

# Step 1: Remove any LVM metadata
echo ">>> Removing LVM signatures..."
pvremove -ff "$PART1" 2>/dev/null || true
wipefs -af "$DISK" 2>/dev/null || true

# Step 2: Create GPT partition table
echo ">>> Creating GPT partition table..."
parted -s "$DISK" mklabel gpt

# Step 3: Create EFI partition (512MB)
echo ">>> Creating EFI partition (512MB)..."
parted -s "$DISK" mkpart primary fat32 1MiB 513MiB
parted -s "$DISK" set 1 esp on

# Step 4: Create Btrfs partition (rest)
echo ">>> Creating Btrfs partition (remaining space)..."
parted -s "$DISK" mkpart primary btrfs 513MiB 100%

# Step 5: Format EFI partition
echo ">>> Formatting EFI partition..."
mkfs.vfat -F 32 -n GUIX-EFI "$PART1"

# Step 6: Format Btrfs partition
echo ">>> Formatting Btrfs partition with zstd compression..."
mkfs.btrfs -f -L guix-root "$PART2"

# Step 7: Create Btrfs subvolumes
echo ">>> Creating Btrfs subvolumes..."
mount "$PART2" /mnt
cd /mnt
btrfs subvolume create @
btrfs subvolume create @home
btrfs subvolume create @gnu
btrfs subvolume create @log
btrfs subvolume create @tmp
cd /
umount /mnt

# Step 8: Mount subvolumes for installation
echo ">>> Mounting subvolumes..."
mount -o subvol=@,compress=zstd:1,noatime,space_cache=v2 "$PART2" /mnt

mkdir -p /mnt/{home,gnu/store,var/log,tmp,boot/efi}

mount -o subvol=@home,compress=zstd:1,noatime,space_cache=v2 "$PART2" /mnt/home
mount -o subvol=@gnu,compress-force=zstd:1,noatime,space_cache=v2 "$PART2" /mnt/gnu/store
mount -o subvol=@log,compress=zstd:3,noatime,space_cache=v2 "$PART2" /mnt/var/log
mount -o subvol=@tmp,compress=zstd:1,noatime,space_cache=v2 "$PART2" /mnt/tmp
mount "$PART1" /mnt/boot/efi

echo ""
echo "=== Partitioning complete! ==="
echo ""
lsblk "$DISK"
echo ""
df -h /mnt /mnt/home /mnt/gnu/store /mnt/var/log /mnt/tmp /mnt/boot/efi
echo ""
echo "Next steps:"
echo "  1. Run: guix system init ~/cahy/guix/system.scm /mnt \\"
echo "       --substitute-urls='https://bordeaux.guix.gnu.org https://ci.guix.gnu.org https://substitutes.nonguix.org'"
echo "  2. Wait for installation to complete"
echo "  3. Reboot and select Guix from GRUB"
