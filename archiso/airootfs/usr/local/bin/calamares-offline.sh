#!/bin/bash

Main() {
    local mode=offline
    local progname=""
    progname="$(basename "$0")"
    local log=/home/liveuser/cachy-install.log

    cat <<EOF > $log
########## $log by $progname
########## Started (UTC): $(date -u "+%x %X")
########## Install mode: $mode

EOF
    RunInTerminal "tail -f $log" &

    sudo cp /usr/share/calamares/settings_${mode}.conf /etc/calamares/settings.conf
    sudo -E dbus-launch calamares -D6 >> $log
}

Main "$@"
