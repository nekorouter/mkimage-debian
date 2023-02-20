#!/bin/bash

make_imagefile_sifive_unmatched()
{
	sgdisk -og "$IMAGE_FILE"
    ENDSECTOR=$(sgdisk -E "$IMAGE_FILE")

    sgdisk -g --clear -a 1 \
        --new=1:40:2087         --change-name=1:'SPL' --typecode=1:5B193300-FC78-40CD-8002-E86C45580B47 \
        --new=2:2088:10279      --change-name=2:'UBOOT'  --typecode=2:2E54B353-1271-4842-806F-E436D6AF6985 \
        --new=3:10280:10535     --change-name=3:'ENV'   --typecode=3:0FC63DAF-8483-4772-8E79-3D69D8477DE4 \
        --new=4::+40M: --change-name=4:'EFI'   --typecode=1:ef00 \
        --new=5::+500M: --change-name=5:'BOOT'   --typecode=1:ef00 \
        --new=6::$ENDSECTOR: --change-name=6:'ROOT'   --typecode=2:8300 --attributes=2:set:2 \
        "$IMAGE_FILE"
    sgdisk -p "$IMAGE_FILE"
}

make_imagefile_allwinner_d1()
{
	# Create a efi partition and a root partition
	sgdisk -og "$IMAGE_FILE"
	sgdisk -n 1:2048:+40M -c 1:"EFI" -t 1:ef00 "$IMAGE_FILE"
	sgdisk -n 2:0:+500M -c 2:"BOOT" -t 1:ef00 "$IMAGE_FILE"
	#ENDSECTOR=$(sgdisk -E "$IMAGE_FILE")
	sgdisk -n 3:0:"$ENDSECTOR" -c 3:"ROOT" -t 2:8300 -A 2:set:2 "$IMAGE_FILE"
	sgdisk -p "$IMAGE_FILE"
}

make_imagefile_starfive_jh7110()
{
	# Create a efi partition and a root partition
	sgdisk -og "$IMAGE_FILE"
	sgdisk -n 1:2048:+40M -c 1:"EFI" -t 1:ef00 "$IMAGE_FILE"
	sgdisk -n 2:0:+500M -c 2:"BOOT" -t 1:ef00 "$IMAGE_FILE"
	#ENDSECTOR=$(sgdisk -E "$IMAGE_FILE")
	sgdisk -n 3:0:"$ENDSECTOR" -c 3:"ROOT" -t 2:8300 -A 2:set:2 "$IMAGE_FILE"
	sgdisk -p "$IMAGE_FILE"
}

make_imagefile()
{
	echo "Make partition for image file..."
	
	# Create image file
	IMAGE_FILE="$MACHINE-$(date +%Y%m%d-%H%M%S).img"
	truncate -s "$IMAGE_SIZE" "$IMAGE_FILE"
	
	case $MACHINE in
	
		sifive_unmatched)
			make_imagefile_sifive_unmatched
			;;
		
		allwinner_d1)
			make_imagefile_allwinner_d1
			;;
		
		starfive_jh7110)
			make_imagefile_starfive_jh7110
			;;
		
		*)
			echo "No machine matched!!"
			;;
	esac
}
