# 24.05

**Features:**
- Filesystems: Introduce bcachefs as filesystem choice
- pacstrap: Add detection if bcachefs is used and install bcachefs-tools
- CachyOS-AI-SDK: Introduce new install option to have a OOB NVIDIA SDK Setup
- CachyOS-Deckify: Provide own variant for Handhelds (experimental)
- ISO: Drop Offline Installation
- Package Updates: Python 3.12, gcc 13.1.1, mesa 24.0.6, xwayland 24.1 branch, NVIDIA 550.78

**Bug-Fixes:**
- settings.conf: Move hardware detection before netinstall
- pacstrap: Use btrfs-assistant instead of btrfs-assistant-git
- plymouth: remove plymouth hook on zfs + encryption
- ISO: Add various config files for KDE, to avoid getting into Screenlocker at Installation Time
- services-systemd: Properly enable fstrim.timer
- umount: Disable emergency to avoid issues with the zfs installation
- shellprocess: Cleanup leftovers from the offline installation

# 24.04

**Features:**
- plymouth: Use plymouth and provide a themed boot animation
- ISO: Switch back to X11 due to issues when setting the keyboard layout in calamares
- Refind: New portioning layout
- netinstall: KDE: Install xwaylandvideobridge as default
- netinstall: Use lightdm instead of ly at various Desktop Environments, due to a bug in ly
- systemd-boot: Use @saved for systemd-boot to boot all time in the previous booted kernel
- cachyos-keyring: Refactor cachyos-keyring package and provide a cachyos-trusted
- ISO: Use ZSTD 19 Compression for mkinitcpio image for ISO
- Package Updates: linux-cachyos 6.8.2, pacman 6.1.0-5, mesa 24.0.4, Plasma 6.0.3, nvidia 550.67, cachyos-settings 39-2

**Bug-Fixes:**
- Autologin: Fix the autologin option when used together with sddm
- xz: Provide a patched xz package
- cachyos-settings: udev-rule don't set watermark_scale_factor to 125, since it increases the RAM usage massively
- calamares: pacman-keyring use more simply method to integrate the keyring into the installation

# 24.03.1

**Features:**
- netinstall: Remove extra kernels in the netinstall selection to avoid confusion by users. Other custom kernels can be installed via Kernel Manager
- Kernel Manager: NVIDIA Modules are automatically installed when detected, Rebased for QT6, Fixed custom names when using LTO Option
- Package Installer: Rebased on QT6, updated for pacman 6.1
- Package Updates: linux-cachyos 6.8.1, pacman 6.1, mesa 24.0.3, Plasma 6.0.2, llvm 17.0.6

**Bug-Fixes:**
- NVIDIA: patched nvidia module to take the owner ship of nvidia.drm.modeset earlier to avoid issues on nvidia graphics
- Refind: Don't install the lts kernel to avoid issues
- shellprocess: Remove the liveusers directory completly


# 24.03

**Features:**
- ISO: Plasma 6 is now shipped in the ISO and uses Wayland as default, GNOME ISO got dropped to avoid confusion about netinstall
- Calamares: Rebased for QT6
- refind: Add f2fs and zfs as option including luks2 encryption
- mirrors: We provide now 2 global CDNs. One hosted by Cloudflare R2 and one hosted by Digital Ocean
- mirrorlist: Fetch the online installer directly from cdn to provide a faster delivery
- initcpiocfg: Use the new microcode hook for early loading the ucode
- bootloader: Dont load the microcode with the bootloader anymore
- Package Updates: linux-cachyos 6.7.9, mesa 24.0.2, zfs-utils 2.2.3

**Bug-Fixes:**
- pacstrap: Do not install config packages to provide the user a more clean selection of the installation
- shellprocess_pacman: Also copy the ranked cachyos-v4-mirrorlists to the target


# 24.02

