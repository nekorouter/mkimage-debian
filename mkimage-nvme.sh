#!/bin/bash

chroot_target=/tmp/mountpoint

# Create a efi partition and a root partition
sgdisk -og "$1"
sgdisk -n 1:2048:+512M -c 1:"EFI System Partition" -t 1:ef00 "$1"
ENDSECTOR=$(sgdisk -E "$1")
sgdisk -n 2:0:"$ENDSECTOR" -c 2:"RootFS" -t 2:8300 -A 2:set:2 "$1"
sgdisk -p "$1"

# format partitions
mkfs.vfat "$1"1
mkfs.ext4 "$1"2
#e2label "$1"1 efi
#e2label "$1"2 rootfs

mkdir "$chroot_target"
mount "$1"2 "$chroot_target"
#apt install mmdebstrap debian-ports-archive-keyring

###
# TODO: maybe use Multistrap?
###

#mmdebstrap --architectures=riscv64 --include="debian-ports-archive-keyring locales" sid "$chroot_target" "deb http://deb.debian.org/debian-ports sid main contrib non-free"
mmdebstrap --architectures=riscv64 --include="debian-ports-archive-keyring ca-certificates locales" --aptopt='Acquire::Check-Valid-Until "false"' sid "$chroot_target" "deb https://snapshot.debian.org/archive/debian-ports/20221017T204716Z/ sid main contrib non-free"
mkdir "$chroot_target"/boot/efi
mount "$1"1 "$chroot_target"/boot/efi

mount -t proc /proc "$chroot_target"/proc
mount -B /sys "$chroot_target"/sys
mount -B /run "$chroot_target"/run/
mount -B /dev "$chroot_target"/dev/
mount -B /dev/pts "$chroot_target"/dev/pts

#config locale to en_US (debian bug:1021109)
chroot "$chroot_target" sh -c "echo 'en_US.UTF-8 UTF-8' | tee -a /etc/locale.gen"
chroot "$chroot_target" sh -c "locale-gen"

###
# TODO: some packages install can move to mmdebstrap step
###

# Update package information
chroot "$chroot_target" sh -c "apt update"

# Install some tools
chroot "$chroot_target" sh -c "apt install -y arch-install-scripts"

# Change hostname
chroot "$chroot_target" sh -c "echo unmatched > /etc/hostname"

# Set up fstab
chroot "$chroot_target" sh -c "genfstab -U / > /etc/fstab"

# Install kernel and bootloader infrastructure
chroot "$chroot_target" sh -c "apt install -y linux-image-riscv64 u-boot-menu u-boot-sifive"
chroot "$chroot_target" sh -c "echo 'U_BOOT_ROOT="root=/dev/nvme0n1p2"' | tee -a /etc/default/u-boot"
chroot "$chroot_target" sh -c "u-boot-update"

# Install other tools
chroot "$chroot_target" sh -c "apt install -y bash-completion firmware-linux firmware-amd-graphics network-manager openssh-server"

# add root password as root
#chroot "$chroot_target" sh -c "usermod --password $(openssl passwd -6 "root") root"

# Add new user named "debian"
chroot "$chroot_target" sh -c "useradd -m debian"
chroot "$chroot_target" sh -c "echo 'debian:debian' | chpasswd"

chroot "$chroot_target"

echo "Finished, cleaning..."
umount -l "$chroot_target"
rm -r "$chroot_target"
sync
