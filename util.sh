#!/bin/bash
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

get_timer(){
    echo $(date +%s)
}

# $1: start timer
elapsed_time(){
    echo $(echo $1 $(get_timer) | awk '{ printf "%0.2f",($2-$1)/60 }')
}

show_elapsed_time(){
    info "Time %s: %s minutes" "$1" "$(elapsed_time $2)"
}

check_root(){
    (( EUID == 0 )) && return
    if type -P sudo >/dev/null; then
        exec sudo -- "$@"
    else
        exec su root -c "$(printf ' %q' "$@")"
    fi
}

check_requirements(){
    local package="archiso"
    #checking if application is already installed or else install with aur helpers
    if ! pacman -Qi $package &> /dev/null; then
        # checking which helper is installed
        if pacman -Qi yay &> /dev/null; then
            echo "################################################################"
            echo "######### Installing with yay"
            echo "################################################################"
            yay -S --noconfirm $package
        elif pacman -Qi trizen &> /dev/null; then
            echo "################################################################"
            echo "######### Installing with trizen"
            echo "################################################################"
            trizen -S --noconfirm --needed --noedit $package
        fi

        # Just checking if installation was successful
        if pacman -Qi $package &> /dev/null; then
            echo "################################################################"
            echo "#########  "$package" has been installed"
            echo "################################################################"
        else
            echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            echo "!!!!!!!!!  "$package" has NOT been installed"
            echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            exit 1
        fi
    fi
}

prepare_dir(){
    if [[ ! -d $1 ]]; then
        mkdir -p $1
    fi
}

create_chksums() {
    msg2 "creating checksums for [$1]"
    sha1sum $1 > $1.sha1
    sha256sum $1 > $1.sha256
}
