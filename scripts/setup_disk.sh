#!/bin/bash

set -euo pipefail

DISK=/dev/vda

sudo sgdisk ${DISK} --new=1:0:+${EFI_SIZE}  --typecode=1:ef00 --change-name=1:EF_System
sudo sgdisk ${DISK} --new=2:0:+${ROOT_SIZE} --typecode=2:8300 --change-name=2:Root_Filesystem
sudo sgdisk ${DISK} --new=3:0:+${SWAP_SIZE} --typecode=3:8200 --change-name=3:Swap_Space
sudo sgdisk ${DISK} --new=4:0:              --typecode=4:8300 --change-name=4:Home_Directory

# Synchronize kernel partition table
sudo partprobe /dev/vda

sudo mkfs.fat -F32 ${DISK}1
sudo mkfs.ext4 -F ${DISK}2
sudo mkfs.ext4 -F ${DISK}4

sudo mkswap -f ${DISK}3
sudo swapon ${DISK}3

sudo mount ${DISK}2 /mnt
sudo mkdir -p /mnt/boot/efi && sudo mount ${DISK}1 /mnt/boot/efi
sudo mkdir -p /mnt/home && sudo mount ${DISK}4 /mnt/home
