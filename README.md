These are the basic needed files and folders to build CachyOS system.

* Uses the same signature that normal repo and has no mirrors package to install.

`sudo pacman -Syy`

## Install necessary packages
`sudo pacman -S archiso mkinitcpio-archiso git squashfs-tools --needed`

Clone:\
`git clone https://github.com/CachyOS/CachyOS-Live-ISO.git`

`cd CachyOS-Live-ISO`

## Build
`./30-build-the-iso-the-first-time.sh`

#### if you want rebuild
`./40-build-the-iso-local-again.sh`

## The iso appears at out folder
