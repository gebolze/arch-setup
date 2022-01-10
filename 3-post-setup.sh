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
echo "Cleaning"
echo "------------------------------------------------------------------------"

# Remove no password sudo rights
sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

rm -r /root/archmatic
rm -r /home/$USERNAME/archmatic

cd $pwd