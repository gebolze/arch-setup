#!/usr/bin/env bash

cat << EOF
-------------------------------------------------------------------------
  _______           __    ___ ___       __   __
 |   _   .----.----|  |--|   Y   .---.-|  |_|__.----.
 |.  1   |   _|  __|     |.      |  _  |   _|  |  __|
 |.  _   |__| |____|__|__|. \_/  |___._|____|__|____|
 |:  |   |               |:  |   |
 |::.|:. |               |::.|:. |
 \`--- ---'               \`--- ---'

        Arch Linux Post Install and Setup Config

-------------------------------------------------------------------------
EOF

source /root/archmatic/setup.conf


nc=$(grep -c ^processor /proc/cpuinfo)
echo "------------------------------------------------------------------------"
echo "You have $nc cores. Changing the makeflags and compression settings"
echo "------------------------------------------------------------------------"
sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$nc\"/g" /etc/makepkg.conf
sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g" /etc/makepkg.conf


echo "------------------------------------------------------------------------"
echo "Setup Language to US and set locale"
echo "------------------------------------------------------------------------"
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/#de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "LC_TIME=de_DE.UTF-8" >> /etc/locale.conf
echo "LC_MONETARY=de_DE.UTF-8" >> /etc/locale.conf
echo "KEYMAP=${KEYMAP}" > /etc/vconsole.conf

ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
hwclock --systohc

echo "------------------------------------------------------------------------"
echo "Configuring pacman"
echo "------------------------------------------------------------------------"

sed -i 's/^#Color/Color/' /etc/pacman.conf
sed -i '/Color/a ILoveCandy' /etc/pacman.conf
sed -i 's/#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
pacman -Sy --noconfirm


echo "------------------------------------------------------------------------"
echo "Installing required system packages"
echo "------------------------------------------------------------------------"
pacman -S --noconfirm amd-ucode btrfs-progs

echo "------------------------------------------------------------------------"
echo "Setting hostname"
echo "------------------------------------------------------------------------"

echo "${nameofmachine}" > /etc/hostname


echo "------------------------------------------------------------------------"
echo "Installing Graphics Drivers"
echo "------------------------------------------------------------------------"
    echo "Installing nvidia driver"
    pacman -S nvidia-open --noconfirm --needed

    echo "Adding nvidia modules to initramfs"
    sed -i 's/MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /g' /etc/mkinitcpio.conf
    mkinitcpio -P


echo "------------------------------------------------------------------------"
echo "Configuring mkinitcpio"
echo "------------------------------------------------------------------------"
if [[ "${encryption}" -eq 1 ]]; then
    echo "Adding btrfs and usb modules to initramfs"
    sed -i 's/MODULES=(/MODULES=(btrfs usbhid xhci_hcd /g' /etc/mkinitcpio.conf

    echo "Adding sd-encrypt & removing kms hook to initramfs"
    sed -i 's/HOOKS=(base systemd autodetect microcode modconf kms keyboard keymap sd-vconsole block filesystems fsck)/HOOKS=(base systemd autodetect microcode modconf keyboard keymap sd-vconsole block sd-encrypt filesystems fsck)/' /etc/mkinitcpio.conf
    mkinitcpio -P
fi

echo "------------------------------------------------------------------------"
echo "Installing Systemd Bootloader"
echo "------------------------------------------------------------------------"
if [[ "${DISK}" =~ "nvme" ]]; then
    if [[ "${swaptype}" == "part" ]]; then
      root_partition="${DISK}p3"
    else
      root_partition="${DISK}p2"
    fi
else
    if [[ "${swaptype}" == "part" ]]; then
      root_partition="${DISK}3"
    else
      root_partition="${DISK}2"
    fi
fi

bootctl install

if [[ "${encryption}" -eq 1 ]]; then
    cat <<EOF > /boot/loader/entries/arch.conf
title Arch Linux
linux /vmlinuz-linux
initrd /amd-ucode.img
initrd /initramfs-linux.img
options rd.luks.name=$(blkid -s UUID -p value ${root_partition})=root root=/dev/mapper/root rootflags=subvol=@ rw
EOF
else
    cat <<EOF > /boot/loader/entries/arch.conf
title Arch Linux
linux /vmlinuz-linux
initrd /amd-ucode.img
initrd /initramfs-linux.img
options root=${root_partition} rootflags=subvol=@ rw
EOF
fi


echo "------------------------------------------------------------------------"
echo "configuring users"
echo "------------------------------------------------------------------------"

echo "root:$ROOTPASSWORD" | chpasswd
useradd -m -G wheel -s /bin/bash $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd


echo "------------------------------------------------------------------------"
echo "moving scripts to user home"
echo "------------------------------------------------------------------------"

mv -R /root/archmatic /home/$USERNAME/
chown -R $USERNAME: /home/$USERNAME/archmatic