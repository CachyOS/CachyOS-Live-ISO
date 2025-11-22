*This is a fork of the official CachyOS-Live-ISO repo to build a Live OS ISO that supports legacy Wifi cards with broadcom chips.*

## Notes

Adds broadcom-wl-dkms and dependencies to support legacy broadcom wifi chips from Live OS.

ISO build success on kernel version 6.17.8-2-cachyos (64-bit) as of 2025-11-16. Note that this configuration increases ISO size by 200MB-500MB. (Last built size is 3GB.)

Packages added to archiso/packages_desktop.x86_64:

* broadcom-wl-dkms
* dkms
* gc
* gcc
* guile
* libisl
* libmpc
* linux-cachyos-lts-headers
* make
* patch

## Original README

These are the basic needed files and folders to build CachyOS system.

### buildiso

buildiso is used to build CachyOS ISO.

#### Arguments

~~~
$ ./buildiso.sh -h
Usage: buildiso [options]
    -c                 Disable clean work dir
    -r                 Disable building in RAM on systems with more than 23GB RAM
    -w                 Remove build directory (not the ISO) after ISO file is built
    -h                 This help
    -p <profile>       Buildset or profile [default: desktop]
    -v                 Verbose output to log file, show profile detail (-q)
~~~

* Uses the same signature that normal repo and has no mirrors package to install.

```bash
sudo pacman -Syy
```

### Install necessary packages:
```bash
sudo pacman -S archiso mkinitcpio-archiso git squashfs-tools grub --needed
```

### Clone:
```bash
git clone https://github.com/cachyos/cachyos-live-iso.git cachyos-archiso
cd cachyos-archiso
```

### Build
```bash
sudo ./buildiso.sh -p desktop -v -w
```

As the result iso appears at the `out` folder
