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

umount_img() {
    if [[ -n ${IMG_ACTIVE_MOUNTS[@]} ]]; then
        info "umount: [%s]" "${IMG_ACTIVE_MOUNTS[@]}"
        sudo umount "${IMG_ACTIVE_MOUNTS[@]}"
        unset IMG_ACTIVE_MOUNTS
        rm -r "$1"
    fi
}

check_umount() {
    if mountpoint -q "$1"; then
        sudo umount "$1"
    fi
}

umount_fs(){
    if [[ -n ${FS_ACTIVE_MOUNTS[@]} ]]; then
        info "overlayfs umount: [%s]" "${FS_ACTIVE_MOUNTS[@]}"
        #umount "${FS_ACTIVE_MOUNTS[@]}"
        for i in "${FS_ACTIVE_MOUNTS[@]}"
        do
            info "umount overlayfs: [%s]" "$i"
            check_umount $i
        done
        unset FS_ACTIVE_MOUNTS
        rm -rf "${mnt_dir}/work"
    fi
    mount_folders=$(grep "${work_dir}" /proc/mounts | awk '{print$2}' | sort -r)
    for i in $mount_folders
    do
        info "umount folder: [%s]" "$i"
        check_umount $i
    done
}
