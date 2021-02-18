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

echo -e "\nInstalling Base System\n"

PKGS=(

    # --- XORG Display Rendering
        'nvidia'
        'nvidia-utils'
        'xterm'         # Terminal for TTY
        'xorg-server'   # XOrg server
        'xorg-apps'     # XOrg apps group
        'xorg-xinit'    # XOrg init
        'xorg-xinput'   # XOrg xinput

    # --- Setup Desktop
        'awesome'               # Awesome Desktop
        'xfce4-power-manager'   # Power Manager
        'rofi'                  # Menu System
        'picom'                 # Translucent Windows
        'xclip'                 # System clipboard
        'polkit-gnome'          # Elevated Applications
        'lxappearance'          # Set System Themes

    # --- Login Display Manager
        'lightdm'                   # Base Login Manager
        'lightdm-webkit2-greeter'   # Framework for Awesome Login Themes

    # --- Networking Setup
        'wpa_supplicant'            # Key negotiation for WPA wireless networks
        'dialog'                    # Enables shell scripts to trigger dialog boxes
        'openvpn'                   # Open VPN support
        'networkmanager-openvpn'    # Open VPN plugin for NM
        'networkmanager-applet'     # System try icon/utility for network connectivity
        'libsecret'                 # Library for storing passwords

    # --- Audio
        'alsa-utils'        # Advanced Linux Sound Architecture (ALSA) Components
        'alsa-plugins'      # ALSA plugins
        'pulseaudio'        # Pluse Audio sound components
        'pulseaudio-alsa'   # ALSA configuration for pulse audio
        'pavucontrol'       # Pulse Audio volume control
        'pnmixer'           # System tray volume control
    
    # --- Bluetooth
        'bluez'                 # Daemons for the bluetooth protocol stack
        'bluez-utils'           # Bluetooth development and debugging utilities
        'bluez-firmware'        # Firmwares for Boardcom BCM203x and STLC2300 Bluetooth chips
        'blueberry'             # Bluetooth configuration tool
        'pulseaudio-bluetooth'  # Bluetooth support for PulseAudio

    # --- Printers
        'cups'                  # Open source printer drivers
        'cups-pdf'              # PDF support for cups
        'ghostscript'           # PostScript interpreter
        'gsfonts'               # Adobe Postscript replacement fonts
        'system-config-printer' # Printer setup utility
)

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done

echo -e "\nDone!\n"
