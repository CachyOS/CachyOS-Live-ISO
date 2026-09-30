#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="steamify-cachyos"
# The label follows the release tag, which GitHub names (iso-1-github-tag.yml): the Steamify version on the ISO
# (steamify-prepare.sh put it there) plus the tag's date and time, e.g. STEAMIFY_2_9_3_20260929_2030 (ISO 9660:
# at most 32 characters, A-Z 0-9 _). STEAMIFY_BUILD_STAMP (YYYYMMDD_HHMM, UTC) comes from the tag; the build
# reads no clock of its own. Built by hand, without a tag: LOCAL.
_steamify="$(sed -n 's/^VERSION=//p' "${BASH_SOURCE[0]%/*}/airootfs/usr/local/share/steamify/steamify.sh" 2>/dev/null | head -n 1)"
_stamp="${STEAMIFY_BUILD_STAMP:-LOCAL}"
iso_label="STEAMIFY_${_steamify:+${_steamify//./_}_}${_stamp}"
iso_label="${iso_label:0:32}"
iso_publisher="CachyOS <https://cachyos.org>"
iso_application="Steamify CachyOS Live (based on CachyOS)"
# The file name (<iso_name>-<iso_version>-x86_64.iso) is the release tag without its v (STEAMIFY_ISO_VERSION
# from the tag: steamify-cachyos-2.9.3-dev.2026.09.29-2030-x86_64.iso). Built by hand, without a tag: local.
iso_version="${STEAMIFY_ISO_VERSION:-local}"
install_dir="arch"
buildmodes=('iso')
## GRUB
bootmodes=('bios.syslinux' 'uefi.grub')
## systemd-boot
#bootmodes=('bios.syslinux' 'uefi.systemd-boot')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/etc/polkit-1/rules.d"]="0:0:750"
  ["/etc/sudoers.d"]="0:0:750"
  ["/etc/sudoers.d/g_wheel"]="0:0:440"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/.gnupg"]="0:0:700"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/dmcheck"]="0:0:755"
  ["/usr/local/bin/steamify-install"]="0:0:755"
  ["/usr/local/bin/steamify-live-theme"]="0:0:755"
  ["/usr/local/bin/calamares-online.sh"]="0:0:755"
  ["/usr/local/bin/remove-nvidia"]="0:0:755"
  ["/usr/local/bin/removeun"]="0:0:755"
  ["/usr/local/bin/removeun-online"]="0:0:755"
  ["/usr/local/bin/prepare-live-desktop.sh"]="0:0:755"
  ["/usr/local/bin/nvidia-module-loader"]="0:0:755"
  ["/usr/local/bin/pkexec-wrapper"]="0:0:755"
  # steamify-prepare.sh writes this via curl -o, which doesn't carry the
  # executable bit; calamares-online.sh runs it directly ("$sbin" --defaults
  # --list) to regenerate Items.qml/items.json at boot, so without this it
  # silently fails (stderr redirected) and the Steamify page/Summary step
  # fall back to build-time data.
  ["/usr/local/share/steamify/steamify.sh"]="0:0:755"
)
