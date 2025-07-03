#!/bin/bash

set -euo pipefail

sudo pacstrap /mnt base base-devel linux linux-firmware

# The 'genfstab' generates the /etc/fstab file, which defines how partitions should be mounted
# The -U option ensures that UUIDs are used instead of device names (e.g., /dev/sda1),
# making the system more stable against disk order changes.
sudo genfstab -U /mnt | sudo tee -a /mnt/etc/fstab

sudo arch-chroot /mnt /bin/bash <<EOF
# Timezone
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

# Locale
sed -i "s/^#$LOCALE/$LOCALE/" /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf

# Hostname
echo $HOSTNAME > /etc/hostname
cat > /etc/hosts <<EOL
127.0.0.1	localhost
::1		localhost
EOL

# Users
echo "root:$ROOT_PASSWORD" | chpasswd

useradd -m -G wheel $USERNAME 
echo "$USERNAME:$PASSWORD" | chpasswd
echo "%wheel ALL=(ALL) ALL" | EDITOR="tee -a" visudo > /dev/null
# echo "%wheel ALL=(ALL) NOPASSWD:ALL" | EDITOR="tee -a" visudo

# Network manager
pacman -S networkmanager --noconfirm
systemctl enable NetworkManager

pacman -S openssh --noconfirm
systemctl enable sshd.service

pacman -Sy --noconfirm ansible

# Bootloader
pacman -S grub efibootmgr --noconfirm
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg
EOF

sudo umount -R /mnt
sudo reboot 
