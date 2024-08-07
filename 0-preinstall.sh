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

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source setup.conf

echo "------------------------------------------------------------------------"
echo "Setting up mirrors for optimal downloads"
echo "------------------------------------------------------------------------"

iso=$(curl -4 ifconfig.co/country-iso)
timedatectl set-ntp true
pacman -Sy --noconfirm pacman-contrib terminus-font
setfont ter-v22b
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
pacman -S --noconfirm reflector rsync
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

echo "------------------------------------------------------------------------"
echo "Setting up $iso mirrors for optimal downloads"
echo "------------------------------------------------------------------------"

reflector -a 48 -c $iso -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist
mkdir /mnt &>/dev/null

echo "------------------------------------------------------------------------"
echo "Installing Prerequisites"
echo "------------------------------------------------------------------------"

pacman -S --noconfirm gptfdisk btrfs-progs

echo "------------------------------------------------------------------------"
echo "Creating Partitions on ${DISK}"
echo "------------------------------------------------------------------------"

sgdisk -Z ${DISK}           # zap all on disk
sgdisk -a 2048 -o ${DISK}   # new gpt disk with 2048 sector (1MB) alignment

# create partitions
sgdisk -n 1::+1G -typecode=1:ef00 --change-name=1:'UEFISYS' ${DISK}
if [[ "${swaptype}" == "part" ]]; then
  sgdisk -n 2::+32G  -typecode=2:8200 --change-name=2:'SWAP' ${DISK}
  sgdisk -n 3::-0    -typecode=3:8300 --change-name=3:'ROOT' ${DISK}
else
  sgdisk -n 2::-0    -typecode=2:8300 --change-name=2:'ROOT' ${DISK}
fi

echo "------------------------------------------------------------------------"
echo "Creating Filesystems"
echo "------------------------------------------------------------------------"

if [[ "${DISK}" =~ "nvme" ]]; then
    sys_partition=${DISK}p1
    if [[ "${swaptype}" == "part" ]]; then
      swap_partition=${DISK}p2
      root_partition=${DISK}p3
    else
      root_partition=${DISK}p2
    fi
else
    sys_partition=${DISK}1
    if [[ "${swaptype}" == "part" ]]; then
      swap_partition=${DISK}2
      root_partition=${DISK}3
    else
      root_partition=${DISK}2
    fi
fi

mkfs.vfat -F32 -n "EFIBOOT" ${sys_partition}

if [[ "${FS}" == "btrfs" ]]; then
    mkfs.btrfs -L "ROOT" $root_partition -f
    mount -t btrfs $root_partition /mnt
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    btrfs subvolume create /mnt/@.snapshots
    btrfs subvolume create /mnt/@var_log
    if [[ "${swaptype}" == "file" ]]; then
        btrfs subvolume create /mnt/@swap
    fi

    umount /mnt

    mount -o ${mountoptions},subvol=@ ${root_partition} /mnt
    mkdir -p /mnt/{boot,home,.snapshots,var/log}
    mount -o ${mountoptions},subvol=@home ${root_partition} /mnt/home
    mount -o ${mountoptions},subvol=@.snapshots ${root_partition} /mnt/.snapshots
    mount -o ${mountoptions},subvol=@var_log ${root_partition} /mnt/var/log
    if [[ "${swaptype}" == "file" ]]; then
        mkdir -p /mnt/.swap
        mount -o ${mountoptions},subvol=@swap ${root_partition} /mnt/.swap
        btrfs filesystem mkswapfile --size 32G --uuid clear /mnt/.swap/swapfile
    fi
elif [[ "${FS}" == "ext4" ]]; then
    mkfs.ext4 -L "ROOT" $root_partition
    mount -t ext4 $root_partition /mnt
    if [[ "${swaptype}" == "file" ]]; then
        mkdir -p /mnt/.swap
        mkswap -U clear --size 32G --file /mnt/.swap/swapfile
    fi
fi

if [[ "${swaptype}" == "part" ]]; then
    mkswap $swap_partition
    swapon $swap_partition
else
    swapon /mnt/.swap/swapfile
fi

mount $sys_partition /mnt/boot

echo "------------------------------------------------------------------------"
echo "Arch Install on Main Drive"
echo "------------------------------------------------------------------------"
pacstrap /mnt base base-devel linux linux-firmware --noconfirm --needed
genfstab -U /mnt >> /mnt/etc/fstab

echo "------------------------------------------------------------------------"
echo "Copying install scripts & pacman mirrors for optimal downloads"
echo "------------------------------------------------------------------------"
cp -R ${SCRIPT_DIR} /mnt/root/archmatic
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
