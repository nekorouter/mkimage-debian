#!/bin/bash

# Supported machine name:
#	sifive_unmatched
#	allwinner_d1
#	starfive_jh7110
# PS: "" means preserve variant

# TODO:
# jh7110: can't read uEnv.txt
# d1: 
# unmatched: redo partition for special uboot partition

MACHINE=sifive_unmatched
BOARD=
IMAGE_SIZE=4G
IMAGE_FILE=""

LOOP_DEVICE=""
EFI_MOUNTPOINT=""
BOOT_MOUNTPOINT=""
ROOT_MOUNTPOINT=""

CHROOT_TARGET=rootfs

install_depends()
{
	echo "TODO: check if depends has been installed"
	#apt install -y mmdebstrap debian-ports-archive-keyring \
	#	qemu binfmt-support qemu-user-static curl wget \
	#	libncurses-dev gawk flex bison openssl libssl-dev device-tree-compiler \
	#	swig 
}

unmount_image()
{
	echo "Finished and cleaning..."
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
}

cleanup_env()
{
	echo "Cleanup..."
	rm -rv kernel
	rm -rv opensbi
	rm -rv u-boot
	rm -v *.deb
	rm -v *.buildinfo
	rm -v *.changes
	rm -v *.bin
	rm -v *.itb
	echo "Done."
}

main()
{
	# TODO: exception handling
	install_depends
	make_imagefile
	pre_chroot
	make_rootfs
	make_kernel
	make_bootable
	after_chroot
	# for debug:
	chroot "$CHROOT_TARGET" bash
	unmount_image
	cleanup_env
}


source $(pwd)/scripts/after_chroot.sh
source $(pwd)/scripts/make_bootable.sh
source $(pwd)/scripts/make_imagefile.sh
source $(pwd)/scripts/make_kernel.sh
source $(pwd)/scripts/make_rootfs.sh
source $(pwd)/scripts/pre_chroot.sh


# Check root privileges:
if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi

# TODO: clean other things
trap clean_env INT
clean_env()
{
	echo "Ctrl+C exit!!"
	unmount_image
	rm -v "$IMAGE_FILE"
	exit
}

main
