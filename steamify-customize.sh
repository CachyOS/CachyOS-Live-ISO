#!/bin/bash
# steamify-customize.sh <live root>: changes to the live system after its
# packages are installed (mkarchiso runs it, see modify_mkarchiso in
# util-iso.sh); files in airootfs are copied before the packages, which
# overwrite them.
set -euo pipefail
root="$1"
# The name CachyOS Hello shows ("Steamify CachyOS, based on CachyOS rolling").
sed -i -e 's/^NAME=.*/NAME="Steamify CachyOS, based on CachyOS"/' \
    -e 's/^PRETTY_NAME=.*/PRETTY_NAME="Steamify CachyOS, based on CachyOS"/' "$root/etc/os-release"
