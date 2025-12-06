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

cp  /usr/lib/systemd/network/89-ethernet.network.example /etc/systemd/network/89-ethernet.network
ln -sf ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

systemctl enable systemd-networkd.service
systemctl enable systemd-resolved.service


echo "------------------------------------------------------------------------"
echo "Installing additional system packages"
echo "------------------------------------------------------------------------"

cat /root/archmatic/pkg-files/pacman-pkgs.txt | while read line
do
    [[ "$line" =~ ^\#.*$ ]] && continue # ignore lines start with a #
    [[ "$line" =~ ^\s*$ ]] && continue  # ignore lines that only contain whitespace

    echo "Installing: ${line}"
    sudo pacman -S --noconfirm --needed ${line}
done


echo "------------------------------------------------------------------------"
echo "Configuring the Display Manager"
echo "------------------------------------------------------------------------"
pacman -S --no-confirm cage greetd-regreet polkit
cp -r ./system-config/greetd/ /etc/greetd/
systemctl enable greetd.service

echo "------------------------------------------------------------------------"
echo "Enabling weekly filesystem TRIM"
echo "------------------------------------------------------------------------"
systemctl enable fstrim.timer

echo "------------------------------------------------------------------------"
echo "Configuring hardware monitoring"
echo "------------------------------------------------------------------------"
pacman -S lm_sensors --no-confirm
cp ./system-config/lm_sensors/strix /etc/sensors.d/strix
cp ./system-config/lm_sensors/sensors.conf /etc/modules-load.d/sensors.conf

echo "------------------------------------------------------------------------"
echo "Enabling virtual machine support"
echo "------------------------------------------------------------------------"
pacman -S qemu-desktop virt-manager
systemctl enable libvirtd.socket

echo "------------------------------------------------------------------------"
echo "Adding user"
echo "------------------------------------------------------------------------"
if [ $(whoami) = "root" ]; then
    gpasswd -a $USERNAME libvirt
fi
