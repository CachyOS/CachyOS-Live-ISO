#!/bin/bash
# build-live-modules.sh: builds Steamify's power-off fix for the live ISO's
# kernels, so the Steam Machine stays off after shutting down from the live
# session (recent kernels keep a firmware wake bit set; see Steamify's
# patches/steamify-fremont-poweroff.c). Run as root in the build container,
# after steamify-prepare.sh and before buildiso.sh: the headers come from the
# same repos at the same time as the ISO's kernels, so the versions match.
# The module checks for Fremont itself and does nothing on other hardware.
set -euo pipefail
cd "$(dirname "$0")"
src=archiso/airootfs/usr/local/share/steamify/steamify-fremont-poweroff.c
[[ -f "$src" ]] || { echo "No $src: run steamify-prepare.sh first." >&2; exit 1; }

pacman -S --needed --noconfirm base-devel clang llvm lld linux-cachyos-headers linux-cachyos-lts-headers >/dev/null
for build in /usr/lib/modules/*/build; do
    kver="$(basename "$(dirname "$build")")"
    # A fresh folder per kernel: `make clean modules` in one call makes
    # kbuild re-run itself endlessly for an external module.
    work="$(mktemp -d)"
    cp "$src" "$work/"
    echo 'obj-m += steamify-fremont-poweroff.o' > "$work/Makefile"
    # CachyOS's kernels differ in compiler (linux-cachyos is clang-built):
    # build with the one the kernel was built with.
    llvm=()
    grep -q '^CONFIG_CC_IS_CLANG=y' "$build/.config" && llvm=(LLVM=1)
    make -s -C "$build" M="$work" "${llvm[@]}" modules
    install -Dm644 "$work/steamify-fremont-poweroff.ko" \
        "archiso/airootfs/usr/lib/modules/$kver/extra/steamify-fremont-poweroff.ko"
    rm -rf "$work"
    echo "Power-off fix built for $kver."
done
install -Dm644 /dev/stdin archiso/airootfs/etc/modules-load.d/steamify-fremont-poweroff.conf <<< 'steamify-fremont-poweroff'