**Features:**
- refind: Change layout from /boot/efi to /boot to provide more options of filesystems and encryption
- Live-ISO: Cleanup and Sync the Live-ISO
- Launch Installer: Add recommendation for the online installation
- shell-configs: Add option to disable fastfetch when starting the terminal and add an "update" alias
- netinstall: Add phonon-qt5-vlc to kde
- Package Updates: linux-cachyos 6.7.5, mesa 23.3.5, gcc 13.2.1-12, glibc 2.39, mesa 24.0.1, nvidia 550.54.14

# 23.12

**Bug-fixes:**
- zfs: Add compatibility=grub to the pool options to ensure the compatibility
- grub/xfs: Add a patch to grub to have compatibility with the new xfs bigtime default
- netinstall: xdg-desktop-portal-hyprland instead of xdg-desktop-portal-hyprland-git

# 23.11

**Features:**
- nvidia: Use nvidia module instead of dkms
- Calamares synced with upstream
- Package updates: linux-cachyos 6.6.1, nvidia-utils 545.29.02, mesa 23.2.1, zfs-utils 2.2.0, mkinitcpio 37

**Bug-fixes:**
- nvidia-hook: Added nvidia-hook back to avoid issues at installation time with the new module
- netinstall: Packages got renamed due the recent changes at the KF5 packaging
- netinstall: xdg-desktop-portal-gnome got added to the GNOME Installation

# 23.09

**Features:**
- systemd-boot: Default to luks2
- netinstall: Provide a own category for CachyOS Packages
- Calamares synced with upstream
- Package updates: linux-cachyos 6.5.3, nvidia-utils 535.104.05, mesa 23.2.7

**Bug-fixes:**
- shellprocess_sdboot: Avoid using "sudo", when generating the boot entries at the installation process

# 23.08

**Features:**
- Calamares synced with upstream
- Package updates: linux-cachyos 6.4.10, nvidia-utils 535.98

**Bug-fixes:**
- Keyring got updated and works now correctly


# 23.07

**Features:**
- CachyOS-Settings includes now "bpftune", which automatically tweaks the network settings depending on the usage
- CachyOS-Qtile-Settings: Quality of Life changes, better icons, ...
- Package updates: linux-cachyos 6.4.2, cachy-browser 115.0.1, mesa 23.1.3,

**Bug-fixes:**
- rate-mirrors got fixed
- chwd (Hardware Detection) got multiple fixes
- fixed installation of nonfree drivers for hybrid setup in the installer
- fixed Calamares freezes, which happened in some rare configurations, mainly VM
- Slides: Slide 6 typo fix

# 23.06

**Bug-fixes:**
- Offline Installation: Fix calamares

# 23.05

**Features:**
- CachyOS Git Migration layout is now reflected in the installation
- chwd (mhwd) got multiple fixes
- Pacman: We added a feature, which makes it possible to provide a message to our users before updating
- Calamares got synced with upstream
- Package updates: linux-cachyos 6.3.4, cachy-browser 113.0.1, mesa 23.1.1, python 3.11

**Bug-fixes:**
- netinstall: minimal fixes due package changes
- Slides: Slide 6 got updated to reflect the lastest changes

# 23.04

**Features:**

- Introduce the Qtile desktop enviroment
- Reworked mhwd: Rust rewrite; Simplified profiles for GPUs and network cards; Removed bunch of ancient code
- Package updates: linux-cachyos 6.2.12, cachy-browser 112.0.1, mesa 23.0.3, zfs-utils 2.1.11

**Bug-fixes:**

- f2fs: Remove "atgc" mount options since it has issues with systemd

# 23.03.1

**Features:**

- Package updates: linux-cachyos 6.2.7, cachy-browser 111.0

**Bug-fixes:**

- Calamares got fixed with the lightdm displaymanager due faulty calamares upstream commits
- Offline installation keyring issue got fixed
- Refind: Use linux-cachyos-lts as defaullt. Current 6.2 seems not to work well together with refind


# 23.03

**New Features:**

- Added the refind bootloader
- Automatic Nvidia driver installation using MHWD
- Encryption support for ZFS installation
- Added Hyprland to netinstallation
- CachyOS-KDE-Settings now uses the KDE default theme, but the CachyOS Themes are still preinstalled and available for use
- Package updates: linux-cachyos 6.2.2, mesa 23.0.0, cachy-browser 110.0.1, plasma 5.27.2
- Fully reworked and improved the bootloader calamares module
- The ISO gets now signed with a GPG key
- MHWD got improved and updated
- Synced Calamares with upstream

