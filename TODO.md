# To do (Steam Machine edition)

## Open

1. **Test the Steamify installer pages** (after the next build, needs
   Steamify 2.7.0 with `--skip`/`--boot`; the ISO has the branch's bundle
   until it's released): a "Steam Machine" page (leave out: multi-select,
   nothing selected = full setup) and a "Start in" page (gaming mode or
   desktop) after the Desktop page; check `/var/log/steamify-install.log`
   for the skipped items and the boot choice. If Calamares doesn't expand
   `${gs[...]}` in shellprocess, the log shows "Unknown item: ${gs[...".
2. **Check the live name** after the next build: Hello's subtitle should say
   "Steamify CachyOS, based on CachyOS rolling" (`steamify-customize.sh`,
   run by mkarchiso after the packages; the airootfs copy of os-release is
   overwritten by a package).
3. **Steamify PR**: `feat/defaults-mode` (2.6.0, `b948c20`) in
   steamify-cachyos, pushed, no PR yet (checked 2026-09-27: not on main,
   newest release v2.5.2). Ready: open it; the user
   merges (never commit to main). The ISO's first-login step needs 2.6.0
   released.
4. **Test on the real Steam Machine** from a USB stick (gamescope, LEDs, CEC,
   power-off) before calling the ISO usable.

## Done

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

- **Checkboxes instead of the leave-out list**: Calamares has no ready
  checkbox page whose ticks come out as plain ids (netinstall's are package
  installs); it would take a QML page (packagechooserq) or a small C++
  module. Steamify's side (`--skip`, `--boot`) stays the same.
- **Branding**: the live session's os-release says "Steamify, based on
  CachyOS" (Hello's subtitle); Hello's window title and the boot menu still
  say CachyOS. Check with the CachyOS team.
- **Release**: a CI job that builds the ISO (privileged container, flags from
  the steam-machine-iso skill) and hosts it (>2 GB, not a GitHub release asset).
- **Drop the Boost 1.91 workaround** in `steamify-prepare.sh` once
  `cachyos-calamares-next` is rebuilt against the repos' Boost.

Build and test details: the `steam-machine-iso` skill in steamify-cachyos-dev.
