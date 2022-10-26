#!/bin/bash

CHROOT_TARGET=/tmp/mountpoint
IMAGE_FILE=sdcard.img

# Create image file
rm "$IMAGE_FILE"
truncate -s 8G "$IMAGE_FILE"

# Create a efi partition and a root partition
sgdisk -og "$IMAGE_FILE"
sgdisk -n 1:2048:+512M -c 1:"EFI System Partition" -t 1:ef00 "$IMAGE_FILE"
ENDSECTOR=$(sgdisk -E "$IMAGE_FILE")
sgdisk -n 2:0:"$ENDSECTOR" -c 2:"RootFS" -t 2:8300 -A 2:set:2 "$IMAGE_FILE"
sgdisk -p "$IMAGE_FILE"

# Mount image in loop device
losetup --partscan --find --show "$IMAGE_FILE"
LOOP_DEVICE=$(losetup -j "$IMAGE_FILE" | grep -o "/dev/loop[0-9]*")

# format partitions
mkfs.vfat "$LOOP_DEVICE"p1
mkfs.ext4 "$LOOP_DEVICE"p2
#e2label "$LOOP_DEVICE"p1 efi
#e2label "$LOOP_DEVICE"p2 rootfs

mkdir "$CHROOT_TARGET"
mount "$LOOP_DEVICE"p2 "$CHROOT_TARGET"
#apt install mmdebstrap debian-ports-archive-keyring

###
# TODO: maybe use Multistrap?
###

mmdebstrap --architectures=riscv64 --include="debian-ports-archive-keyring locales" sid "$CHROOT_TARGET" "deb http://deb.debian.org/debian-ports sid main contrib non-free"
#mmdebstrap --architectures=riscv64 --include="debian-ports-archive-keyring ca-certificates locales" --aptopt='Acquire::Check-Valid-Until "false"' sid "$CHROOT_TARGET" "deb https://snapshot.debian.org/archive/debian-ports/20221017T204716Z/ sid main contrib non-free"
mkdir "$CHROOT_TARGET"/boot/efi
mount "$LOOP_DEVICE"p1 "$CHROOT_TARGET"/boot/efi

mount -t proc /proc "$CHROOT_TARGET"/proc
mount -B /sys "$CHROOT_TARGET"/sys
mount -B /run "$CHROOT_TARGET"/run/
mount -B /dev "$CHROOT_TARGET"/dev/
mount -B /dev/pts "$CHROOT_TARGET"/dev/pts

#config locale to en_US (debian bug:1021109)
chroot "$CHROOT_TARGET" sh -c "echo 'en_US.UTF-8 UTF-8' | tee -a /etc/locale.gen"
chroot "$CHROOT_TARGET" sh -c "locale-gen"

###
# TODO: some packages install can move to mmdebstrap step
###

# Update package information
chroot "$CHROOT_TARGET" sh -c "apt update"

# Install some tools
chroot "$CHROOT_TARGET" sh -c "apt install -y arch-install-scripts"

# Change hostname
chroot "$CHROOT_TARGET" sh -c "echo unmatched > /etc/hostname"
# chroot "$CHROOT_TARGET" sh -c "echo unmatched > /etc/hosts"

# Set up fstab
chroot "$CHROOT_TARGET" sh -c "genfstab -U / > /etc/fstab"

# Install kernel and bootloader infrastructure
chroot "$CHROOT_TARGET" sh -c "apt install -y linux-image-riscv64 u-boot-menu u-boot-sifive"
chroot "$CHROOT_TARGET" sh -c "echo 'U_BOOT_ROOT="root=/dev/nvme0n1p2"' | tee -a /etc/default/u-boot"
chroot "$CHROOT_TARGET" sh -c "u-boot-update"

# Install other tools
chroot "$CHROOT_TARGET" sh -c "apt install -y bash-completion firmware-linux firmware-amd-graphics network-manager openssh-server"

# add root password as root
#chroot "$CHROOT_TARGET" sh -c "usermod --password $(openssl passwd -6 "root") root"
chroot "$CHROOT_TARGET" sh -c "echo 'root:debian' | chpasswd"

# Add new user named "debian"
chroot "$CHROOT_TARGET" sh -c "useradd -m debian"
chroot "$CHROOT_TARGET" sh -c "echo 'debian:debian' | chpasswd"

chroot "$CHROOT_TARGET"

echo "Finished, cleaning..."
umount -l "$CHROOT_TARGET"
losetup -d "$LOOP_DEVICE"
if [ "$(ls -A $CHROOT_TARGET)" ]; then
    echo "folder not empty! umount may fail!"
    exit 2
else
    echo "Deleting chroot temp folder..."
    rmdir "$CHROOT_TARGET"
    echo "Done."
fi
