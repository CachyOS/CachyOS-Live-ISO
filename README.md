These are the basic needed files and folders to build CachyOS system.

* Uses the same signature that normal repo and has no mirrors package to install.

`sudo pacman -Syy`

## Install necessary packages
`sudo pacman -S archiso mkinitcpio-archiso git squashfs-tools --needed`

Clone:\
`git clone https://gitlab.com/cachyos/cachyos-archiso.git`

`cd cachyos-archiso`

## Run fix permissions script
`sudo ./fix_permissions.sh`

## Build
`sudo ./build.sh -v`

## The iso appears at out folder
