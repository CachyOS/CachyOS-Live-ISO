These are the basic needed files and folders to build CachyOS system.

### buildiso

buildiso is used to build CachyOS ISO.

#### Arguments

~~~
$ ./buildiso.sh -h
Usage: buildiso [options]
    -c                 Disable clean work dir
    -h                 This help
    -p <profile>       Buildset or profile [default: kde]
    -v                 Verbose output to log file, show profile detail (-q)
~~~

* Uses the same signature that normal repo and has no mirrors package to install.

```bash
sudo pacman -Syy
```

## Install necessary packages
```bash
sudo pacman -S archiso mkinitcpio-archiso git squashfs-tools --needed
```

Clone:\
```bash
git clone https://github.com/cachyos/cachyos-live-iso.git cachyos-archiso
cd cachyos-archiso
```

## Build
```bash
sudo ./buildiso.sh -p kde -v
```

## The iso appears at out folder
