#!/bin/bash

after_make_rootfs_sifive_unmatched()
{
	mount "$LOOP_DEVICE"p5 "$CHROOT_TARGET"/boot
	mkdir "$CHROOT_TARGET"/boot/efi
	mount "$LOOP_DEVICE"p4 "$CHROOT_TARGET"/boot/efi
}

after_make_rootfs_allwinner_d1()
{
	mount "$LOOP_DEVICE"p2 "$CHROOT_TARGET"/boot
	mkdir "$CHROOT_TARGET"/boot/efi
	mount "$LOOP_DEVICE"p1 "$CHROOT_TARGET"/boot/efi
}

after_make_rootfs_starfive_jh7110()
{
	mount "$LOOP_DEVICE"p2 "$CHROOT_TARGET"/boot
	mkdir "$CHROOT_TARGET"/boot/efi
	mount "$LOOP_DEVICE"p1 "$CHROOT_TARGET"/boot/efi
}

make_rootfs()
{
	echo "Pull rootfs..."
	
	#mmdebstrap --architectures=riscv64 --include="debian-ports-archive-keyring ca-certificates locales dosfstools" --aptopt='Acquire::Check-Valid-Until "false"' sid "$CHROOT_TARGET" "deb https://snapshot.debian.org/archive/debian-ports/20221225T084846Z/ sid main contrib non-free"
    mmdebstrap --architectures=riscv64 --include="ca-certificates locales dosfstools" sid "$CHROOT_TARGET" "deb http://deb.debian.org/debian sid main contrib non-free non-free-firmware"

    # echo "Install board specfied packages..."
    
	case $MACHINE in
	
		sifive_unmatched)
			after_make_rootfs_sifive_unmatched
			;;
		
		allwinner_d1)
			after_make_rootfs_allwinner_d1
			;;
		
		starfive_jh7110)
			after_make_rootfs_starfive_jh7110
			;;
		
		*)
			echo "No machine matched!!"
			;;
	esac
	
	mount -t proc /proc "$CHROOT_TARGET"/proc
	mount -B /sys "$CHROOT_TARGET"/sys
	mount -B /run "$CHROOT_TARGET"/run
	mount -B /dev "$CHROOT_TARGET"/dev
	mount -B /dev/pts "$CHROOT_TARGET"/dev/pts
	
	# debug
	#rm -v "$IMAGE_FILE"
	#chroot "$CHROOT_TARGET" bash
	#exit
	
	# Update package information
	chroot "$CHROOT_TARGET" sh -c "apt update"
	
	# Install some tools
	chroot "$CHROOT_TARGET" sh -c "apt install -y arch-install-scripts"
}
