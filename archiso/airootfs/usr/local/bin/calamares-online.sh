#!/bin/bash

main() {
    local progname="$(basename "$0")"
    local log="/home/liveuser/cachy-install.log"
    local mode="online"  # TODO: keep this line for now

    local _efi_check_dir="/sys/firmware/efi"
    local _exitcode=""

    local SYSTEM=""
    local BOOTLOADER=""
    if [ -d "${_efi_check_dir}" ]; then
        SYSTEM="UEFI SYSTEM"
        _exitcode=$(choose_bootloader_uefi)
    else
        SYSTEM="BIOS/MBR SYSTEM"
        _exitcode=$(choose_bootloader_bios)
    fi

    if [[ -z "$_exitcode" ]]; then
      echo "User didn't choose."
      exit 10
    fi

    local ISO_VERSION="$(cat /etc/version-tag)"
    echo "USING ISO VERSION: ${ISO_VERSION}"

    setup_pacman_keyring

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

setup_pacman_keyring() {
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

choose_bootloader_uefi() {
  kdialog --title Bootloader \
    --icon system-shutdown \
    --radiolist "Choose Bootloader/Edition:" \
    6 Limine on \
    2 GRUB off \
    4 rEFInd off \
    3 systemd-boot off \
    5 "AI SDK / rEFInd" off
}

choose_bootloader_bios() {
  kdialog --title Bootloader \
    --icon system-shutdown \
    --radiolist "Choose Bootloader/Edition:" \
    6 Limine on \
    2 GRUB off
}

if [[ "$0" = "$BASH_SOURCE" ]]; then
  main "$@"
fi
