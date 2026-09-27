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
echo "Steamify $(grep -m1 '^VERSION=' "$dest" | cut -d= -f2) on the ISO."
