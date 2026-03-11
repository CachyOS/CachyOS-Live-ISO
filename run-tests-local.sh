#!/bin/bash
# Run CLI installer tests locally using quickemu + quicktest
#
# Prerequisites:
#   - quickemu installed (pacman -S quickemu)
#   - qemu-desktop installed
#   - tesseract-data-eng, ffmpeg, imagemagick installed
#   - A CachyOS ISO file in ./machines/cachyos-dailylive/ (or specify ISO_PATH)
#
# Usage:
#   ./run-tests-local.sh                                    # Show usage
#   ./run-tests-local.sh grub btrfs                         # Run single combo
#   ./run-tests-local.sh --list                              # List all combos
#   ./run-tests-local.sh --all                               # Run all combos
#   ISO_PATH=/path/to/cachyos.iso ./run-tests-local.sh      # Use specific ISO

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
QUICKTEST_DIR="${SCRIPT_DIR}/quicktest"
QUICKTEST_REPO="https://github.com/quickemu-project/quicktest"
MACHINES_DIR="${SCRIPT_DIR}/machines"
RESULTS_DIR="${SCRIPT_DIR}/results"
TESTCASES_DIR="${SCRIPT_DIR}/testcases"

BOOTLOADERS=(grub systemd-boot refind limine)
FILESYSTEMS=(btrfs xfs ext4 f2fs zfs)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

usage() {
    echo "Usage: $0 [bootloader] [filesystem]"
    echo "       $0 --list"
    echo "       $0 --all"
    echo ""
    echo "Examples:"
    echo "  $0 grub btrfs          # Test grub + btrfs"
    echo "  $0 systemd-boot ext4   # Test systemd-boot + ext4"
    echo "  $0 --all               # Run all 20 combinations"
    echo "  $0 --list              # List all combinations"
    echo ""
    echo "Environment variables:"
    echo "  ISO_PATH    Path to CachyOS ISO (default: auto-detect in machines/)"
    echo "  DISPLAY_VM  Set to 'sdl' or 'spice' to show VM window (default: none)"
}

check_deps() {
    local missing=()
    for cmd in quickemu qemu-system-x86_64 tesseract ffmpeg convert; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${RED}Missing dependencies: ${missing[*]}${NC}"
        echo "Install with: sudo pacman -S quickemu qemu-desktop tesseract-data-eng ffmpeg imagemagick"
        exit 1
    fi
}

setup_quicktest() {
    if [ ! -d "$QUICKTEST_DIR" ]; then
        echo -e "${YELLOW}Cloning quicktest...${NC}"
        git clone "$QUICKTEST_REPO" "$QUICKTEST_DIR"
    fi
}

setup_iso() {
    if [ -n "${ISO_PATH:-}" ]; then
        mkdir -p "$MACHINES_DIR/cachyos-dailylive"
        ln -sf "$(realpath "$ISO_PATH")" "$MACHINES_DIR/cachyos-dailylive/"
    fi

    local iso_count
    iso_count=$(find "$MACHINES_DIR" -name "*.iso" 2>/dev/null | wc -l)
    if [ "$iso_count" -eq 0 ]; then
        echo -e "${RED}No ISO found in $MACHINES_DIR/cachyos-dailylive/${NC}"
        echo "Either place an ISO there or set ISO_PATH=/path/to/cachyos.iso"
        exit 1
    fi
}

run_single_test() {
    local bootloader="$1"
    local filesystem="$2"
    local test_label="${bootloader}/${filesystem}"

    echo -e "${YELLOW}▶ Testing: ${test_label}${NC}"

    # Clean previous disk image for fresh test
    rm -f "$MACHINES_DIR/cachyos-dailylive/disk.qcow2"

    TEST_BOOTLOADER="$bootloader" \
    TEST_FILESYSTEM="$filesystem" \
    QT_NOTIFY="false" \
    QT_OPEN_RESULTS="false" \
    QT_QUICKGET_SKIP="true" \
    QT_TESTCASES_DIR="$TESTCASES_DIR" \
    QUICKEMU_DISPLAY="${DISPLAY_VM:-none}" \
    QUICKEMU_VM_DIR="$MACHINES_DIR" \
        "$QUICKTEST_DIR/quicktest" test_install_cli cachyos dailylive

    local exit_code=$?

    # Move results to per-combo directory
    if [ -d "$RESULTS_DIR" ]; then
        local combo_dir="${RESULTS_DIR}/${bootloader}-${filesystem}"
        mkdir -p "$combo_dir"
        mv "$RESULTS_DIR"/*.ppm "$combo_dir/" 2>/dev/null || true
        mv "$RESULTS_DIR"/*.txt "$combo_dir/" 2>/dev/null || true
    fi

    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✅ PASSED: ${test_label}${NC}"
    else
        echo -e "${RED}❌ FAILED: ${test_label}${NC}"
    fi
    return $exit_code
}

run_all_tests() {
    local passed=0 failed=0 total=0
    local failed_combos=()

    for bootloader in "${BOOTLOADERS[@]}"; do
        for filesystem in "${FILESYSTEMS[@]}"; do
            total=$((total + 1))
            if run_single_test "$bootloader" "$filesystem"; then
                passed=$((passed + 1))
            else
                failed=$((failed + 1))
                failed_combos+=("${bootloader}/${filesystem}")
            fi
        done
    done

    echo ""
    echo "==============================="
    echo "Results: $passed/$total passed, $failed failed"
    if [ ${#failed_combos[@]} -gt 0 ]; then
        echo "Failed:"
        for combo in "${failed_combos[@]}"; do
            echo "  - $combo"
        done
    fi
    echo "Screenshots in: $RESULTS_DIR/"
    echo "==============================="

    [ $failed -eq 0 ]
}

list_combos() {
    echo "Available test combinations (${#BOOTLOADERS[@]} × ${#FILESYSTEMS[@]} = $(( ${#BOOTLOADERS[@]} * ${#FILESYSTEMS[@]} ))):"
    for bootloader in "${BOOTLOADERS[@]}"; do
        for filesystem in "${FILESYSTEMS[@]}"; do
            echo "  $bootloader  $filesystem"
        done
    done
}

# --- Main ---

check_deps
setup_quicktest
setup_iso

case "${1:-}" in
    --help|-h)
        usage; exit 0 ;;
    --list)
        list_combos; exit 0 ;;
    --all)
        run_all_tests ;;
    "")
        usage; exit 0 ;;
    *)
        bootloader="${1:?Bootloader required}"
        filesystem="${2:?Filesystem required}"
        run_single_test "$bootloader" "$filesystem"
        ;;
esac
