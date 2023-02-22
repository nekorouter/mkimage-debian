#!/bin/bash

after_chroot_sifive_unmatched()
{
	# Install tools and drivers
	chroot "$CHROOT_TARGET" sh -c "apt install -y sudo bash-completion network-manager openssh-server ntp"
	
	# Change hostname
	chroot "$CHROOT_TARGET" sh -c "echo unmatched > /etc/hostname"
	chroot "$CHROOT_TARGET" sh -c "echo 127.0.1.1 unmatched >> /etc/hosts"
	
	# Set up fstab
	#chroot "$CHROOT_TARGET" sh -c "genfstab -U -p / | sed '/\//!d' > /etc/fstab"
	chroot "$CHROOT_TARGET" sh -c "genfstab -U / > /etc/fstab"
}

after_chroot_allwinner_d1()
{
	# Install tools and drivers
	chroot "$CHROOT_TARGET" sh -c "apt install -y sudo bash-completion network-manager openssh-server ntp"
	
	# Change hostname
	chroot "$CHROOT_TARGET" sh -c "echo d1 > /etc/hostname"
	chroot "$CHROOT_TARGET" sh -c "echo 127.0.1.1 d1 >> /etc/hosts"
	
	# Set up fstab
	#chroot "$CHROOT_TARGET" sh -c "genfstab -U -p / | sed '/\//!d' > /etc/fstab"
	#chroot "$CHROOT_TARGET" sh -c "genfstab -U / > /etc/fstab"
	EFI_UUID=$(blkid -o value -s UUID "$LOOP_DEVICE"p1)
	BOOT_UUID=$(blkid -o value -s UUID "$LOOP_DEVICE"p2)
	ROOT_UUID=$(blkid -o value -s UUID "$LOOP_DEVICE"p3)
	chroot "$CHROOT_TARGET" sh -c "echo 'UUID=$EFI_UUID	/boot/efi	vfat	rw,relatime	0 2' >> /etc/fstab"
	chroot "$CHROOT_TARGET" sh -c "echo 'UUID=$BOOT_UUID	/boot	ext4	rw,relatime	0 2' >> /etc/fstab"
	chroot "$CHROOT_TARGET" sh -c "echo 'UUID=$ROOT_UUID	/	ext4	rw,relatime	0 1' >> /etc/fstab"
}

after_chroot_starfive_jh7110()
{
	# Install tools and drivers
	chroot "$CHROOT_TARGET" sh -c "apt install -y sudo bash-completion network-manager openssh-server ntp"

	# Change hostname
	chroot "$CHROOT_TARGET" sh -c "echo jh7110 > /etc/hostname"
	chroot "$CHROOT_TARGET" sh -c "echo 127.0.1.1 jh7110 >> /etc/hosts"
	
	# Set up fstab
	EFI_UUID=$(blkid -o value -s UUID "$LOOP_DEVICE"p1)
	BOOT_UUID=$(blkid -o value -s UUID "$LOOP_DEVICE"p2)
	ROOT_UUID=$(blkid -o value -s UUID "$LOOP_DEVICE"p3)
	chroot "$CHROOT_TARGET" sh -c "echo 'UUID=$EFI_UUID	/boot/efi	vfat	rw,relatime	0 2' >> /etc/fstab"
	chroot "$CHROOT_TARGET" sh -c "echo 'UUID=$BOOT_UUID	/boot	vfat	rw,relatime	0 2' >> /etc/fstab"
	chroot "$CHROOT_TARGET" sh -c "echo 'UUID=$ROOT_UUID	/	ext4	rw,relatime	0 1' >> /etc/fstab"

	# TODO: make sure root UUID is correct, but why it is wrong?
	chroot "$CHROOT_TARGET" sh -c "u-boot-update"
}

after_chroot()
{
	echo "After-chroot task for $MACHINE ..."
	
	# add root password as root
	#chroot "$CHROOT_TARGET" sh -c "echo 'root:debian' | chpasswd"

	# Add new user named "debian"
	chroot "$CHROOT_TARGET" sh -c "useradd -m -s /bin/bash debian"
	chroot "$CHROOT_TARGET" sh -c "echo 'debian:debian' | chpasswd"
	chroot "$CHROOT_TARGET" sh -c "usermod -aG sudo debian"

	case $MACHINE in
	
		sifive_unmatched)
			after_chroot_sifive_unmatched
			;;
		
		allwinner_d1)
			after_chroot_allwinner_d1
			;;
		
		starfive_jh7110)
			after_chroot_starfive_jh7110
			;;
		
		*)
			echo "After-chroot: Unknown machine "$MACHINE", skip."
			;;
	esac
}
