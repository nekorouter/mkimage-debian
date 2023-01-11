#!/bin/bash

CHROOT_TARGET=/tmp/mountpoint
IMAGE_FILE=sdcard.img

# Create image file
rm "$IMAGE_FILE"
truncate -s 4G "$IMAGE_FILE"

# Create a efi partition and a root partition
sgdisk -og "$IMAGE_FILE"
sgdisk -n 1:2048:+40M -c 1:"EFI" -t 1:ef00 "$IMAGE_FILE"
sgdisk -n 2:0:+500M -c 2:"BOOT" -t 1:ef00 "$IMAGE_FILE"
ENDSECTOR=$(sgdisk -E "$IMAGE_FILE")
sgdisk -n 3:0:"$ENDSECTOR" -c 3:"ROOT" -t 2:8300 -A 2:set:2 "$IMAGE_FILE"
sgdisk -p "$IMAGE_FILE"

# Mount image in loop device
losetup --partscan --find --show "$IMAGE_FILE"
LOOP_DEVICE=$(losetup -j "$IMAGE_FILE" | grep -o "/dev/loop[0-9]*")

# format partitions
mkfs.vfat -F32 -n efi "$LOOP_DEVICE"p1
mkfs.ext4 -F -L boot "$LOOP_DEVICE"p2
mkfs.ext4 -F -L root "$LOOP_DEVICE"p3

mkdir "$CHROOT_TARGET"
mount "$LOOP_DEVICE"p3 "$CHROOT_TARGET"
#apt install mmdebstrap debian-ports-archive-keyring

# install u-boot
dd if=u-boot-sunxi-with-spl.bin of="${LOOP_DEVICE}" bs=1024 seek=128

# mmdebstrap --architectures=riscv64 --include="debian-ports-archive-keyring locales" sid "$CHROOT_TARGET" "deb http://deb.debian.org/debian-ports sid main contrib non-free"
mmdebstrap --architectures=riscv64 --include="debian-ports-archive-keyring ca-certificates locales" --aptopt='Acquire::Check-Valid-Until "false"' sid "$CHROOT_TARGET" "deb https://snapshot.debian.org/archive/debian-ports/20221225T084846Z/ sid main contrib non-free"

mount "$LOOP_DEVICE"p2 "$CHROOT_TARGET"/boot
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

# Install kernel
cp linux-image-*.deb "$CHROOT_TARGET"/tmp
chroot "$CHROOT_TARGET" sh -c "apt install /tmp/*.deb"
cp -v vmlinuz-* "$CHROOT_TARGET"/boot/
cp -v config-* "$CHROOT_TARGET"/boot/
# *** should make a "make-kernel.sh" for install kernel form source, because of need of uncompressed kernel ***

# Update package information
chroot "$CHROOT_TARGET" sh -c "apt update"

# Install some tools
chroot "$CHROOT_TARGET" sh -c "apt install -y initramfs-tools u-boot-menu"

# Change hostname
chroot "$CHROOT_TARGET" sh -c "echo mqpro > /etc/hostname"
# chroot "$CHROOT_TARGET" sh -c "echo mqpro > /etc/hosts"

# Set up fstab
# chroot "$CHROOT_TARGET" sh -c "genfstab -U / > /etc/fstab"
cp -v fstab "$CHROOT_TARGET"/etc/fstab

# Install kernel and bootloader infrastructure
# chroot "$CHROOT_TARGET" sh -c "apt install -y u-boot-menu"
chroot "$CHROOT_TARGET" sh -c "echo 'U_BOOT_ROOT="root=/dev/mmcblk0p3"' | tee -a /etc/default/u-boot"
chroot "$CHROOT_TARGET" sh -c "u-boot-update"

# Install other tools
chroot "$CHROOT_TARGET" sh -c "apt install -y bash-completion network-manager openssh-server"

# add root password as root
#chroot "$CHROOT_TARGET" sh -c "usermod --password $(openssl passwd -6 "root") root"
chroot "$CHROOT_TARGET" sh -c "echo 'root:debian' | chpasswd"

# Add new user named "debian"
chroot "$CHROOT_TARGET" sh -c "useradd -m debian -s /bin/bash"
chroot "$CHROOT_TARGET" sh -c "echo 'debian:debian' | chpasswd"

# add grub efi and grub.cfg
mkdir -p "$CHROOT_TARGET"/boot/efi/efi/boot/
cp -v ../bootriscv64.efi "$CHROOT_TARGET"/boot/efi/efi/boot/
export kernel_version=$(ls "$CHROOT_TARGET"/boot/ | grep vmlinuz- | sed 's/vmlinuz-//' | head -n 1 )
cp -v grub.cfg "$CHROOT_TARGET"/boot/
cp -rv extlinux "$CHROOT_TARGET"/boot/
sed -i "s/custom_kernel_version/$kernel_version/g" "$CHROOT_TARGET"/boot/grub.cfg
sed -i "s/custom_kernel_version/$kernel_version/g" "$CHROOT_TARGET"/boot/extlinux/extlinux.conf

# add device tree
cp -v ./*.dtb "$CHROOT_TARGET"/boot/

# Generate initramfs

if [ x"$(cat "$CHROOT_TARGET"/boot/config-$kernel_version | grep CONFIG_MODULES=y)" = x"CONFIG_MODULES=y" ]; then
    chroot "$CHROOT_TARGET" /bin/bash -c 'source /etc/profile && update-initramfs -c -k all'
else
    sed -i '/initrd/d' "$CHROOT_TARGET"/boot/grub.cfg
fi

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
