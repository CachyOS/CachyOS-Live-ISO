#!/bin/bash
# Generate settings.json for headless CLI installer testing
# Usage: TEST_BOOTLOADER=grub TEST_FILESYSTEM=btrfs ./generate-installer-config.sh

BOOTLOADER="${TEST_BOOTLOADER:-grub}"
FILESYSTEM="${TEST_FILESYSTEM:-btrfs}"
DEVICE="${TEST_DEVICE:-/dev/vda}"
HOSTNAME="${TEST_HOSTNAME:-cachyos}"
USERNAME="${TEST_USERNAME:-cachyos}"
PASSWORD="${TEST_PASSWORD:-ILoveCandy}"
KERNEL="${TEST_KERNEL:-linux-cachyos}"
DESKTOP="${TEST_DESKTOP:-kde}"

cat > settings.json << EOF
{
    "menus": 1,
    "headless_mode": true,
    "server_mode": false,
    "device": "${DEVICE}",
    "fs_name": "${FILESYSTEM}",
    "partitions": [
        {
            "name": "${DEVICE}1",
            "mountpoint": "/boot",
            "size": "512M",
            "type": "boot",
            "fs_name": "vfat"
        },
        {
            "name": "${DEVICE}2",
            "mountpoint": "/",
            "size": "100%",
            "type": "root"
        }
    ],
    "hostname": "${HOSTNAME}",
    "locale": "en_US",
    "xkbmap": "us",
    "timezone": "America/New_York",
    "user_name": "${USERNAME}",
    "user_pass": "${PASSWORD}",
    "user_shell": "/bin/bash",
    "root_pass": "${PASSWORD}",
    "kernel": "${KERNEL}",
    "desktop": "${DESKTOP}",
    "bootloader": "${BOOTLOADER}"
}
EOF

echo "Generated settings.json: bootloader=${BOOTLOADER} filesystem=${FILESYSTEM} device=${DEVICE}"
