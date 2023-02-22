# mkimage-debian
Make a Debian image for (some) RISC-V boards

## Requirements
```bash
apt install -y mmdebstrap debian-ports-archive-keyring \
	qemu binfmt-support qemu-user-static curl wget \
	libncurses-dev gawk flex bison swig openssl libssl-dev device-tree-compiler \ 
```

## Script Descriptions
mkimage.sh: will build a bootable sdcard image for target board, target board can be set in this script.

```Supported machine name: sifive_unmatched, allwinner_d1, starfive_jh7110```

other/mkimage-uboot.sh: Make a image file contains only uboot, write to sdcard if device path is given, only for Hifive Unmatched

```sudo mkimage-uboot.sh -d [sdcard device (/dev/sdx)]```

## Image Making Steps
1. Partition and format target disk (a EFI partition for future use and a root partition)
2. Using bootstrap tool (mmdebstrap or other tools) get a Debian chroot environment
3. (Temprorary?) Set locale of the chroot, in case of bug #1021109 (https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1021109)
4. Set up u-boot (U_BOOT_ROOT="root=/dev/nvme0n1p1")
5. Set /etc/fstab (for future use)
6. Set root password
7. Install other useful tools
8. clean up and umount


## Similar Projects
https://wiki.debian.org/InstallingDebianOn/SiFive/HiFiveUnmatched

https://github.com/XYenChi/bootloader

https://github.com/deepin-community/deepin-riscv-board/
