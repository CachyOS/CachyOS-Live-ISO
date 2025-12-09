#!/bin/bash

Main() {
    local progname="$(basename "$0")"
    local log="/home/liveuser/cachy-install.log"
    local mode="online"  # TODO: keep this line for now

    local _efi_check_dir="/sys/firmware/efi"
    local _exitcode=2 # by default use grub

    local SYSTEM=""
    local BOOTLOADER=""
    if [ -d "${_efi_check_dir}" ]; then
        SYSTEM="UEFI SYSTEM"
        _exitcode=$(ChooseBootLoaderUefi)
    else
        SYSTEM="BIOS/MBR SYSTEM"
        _exitcode=$(ChooseBootLoaderBios)
    fi

    local ISO_VERSION="$(cat /etc/version-tag)"
    echo "USING ISO VERSION: ${ISO_VERSION}"

    SetupPacmanKeyring

    if [[ "${_exitcode}" -eq 2 ]]; then
        BOOTLOADER="GRUB"
        echo "USING GRUB!"
        yes | sudo pacman -R cachyos-calamares-qt6-next-systemd
        yes | sudo pacman -R cachyos-calamares-qt6-next-grub
        yes | sudo pacman -R cachyos-calamares-qt6-next-refind
        yes | sudo pacman -R cachyos-calamares-qt6-next-limine
        yes | sudo pacman -Sy cachyos-calamares-qt6-next-grub
    elif [[ "${_exitcode}" -eq 3 ]]; then
        BOOTLOADER="SYSTEMD-BOOT"
        echo "USING SYSTEMD-BOOT!"
        yes | sudo pacman -R cachyos-calamares-qt6-next-grub
        yes | sudo pacman -R cachyos-calamares-qt6-next-refind
        yes | sudo pacman -R cachyos-calamares-qt6-next-limine
        yes | sudo pacman -Sy cachyos-calamares-qt6-next-systemd
    elif [[ "${_exitcode}" -eq 4 ]]; then
        BOOTLOADER="REFIND"
        echo "USING REFIND!"
        yes | sudo pacman -R cachyos-calamares-qt6-next-grub
        yes | sudo pacman -R cachyos-calamares-qt6-next-systemd
        yes | sudo pacman -R cachyos-calamares-qt6-next-limine
        yes | sudo pacman -Sy cachyos-calamares-qt6-next-refind
    elif [[ "${_exitcode}" -eq 5 ]]; then
        BOOTLOADER="AI-SDK/Refind"
        echo "USING AI SDK and Refind!"
        yes | sudo pacman -R cachyos-calamares-qt6-next-grub
        yes | sudo pacman -R cachyos-calamares-qt6-next-systemd
        yes | sudo pacman -R cachyos-calamares-qt6-next-refind
        yes | sudo pacman -R cachyos-calamares-qt6-next-limine
        yes | sudo pacman -Sy cachyos-calamares-qt6-next-ai
    elif [[ "${_exitcode}" -eq 6 ]]; then
        BOOTLOADER="Limine"
        echo "USING Limine"
        yes | sudo pacman -R cachyos-calamares-qt6-next-grub
        yes | sudo pacman -R cachyos-calamares-qt6-next-systemd
        yes | sudo pacman -R cachyos-calamares-qt6-next-refind
        yes | sudo pacman -Sy cachyos-calamares-qt6-next-limine
    else
        exit
    fi

    # Get Hardware Informations
    inxi -F > $log

    cat <<EOF >> $log
########## $log by $progname
########## Started (UTC): $(date -u "+%x %X")
########## ISO version: $ISO_VERSION
########## System: $SYSTEM
########## Bootloader: $BOOTLOADER
EOF

    sudo cp "/usr/share/calamares/settings_${mode}.conf" /etc/calamares/settings.conf
    sudo -E dbus-launch calamares -D6 >> $log &
}

SetupPacmanKeyring() {
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
}

ChooseBootLoaderUefi() {
  yad --width 300 --title "Bootloader" \
    --image=gnome-shutdown \
    --button="Limine:6" \
    --button="Grub:2" \
    --button="rEFInd:4" \
    --button="systemd-boot:3" \
    --button="AI SDK / rEFInd:5" \
    --text "Choose Bootloader/Edition:"
  echo $?
}

ChooseBootLoaderBios() {
  yad --width 300 --title "Bootloader" \
    --image=gnome-shutdown \
    --button="Limine:6" \
    --button="Grub:2" \
    --text "Choose Bootloader/Edition:"
  echo $?
}

if [[ "$0" = "$BASH_SOURCE" ]]; then
  Main "$@"
fi
