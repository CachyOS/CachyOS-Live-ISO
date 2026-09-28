# To do (Steam Machine edition)

## Open

1. **Steamify installer page** (2026-09-28, confirmed dead end, next: netinstall).
   Tested live in the ISO VM (vmisoboot.sh, QMP clicks/screenshots):
   - **`packagechooserq` (custom QML) does not exist on this Calamares
     build.** `cachyos-calamares-next` ships `packagechooserq.conf` as a
     vestigial config file, but no `.so`: `/usr/lib/calamares/modules/`
     only has `packagechooser` (no q). Calamares refuses to start
     ("Module ... not found in module search paths"). So `SteamifyPage.qml`
     (app-styled switches) **cannot be loaded as a real module** on this
     ISO; don't retry it without first confirming the module is installed
     (`pacman -Ql cachyos-calamares-next | grep viewmodule`, or
     `ls /usr/lib/calamares/modules` in the live session) before building.
   - **`packagechooser` (the real, installed module), `method: legacy`, is
     single-choice regardless of `mode`.** Tested `mode: optionalmultiple`
     live: renders as "Choose a product from the list. The selected
     product will be installed." — a single-select list, not checkboxes.
     This matches the pre-session finding that started this whole redesign
     (the very first packagechooser-based skip/boot pages had the same
     single-select bug). So going back to plain `packagechooser` for
     Steamify's options does **not** give real multi-select either.
   - **`netinstall` is the one module that genuinely renders checkboxes**
     for multiple simultaneous selections (confirmed live on the Packages
     step: CachyOS Packages, shell config, base-devel, KDE-Desktop all
     ticked together, a real QTreeView-with-checkboxes widget). Next
     attempt: a `netinstall`-based page for Steamify's options (custom
     `netinstall.yaml`/groups data instead of real packages; the choice
     goes to global storage as `netinstallSelect`, which
     `shellprocess_steamify.conf` would read instead of
     `packagechooser_steamifypage`). Verify the exact global-storage key
     and whether netinstall's groups mechanism can host non-package items
     before building anything.
   - **Lesson for next time (the user's point):** check a Calamares module
     is actually installed/available (`ls /usr/lib/calamares/modules`,
     `pacman -Ql cachyos-calamares-next`) and test the page live by editing
     `/etc/calamares/settings.conf` + the module's `.conf` in a running
     live session (`pkexec-wrapper calamares -D6`, no full ISO rebuild
     needed) *before* spending a 13+ minute ISO build on it.
   - Steamify-side work from this session (kept, still valid once a real
     page module is found): `steamify.sh --defaults --list` (2.8.0,
     released) and `calamares-online.sh`'s newest-steamify.sh-before-install
     fetch. `SteamifyPage.qml`/`Items.qml`/`Theme.qml` copies are dead code
     until/unless `packagechooserq` becomes available; left in the tree for
     now, not referenced by any working settings.conf sequence.

2. **Check the live name**2. **Check the live name** (the build tree has it right:
   `build/x86_64/airootfs/etc/os-release`) after the next build: Hello's subtitle should say
   "Steamify CachyOS, based on CachyOS rolling" (`steamify-customize.sh`,
   run by mkarchiso after the packages; the airootfs copy of os-release is
   overwritten by a package).
3. **Steamify PR** for `feat/defaults-options` (2.7.0, `c4ec755`:
   `--options`, `--boot`; also `steamify.sh --boot` on its own and the
   HDMI-CEC volume fix): pushed and regression-tested in the VM (`--fremont`),
   no PR yet; the user merges (never commit to main).
   2.6.0 is released. Until 2.7.0 is, build the ISO with
   `steamify-prepare.sh ~/projects/steamify-cachyos` (the branch).
4. **Build in the test VM** instead of on the Steam Machine
   (steam-machine-iso skill), and install the result unattended with
   `scripts/vminstall.sh --iso` (vm-install skill; the Calamares Steamify
   step then needs `steamify-install` run from the live script).
5. **Test on the real Steam Machine** from a USB stick (gamescope, LEDs, CEC,
   power-off) before calling the ISO usable.

## Done

- **Steamify 2.6.0** released (`--defaults`, install-time mode).
- **Live session** (VM, `--fremont`): Vapor look and layout (Steam Deck
  wallpaper) at the live login; the power-off module is built for both ISO
  kernels and loaded at boot, in the VM it returns "No such device" (no
  AMDI0030 GPIO controller), as designed. Whether it keeps the real Steam
  Machine off is part of the hardware test.
- **Regression test 2.6.0 on an existing desktop install** (test VM from
  ssh-ready, `--fremont`): full first run, re-apply, notifications/CEC/theme
  off and on again. No errors; user units enabled and running, theme applied
  and restored live, no first-login autostart with a session.
- **ISO name**: `steamify-cachyos-<date>-x86_64.iso` (`iso_name` in
  `archiso/profiledef.sh`); the volume label stays `COS_<yyyymm>`.
- **VM install from the ISO (2026-09-27, `f42859a`):** a VM install from the ISO (Hello's
  Install, no manual fixes) ran Steamify's step: every component OK,
  `exit: 0`, SDDM autologin into gamescope. First desktop login (session switched to plasma in the VM) passed too:
  Vapor layout, the app opened with everything on. The first-login script
  runs the newest *release*, so it only works once 2.6.0 is released (in the
  test it was pointed at the bundle).
  The VM's text
  console doesn't show (virgl): read the installed disk with
  `qemu-nbd -r` + `mount -o ro,rescue=nologreplay,subvol=@` (logs in `@log`).

## Later

- **Branding**: the live session's os-release says "Steamify, based on
  CachyOS" (Hello's subtitle); Hello's window title and the boot menu still
  say CachyOS. Check with the CachyOS team.
- **Release**: a CI job that builds the ISO (privileged container, flags from
  the steam-machine-iso skill) and hosts it (>2 GB, not a GitHub release asset).
- **Drop the Boost 1.91 workaround** in `steamify-prepare.sh` once
  `cachyos-calamares-next` is rebuilt against the repos' Boost.

Build and test details: the `steam-machine-iso` skill in steamify-cachyos-dev.
