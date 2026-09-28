# To do (Steam Machine edition)

## Open

1. **Steamify installer page** (2026-09-28, working end to end; see
   `AGENTS.md` for the module/build/testing details and gotchas behind
   this). `packagechooserq` (custom QML) is built with each ISO by
   `build-calamares-modules.sh` into `archiso/airootfs/usr/lib/calamares/modules/packagechooserq/`.
   `netinstall` (checkbox tree) stays as a manually-swappable fallback
   (`steamify-cachyos-dev/share/sn.sh` + `nisteamify.conf`) for when the
   module can't load, but isn't wired into `calamares-online.sh`
   automatically yet.
   - **Still open**:
     - "Boot into gaming mode" as an opt-out sub-toggle under SteamOS
       conversion (agreed with the user) isn't implemented on either page
       yet — both still use the old Gaming/Desktop radio-row.
     - A Python job (e.g. `steamifychoice`, before `packages@online`) to
       normalize either page's choice (packagechooserq's
       `packagechooser_steamifypage` GS key, or netinstall's
       packageOperations markers) into one `steamifyChoice` GS key, so
       `shellprocess_steamify.conf` doesn't need to know which page ran.

2. **Check the live name** (the build tree has it right:
   `build/x86_64/airootfs/etc/os-release`) after the next build: Hello's subtitle should say
   "Steamify CachyOS, based on CachyOS rolling" (`steamify-customize.sh`,
   run by mkarchiso after the packages; the airootfs copy of os-release is
   overwritten by a package).
3. ~~Steamify PR for `feat/defaults-options`~~ — done: 2.7.0 (`--options`,
   `--boot`, `steamify.sh --boot` standalone) and 2.8.0
   (`--defaults --list`, what the Steamify page's rows come from) are both
   released. **The ISO builder is up to date with this**: no checkout
   argument needed, `steamify-prepare.sh` (no args) and `calamares-online.sh`
   at boot both just fetch the newest release, so the ISO always has 2.8.0+
   without a rebuild for a Steamify-side change alone. Only pass
   `steamify-prepare.sh <checkout>` / `vmisobuild.sh --steamify <path>` when
   testing an *unreleased* Steamify change.
4. **Build in the test VM** instead of on the Steam Machine
   (steam-machine-iso skill), and install the result unattended with
   `scripts/vminstall.sh --iso` (vm-install skill; the Calamares Steamify
   step then needs `steamify-install` run from the live script).
5. **Test on the real Steam Machine** from a USB stick (gamescope, LEDs, CEC,
   power-off) before calling the ISO usable.

## Done

- **Full ISO install with the Steamify page** (2026-09-28, ISO VM,
  `--fremont`, Start in: desktop): Summary listed the choices, the
  install step ran Steamify 2.8.0 with every item OK, `--boot desktop`
  applied, `exit: 0`; the installed system boots into the desktop.
- **Steamify Summary** (2026-09-28, ISO VM): an unordered list of the chosen
  items' names plus "Starts in gaming mode/the desktop"
  (`patches/packagechooserq-steamify-summary.patch`), with `items.json`
  written by the launcher (its `$sdir` bug fixed, `0cc7367`).
- **packagechooserq built with the ISO** (2026-09-28):
  `build-calamares-modules.sh` builds it in the build container/VM from
  CachyOS's Calamares source against the current `cachyos-calamares-next`
  (no prebuilt `.so` in git), with `built-for`; `calamares-online.sh` leaves
  the Steamify page out when the Calamares it runs differs (the step then
  installs everything on) instead of risking "Initialization Failed".
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
