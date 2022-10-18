# mkimage-debian
Make a Debian image for Sifive Unmatched

## Requirements
```bash
sudo apt install mmdebstrap debian-ports-archive-keyring
```

## Script Descriptions
mkimage-nvme.sh: Directly make a "u-boot ready" nvme disk for Unmatched

mkimage-sdcard.sh: Make a image file with u-boot, suitable for sdcard

mkimage-uboot.sh: Make a image file contains only uboot, write to sdcard if device path is given

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

### Flash U-Boot to SDCard

```
sudo mkimage-uboot.sh -d [sdcard device (/dev/sdx)]
```
This will make a sdcard only contains opensbi and u-boot, suitable for boot form nvme case.

### Flash U-Boot Unmatched onboard Flash

```
sudo mkimage-uboot.sh -o [image_file_name]
(copy output image file to unmatched)
sudo modprobe mtdblock    # Load the MTD block driver
sudo dd if=[image_file_name] of=/dev/mtdblock0 status=progress    # flash image to MTD device (SPI Flash)
```
After this step, set the "BOOT MODE SEL" switches to "0110" and boot.

## Addtional
>TODO (a hardware setup guide needed?)

### BOOT MODE SEL (MSEL) switch

```
Boot from sdcard (SPI0): 1101

Boot from onboard flash (QSPI0): 0110
```

>On [hifive-unmatched-schematics-v3.pdf](https://sifive.cdn.prismic.io/sifive/6a06d6c0-6e66-49b5-8e9e-e68ce76f4192_hifive-unmatched-schematics-v3.pdf), SD Card is connected to SPI0, but on [fu740-c000-manual-v1p6.pdf](https://sifive.cdn.prismic.io/sifive/1a82e600-1f93-4f41-b2d8-86ed8b16acba_fu740-c000-manual-v1p6.pdf), there is a table 19 where mentioned "QSPI2 SD Card", and it matched boot from sd card case. need more research?

### Partitions
Rootfs: ext4, must have ```legacy_boot``` flag set for extlinux boot

EFI: vfat, must have ```boot,esp``` flag set for grub boot

## Similar Projects
https://wiki.debian.org/InstallingDebianOn/SiFive/HiFiveUnmatched

https://github.com/XYenChi/bootloader

