#!/bin/bash

FollowFile() {
    local tailfile="$1"
    local term_title="$2"

    alacritty -t "$term_title" -e tail -f "$tailfile" &
}

catch_chrooted_pacman_log() {
    local pacmanlog=""
    local lockfile="$HOME/.$1.lck"

    # wait until pacman.log is available in the chrooted system, then follow the log in background
    while true ; do
        sleep 2
        pacmanlog="$(/usr/bin/ls -1 /tmp/calamares-root-*/var/log/pacman.log 2>/dev/null | /usr/bin/tail -n 1)"
        if [ -n "$pacmanlog" ] ; then
            # pacman.log found
            [ -r "$lockfile" ] && return
            /usr/bin/touch "$lockfile"
            FollowFile "$pacmanlog" "Pacman log" 400 50
            break
        fi
    done
}

Main() {
    # We are using this, because archlinux is signing the keyring often with a newly created keyring
    # This results into a failed installation for the user.
    # Installing archlinux-keyring fails due not being correctly signed
    # Mitigate this by installing the latest archlinux-keyring on the ISO, before starting the installation
    # The issue could also happen, when the installation does rank the mirrors and then a "faulty" mirror gets used
    sudo pacman -Sy --noconfirm archlinux-keyring
    # Also populate the keys, before starting the Installer, to avoid above issue
    sudo pacman-key --init
    sudo pacman-key --populate archlinux cachyos

    local progname
    progname="$(basename "$0")"
    local log=/home/liveuser/cachy-install.log
    local mode=""

    case "$progname" in
        calamares-online.sh) mode=online ;;
        calamares-offline.sh) mode=offline ;;
    esac
    mode=online  # keep this line for now!

    local _efi_check_dir="/sys/firmware/efi"
    local _exitcode=2 # by default use grub

    local SYSTEM=""
    local BOOTLOADER=""
    if [ -d "${_efi_check_dir}" ]; then
        SYSTEM="UEFI SYSTEM"

        # Restrict bootloader selection to only UEFI systems
        _exitcode=$(yad --width 300 --title "Bootloader" \
    --image=gnome-shutdown \
    --button="Grub:2" \
    --button="Systemd-boot(Default):3" \
    --button="Refind:4" \
    --button="AI SDK / Refind:5" \
    --text "Choose Bootloader/Edition:" ; echo $?)
    else
        SYSTEM="BIOS/MBR SYSTEM"
    fi


    if [[ "${_exitcode}" -eq 2 ]]; then
        BOOTLOADER="GRUB"
        echo "USING GRUB!"
        yes | sudo pacman -R cachyos-calamares-qt6-systemd
        yes | sudo pacman -R cachyos-calamares-qt6-grub
        yes | sudo pacman -R cachyos-calamares-qt6-refind
        yes | sudo pacman -Sy cachyos-calamares-qt6-grub
    elif [[ "${_exitcode}" -eq 3 ]]; then
        BOOTLOADER="SYSTEMD-BOOT"
        echo "USING SYSTEMD-BOOT!"
        yes | sudo pacman -R cachyos-calamares-qt6-grub
        yes | sudo pacman -R cachyos-calamares-qt6-refind
        yes | sudo pacman -Sy cachyos-calamares-qt6-systemd
    elif [[ "${_exitcode}" -eq 4 ]]; then
        BOOTLOADER="REFIND"
        echo "USING REFIND!"
        yes | sudo pacman -R cachyos-calamares-qt6-grub
        yes | sudo pacman -R cachyos-calamares-qt6-systemd
        yes | sudo pacman -Sy cachyos-calamares-qt6-refind
    elif [[ "${_exitcode}" -eq 5 ]]; then
        BOOTLOADER="AI-SDK/Refind"
        echo "USING AI SDK and Refind!"
        yes | sudo pacman -R cachyos-calamares-qt6-grub
        yes | sudo pacman -R cachyos-calamares-qt6-systemd
        yes | sudo pacman -R cachyos-calamares-qt6-refind
        yes | sudo pacman -Sy cachyos-calamares-qt6-ai
    else
        exit
    fi

    cat <<EOF > $log
########## $log by $progname
########## Started (UTC): $(date -u "+%x %X")
########## Install mode: $mode
########## System: $SYSTEM
########## Bootloader: $BOOTLOADER
EOF
    FollowFile "$log" "Install log" 20 20

    sudo cp /usr/share/calamares/settings_${mode}.conf /etc/calamares/settings.conf
    sudo -E  dbus-launch calamares -D6 >> $log &

    # comment out the following line if pacman.log is not needed:
    [ "$mode" = "online" ] && catch_chrooted_pacman_log "$progname"
}

Main "$@"