**Bug-fixes:**

- The "replace partition" option now offers a filesystem selection
- Fixed a typo in slide 3
- nouveau got fixed and does now proper load the module
- MHWD: Use modesetting for INTEL/ATI and Nouveau
- Removed the zfs hook from mkinitcpio on the live iso, which caused issues when booting
- You can download the update from our mirrors on SourceForge.

# 23.02
**New Features:**

- The cachyos-community-v3 repo has been added
- Budgie, Mate, and LXDE desktop environments have been added to the Netinstallation
- Bluetooth.service is now enabled by default
- F2FS and grub are enabled and working again
- Package Updates: linux-cachyos 6.1.10, mesa 22.3.4, zfs-utils 2.1.9, glibc 2.37, cachy-browser 109.0.1

**Bug-fixes:**

- Rate-mirrors now fall back to unranked mirrors if it fails to rate them
- cachyos-rate-mirrors has a longer fetch-mirrors-timeout
- Github has been added to the hosts to avoid mirrorlist issues
- Boot entries for BIOS have been updated in syslinux


# 23.01

**Features:**

- Calamares Slides got reworked and updated
- UKUI Desktop Enviroment got added to the Netinstallation
- Cinnamon Desktop Enviroment got added to the Netinstallation
- Cmdline: zswap is now disabled as default because CachyOS provides zram as default
- Calamares updated to the latest commit
- LLVM 15 is now shipped as default
- Package Updates: linux-cachyos 6.1.7, mesa 22.3.3, Plasma 5.26.5, llvm 15.0.7, gcc 12.1.1, binutils 2.40, zfs-utils 2.1.8, nvidia 525.85.05
- CLI Installer got updated

**Bug-fixes:**

- remove-ucode shellprocess does also run now at the offline installation
- pamac got removed from the netinstall
- The ranked cachyos mirrors gets now correctly copied to the install target
- power-profile-daemon don't gets enabled anymore as default


# 22.12

**Features:**

- New GRUB background at the ISO bootloader
- memtest is now included for UEFI Systems
- CachyOS-sddm-theme got added to the KDE Installation
- Automatic version script added when creating the ISO
- Calamares updated to the latest commit
- The mirrors are now ranked with "cachyos-rate-mirros", which ranks our mirrors and the arch ones
- Packages Update: 6.1.1 Kernel, mesa 22.3.1, plasma 5.26.4,...
- The Kofuku Desktop Enviroment got removed
- extra ISO with llvm 15 included to provide support for newer AMD Cards


**Bug-fixes:**

- Calamares got fixed when using GNOME as ISO
- zfshostid does now work proper for the offline and online installation
- Add "kms" hook to the initcpiocfg module to follow archlinux defaults
- And more ISO fixes


# 22.11

**Features:**

- Calamares and its config are shipped in one package
- Complete Cleanup of the packages in the netinstall
- Add a module which automatically removes the not needed ucode
- required RAM decreased to 2.5GB
- Packages which are required for btrfs, are now only installed for btrfs
- Calamares updated to the latest commit
- The ISO Bootloader has now a background
- Common package upgrades (mesa, kernel, ...)
- Replace systemd-network with networkmanager


**Bug-fixes:**

- qemu-quest-agent.service got removed from the ISO
- copytoram got completly disabled, it breaks the offline installation
- mkinitcpio.conf got updated
- And more ISO fixes


# 22.10

**Features:**

- Pacman uses now Architecture=auto for x86-64-v3 installation, since we added a patch that pacman does autodetect x86-64-v3
- Pacman does show now, from which repo a package was installed
- Bootloader selection auto detect if EFI is present, if not it will default to grub
- Swap choice has been disabled now as default, since zram gets automatically dynamically generated
- Calamares updated to the latest commit
- Minimum RAM requirement has been set to 4GB
- cachyos-grub-theme got removed

**Bug-fixes:**

