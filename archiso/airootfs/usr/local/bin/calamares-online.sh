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
    local progname
    progname="$(basename "$0")"
    local log=/home/liveuser/cachy-install.log
    local mode=""

    case "$progname" in
        calamares-online.sh) mode=online ;;
        calamares-offline.sh) mode=offline ;;
    esac
    mode=online  # keep this line for now!

    cat <<EOF > $log
########## $log by $progname
########## Started (UTC): $(date -u "+%x %X")
########## Install mode: $mode
EOF
    FollowFile "$log" "Install log" 20 20

    sudo cp /usr/share/calamares/settings_${mode}.conf /etc/calamares/settings.conf
    sudo -E calamares -style kvantum -d >> $log &

    # comment out the following line if pacman.log is not needed:
    [ "$mode" = "online" ] && catch_chrooted_pacman_log "$progname"
}

Main "$@"
