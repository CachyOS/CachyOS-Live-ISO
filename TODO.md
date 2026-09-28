# To do (Steam Machine edition)

## Open

1. **Steamify installer page with checkboxes** (next, 2026-09-28). Tested
   in the ISO VM: the current packagechooser page ("Steam Machine", mode
   `optionalmultiple`) only lets you select one item, not several. Wanted:
   - a page titled **"Steamify"** (not "Steam Machine");
   - **toggle switches like the Steamify app's** (preferred, so the page
     looks like Steamify itself; checkboxes only as a fallback) (`ui/qml` in
     steamify-cachyos: the rows with "now on" and a switch), one per Steamify
     option, **all on by default** (opt-out: switch off what you don't
     want), several at a time; a QML page could reuse the app's look
     (`Theme`, its toggle rows) and texts (`Texts`);
   - the "Start in" page (gaming mode / desktop) can stay.
   Calamares has no ready checkbox page whose ticks come out as plain ids
   (netinstall's checkboxes are package installs), so this needs our own page:
   a QML page (adapt CachyOS's `packagechooserq`) or a small Calamares
   module. The page passes the **ticked** ids to `steamify-install`, which
   runs `--defaults --options <ids> --boot gamescope|desktop` (Steamify 2.7.0:
   exactly these on; Boot into can be a row under the conversion like in the
   app, or stay its own page). Rows and texts can come from
   `steamify.sh --backend status` (+ the app's `Texts.qml`). Until then
   `steamify-install` turns the current page's "leave out" ids into
   `--options`. "Add as non-Steam game" needs a Steam account: not at install.
   Also still to check with it: that `${gs[...]}` reaches shellprocess (the
   install log shows "Unknown item: ${gs[..." if not).
2. **Check the live name** (the build tree has it right:
   `build/x86_64/airootfs/etc/os-release`) after the next build: Hello's subtitle should say
   "Steamify CachyOS, based on CachyOS rolling" (`steamify-customize.sh`,
   run by mkarchiso after the packages; the airootfs copy of os-release is
   overwritten by a package).
3. **Steamify PR** for `feat/defaults-options` (2.7.0, `c771001`:
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
