#!/bin/bash
# steamify-prepare.sh [steamify checkout]: puts the Steamify bundle on the
# ISO (archiso/airootfs/usr/local/share/steamify/steamify.sh), used by the
# installer's Steamify step, and what its Steamify page shows (qml/). Built from a checkout when given, else the
# newest release. Run before buildiso.sh.
set -euo pipefail
dest="$(cd "$(dirname "$0")" && pwd)/archiso/airootfs/usr/local/share/steamify/steamify.sh"
mkdir -p "$(dirname "$dest")"
if [[ -n "${1:-}" ]]; then
    (cd "$1" && .github/tools/bundle.sh "$dest")
else
    curl -fsSL https://github.com/theupriser/steamify-cachyos/releases/latest/download/steamify.sh -o "$dest"
fi
# The power-off fix's source, for build-live-modules.sh (live session).
poweroff="$(dirname "$dest")/steamify-fremont-poweroff.c"
if [[ -n "${1:-}" ]]; then
    cp "$1/patches/steamify-fremont-poweroff.c" "$poweroff"
else
    curl -fsSL https://raw.githubusercontent.com/theupriser/steamify-cachyos/main/patches/steamify-fremont-poweroff.c -o "$poweroff"
fi
# The installer's Steamify page (/usr/local/share/steamify-installer/
# SteamifyPage.qml) shows the app's explanations (Theme.qml, Texts.qml, from the
# checkout, else the newest release's app) and its rows (Items.qml: this
# fallback until calamares-online.sh writes the real list).
qml="$(dirname "$dest")/qml"
rm -rf "$qml"; mkdir -p "$qml"
if [[ -n "${1:-}" ]]; then
    cp "$1"/ui/qml/{Theme,Texts}.qml "$qml/"
else
    curl -fsSL https://github.com/theupriser/steamify-cachyos/releases/latest/download/steamify-app.tar.gz |
        tar -xz -C "$qml" --strip-components=2 ui/qml/Theme.qml ui/qml/Texts.qml
fi
cp "$(cd "$(dirname "$0")" && pwd)/archiso/airootfs/usr/local/share/steamify-installer/Items.qml" "$qml/"
printf '%s\n' 'singleton Theme 1.0 Theme.qml' 'singleton Texts 1.0 Texts.qml' 'singleton Items 1.0 Items.qml' > "$qml/qmldir"
grep -q -- '--defaults' "$dest" || { echo "This Steamify has no --defaults (needs 2.6.0 or newer)." >&2; exit 1; }
chmod 755 "$dest"
# Temporary: cachyos-calamares-next 3.4.2-13 is linked against Boost 1.91
# while the repos ship 1.92, so the installer doesn't start. Boost's
# libraries carry their version in the name: 1.91's sit next to 1.92's.
# Drop this once CachyOS rebuilds the installer.
boost=boost-libs-1.91.0-2-x86_64.pkg.tar.zst
libs="$(cd "$(dirname "$0")" && pwd)/archiso/airootfs"
curl -fsSL "https://archive.archlinux.org/packages/b/boost-libs/$boost" -o "/tmp/$boost"
tar -xf "/tmp/$boost" -C "$libs" --wildcards 'usr/lib/libboost_*.so.1.91.0'
rm -f "/tmp/$boost"
echo "Steamify $(grep -m1 '^VERSION=' "$dest" | cut -d= -f2) on the ISO."
