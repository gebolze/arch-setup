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

echo -e "\nINSTALLING AUR SOFTWARE\n"

cd "${HOME}"

echo "CLONING: YAY"
git clone "https://aur.archlinux.org/yay.git"

PKGS=(

    # --- Utilities

    'i3lock-fancy'          # Screen locker
    'synology-drive'        # Synology Drive
    'freeoffice'            # Office Alternative

    # --- Media

    'screenkey'             # Screencast your keypreses
    'pnmixer'               # Systray pulse audio mixer

    # --- Communication

    'brave-bin'             # Brave
    'slack-desktop'         # Slack

    # --- Themes

    'lightdm-webkit-theme-aether'   # Lightdm Login Theme - https://github.com/NoiSek/Aether#installation
    'materia-gtk-theme'             # Desktop Theme
    'papirus-icon-theme'            # Desktop Icons
    'capitaine-cursors'             # Cursor Themes
)

cd ${HOME}/yay
makepkg -si

for PKG in "${PKGS[@]}"; do
    yay -S --noconfirm $PKG
done

echo -e "\nDone!\n"
