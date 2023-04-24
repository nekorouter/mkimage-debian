#!/bin/bash
set -e

# Supported machine name:
#	sifive_unmatched
#	allwinner_d1
#	starfive_jh7110
# PS: "" means preserve variant

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
	sudo apt install -y git gdisk dosfstools mmdebstrap qemu-system-misc binfmt-support qemu-user-static debian-ports-archive-keyring \
		wget make gcc flex bison gcc-riscv64-linux-gnu libssl-dev bc dpkg-dev rsync 
}

unmount_image()
{
	echo "Finished and cleaning..."
	if mount | grep "$CHROOT_TARGET" > /dev/null; then
		umount -l "$CHROOT_TARGET"
	fi
	if losetup -l | grep "$LOOP_DEVICE" > /dev/null; then
		losetup -d "$LOOP_DEVICE"
	fi
	if [ "$(ls -A $CHROOT_TARGET)" ]; then
		echo "folder not empty! umount may fail!"
		exit 2
	else
		echo "Deleting chroot temp folder..."
		if [ -d "$CHROOT_TARGET" ]; then
			rmdir "$CHROOT_TARGET"
		fi
		echo "Done."
	fi
}

cleanup_env()
{
	echo "Cleanup..."
	if [ -d kernel ]; then
		rm -rv kernel
		rm -v *.deb
		rm -v *.buildinfo
		rm -v *.changes
	fi

	if [ -d opensbi ]; then
		rm -rv opensbi
	fi

	if [ -d u-boot ]; then
		rm -rv u-boot
	fi

	if [ -f *.bin ]; then
		rm -v *.bin
	fi

	if [ -f *.itb ]; then
		rm -v *.itb
	fi

	echo "Done."
}

main()
{
	install_depends
	make_imagefile
	pre_chroot
	make_rootfs
	make_kernel
	make_bootable
	after_chroot
	exit
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
	if [[ " ${machine_list[*]} " =~ " ${MACHINE} " ]]; then
    	echo "MACHINE=$MACHINE"
	else
		echo "$MACHINE is not compatible with this script!!"
		exit 1
	fi
fi

trap return 2 INT
trap clean_on_exit EXIT

clean_on_exit()
{
	if [ $? -eq 0 ]; then
		unmount_image
		cleanup_env
		echo "exit."
	else
		unmount_image
		cleanup_env
		if [ -f $IMAGE_FILE ]; then
			echo "delete image $IMAGE_FILE ..."
			rm -v "$IMAGE_FILE"
		fi
		echo "interrupted exit."
	fi
}

main
