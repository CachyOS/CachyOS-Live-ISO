# To do (Steam Machine edition)

## In progress (2026-09-27)

1. **Finish the running build** (`f663ce8`+) on the Steam Machine
   (`~/projects/steammachine-cachyos-live-iso`, log `~/projects/iso-build.log`;
   the harmless `chown: missing operand` error at the end is expected).
2. **Test install in the ISO VM** (`~/projects/iso-vm`): power it off, delete
   `disk.qcow2` and `vars.fd` (run.sh recreates them), point `cachyos.iso` at
   the new ISO, `run.sh install --fremont` as a user unit. Check:
   - Hello's Install opens Calamares without the "testing ISO" message
     (version-tag = CachyOS release);
   - Calamares starts without the manual Boost fix;
   - the "Setting up the Steam Machine (Steamify)" step runs;
   - after reboot: `/var/log/steamify-install.log` (every component OK,
     `exit: 0`), SDDM autologin into gamescope (black/looping in the VM is
     expected; Ctrl+Alt+F3 for a console), first desktop login: Vapor layout,
     single user's launcher, the app next to Hello.
   Likely problem: in the chroot `uname -r` is the live kernel, so the LED
   module load/check in `machine_enable` may fail although DKMS built for the
   installed kernel. Make those checks tolerate a different running kernel.
3. **Steamify PR**: `feat/defaults-mode` (2.6.0, `b948c20`) in
   steamify-cachyos, pushed but no PR yet. Open it once the install test
   passes; the user merges (never commit to main).
4. **Test on the real Steam Machine** from a USB stick (gamescope, LEDs, CEC,
   power-off) before calling the ISO usable.

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
- **Steamify options in the installer**: a Calamares page (netinstall-style
  YAML or QML) listing Steamify's options; pass the ticked ids to
  `steamify.sh --backend apply <ids>` instead of `--defaults`.
- **Branding**: name the ISO file and live session "Steam Machine CachyOS"
  (not plain `cachyos-*.iso`); check with the CachyOS team.
- **Release**: a CI job that builds the ISO (privileged container, flags from
  the steam-machine-iso skill) and hosts it (>2 GB, not a GitHub release asset).
- **Drop the Boost 1.91 workaround** in `steamify-prepare.sh` once
  `cachyos-calamares-next` is rebuilt against the repos' Boost.

Build and test details: the `steam-machine-iso` skill in steamify-cachyos-dev.
