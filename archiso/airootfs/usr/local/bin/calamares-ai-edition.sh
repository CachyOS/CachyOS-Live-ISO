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
    local progname="$(basename "$0")"
    local log="/home/liveuser/cachy-install.log"
    local _efi_check_dir="/sys/firmware/efi"

    if [ ! -d "${_efi_check_dir}" ]; then
        notify-send --app-name='CachyOS Welcome' 'MBR/BIOS system is not supported for AI Edition'
        exit
    fi

    yes | sudo pacman -R cachyos-calamares-qt6-next-grub
    yes | sudo pacman -R cachyos-calamares-qt6-next-systemd
    yes | sudo pacman -R cachyos-calamares-qt6-next-refind
    yes | sudo pacman -Sy cachyos-calamares-qt6-next-ai

    cat <<EOF > $log
########## $log by $progname
########## Started (UTC): $(date -u "+%x %X")
########## Edition: AI Edition
EOF
    FollowFile "$log" "Install log" 20 20

    sudo cp /usr/share/calamares/settings_${mode}.conf /etc/calamares/settings.conf
    sudo -E  dbus-launch calamares -D6 >> $log &

    # comment out the following line if pacman.log is not needed:
    catch_chrooted_pacman_log "$progname"
}

Main "$@"
