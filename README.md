# Steamify CachyOS ISO for the Steam Machine

A CachyOS desktop ISO for the Valve Steam Machine with
[Steamify](https://github.com/theupriser/steamify-cachyos) built in:
- The live session has the Steam Machine drivers (power-off fix).
- The installer ("CachyOS with Steamify Installer") has a Steamify page where
  you pick the options and whether the PC starts in gaming mode or on the
  desktop. Steamify is applied during the install.

> **Choose KDE Plasma in the installer.** Steamify only works with KDE Plasma
> (the default). With another desktop (GNOME, Hyprland, Cosmic, ...) Steamify
> doesn't work yet.

## Building the ISO yourself

You need about 20 GB of free space, and a Linux PC with
[podman](https://podman.io) (or Docker: replace `podman` with `docker`). The
build runs in CachyOS's own container, so the PC doesn't have to run CachyOS.

```bash
git clone -b feat/steamify https://github.com/theupriser/steammachine-cachyos-live-iso
cd steammachine-cachyos-live-iso

# Put Steamify on the ISO: the newest release. To use your own checkout,
# pass its path: ./steamify-prepare.sh ~/steamify-cachyos
./steamify-prepare.sh

mkdir -p ~/iso-cache    # downloaded packages, kept for the next build
sudo podman run --rm -t --privileged --network=host \
  --pids-limit=-1 --ulimit nofile=65536:65536 \
  -v ~/iso-cache:/var/cache/pacman/pkg -v "$PWD":/iso -w /iso \
  docker.io/cachyos/cachyos:latest bash -c '
    pacman-key --init && pacman-key --populate &&
    pacman -Syu --noconfirm --needed archiso mkinitcpio-archiso git squashfs-tools grub sudo &&
    ./build-live-modules.sh && ./build-calamares-modules.sh &&
    ./buildiso.sh -p desktop -w'
```

The ISO is written to `out/desktop/steamify-cachyos-<date>.iso`. Write it to
a USB stick (for example with `dd` or Fedora Media Writer) and boot the Steam
Machine from it.

**Why these steps:**
- `build-live-modules.sh` builds the power-off fix for the ISO's kernels.
  Without it, the Steam Machine starts up again right after shutting down.
- `build-calamares-modules.sh` builds the installer module that shows the
  Steamify page. CachyOS's installer package leaves it out.
- `--pids-limit=-1` and `--ulimit nofile=...` are needed because pacman runs
  out of processes or open files in the container otherwise (GPGME errors).
- `--network=host` gives the container DNS.
- `-w` removes the build folder afterwards. Before building again, run
  `sudo rm -rf build out`.

To build on CachyOS directly, without a container, install the same packages
with pacman and run the three scripts with `sudo`.

---

The notes below are from CachyOS's original repository.

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
