#!/bin/bash

# opensbi and uboot layout: https://forums.sifive.com/t/booting-from-flash/5104/11

device=
filename=

#check root privileges:
if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi

# if -h is given, print help
# if var is empty, make image file; if specific device is given, write it to device:
while getopts 'd:o:' option
do
    case "$option" in
    d)
        device="$OPTARG"
        ;;
    o)
        filename="$OPTARG"
        ;;
    ?)
        echo "usage: $0 [-d device] [-o image filename]"
        exit 1
        ;;
    esac
done

if [ -z "$device" ] && [ -z "$filename" ]; then
    echo "target device/filename is not specified!"
    exit 2
fi
if [ -z "$filename" ]; then
    filename=uboot.img
fi

# Make empty image file
truncate -s 8M "$filename"

# Create opensbi and u-boot partition
sgdisk -g --clear -a 1 \
    --new=1:40:2087:    --change-name=1:'u-boot-spl'    --typecode=1:5b193300-fc78-40cd-8002-e86c45580b47 \
    --new=2:2088:10279:  --change-name=2:'opensbi-uboot' --typecode=2:2e54b353-1271-4842-806f-e436d6af6985 \
    --new=3:10280:10535: --change-name=3:env   --typecode=3:3DE21764-95BD-54BD-A5C3-4ABE786F38A8 \
    "$filename"
echo "======================="
sgdisk -p "$filename"

# Setup bootloaders
dd if=u-boot-spl.bin-unmatched-2022.07-r0 of="$filename" bs=512 seek=40 conv=sync,notrunc status=progress
dd if=u-boot-unmatched-2022.07-r0.itb of="$filename" bs=512 seek=2088 conv=sync,notrunc status=progress
#sync

# Write image to disk
if [ ! -z "$device" ]; then
    dd if="$filename" of="$device" status=progress
fi

echo "done."

