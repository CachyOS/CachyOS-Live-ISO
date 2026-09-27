#!/bin/bash
# steamify-prepare.sh [steamify checkout]: puts the Steamify bundle on the
# ISO (archiso/airootfs/usr/local/share/steamify/steamify.sh), used by the
# installer's Steamify step. Built from a checkout when given, else the
# newest release. Run before buildiso.sh.
set -euo pipefail
dest="$(cd "$(dirname "$0")" && pwd)/archiso/airootfs/usr/local/share/steamify/steamify.sh"
mkdir -p "$(dirname "$dest")"
if [[ -n "${1:-}" ]]; then
    (cd "$1" && .github/tools/bundle.sh "$dest")
else
    curl -fsSL https://github.com/theupriser/steamify-cachyos/releases/latest/download/steamify.sh -o "$dest"
fi
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
