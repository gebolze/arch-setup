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
echo "Setting up mirrors for optimal downloads - Germany Only"
echo "------------------------------------------------------------------------"
pacman -S --noconfirm pacman-contrib curl
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
curl -s "https://archlinux.org/mirrorlist/?country=DE&protocol=http&protocol=https&use_mirror_status=on" | curl -s "https://archlinux.org/mirrorlist/?country=DE&protocol=http&protocol=https&use_mirror_status=on" | sed -e '' | rankmirrors -n 5 - > /etc/pacman.d/mirrorlist


echo "------------------------------------------------------------------------"
echo "Setup makepkg.conf"
echo "------------------------------------------------------------------------"
nc=$(grep -c ^processor /proc/cpuinfo)
echo "You have $nc cores."
sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$nc"/g' /etc/makepkg.conf
echo "Changing the compression for $nc cores."
sudo sed -i 's/COMPRESSXZ=(xz -c -)/COMPRESSZX=(xz -c -T $nc -z -)/'

echo "------------------------------------------------------------------------"
echo "Setup Language to US and set locale"
echo "------------------------------------------------------------------------"
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/#de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
timedatectl --no-ask-password set-timezone Europe/Berlin
timedatectl --no-ask-password set-ntp 1
localectl --no-ask-password set-locale LANG="en_US.UTF-8" LC_COLLATE="" LC_TIME="en_US.UTF-8"

# set keymaps
localectl --no-ask-password set-keymap de-latin1

# hostname
hostnamectl --no-ask-password set-hostname $hostname

# Add sudo no password rights
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD:ALL/' /etc/sudoers
