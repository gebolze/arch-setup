#!/usr/bin/env bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
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

bash startup.sh
source $SCRIPT_DIR/setup.conf
bash 0-preinstall.sh &> ./preinstall.log

arch-chroot /mnt /root/archmatic/1-setup.sh &> ./setup.log
arch-chroot /mnt /usr/bin/runuser -u $USERNAME -- /home/$USERNAME/archmatic/2-user.sh &> ./user.log
arch-chroot /mnt /root/archmatic/3-post-setup.sh &> ./post-setup.log

tar -cJf archmatic-logs.tar.xz *.log
cp ./archmatic-logs.tar.xz /mnt/root/archmatic-logs.tar.xz

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
Done - Please Eject Install Media and Reboot
-------------------------------------------------------------------------
EOF
