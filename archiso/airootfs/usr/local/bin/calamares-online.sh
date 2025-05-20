#!/usr/bin/env bash

main() {
    # Remove current keyring first, to complete initiate it
    sudo rm -rf /etc/pacman.d/gnupg
    # We are using this, because archlinux is signing the keyring often with a newly created keyring
    # This results into a failed installation for the user.
    # Installing archlinux-keyring fails due not being correctly signed
    # Mitigate this by installing the latest archlinux-keyring on the ISO, before starting the installation
    # The issue could also happen, when the installation does rank the mirrors and then a "faulty" mirror gets used
    sudo pacman -Sy --noconfirm archlinux-keyring cachyos-keyring
    # Also populate the keys, before starting the Installer, to avoid above issue
    sudo pacman-key --init
    sudo pacman-key --populate archlinux cachyos
    # Also use timedatectl to sync the time with the hardware clock
    # There has been a bunch of reports, that the keyring was created in the future
    # Syncing appears to fix it
    timedatectl set-ntp true

    local progname="$(basename "$0")"
    local log="/home/liveuser/cachy-install.log"
    local mode="online"  # TODO: keep this line for now

    local _efi_check_dir="/sys/firmware/efi"
    local _exitcode=6 # by default use limine

    local system="BIOS/MBR SYSTEM"
    local bootloader=""

    if [ -d "${_efi_check_dir}" ]; then
        system="UEFI SYSTEM"
        _exitcode=$(yad --width 300 --title "Bootloader" \
    --image=gnome-shutdown \
    --button="Systemd-boot:3" \
    --button="Refind:4" \
    --button="AI SDK / Refind:5" \
    --button="Limine (Default):6" \
    --text "Choose Bootloader/Edition:" ; echo $?)
    fi

    local -A bootloaders=(
        ["3"]="systemd-boot"
        ["4"]="rEFInd"
        ["5"]="AI SDK / rEFInd"
        ["6"]="Limine"
    )

    local iso_version="$(cat /etc/version-tag)"
    echo "USING ISO VERSION: ${iso_version}"

    case "${_exitcode}" in
        3) yes | sudo pacman -Sy cachyos-calamares-qt6-next-systemd;;
        4) yes | sudo pacman -Sy cachyos-calamares-qt6-next-refind;;
        5) yes | sudo pacman -Sy cachyos-calamares-qt6-next-ai;;
        6) yes | sudo pacman -Sy cachyos-calamares-qt6-next-limine;;
        *) exit;;
    esac

    bootloader="${bootloaders[$_exitcode]}"
    echo "Using ${bootloader}!"

    # Get Hardware Informations
    inxi -F > "$log"

    cat <<EOF >> "$log"
########## $log by $progname
########## Started (UTC): $(date -u "+%x %X")
########## ISO version: $iso_version
########## System: $system
########## Bootloader: $bootloader
EOF

    sudo cp "/usr/share/calamares/settings_${mode}.conf" /etc/calamares/settings.conf
    sudo -E dbus-launch calamares -D6 >> "$log" &
}

main "$@"
