#!/bin/bash
# steamify-customize.sh <live root>: changes to the live system after its
# packages are installed (mkarchiso runs it, see modify_mkarchiso in
# util-iso.sh); files in airootfs are copied before the packages, which
# overwrite them.
set -euo pipefail
root="$1"
# Nothing yet: the live session keeps CachyOS's own name (only the installer
# says "CachyOS with Steamify", see calamares-online.sh).
exit 0
