#!/bin/bash
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

error_function() {
    if [[ -p $logpipe ]]; then
        rm "$logpipe"
    fi
    # first exit all subshells, then print the error
    if (( ! BASH_SUBSHELL )); then
        error "A failure occurred in %s()." "$1"
        plain "Aborting..."
    fi
    umount_fs
    umount_img
    exit 2
}

run_safe() {
    local restoretrap func="$1"
    set -e
    set -E
    restoretrap=$(trap -p ERR)
    trap 'error_function $func' ERR

    if ${verbose}; then
        run_log "$func"
    else
        "$func"
    fi

    eval $restoretrap
    set +E
    set +e
}

check_umount() {
    if mountpoint -q "$1"; then
        umount -l "$1"
    fi
}

trap_exit() {
    local sig=$1; shift
    error "$@"
    umount_fs
    trap -- "$sig"
    kill "-$sig" "$$"
}

generate_gdm_config() {
    mkdir -p ${src_dir}/archiso/airootfs/etc/gdm
    cat << 'EOF' > ${src_dir}/archiso/airootfs/etc/gdm/custom.conf
# GDM configuration storage

[daemon]
AutomaticLoginEnable=True
# Uncomment the line below to force the login screen to use Xorg
WaylandEnable=false
DefaultSession=gnome-xorg.desktop

[security]

[xdmcp]

[chooser]

[debug]
# Uncomment the line below to turn on debugging
#Enable=true
EOF
}

fetch_cachyos_mirrorlist() {
    mkdir -p ${src_dir}/archiso/airootfs/etc/pacman.d
    local _mirrorlist_url="https://github.com/CachyOS/CachyOS-PKGBUILDS/raw/master/cachyos-mirrorlist/cachyos-mirrorlist"

    curl -sSL "${_mirrorlist_url}" > ${src_dir}/archiso/airootfs/etc/pacman.d/cachyos-mirrorlist
}

change_grub_version() {
    local _version="$1"
    sed -i "s/CACHYOS_VERSION=\".*\"/CACHYOS_VERSION=\"${_version}\"/" ${src_dir}/archiso/grub/grub.cfg
}

prepare_profile(){
    profile=$1

    info "Profile: [%s]" "${profile}"

    change_grub_version "$(date +%y%m%d)"

    # Fetch up-to-date version of CachyOS repo mirrorlist
    fetch_cachyos_mirrorlist

    rm -f ${src_dir}/archiso/airootfs/etc/systemd/system/display-manager.service
    if [ "$profile" == "kde" ]; then
        cp ${src_dir}/archiso/packages_kde.x86_64 ${src_dir}/archiso/packages.x86_64
        ln -sf /usr/lib/systemd/system/sddm.service ${src_dir}/archiso/airootfs/etc/systemd/system/display-manager.service
    elif [ "$profile" == "gnome" ]; then
        rm -f ${src_dir}/archiso/airootfs/etc/motd
        rm -rf ${src_dir}/archiso/airootfs/etc/gdm
        generate_gdm_config
        cp ${src_dir}/archiso/packages_gnome.x86_64 ${src_dir}/archiso/packages.x86_64
        ln -sf /usr/lib/systemd/system/gdm.service ${src_dir}/archiso/airootfs/etc/systemd/system/display-manager.service
    elif [ "$profile" == "xfce" ]; then
        cp ${src_dir}/archiso/packages_xfce.x86_64 ${src_dir}/archiso/packages.x86_64
        ln -sf /usr/lib/systemd/system/lightdm.service ${src_dir}/archiso/airootfs/etc/systemd/system/display-manager.service
    elif [ "$profile" == "openbox" ]; then
        rm -f ${src_dir}/archiso/airootfs/etc/skel/.Xresources
        cp ${src_dir}/archiso/packages_openbox.x86_64 ${src_dir}/archiso/packages.x86_64
        ln -sf /usr/lib/systemd/system/lightdm.service ${src_dir}/archiso/airootfs/etc/systemd/system/display-manager.service
    elif [ "$profile" == "wayfire" ]; then
        cp ${src_dir}/archiso/packages_wayfire.x86_64 ${src_dir}/archiso/packages.x86_64
        #ln -sf /usr/lib/systemd/system/lightdm.service ${src_dir}/archiso/airootfs/etc/systemd/system/display-manager.service
    else
        die "Unknown profile: [%s]" "${profile}"
    fi

    iso_file=$(gen_iso_fn).iso
}

run_build() {
    prepare_profile "$1"
    local _profile="$1"

    msg "Prepare [work: ${work_dir}, out: ${outFolder}]"

    if $verbose; then
        msg2 "Making mkarchiso verbose"
        sudo sed -i 's/quiet="y"/quiet="n"/g' /usr/bin/mkarchiso
    fi

    if $clean_first; then
        msg2 "Deleting the build folder if one exists - takes some time"
        umount_fs
        [ -d ${work_dir} ] && sudo rm -rf ${work_dir}
    fi

    msg2 "Copying the Archiso folder to build work"
    mkdir -p ${work_dir}
    cp -r archiso ${work_dir}/archiso

    msg "Start [Build ISO]"

    [ -d "$outFolder/$_profile" ] || mkdir -p "$outFolder/$_profile"
    cd ${work_dir}/archiso/
    sudo mkarchiso -v -w ${work_dir} -o "$outFolder/$_profile" ${work_dir}/archiso/
    sudo chown $USER $outFolder

    cp ${work_dir}/iso/arch/pkglist.x86_64.txt "$outFolder/$_profile/$(gen_iso_fn).pkgs.txt"
    mv "$outFolder/$_profile/cachyos-$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)-x86_64.iso" "$outFolder/$_profile/${iso_file}"

    msg "Done [Build ISO] ${iso_file}"
    msg "Finished building [%s]" "${_profile}"

    cd "$outFolder/$_profile"
    for f in $(find . -maxdepth 1 -name '*.iso' | cut -d'/' -f2); do
        if [[ ! -e $f.sha256 ]]; then
            create_chksums $f
        elif [[ $f -nt $f.sha256 ]]; then
            create_chksums $f
        else
            info "checksums for [$f] already created"
        fi
        if [[ ! -e $f.sig ]]; then
            sign_with_key $f
        elif [[ $f -nt $f.sig ]]; then
            rm $f.sig
            sign_with_key $f
        else
            info "signature file for [$f] already created"
        fi
    done
    show_elapsed_time "${FUNCNAME}" "${timer_start}"
}

gen_iso_fn(){
    local vars=() name
    vars+=("cachyos")
    [[ -n ${profile} ]] && vars+=("${profile}")

    vars+=("linux")
    vars+=("$(date +%y%m%d)")

    for n in ${vars[@]}; do
        name=${name:-}${name:+-}${n}
    done

    echo $name
}
