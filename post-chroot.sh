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

if ! source install.conf; then
    read -p "Please enter hostname:" hostname
    read -p "Please enter username:" username
    read -sp "Please enter password:" password; echo ""
    read -sp "Please repeat password:" password2; echo ""

    # check that both passwords match
    if [ "$password" != "$password2" ]; then
        echo "Passwords do not match"
        exit 1
    fi

    printf "hostname=$hostname\n" >> install.conf
    printf "username=$username\n" >> install.conf
    printf "password=$password\n" >> install.conf
fi

echo "------------------------------------------------------------------------"
echo "Bootloader Systemd Installation"
echo "------------------------------------------------------------------------"
bootctl install
cat <<EOF > /boot/loader/entries/arch.conf
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=${DISK}p3 rootflags=subvol=@ rw
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

echo "------------------------------------------------------------------------"
echo "Add user: ${username}"
echo "------------------------------------------------------------------------"
useradd -mG wheel ${username}
passwd ${username} ${password}