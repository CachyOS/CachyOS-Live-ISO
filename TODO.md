# To do (Steam Machine edition)

## Open

1. **Steamify installer page** (2026-09-28, in progress).
   Tested live in the ISO VM (vmisoboot.sh, QMP clicks/screenshots +
   `pkexec-wrapper calamares -D6` foregrounded, its own debug log):
   - **`packagechooserq` (custom QML) does not exist on this Calamares
     build**: only `packagechooser` is installed
     (`ls /usr/lib/calamares/modules`). `SteamifyPage.qml` can't be loaded
     by any real module here; confirm a module is actually installed
     before writing QML/config for it again.
   - **`packagechooser`, `mode: optionalmultiple`, genuinely multi-selects**
     (confirmed from its actual global-storage write, not its static label
     text which misleadingly says "Choose a product..." either way):
     `"packagechooser@steamifypage" selected "single,gaming,theme"` — a
     real comma-separated list, matching `steamify-install`'s expected
     `--options` format. Global storage key: `packagechooser_steamifypage`.
   - **But its UI doesn't look like a multi-select** (a plain list with a
     big blank preview pane, no checkboxes shown) — confirmed by the user
     watching the VM live. Not good enough visually, even though it's
     functionally correct.
   - **Decision (the user, 2026-09-28): use `netinstall` instead**, the
     module that actually renders a checkbox tree (confirmed live on the
     Packages step: CachyOS Packages/shell config/base-devel/KDE-Desktop
     all ticked together, real checkboxes). Not yet re-confirmed live this
     session (the live session's keyboard layout flipped to Dutch after
     the Welcome page's live keyboard preview, breaking `/`/`(`/`)` in
     `qmptype.py`'s US-layout key map — `setxkbmap us` has no effect on
     Wayland; fix the layout in the live session's own settings before
     typing shell commands with those characters again).
   - **Next**, from already-known Calamares internals (its `Config.cpp`
     logged `"packagechooser@desktop" groups to select in netinstall
     QList("KDE-Desktop")` — i.e. netinstall groups CAN be driven by
     another module's choice, and/or defined directly): write a
     `netinstall_steamify.conf`/groups YAML for Steamify's items (id,
     name, description per group; check whether a non-package/virtual
     group is possible, or whether `packages: []` with `critical: false`
     is enough to make a group purely informational/no-op for pacman) from
     `steamify.sh --defaults --list`, generated in `calamares-online.sh`
     (same spot the abandoned Items.qml/packagechooser YAML generation
     was). Read the selection back from whichever global-storage key
     netinstall actually writes (`netinstallSelect`, seen in Config.cpp;
     confirm the exact key/shape live) in
     `shellprocess_steamify.conf`/`steamify-install`. Boot into
     (gaming/desktop) still needs its own small `packagechooser`,
     `mode: required` page (an either/or choice doesn't fit a checkbox
     tree).
   - Dead code from this session, left in the tree for now: `SteamifyPage.qml`.
   - **Lessons for next time:**
     - Verify a Calamares module is actually installed
       (`ls /usr/lib/calamares/modules`) before writing QML/config for it.
     - Read a module's *actual* logged global-storage writes, not its UI
       label text, to know what a `mode`/`method` really does.
     - Both testable live in the booted ISO VM with no rebuild: edit
       `/etc/calamares/modules/*.conf` + `settings.conf`, relaunch
       `pkexec-wrapper calamares -D6` in a **separate Konsole tab** (it
       blocks the tab it runs in — typing into that same tab just echoes
       inertly into its blocked stdin, doesn't run commands).
     - Watch for the live session's keyboard layout changing away from US
       (e.g. via Calamares' Welcome page keyboard preview) mid-session:
       `qmptype.py` assumes US and silently sends wrong characters
       (`/` → `-`, parens garbled) once it does, with no error for the
       common ones. Check with a no-symbols probe (`echo test123`) after
       any language/keyboard step, and fix via the live session's own
       keyboard settings if needed, not `setxkbmap` (no effect on Wayland).

2. **Check the live name**2. **Check the live name**2. **Check the live name**2. **Check the live name** (the build tree has it right:
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
