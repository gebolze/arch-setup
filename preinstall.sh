#!/usr/bin/env bash

# ------------------------------------------------------------------------
#  _______           __    ___ ___       __   __      
# |   _   .----.----|  |--|   Y   .---.-|  |_|__.----.
# |.  1   |   _|  __|     |.      |  _  |   _|  |  __|
# |.  _   |__| |____|__|__|. \_/  |___._|____|__|____|
# |:  |   |               |:  |   |                   
# |::.|:. |               |::.|:. |                   
# `--- ---'               `--- ---'                   
#
#        Arch Linux Post Install and Setup Config
#
# ------------------------------------------------------------------------

echo "------------------------------------------------------------------------"
echo "Setting up mirrors for optimal download - EU only"
echo "------------------------------------------------------------------------"
timedatectl set-ntp true
pacman -S --noconfirm pacman-contrib
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
curl -s "https://archlinux.org/mirrorlist/?country=DE&protocol=http&protocol=https&use_mirror_status=on" | curl -s "https://archlinux.org/mirrorlist/?country=DE&protocol=http&protocol=https&use_mirror_status=on" | sed -e '' | rankmirrors -n 5 - > /etc/pacman.d/mirrorlist
pacman -Syy

echo -e "\nInstalling prereqs...\n"
pacman -S --noconfirm gptfdisk btrfs-progs

echo "------------------------------------------------------------------------"
echo "Select your disk to format"
echo "------------------------------------------------------------------------"
lsblk
echo -n "Please enter disk (eg: /dev/sda): "
read DISK
echo "------------------------------------------------------------------------"
echo -e "Formatting disk..."
echo "------------------------------------------------------------------------"

# disk prep
sgdisk -Z ${DISK}
sgdisk -a 2048 -o ${DISK}

# create partitions
sgdisk -n 1:0:+300M ${DISK}
sgdisk -n 2:0:+2G   ${DISK}
sgdisk -n 3:0:0     ${DISK}

# set partition types
sgdisk -t 1:ef00 ${DISK}
sgdisk -t 2:8200 ${DISK}
sgdisk -t 3:8300 ${DISK}

# label partitions
sgdisk -c 1:"UEFISYS" ${DISK}
sgdisk -c 2:"SWAP"    ${DISK}
sgdisk -c 3:"ROOT"    ${DISK}

# make filesystems
echo -e "\nCreating Filesystems...\n"

mkfs.fat -F32 "${DISK}1"
mkswap "${DISK}2"
mkfs.btrfs -L "ROOT" "${DISK}3"

# enable swap
swapon "${DISK}2"

# prepare subvolumes
mount "${DISK}3" /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@var_log
umount /mnt

# mount target
mount -o noatime,compress=lzo,space_cache=v2,subvol=@ "${DISK3}" /mnt
mkdir -p /mnt/{boot,home,.snapshots,var_log}
mount "${DISK}1" /mnt/boot
mount -o noatime,compress=lzo,space_cache=v2,subvol=@home "${DISK3}" /mnt/home
mount -o noatime,compress=lzo,space_cache=v2,subvol=@snapshots "${DISK3}" /mnt/.snapshots
mount -o noatime,compress=lzo,space_cache=v2,subvol=@var_log "${DISK3}" /mnt/var_log

echo "------------------------------------------------------------------------"
echo "Arch Install on Main Drive"
echo "------------------------------------------------------------------------"
pacstrap /mnt base base-devel linux linux-firmware amd-ucode --noconfirm --needed
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

echo "------------------------------------------------------------------------"
echo "Bootloader Systemd Installation"
echo "------------------------------------------------------------------------"
bootctl install
cat <<EOF > /boot/loader/entries/arch.conf
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=${DISK}1 rw
EOF

echo "------------------------------------------------------------------------"
echo "Network Setup"
echo "------------------------------------------------------------------------"
pacman -S networkmanager dhclient --noconfirm --needed
systemctl enable --now NetworkManager

echo "------------------------------------------------------------------------"
echo "Set Password For Root"
echo "------------------------------------------------------------------------"
echo "Enter password for root user: "
passwd root

exit
umount -R /mnt

echo "------------------------------------------------------------------------"
echo "SYSTEM READY FOR FIRST BOOT"
echo "------------------------------------------------------------------------"
