These are the basic needed files and folders to build CachyOS system.

### buildiso

buildiso is used to build CachyOS ISO.

#### Arguments

~~~
$ buildiso -h
Usage: buildiso [options]
    -c                 Disable clean work dir
    -h                 This help
    -p <profile>       Buildset or profile [default: kde]
    -v                 Verbose output to log file, show profile detail (-q)
~~~

* Uses the same signature that normal repo and has no mirrors package to install.

`sudo pacman -Syy`

## Install necessary packages
`sudo pacman -S archiso mkinitcpio-archiso git squashfs-tools --needed`

Clone:\
`git clone https://github.com/CachyOS/CachyOS-Live-ISO.git`

`cd CachyOS-Live-ISO`

## Build
`sudo ./buildiso -p kde -c -v`

## The iso appears at out folder
