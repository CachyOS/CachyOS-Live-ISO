#!/bin/bash
# build-calamares-modules.sh: builds Calamares' packagechooserq module (the
# QML page the Steamify page runs in) for the ISO. CachyOS's
# cachyos-calamares-next leaves it out of its own build, so it's built here,
# out of tree, from CachyOS's Calamares source against the installed
# cachyos-calamares-next, and installed into airootfs. Run as root in the
# build container, before buildiso.sh: the package comes from the same repos
# at the same time as the ISO's, so the module matches the ISO's Calamares.
# Records the version it was built for next to it (calamares-online.sh
# compares that with the Calamares it ends up with).
set -euo pipefail
cd "$(dirname "$0")"
dest=archiso/airootfs/usr/lib/calamares/modules/packagechooserq
src_url=https://github.com/CachyOS/cachyos-calamares/archive/refs/heads/cachyos.tar.gz

pacman -S --needed --noconfirm cachyos-calamares-next cmake extra-cmake-modules \
    qt6-declarative qt6-tools qt6-svg kcoreaddons yaml-cpp base-devel patch >/dev/null
work="$(mktemp -d)"
mkdir -p "$work/src" "$work/cmake"
# The module and the packagechooser sources it shares (Config, PackageModel),
# plus the CMake helper its CMakeLists includes, which Calamares doesn't install.
curl -fsSL "$src_url" -o "$work/calamares.tar.gz"
tar -xzf "$work/calamares.tar.gz" --strip-components=3 -C "$work/src" \
    cachyos-calamares-cachyos/src/modules/packagechooserq cachyos-calamares-cachyos/src/modules/packagechooser
tar -xzf "$work/calamares.tar.gz" --strip-components=2 -C "$work/cmake" \
    cachyos-calamares-cachyos/CMakeModules/AppStreamHelper.cmake
# The Steamify page's Summary line shows labels instead of ids.
patch -s -d "$work/src" -p1 < patches/packagechooserq-steamify-summary.patch
# KF6CoreAddons before Calamares: Calamares' CMake config needs its target.
cat > "$work/src/CMakeLists.txt" << EOF
cmake_minimum_required(VERSION 3.16)
project(steamify_packagechooserq LANGUAGES CXX)
set(WITH_QML ON)
set(WITH_QT6 ON)
set(qtname Qt6)
set(QT_VERSION_SUFFIX -qt6)
find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH \${ECM_MODULE_PATH} /usr/lib/cmake/Calamares $work/cmake \${CMAKE_MODULE_PATH})
find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets Qml Quick)
find_package(KF6CoreAddons REQUIRED)
find_package(Calamares REQUIRED)
add_subdirectory(packagechooserq)
EOF
cmake -S "$work/src" -B "$work/build" -DCMAKE_BUILD_TYPE=Release > "$work/cmake.log" 2>&1 ||
    { tail -30 "$work/cmake.log"; exit 1; }
make -s -C "$work/build" -j"$(nproc)"
install -Dm755 "$work/build/packagechooserq/libcalamares_viewmodule_packagechooserq.so" "$dest/libcalamares_viewmodule_packagechooserq.so"
install -Dm644 "$work/build/packagechooserq/module.desc" "$dest/module.desc"
pacman -Q cachyos-calamares-next | cut -d' ' -f2 > "$dest/built-for"
rm -rf "$work"
echo "packagechooserq built for cachyos-calamares-next $(cat "$dest/built-for")."
