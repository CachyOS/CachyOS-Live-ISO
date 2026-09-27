# To do (Steam Machine edition)

## Open

1. **Regression test 2.6.0 on an existing desktop install** before merging:
   test VM from ssh-ready, full first run from the desktop, re-apply, a few
   components off and on (every `systemctl --user` now goes through
   `user_systemctl`; with a session it should behave exactly as before).
2. **Steamify PR**: `feat/defaults-mode` (2.6.0, `b948c20`) in
   steamify-cachyos, pushed, no PR yet (checked 2026-09-27: not on main,
   newest release v2.5.2). Open it after the regression test; the user
   merges (never commit to main). The ISO's first-login step needs 2.6.0
   released.
3. **Test on the real Steam Machine** from a USB stick (gamescope, LEDs, CEC,
   power-off) before calling the ISO usable.

## Done

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

- **Power-off fix in the live session.** Without it the Steam Machine starts
  again right after shutting down from the live ISO. Build
  `steamify-fremont-poweroff.ko` in `steamify-prepare.sh` against the headers
  of the ISO's kernel, put it in `airootfs/usr/lib/modules/<version>/extra`
  and run depmod (small); or ship DKMS packages from a local repo (~250 MB of
  headers on the ISO). Later maybe the CEC and LED drivers the same way.
- **Vapor theme in the live session.** Add `cachyos-vapor` to
  `packages_desktop.x86_64` and set it as the live user's look and feel in
  `airootfs/etc/skel` (kdeglobals `LookAndFeelPackage`, no layout file, so
  Plasma lays out Vapor at the live login).
- **Steamify wizard pages in the installer**, before anything is installed:
  the same choices as Steamify's menu (conversion, boot into gamescope or
  desktop, theme, Deck icons, single user, shortcut + non-Steam game,
  notifications, VRAM booster, HDMI-CEC, Steam Machine support + power-off
  fix), defaults ticked like a first run. A Calamares page (netinstall-style
  YAML or a QML module in the `show` sequence) stores the ticked ids in
  global storage; `steamify-install` passes them to
  `steamify.sh --backend apply <ids>` (`--boot gamescope|desktop`) instead of
  `--defaults`.
- **Branding**: the live session still says CachyOS (Hello, os-release,
  boot menu); decide what to rename there and check with the CachyOS team.
- **Release**: a CI job that builds the ISO (privileged container, flags from
  the steam-machine-iso skill) and hosts it (>2 GB, not a GitHub release asset).
- **Drop the Boost 1.91 workaround** in `steamify-prepare.sh` once
  `cachyos-calamares-next` is rebuilt against the repos' Boost.

Build and test details: the `steam-machine-iso` skill in steamify-cachyos-dev.
