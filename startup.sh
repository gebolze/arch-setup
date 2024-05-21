#!/usr/bin/env bash

# This script will ask the user about his perferences
# like disk, file system, timezone, keyboard layout,
# user name, password, etc.

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# set up a config file
CONFIG_FILE=$SCRIPT_DIR/setup.conf
if [ ! -f $CONFIG_FILE ]; then
    touch -f $CONFIG_FILE
fi

# set options in setup.conf
set_option () {
    sed -i -e "/^${1}.*/d" $CONFIG_FILE
    echo "${1}=${2}" >> $CONFIG_FILE
}

# This will be shown on every set as user is progressing
logo () {
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
}

userinfo () {
    read -p "Please enter your username: " username
    set_option USERNAME ${username,,}

    read -p "Please enter your password: " -s password
    set_option PASSWORD $password
    echo -ne "\n"

    read -p "Please enter root password: " -s password
    set_option ROOTPASSWORD $password
    echo -ne "\n"

    read -rep "Please enter your hostname: " nameofmachine
    set_option nameofmachine $nameofmachine
}

# selection for disk type
diskpart () {
    lsblk -n --output TYPE,KNAME | awk '$1=="disk"{print NR,"/dev/"$2}'
    cat << EOF
-------------------------------------------------------------------------
    THIS WILL FORMAT AND DELETE ALL DATA ON THE DISK
    Please make sure you know what you are doing because
    after formating your disk there is no way to get data back
-------------------------------------------------------------------------
EOF
    read -p "Please enter full path to disk: (example /dev/sda):" option
    set_option DISK $option

    while : ; do
        read -p "Is this a ssd? yes/no:" ssd_drive
        case $ssd_drive in
            y|Y|Yes|yes|YES)
                set_option mountoptions "noatime,compress=zstd,ssd"; break;;
            n|N|No|no|NO)
                set_option mountoptions "noatime,compress=zstd"; break;;
            *)
                echo "Wrong option. Try again";;
        esac
    done
}

filesystem () {
    cat << EOF
Please select your file system for both boot and root
1) btrfs
2) ext4
0) exit
EOF

    while : ; do
        read filesystem
        case $filesystem in
            1)
                set_option FS btrfs
                break
                ;;
            2)
                set_option FS ext4
                break
                ;;
            0)
                exit
                ;;
            *)
                echo "Wrong option. Try again"
                ;;
        esac
    done
}

timezone () {
    # Added this from arch wiki https://wiki.archlinux.org/title/System_time
    time_zone="$(curl --fail https://ipapi.co/timezone)"
    echo -ne "System detected your timezone to be '$time_zone' \n" 
    while : ; do
        read -p "Is this correct? yes/no:" answer
        case $answer in
            y|Y|yes|Yes|YES)
                set_option TIMEZONE $time_zone
                break
                ;;
            n|N|no|No|NO)
                read -p "Please enter your desired timezone e.g. Europe/Berlin:" new_timezone
                set_option TIMEZONE $new_timezone
                break
                ;;
            *)
                echo "Wrong option. Try again"
                ;;
        esac
    done
}

keymap () {
    cat << EOF
Please select keyboard layout from this list
  - by
  - ca
  - cf
  - cz
  - de
  - dk
  - es
  - et
  - fa
  - fi
  - fr
  - gr
  - hu
  - il
  - it
  - lt
  - lv
  - mk
  - nl
  - no
  - pl
  - ro
  - ru
  - sg
  - ua
  - uk
  - us

EOF
    read -p "Your keyboard layout: " keymap
    set_option KEYMAP $keymap
}

clear; logo; userinfo
clear; logo; diskpart
clear; logo; filesystem
clear; logo; timezone
clear; logo; keymap