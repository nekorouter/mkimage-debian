#!/bin/bash

OUT_DIR=$(pwd)

make_bootable_sifive_unmatched()
{
    # Install kernel and bootloader infrastructure
    chroot "$CHROOT_TARGET" sh -c "apt install -y u-boot-menu u-boot-sifive"
    #chroot "$CHROOT_TARGET" sh -c "echo 'U_BOOT_ROOT="root=/dev/mmcblk0p6"' | tee -a /etc/default/u-boot"
    chroot "$CHROOT_TARGET" sh -c "u-boot-update"
    
    ###
	opensbi_branch="v1.5.1"
	opensbi_git="https://github.com/riscv-software-src/opensbi.git"
	uboot_branch="v2024.10"
	uboot_git="https://github.com/u-boot/u-boot.git"
	uboot_config="sifive_unmatched_defconfig"
	
	DIR='opensbi'
	git clone --depth=1 -b ${opensbi_branch} ${opensbi_git} ${DIR}
	pushd ${DIR}
		make CROSS_COMPILE=riscv64-linux-gnu- PLATFORM=generic
	popd
	cp opensbi/build/platform/generic/firmware/fw_dynamic.bin ${OUT_DIR}
	apt install -y libgnutls28-dev
	DIR='u-boot'
	git clone --depth=1 -b ${uboot_branch} ${uboot_git} ${DIR}
	pushd ${DIR}
		make CROSS_COMPILE=riscv64-linux-gnu- ARCH=riscv ${uboot_config}
		make CROSS_COMPILE=riscv64-linux-gnu- ARCH=riscv OPENSBI="${OUT_DIR}/fw_dynamic.bin" -j$(nproc)
	popd
	cp ${DIR}/spl/u-boot-spl.bin "${OUT_DIR}"
	cp ${DIR}/u-boot.itb "${OUT_DIR}"
	
	dd if=u-boot-spl.bin of="$IMAGE_FILE" bs=512 seek=34 conv=sync,notrunc status=progress
	dd if=u-boot.itb of="$IMAGE_FILE" bs=512 seek=2082 conv=sync,notrunc status=progress
}

make_bootable_allwinner_d1()
{
    opensbi_branch="d1-wip"
    opensbi_git="https://github.com/smaeul/opensbi.git"
    uboot_branch="d1-wip"
    uboot_git="https://github.com/smaeul/u-boot.git"
    uboot_config="nezha_defconfig"
    
	DIR='opensbi'
	git clone --depth=1 -b ${opensbi_branch} ${opensbi_git} ${DIR}
	pushd ${DIR}
		make CROSS_COMPILE=riscv64-linux-gnu- PLATFORM=generic FW_PIC=y FW_OPTIONS=0x2
	popd
	cp opensbi/build/platform/generic/firmware/fw_dynamic.bin ${OUT_DIR}/
	
	DIR='u-boot'
	git clone --depth=1 -b ${uboot_branch} ${uboot_git} ${DIR}
	pushd ${DIR}
		make CROSS_COMPILE=riscv64-linux-gnu- ARCH=riscv ${uboot_config}
		make CROSS_COMPILE=riscv64-linux-gnu- ARCH=riscv OPENSBI="${OUT_DIR}/fw_dynamic.bin" -j$(nproc)
	popd
	cp ${DIR}/u-boot-sunxi-with-spl.bin "${OUT_DIR}"

	dd if="${OUT_DIR}/u-boot-sunxi-with-spl.bin" of="${LOOP_DEVICE}" bs=1024 seek=128
	
	chroot "$CHROOT_TARGET" sh -c "apt install -y u-boot-menu"
	chroot "$CHROOT_TARGET" sh -c "echo 'U_BOOT_ROOT="root=/dev/mmcblk0p3"' | tee -a /etc/default/u-boot"
	chroot "$CHROOT_TARGET" sh -c "echo 'U_BOOT_PARAMETERS=\"rw earlycon=sbi console=tty0 console=ttyS0,115200 rootwait \"' | tee -a /etc/default/u-boot"
	chroot "$CHROOT_TARGET" sh -c "echo 'U_BOOT_FDT_DIR=\"/boot/dtbs/\"' | tee -a /etc/default/u-boot"
	chroot "$CHROOT_TARGET" sh -c "u-boot-update"
}

make_bootable_starfive_jh7110()
{
    chroot "$CHROOT_TARGET" sh -c "apt install -y u-boot-menu"
	#chroot "$CHROOT_TARGET" sh -c "echo 'U_BOOT_ROOT="root=/dev/mmcblk1p3"' | tee -a /etc/default/u-boot"
    chroot "$CHROOT_TARGET" sh -c "echo 'U_BOOT_PARAMETERS=\"rw console=tty0 console=ttyS0,115200 earlycon rootwait stmmaceth=chain_mode:1 selinux=0\"' | tee -a /etc/default/u-boot"
    #chroot "$CHROOT_TARGET" sh -c "echo 'U_BOOT_FDT_DIR=\"/boot/dtbs\"' | tee -a /etc/default/u-boot"
	chroot "$CHROOT_TARGET" sh -c "echo 'U_BOOT_FDT_DIR=\"/dtbs/\"' | tee -a /etc/default/u-boot"
    chroot "$CHROOT_TARGET" sh -c "u-boot-update"

	# cp uEnv.txt to /boot/boot so u-boot could pick up correct dtb file
	mkdir -v $CHROOT_TARGET/boot/boot
	cp -v board/starfive_jh7110/visionfive-v2/uEnv.txt $CHROOT_TARGET/boot/boot
}

make_bootable()
{
	echo "Making image bootable for $MACHINE ..."
	
	# Generate initramfs
	chroot "$CHROOT_TARGET" sh -c "apt install -y initramfs-tools"
	#if [ x"$(cat "$CHROOT_TARGET"/boot/config-$kernel_version | grep CONFIG_MODULES=y)" = x"CONFIG_MODULES=y" ]; then
		chroot "$CHROOT_TARGET" /bin/bash -c 'source /etc/profile && update-initramfs -c -k all'
	#else
	#	echo "make_bootable(): debug: ???"
		#sed -i '/initrd/d' "$CHROOT_TARGET"/boot/grub.cfg
	#fi

	case $MACHINE in
	
		sifive_unmatched)
			make_bootable_sifive_unmatched
			;;
		
		allwinner_d1)
			make_bootable_allwinner_d1
			;;
		
		starfive_jh7110)
			make_bootable_starfive_jh7110
			;;
		
		*)
			echo "No machine matched!!"
			;;
	esac
}
