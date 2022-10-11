# mkimage-debian
Make a Debian image for Sifive Unmatched

## Requirements
```bash
sudo apt install mmdebstrap debian-ports-archive-keyring
```

## Script Descriptions
mkimage-nvme.sh: Directly make a "u-boot ready" nvme disk for Unmatched

mkimage-sdcard.sh: Make a image file with u-boot, suitable for sdcard

mkimage-uboot.sh: Only burn u-boot on sdcard, if you only want boot from nvme disk

## Image Making Steps
1. Partition and format target disk (a EFI partition for future use and a root partition)
2. Using bootstrap tool (mmdebstrap or other tools) get a Debian chroot environment
3. (Temprorary?) Set locale of the chroot, in case of bug #1021109 (https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1021109)
4. Set up u-boot (U_BOOT_ROOT="root=/dev/nvme0n1p1")
5. Set /etc/fstab (for future use)
6. Set root password
7. Install other useful tools
8. clean up and umount

## Binary file Source
U-boot files are from meta-sifive (https://github.com/sifive/meta-sifive/tree/master), Mainline U-boot with meta-sifive patches should be same.

Patches: https://github.com/sifive/meta-sifive/tree/master/recipes-bsp/u-boot/files/riscv64

>TODO: Devicetree file? (package: linux-modules-xxx)

## Flash image on SDCard/NVMe
>For only sdcard: TODO (dd)

>For sdcard + nvme disk: TODO (dd + mkimage-nvme.sh)

## Addtional
>TODO (a hardware setup guide needed?)

### Partitions
Rootfs: ext4, must have ```legacy_boot``` flag set for extlinux boot

EFI: vfat, must have ```boot,esp``` flag set for grub boot

## Similar Projects
https://github.com/XYenChi/bootloader

