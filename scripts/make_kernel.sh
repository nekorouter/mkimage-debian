#!/bin/bash

make_kernel_sifive_unmatched()
{
	echo "Note: sifive_unmatched use kernel in repo, no need for build kernel."
	
	# Install kernel
    chroot "$CHROOT_TARGET" sh -c "apt install -y linux-image-riscv64"
}

make_kernel_allwinner_d1()
{
    kernel_branch="riscv/d1-wip"
    kernel_git="https://github.com/smaeul/linux.git"
    kernel_config="nezha_defconfig"

    git clone --depth=1 -b ${kernel_branch} ${kernel_git} kernel
    pushd kernel
        export DIR=$PWD
        echo "CONFIG_LOCALVERSION=${KERNEL_RELEASE}" >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_WIRELESS=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_CFG80211=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        # enable /proc/config.gz
        echo 'CONFIG_IKCONFIG=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_IKCONFIG_PROC=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        # There is no LAN. so let there be USB-LAN
        echo 'CONFIG_USB_NET_DRIVERS=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_CATC=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_KAWETH=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_PEGASUS=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_RTL8150=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_RTL8152=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_LAN78XX=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_USBNET=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_NET_AX8817X=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_NET_AX88179_178A=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_NET_CDCETHER=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_NET_CDC_EEM=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_NET_CDC_NCM=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_NET_HUAWEI_CDC_NCM=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_NET_CDC_MBIM=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_NET_DM9601=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_NET_SR9700=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_NET_SR9800=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_NET_SMSC75XX=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_NET_SMSC95XX=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_NET_GL620A=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_NET_NET1080=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_NET_PLUSB=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_NET_MCS7830=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_NET_RNDIS_HOST=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_NET_CDC_SUBSET_ENABLE=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_NET_CDC_SUBSET=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_ALI_M5632=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_AN2720=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_BELKIN=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_ARMLINUX=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_EPSON2888=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_KC2190=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_NET_ZAURUS=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_NET_CX82310_ETH=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_NET_KALMIA=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_NET_QMI_WWAN=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_NET_INT51X1=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_IPHETH=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_SIERRA_NET=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_VL600=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_NET_CH9200=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_NET_AQC111=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_USB_RTL8153_ECM=m' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        # enable systemV IPC (needed by fakeroot during makepkg)
        echo 'CONFIG_SYSVIPC=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_SYSVIPC_SYSCTL=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        # enable swap
        echo 'CONFIG_SWAP=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_ZSWAP=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        # enable Cedrus VPU Drivers
        echo 'CONFIG_MEDIA_SUPPORT=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_MEDIA_CONTROLLER=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_MEDIA_CONTROLLER_REQUEST_API=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_V4L_MEM2MEM_DRIVERS=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_VIDEO_SUNXI_CEDRUS=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        # enable binfmt_misc
        echo 'CONFIG_BINFMT_MISC=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        # enable EFI
        echo 'CONFIG_EFI=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_EFI_ZBOOT=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        # enable fat
        echo 'CONFIG_VFAT_FS=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-15"' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_FAT_DEFAULT_UTF8=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_EXFAT_FS=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_NLS_CODEPAGE_437=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_NLS_ISO8859_15=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_NLS_DEFAULT="utf8"' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_NLS_UTF8=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        # enable initramfs compression
        echo 'CONFIG_BLK_DEV_INITRD=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_INITRAMFS_SOURCE=""' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_RD_GZIP=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_RD_BZIP2=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_RD_LZMA=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_RD_XZ=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_RD_LZO=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_RD_LZ4=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        echo 'CONFIG_RD_ZSTD=y' >> ${DIR}/arch/riscv/configs/nezha_defconfig
        make CROSS_COMPILE=riscv64-linux-gnu- ARCH=riscv ${kernel_config}
        sed -i '/CONFIG_LOCALVERSION_AUTO/d' .config && echo "CONFIG_LOCALVERSION_AUTO=n" >> .config
        make CROSS_COMPILE=riscv64-linux-gnu- ARCH=riscv -j$(nproc)
        if [ x"$(cat .config | grep CONFIG_MODULES=y)" = x"CONFIG_MODULES=y" ]; then
            make CROSS_COMPILE=riscv64-linux-gnu- ARCH=riscv INSTALL_MOD_PATH=../rootfs/ modules_install -j$(nproc)
        fi
        # Install Kernel
        make CROSS_COMPILE=riscv64-linux-gnu- ARCH=riscv INSTALL_PATH=../rootfs/boot install -j$(nproc)
        make CROSS_COMPILE=riscv64-linux-gnu- ARCH=riscv dtbs
        make CROSS_COMPILE=riscv64-linux-gnu- ARCH=riscv bindeb-pkg -j$(nproc)
        # Install DTB
        #cp -v arch/riscv/boot/dts/allwinner/sun20i-d1-mangopi-mq-pro.dtb ../rootfs/boot/
        #cp -v arch/riscv/boot/dts/allwinner/sun20i-d1-nezha.dtb ../rootfs/boot/
        #cp -v arch/riscv/boot/dts/allwinner/sun20i-d1-lichee-rv-dock.dtb ../rootfs/boot/
        make CROSS_COMPILE=riscv64-linux-gnu- ARCH=riscv INSTALL_PATH=../rootfs/boot dtbs_install
        mv -v ../rootfs/boot/dtbs/$(ls ../rootfs/lib/modules/)/* ../rootfs/boot/dtbs/
        rm -r ../rootfs/boot/dtbs/$(ls ../rootfs/lib/modules/)
        # Copy kernel Deb to root HOME
        cp -v ../*.deb ../rootfs/root/
        # Backup kernel build config
        cp -v .config ../rootfs/boot/latest-config
        ls -al ../rootfs/boot/
        git clone https://github.com/lwfinger/rtl8723ds.git
        pushd rtl8723ds
            make CROSS_COMPILE=riscv64-linux-gnu- ARCH=riscv KSRC=../ -j$(nproc) modules || true
        popd
        for kernel_version in $(ls ../rootfs/lib/modules/);
        do
            install -D -p -m 644 "rtl8723ds/8723ds.ko" \
                "../rootfs/lib/modules/${kernel_version}/kernel/drivers/net/wireless/8723ds.ko"
            depmod -a -b "../rootfs" "${kernel_version}"
            echo '8723ds' >> 8723ds.conf
            mv 8723ds.conf "../rootfs/etc/modules-load.d/"
        done
    popd
}

make_kernel_starfive_jh7110()
{
    kernel_branch="JH7110_VisionFive2_devel"
    kernel_git="https://github.com/starfive-tech/linux.git"
    kernel_config="starfive_visionfive2_defconfig"
    
    git clone --depth=1 -b ${kernel_branch} ${kernel_git} kernel
    pushd kernel
        wget https://github.com/starfive-tech/linux/commit/2f75442523e4b44bdea4ae5bc2e95137d0303c8b.patch
        #git am 2f75442523e4b44bdea4ae5bc2e95137d0303c8b.patch
        patch -p1 arch/riscv/Makefile 2f75442523e4b44bdea4ae5bc2e95137d0303c8b.patch
        make CROSS_COMPILE=riscv64-linux-gnu- ARCH=riscv ${kernel_config}
        make CROSS_COMPILE=riscv64-linux-gnu- ARCH=riscv -j$(nproc)
        if [ x"$(cat .config | grep CONFIG_MODULES=y)" = x"CONFIG_MODULES=y" ]; then
            make CROSS_COMPILE=riscv64-linux-gnu- ARCH=riscv INSTALL_MOD_PATH=../rootfs/ modules_install -j$(nproc)
        fi
        # make CROSS_COMPILE=riscv64-linux-gnu- ARCH=riscv INSTALL_PATH=../rootfs/boot zinstall -j$(nproc)
        # Install Kernel
        make CROSS_COMPILE=riscv64-linux-gnu- ARCH=riscv INSTALL_PATH=../rootfs/boot install -j$(nproc)
        make CROSS_COMPILE=riscv64-linux-gnu- ARCH=riscv dtbs
        make CROSS_COMPILE=riscv64-linux-gnu- ARCH=riscv bindeb-pkg -j$(nproc)
        # Install DTB
        #mkdir ../rootfs/boot/dtbs
        #cp -v arch/riscv/boot/dts/starfive/jh7110-visionfive-v2.dtb ../rootfs/boot/dtbs/
        #cp -v .config ../rootfs/boot/latest-config
        make CROSS_COMPILE=riscv64-linux-gnu- ARCH=riscv INSTALL_PATH=../rootfs/boot dtbs_install
        #mv -v ../rootfs/boot/dtbs/$(ls ../rootfs/lib/modules/)/* ../rootfs/boot/dtbs/
        #rm -r ../rootfs/boot/dtbs/$(ls ../rootfs/lib/modules/)
    popd
}

make_kernel()
{
	echo "making kernel for $MACHINE ..."

	case $MACHINE in
	
		sifive_unmatched)
			make_kernel_sifive_unmatched
			;;
		
		allwinner_d1)
			make_kernel_allwinner_d1
			;;
		
		starfive_jh7110)
			make_kernel_starfive_jh7110
			;;
		
		*)
			echo "No machine matched!!"
			;;
	esac
}
