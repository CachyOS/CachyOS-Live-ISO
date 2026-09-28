#!/bin/bash

main() {
    # Remove current keyring first, to complete initiate it
    sudo rm -rf /etc/pacman.d/gnupg
    # We are using this, because archlinux is signing the keyring often with a newly created keyring
    # This results into a failed installation for the user.
    # Installing archlinux-keyring fails due not being correctly signed
    # Mitigate this by installing the latest archlinux-keyring on the ISO, before starting the installation
    # The issue could also happen, when the installation does rank the mirrors and then a "faulty" mirror gets used
    sudo pacman -Sy --noconfirm archlinux-keyring cachyos-keyring
    # Also populate the keys, before starting the Installer, to avoid above issue
    sudo pacman-key --init
    sudo pacman-key --populate archlinux cachyos
    # Also use timedatectl to sync the time with the hardware clock
    # There has been a bunch of reports, that the keyring was created in the future
    # Syncing appears to fix it
    timedatectl set-ntp true

    local progname="$(basename "$0")"
    local log="/home/liveuser/cachy-install.log"
    local mode="online"  # TODO: keep this line for now

    local SYSTEM=""

    if [ -d /sys/firmware/efi ]; then
        SYSTEM="UEFI SYSTEM"
    else
        SYSTEM="BIOS/MBR SYSTEM"
    fi

    local ISO_VERSION="$(cat /etc/version-tag)"
    echo "USING ISO VERSION: ${ISO_VERSION}"

    sudo pacman -Sy --noconfirm cachyos-calamares-next
    # The installer's window title ("%1 Installer") and welcome text use the
    # branding's productName; the reinstall above restored CachyOS's.
    sudo sed -i 's/^\(    productName: *\)CachyOS$/\1CachyOS - Steamify/' \
        /usr/share/calamares/branding/cachyos/branding.desc

    # Get Hardware Informations
    inxi -F > "$log"

    cat <<EOF >> "$log"
########## $log by $progname
########## Started (UTC): $(date -u "+%x %X")
########## ISO version: $ISO_VERSION
########## System: $SYSTEM
EOF

    # Steamify: try the newest release before Calamares starts, so the page
    # and the install step both show/use it; keep the ISO's copy (from
    # steamify-prepare.sh) on any failure (no network, GitHub unreachable).
    # Separate statements: `local` expands all its values before assigning
    # any, so "$sdir" would still be empty in the same one.
    local sdir=/usr/local/share/steamify
    local sbin="$sdir/steamify.sh" sqml="$sdir/qml"
    local tmp; tmp="$(mktemp)"
    if curl -fsSL --max-time 20 https://github.com/theupriser/steamify-cachyos/releases/latest/download/steamify.sh -o "$tmp" &&
        grep -q -- '--defaults' "$tmp"; then
        sudo install -Dm755 "$tmp" "$sbin"
    fi
    rm -f "$tmp"
    tmp="$(mktemp -d)"
    if curl -fsSL --max-time 20 https://github.com/theupriser/steamify-cachyos/releases/latest/download/steamify-app.tar.gz |
        tar -xz -C "$tmp" --strip-components=2 ui/qml/Theme.qml ui/qml/Texts.qml 2>/dev/null; then
        sudo cp "$tmp/Theme.qml" "$tmp/Texts.qml" "$sqml/"
    fi
    rm -rf "$tmp"
    # The page's rows, from whichever steamify.sh ended up on the ISO
    # (regenerated even when the download failed: the fallback Items.qml
    # doesn't know this machine, e.g. no VRAM region or no Steam account yet).
    # JSON is valid JS array-literal syntax, so the output goes straight into
    # the singleton as-is (--list guarantees one line of only its own JSON
    # punctuation and text fields Steamify itself writes: nothing here can
    # break out of the property).
    tmp="$(mktemp)"
    if "$sbin" --defaults --list > "$tmp" 2>> "$log" && [[ -s "$tmp" ]]; then
        { printf 'pragma Singleton\nimport QtQuick\n\nQtObject {\n    readonly property var rows: '
          cat "$tmp"
          printf '\n}\n'
        } | sudo tee "$sqml/Items.qml" > /dev/null
        # Same rows, plain JSON: packagechooserq's prettyStatus() override
        # reads this to show the Summary step's choice as labels, not ids.
        sudo cp "$tmp" "$sqml/items.json"
    fi
    rm -f "$tmp"

    sudo cp "/usr/share/calamares/settings_${mode}.conf" /etc/calamares/settings.conf
    # Steamify: its page (packagechooserq@steamifypage, right after the
    # packages page) and its step (modules/shellprocess_steamify.conf) before
    # the installer cleans up after itself.
    # The page's module is built for one cachyos-calamares-next
    # (build-calamares-modules.sh); the pacman -Sy above may have brought
    # another, which it might not load in ("Initialization Failed" blocks the
    # installer). Then leave the page out: the step installs the page's
    # default, everything on.
    local built installed
    built="$(cat /usr/lib/calamares/modules/packagechooserq/built-for 2>/dev/null)"
    installed="$(pacman -Q cachyos-calamares-next | cut -d' ' -f2)"
    local page=(-e 's/^  - netinstall$/&\n  - packagechooserq@steamifypage/')
    if [[ -z "$built" || "$built" != "$installed" ]]; then
        echo "Steamify page left out: built for cachyos-calamares-next ${built:-?}, running $installed." >> "$log"
        page=()
    fi
    sudo sed -i -e 's/^- id:       cleanup_calamares$/- id:       steamifypage\n  module:   packagechooserq\n  config:   packagechooserq_steamifypage.conf\n\n- id:       steamify\n  module:   shellprocess\n  config:   shellprocess_steamify.conf\n\n&/' \
        "${page[@]}" \
        -e 's/^  - shellprocess@cleanup_calamares$/  - shellprocess@steamify\n&/' /etc/calamares/settings.conf
    exec pkexec-wrapper calamares -D6 >> $log
}

main "$@"
