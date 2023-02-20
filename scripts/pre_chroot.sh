#!/bin/bash

pre_chroot_sifive_unmatched()
{
	EFI_MOUNTPOINT=""
	BOOT_MOUNTPOINT=""
	ROOT_MOUNTPOINT=""
	
	# format partitions
	mkfs.vfat -F32 -n efi "$LOOP_DEVICE"p4
	mkfs.ext4 -F -L boot "$LOOP_DEVICE"p5
	mkfs.ext4 -F -L root "$LOOP_DEVICE"p6
	
	mkdir "$CHROOT_TARGET"
	mount "$LOOP_DEVICE"p6 "$CHROOT_TARGET"
}

pre_chroot_allwinner_d1()
{
	EFI_MOUNTPOINT=""
	BOOT_MOUNTPOINT=""
	ROOT_MOUNTPOINT=""
	
	# format partitions
	mkfs.vfat -F32 -n efi "$LOOP_DEVICE"p1
	mkfs.ext4 -F -L boot "$LOOP_DEVICE"p2
	mkfs.ext4 -F -L root "$LOOP_DEVICE"p3
	
	mkdir "$CHROOT_TARGET"
	mount "$LOOP_DEVICE"p3 "$CHROOT_TARGET"
}

pre_chroot_starfive_jh7110()
{
    EFI_MOUNTPOINT=""
	BOOT_MOUNTPOINT=""
	ROOT_MOUNTPOINT=""
	
	# format partitions
	mkfs.vfat -F32 -n efi "$LOOP_DEVICE"p1
	mkfs.ext4 -F -L boot "$LOOP_DEVICE"p2
	mkfs.ext4 -F -L root "$LOOP_DEVICE"p3
	
	mkdir "$CHROOT_TARGET"
	mount "$LOOP_DEVICE"p3 "$CHROOT_TARGET"
}

pre_chroot()
{
	echo "Pre-chroot task for $MACHINE ..."
	
	# Mount image in loop device
	losetup --partscan --find --show "$IMAGE_FILE"
	LOOP_DEVICE=$(losetup -j "$IMAGE_FILE" | grep -o "/dev/loop[0-9]*")
	
	case $MACHINE in
	
		sifive_unmatched)
			pre_chroot_sifive_unmatched
			;;
		
		allwinner_d1)
			pre_chroot_allwinner_d1
			;;
		
		starfive_jh7110)
			pre_chroot_starfive_jh7110
			;;
		
		*)
			echo "Pre-chroot: Unknown machine "$MACHINE", skip."
			;;
	esac
}
