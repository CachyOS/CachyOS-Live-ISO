#!/bin/bash

_remove_pacman_package() {
  local _pkgname="$1"
  pacman -Rsnc "$_pkgname" --noconfirm || true
}

# remove pkgs installed for VMs
_clean_vm_packages() {

  #remove virtualbox
  if pacman -Qi virtualbox-guest-utils &> /dev/null; then
    systemctl disable vboxservice.service
    _remove_pacman_package virtualbox-guest-utils
  fi

  if pacman -Qi virtualbox-guest-utils-nox &> /dev/null; then
    systemctl disable vboxservice.service
    _remove_pacman_package virtualbox-guest-utils-nox
  fi

  #remove vmware
  if [ -f /etc/xdg/autostart/vmware-user.desktop ]; then
    rm /etc/xdg/autostart/vmware-user.desktop
  fi

  if pacman -Qi open-vm-tools &> /dev/null; then
    systemctl disable vmtoolsd.service
    _remove_pacman_package open-vm-tools
  fi

  if [ -f /etc/systemd/system/multi-user.target.wants/vmtoolsd.service ]; then
    rm /etc/systemd/system/multi-user.target.wants/vmtoolsd.service
  fi

  #remove qemu
  if pacman -Qi qemu-guest-agent &> /dev/null; then
    systemctl disable qemu-guest-agent.service
    _remove_pacman_package qemu-guest-agent
  fi
}

_check_not_running_vm="$(systemd-detect-virt | grep -q 'none'; echo $?)"
if [[ "${_check_not_running_vm}" -eq 0 ]]; then
  _clean_vm_packages
fi

# vim:set ft=bash sw=2 sts=2 et:
