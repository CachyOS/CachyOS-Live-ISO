# To do (Steam Machine edition)

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
- **Drop the Boost 1.91 workaround** in `steamify-prepare.sh` once
  `cachyos-calamares-next` is rebuilt against the repos' Boost.
