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

source ~/archmatic/setup.conf

echo "------------------------------------------------------------------------"
echo "Installing rua AUR package manager"
echo "------------------------------------------------------------------------"

mkdir -p ~/builds
cd ~/builds
git clone "https://aur.archlinux.org/paru.git"
cd paru
makepkg -si --noconfirm


echo "------------------------------------------------------------------------"
echo "Installing AUR packages"
echo "------------------------------------------------------------------------"

cat ~/archmatic/pkg-files/aur-pkgs.txt | while read line
do
    [[ "$line" =~ ^\#.*$ ]] && continue # ignore lines start with a #
    [[ "$line" =~ ^\s*$ ]] && continue  # ignore lines that only contain whitespace

    echo "Installing: ${line}"
    paru -S ${line}
done