- SSD and hdd fstab detection has been disabled until there is a upstream fix
- double BTRFS subvolume has been fixed
- Added missing microcode to the ISO grub bootloader
- Added a fallback bootmode, which does not set any modeset (nomodeset)
- And more ISO fixes


# 22.09

**Features:**

- Calamares is now on the latest 3.3 branch. Its brings bugfixes and new features to calamares
- TUI-Installer is now included in the GUI ISO, you can use it with "cachyos-installer"
- Calamares does now auto detect, if the target filesystem is a ssd or hdd and adjust to it the fstab options
- Nvidia for latest gpu's (starting at 9xx) has now a own boot entry, to avoid issues with nouveau
- fstab and zfs mount options got updated
- FireFox won't be installed as default anymore since cachy-browser is installed as default

**Bug-fixes:**

- cachyos-gaming-meta has been removed from the netinstall module to avoid issues at the installation process
- netinstall packages has been updated and got some fixes
- OpenBox installation has been fixed
- usual translation fixes


# 22.07

**Features:**

- Boot-loader selection: User can now choose on the online installation between grub and systemd-boot
- At online installation will now always the newest calamares installed, which helps to do bug fixes on the "air"
- Calamares has now a mhwd module which automatically installs the needed drivers (free drivers)
- Calamares has new picture slides at the installation
- fstab and zfs mount options got updated
- HiDPI support

**Bug-fixes:**

- The locales bug in calamares got fixed
- F2FS has been removed for the grub boot loader since it is currently not working (calamares issue), it can be still with systemd-boot used
- Calamares shows now the correct default filesystem
- Gnome ISO got fixed
- Missing packages at the live ISO has been added for the offline installation
- btrfs swap luksencryption got fixed
- usual translation fixes

 # 22.06

Following known bugs has been fixed:

- Install failed when a generic CPU was used
- KDE did automatically mount zfs paritions which resulted that the auto login into the ISO did not worked anymore

**Improvements:**

- The firewall from the server has been corrected, cloudflare did blocked users as "bots", which resulted then into a error at installing
- Added theming support for Gnome, XFCE, OpenBox
- Updated our wiki

**_CachyOS - Kernel - Manager_**
Also we are excited to announce our CachyOS-Kernel-Manager.
Their you have the possibility to install the kernel from the repo and also configure with a GUI your own kernel build which makes is very easy to customize it to his own suits.

Following options you can select for a kernel compile:

- Scheduler (BMQ, BORE, cacULE, cfs, PDS, TT)
- NUMA disabled or enabled
- KBUILD CFLAGS (-O3 or -O2)
- Set performance governor as default
- Enable BBR2
- Tickrate (500Hz, 600Hz, 750Hz, 1000Hz)
- tickless (idle, perodic, full)
- disable MQ-Deadline I/O Scheduler
- disable Kyber I/O Scheduler
- Enable or disable MG-LRU
- Enable or disable DAMON
- Enable or disable Speculative page fault
- Enable or disable LRNG (Linux Random Number Generator)
- Apply Kernel automatic Optimization (Does automatically detect your CPU March)
- Apply Kernel Optimization slecting (You will see a list of different CPU-Marches and can select with a number yours)
- Disable debug (it lowers the size of the kernel)
- Enable or disable nf cone
- Enable LTO (Full, Thin, No)


# 22.05

CachyOS was founded a year ago. After almost one year of development, we are really proud to announce our first Stable Release of GUI Installer.
We spent a lot of time investigating repo management, kernel development, infrastructure, theming, ... and finally put them all into the CachyOS GUI Installer.
All the features we worked on and implemented into the Installer are just trying to offer users a completely customizable experience.

The most exciting changes are that we use now for the online install pacstrap which provide then a complete clear installed environment and we do support a complete native support for the zfs filesystem

Since Discord restrict the length of the messages the full announcement can be found here:

https://forum.cachyos.org/d/34-cachyos-gui-installer-stable-release

Download can be found here:
https://mirror.cachyos.org/ISO/kde/220522/
https://sourceforge.net/projects/cachyos-arch/




