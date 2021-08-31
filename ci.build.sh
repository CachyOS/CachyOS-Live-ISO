#!/bin/bash

pacman --noconfirm -Syu --needed base-devel archiso mkinitcpio-archiso git squashfs-tools

sudo ./fix_permissions.sh
sudo ./mkarchiso .
