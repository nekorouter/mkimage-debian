#!/bin/bash
set -e

# Supported machine name:
#	sifive_unmatched
#	allwinner_d1
#	starfive_jh7110
# PS: "" means preserve variant

# TODO:
# jh7110: can't read uEnv.txt
# d1: 
# unmatched: redo partition for special uboot partition

# MACHINE=sifive_unmatched
machine_list=("sifive_unmatched" "allwinner_d1" "starfive_jh7110")
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
	if mount | grep $CHROOT_TARGET > /dev/null; then
		umount -l "$CHROOT_TARGET"
	fi
	if losetup -l | grep $LOOP_DEVICE > /dev/null; then
		losetup -d "$LOOP_DEVICE"
	fi
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
	# chroot "$CHROOT_TARGET" bash
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
    exit 1
fi

if [ -z "$MACHINE" ]; then
	echo "MACHINE not set!!"
    exit 1
else
	# for $MACHINE in ${machine_list[@]}; do
	# 	echo $MACHINE
	# done
	if [[ " ${machine_list[*]} " =~ " ${MACHINE} " ]]; then
    	echo "MACHINE=$MACHINE"
	else
		echo "$MACHINE is not compatible with this script!!"
		exit 1
	fi
fi

# TODO: clean other things
trap clean_env INT EXIT
clean_env()
{
	echo "exit!!"
	unmount_image
	rm -v "$IMAGE_FILE"
	exit
}

main
