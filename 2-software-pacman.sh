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

echo -e "\nINSTALLING SOFTWARE\n"

PKGS=(

    # --- System
    
    'linux-lts'             # Long term support kernel

    # --- Terminal utilities

    'bash-completion'       # Tab completion for Bash
    'bleachbit'             # File deletion utility
    'cronie'                # cron jobs
    'curl'                  # Remote content retrieval
    'file-roller'           # Archive utility
    'gtop'                  # System monitoring via terminal
    'gufw'                  # Firewall manager
    'hardinfo'              # Hardware info app
    'htop'                  # Process viewer
    'neofetch'              # Shows system info when you launch terminal
    'ntp'                   # Network Time Protocol to set time via network
    'numlockx'              # Turns on numlock in X11
    'openssh'               # SSH connectitvity tools
    'p7zip'                 # 7z compression program
    'rsync'                 # Remote file sync utility
    'speedtest-cli'         # Internet speed via terminal
    'terminus-font'         # Font package with some bigger fonts for login terminal
    'unrar'                 # RAR compression program
    'unzip'                 # Zip compression program
    'wget'                  # Remote content retrieval
    'alacritty'             # Terminal emulator
    'vim'                   # Terminal editor
    'zenity'                # Display graphical dialog boxes via shell scripts
    'zip'                   # Zip compression program
    'zsh'                   # ZSH shell
    'zsh-completions'       # Tab completions for ZSH

    # --- Disk Utilities

    'autofs'                # Auto-mounter
    'btrfs-progs'           # BTRFS Support
    'dosfstools'            # DOS Support
    'exfat-utils'           # Mount extfat drives
    'gparted'               # Disk utility
    'gvfs-mtp'              # Read MTP Connected Systems
    'gvfs-smb'              # More File System Stuff
    'nautilus-share'        # File Sharing in Nautilus
    'ntfs-3g'               # Open source implementation of NTFS file system
    'parted'                # Disk utility
    'samba'                 # Samba File Sharing
    'smartmontools'         # Disk Monitoring
    'smbclient'             # SMB Connection
    'xfsprogs'              # XFS Support

    # --- General Utilities

    'flameshop'             # Screenshots
    'freerdp'               # RDP Connections
    'libvncserver'          # VNC Connections
    'nautilus'              # Filesystem browser
    'remmina'               # Remote Connections
    'variety'               # Wallpaper changes

    # --- Development

    'git'                   # Version control system

    # --- Media

    'obs-studio'            # Record your screen

    # --- Graphics and Design

    'ristretto'             # Multi image viewer

    # --- Productivity

    'hunspell'              # Spellcheck libraries
    'hunspell-en_US'        # English spellcheck library
    'hunspell-de'           # German spellcheck library
    'xpdf'                  # PDF viewer
)

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done

echo -e "\nDone!\n"
