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


echo "------------------------------------------------------------------------"
echo "Network setup"
echo "------------------------------------------------------------------------"

pacman -S networkmanager dhclient --noconfirm --needed
systemctl enable --now NetworkManager


echo "------------------------------------------------------------------------"
echo "Setting up mirrors for optiomal download"
echo "------------------------------------------------------------------------"

pacman -S --noconfirm pacman-contrib curl
pacman -S --noconfirm reflector rsync
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.back

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
echo "KEYMAP=${KEYMAP}" > /etc/vconsole.conf

ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
hwclock --systohc

# Add sudo no password rights
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

# Add parallel downloading
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

pacman -Sy --noconfirm


echo "------------------------------------------------------------------------"
echo "Installing Base System"
echo "------------------------------------------------------------------------"

cat /root/archmatic/pkg-files/pacman-pkgs.txt | while read line
do
    [[ "$line" =~ ^\#.*$ ]] && continue # ignore lines start with a #
    [[ "$line" =~ ^\s*$ ]] && continue  # ignore lines that only contain whitespace

    echo "Installing: ${line}"
    sudo pacman -S --noconfirm --needed ${line}
done


echo "------------------------------------------------------------------------"
echo "Setting hostname"
echo "------------------------------------------------------------------------"

echo "${nameofmachine}" > /etc/hostname


echo "------------------------------------------------------------------------"
echo "Installing Microcode"
echo "------------------------------------------------------------------------"
proc_type=$(lscpu)
if grep -E "GenuineIntel" <<< ${proc_type}; then
    echo "Installing Intel microcode"
    pacman -S --noconfirm intel-ucode
    proc_ucode=intel-ucode.img
elif grep -E "AuthenticAMD" <<< ${proc_type}; then
    echo "Installing AMD microcode"
    pacman -S --noconfirm amd-ucode
    proc_ucode=amd-ucode.img
fi


echo "------------------------------------------------------------------------"
echo "Installing Graphics Drivers"
echo "------------------------------------------------------------------------"
gpu_type=$(lspci)
if grep -E "NVIDIA|GeForce" <<< ${gpu_type}; then
    echo "Installing nvidia driver"
    pacman -S nvidia --noconfirm --needed

    echo "Adding nvidia modules to initramfs"
    sed -i 's/MODULES=\(/MODULES=\(nvidia nvidia_modeset nvidia_uvm nvidia_drm/g' /etc/mkinitcpio.conf
    mkinitcpio -P

    echo "Adding pacman hook for nvidia driver"
    mkdir -p /etc/pacman.d/hooks
    cat <<EOF > /etc/pacman.d/hooks/nvidia.hook
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia
Target=linux

[Action]
Description=Update Nvidia module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case $trg in linux*) exit 0; esac; done; /usr/bin/mkinitcpio -P'
EOF
elif lspci | grep 'VGA' | grep -E "Radeon|AMD"; then
    pacman -S xf86-video-amdgpu --noconfirm --needed
elif grep -E "Integrated Graphics Controller|Intel Corporation UHD" <<< ${gpu_type}; then
    pacman -S libva-intel-driver libvdpau-va-gl vulkan-intel libva-intel-driver libva-utils --needed --noconfirm
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
cat <<EOF > /boot/loader/entries/arch.conf
title Arch Linux
linux /vmlinuz-linux
initrd /${proc_ucode}
initrd /initramfs-linux.img
options root=${root_partition} rootflags=subvol=@ nvidia_drm.modeset=1 nvida_drm.fbdev=1 rw
EOF

echo "------------------------------------------------------------------------"
echo "Enabling weekly filesystem TRIM"
echo "------------------------------------------------------------------------"
systemctl enable fstrim.timer

echo "------------------------------------------------------------------------"
echo "Adding user"
echo "------------------------------------------------------------------------"
if [ $(whoami) = "root" ]; then
    useradd -m -G wheel -s /bin/bash $USERNAME
    echo "$USERNAME:$PASSWORD" | chpasswd
    echo "root:$ROOTPASSWORD" | chpasswd
    cp -R /root/archmatic /home/$USERNAME/
    chown -R $USERNAME: /home/$USERNAME/archmatic
fi
