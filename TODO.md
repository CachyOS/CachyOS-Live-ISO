# To do (Steam Machine edition)

## Open

1. **Steamify installer page** (2026-09-28, working end to end).
   `packagechooserq` (custom QML) doesn't exist in CachyOS's own
   `cachyos-calamares-next` build (`-DSKIP_MODULES=...packagechooserq...`),
   so it's built out of tree against the installed Calamares headers (see
   the build VM notes in the steam-machine-iso skill) and its `.so` +
   `module.desc` are baked straight into `archiso/airootfs/usr/lib/calamares/
   modules/packagechooserq/` (no conflict: the package never ships that
   path). `netinstall` (checkbox tree) stays as a manually-swappable
   fallback (`steamify-cachyos-dev/share/sn.sh` + `nisteamify.conf`) for
   when the module can't load, but isn't wired into `calamares-online.sh`
   automatically yet — see the version-mismatch item below.
   - **Fixed this session**: selected-row contrast (border-only highlight,
     was a translucent teal fill making white text unreadable), page
     background (was falling through to Calamares' white default), a
     sub-option `└` marker, more right padding so the row border clears the
     scrollbar, Summary step showing readable labels (packagechooserq's
     `prettyStatus()` overridden, only for this module instance, to render
     an HTML bullet list from a new `items.json` that `calamares-online.sh`
     writes next to `Items.qml`), and a **pre-existing bug**: `steamify.sh`
     on the ISO was never executable (`curl -o` in `steamify-prepare.sh`
     doesn't set +x, and `profiledef.sh`'s `file_permissions` never listed
     it), so `calamares-online.sh`'s direct exec of it
     (`"$sbin" --defaults --list`) silently failed and `items.json` (no
     static fallback) was never written — fixed by adding the path to
     `file_permissions`.
   - **Still open**:
     - Bake the `packagechooserq` *build* into the ISO build pipeline
       itself (a `build-calamares-modules.sh` step: install
       `cachyos-calamares-next`, build out of tree, install into
       `airootfs`) instead of committing a prebuilt `.so`, so it always
       matches whatever Calamares version is current at build time.
     - Version-mismatch fallback: after `calamares-online.sh`'s
       `pacman -Sy cachyos-calamares-next`, check the installed version
       against what the module was built for; on a mismatch, switch
       `settings.conf` to the `netinstall` page instead (generate its
       groups conf from `--defaults --list` there too) rather than risk an
       "Initialization Failed" module.
     - "Boot into gaming mode" as an opt-out sub-toggle under SteamOS
       conversion (agreed with the user) isn't implemented on either page
       yet — both still use the old Gaming/Desktop radio-row.
     - A Python job (e.g. `steamifychoice`, before `packages@online`) to
       normalize either page's choice (packagechooserq's
       `packagechooser_steamifypage` GS key, or netinstall's
       packageOperations markers) into one `steamifyChoice` GS key, so
       `shellprocess_steamify.conf` doesn't need to know which page ran.
   - **Lessons learned**:
     - Verify a Calamares module is actually installed
       (`ls /usr/lib/calamares/modules`) before writing QML/config for it;
       `packagechooser`'s multi-select needs Shift/Ctrl-click (plain click
       replaces the selection) — not usable as-is, `packagechooserq` or
       `netinstall` only.
     - Both pages are testable live in the booted ISO VM with no rebuild:
       hot-swap `/etc/calamares/modules/*.conf` + `settings.conf`
       (`share/sq.sh` / `share/sn.sh`), relaunch
       `pkexec-wrapper calamares -D6` in a **separate Konsole tab** (it
       blocks the tab it runs in). A C++ module change needs a real
       rebuild (out-of-tree, in the build VM) + redeploy of the `.so`, no
       shortcut.
     - The live session's keyboard layout keeps drifting to Dutch (e.g.
       after Calamares' Welcome page, or after opening System Settings),
       breaking `/`/`(`/`)`/`&`/`>` in `qmptype.py`'s US-layout map with no
       error for the common ones (`/` → `-`) — `setxkbmap us` typed via
       QMP *does* fix it (unlike the earlier Wayland claim), but check
       with a no-symbols probe after any language/keyboard step regardless.
     - `qmptype.py` has no key for `&` or `>` at all: a typed command using
       either raises "no key for" and can leave an unterminated quote in
       the shell's input buffer; send Ctrl+C before retyping. Avoid
       redirection/`&&` in typed commands — write it to a file and run
       `bash /media/foo.sh` instead, since a file's contents aren't typed
       character-by-character.
     - Send QMP keystrokes one command at a time with a beat in between;
       firing several `qmptype.py` calls back-to-back can interleave with
       the guest's own prompt redraw and garble the input.
     - Don't screenshot-poll for VM readiness: pass `VM_SERIAL=<file>` to
       `run.sh`/`vmisoboot.sh` and grep the plain-text serial log instead
       (near-zero tokens vs. repeated screenshot+image-analysis).
     - The build VM's guest sshd applies OpenSSH's `PerSourcePenalties`:
       repeated quick reconnect attempts within its window make `ssh`/`scp`
       fail instantly with "Connection closed" (verbose: "Not allowed at
       this time"), and each further attempt seems to extend the penalty
       rather than reset it. Don't retry-loop through it; back off for a
       while, or just restart the VM (clears its in-memory penalty state
       immediately) instead of waiting it out.

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
