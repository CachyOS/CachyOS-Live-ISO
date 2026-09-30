# AGENTS.md

Guidance for AI coding agents working on this repository (the Steam Machine
live ISO: CachyOS + the Steamify installer step). See `README.md` and
`TODO.md` for what's built and what's left; this file is operational
knowledge — how to test/build/debug it without rediscovering the same
things every session. `TODO.md` should stay a plain task list; lessons and
gotchas belong here instead.

Full build/test workflow (VM scripts, snapshots, cache setup) lives in the
`steam-machine-iso` and `cachyos-vm-testing` skills in `steamify-cachyos-dev`
— load those first. This file is the overflow: things worth knowing that
don't fit a skill's step-by-step flow.

## Calamares modules

- Verify a module is actually installed (`ls /usr/lib/calamares/modules`)
  before writing QML/config for it. A `.conf` file existing is not proof —
  CachyOS's own `cachyos-calamares-next` build explicitly skips
  `packagechooserq` (`-DSKIP_MODULES=...`).
- Read a module's *actual* logged global-storage writes (Calamares debug
  log, `-D6`), not its UI label text, to know what a `mode`/`method` really
  does.
- `packagechooser`'s multi-select only works with Shift/Ctrl-click (a plain
  click replaces the selection) and its UI has no visible checkboxes — not
  usable as the Steamify page. Use `packagechooserq` (custom QML,
  qtplugin/legacy) or `netinstall` (checkbox tree) instead.
- `packagechooserq` is built out of tree against the installed Calamares
  CMake config (`/usr/lib/cmake/Calamares`) with
  `-DWITH_QML=ON -DQT_VERSION_SUFFIX=-qt6 -Dqtname=Qt6 -DWITH_QT6=ON`;
  `find_package(KF6CoreAddons)` must come before `find_package(Calamares)`
  or the build fails with "KF6::CoreAddons target not found". Its `Config`
  class (and `prettyStatus()`'s raw `Install option: <ids>` text) is shared
  with the plain `packagechooser` module — override `prettyStatus()` in
  `PackageChooserQmlViewStep.cpp` itself (not `Config.cpp`) to change only
  this module's Summary display without affecting `packagechooser@desktop`
  etc. elsewhere in the installer.
- Both `packagechooserq` (QML swap) and `netinstall` (config swap) are
  testable live in a booted ISO VM with no rebuild: edit
  `/etc/calamares/modules/*.conf` + `settings.conf`
  (`steamify-cachyos-dev/share/sq.sh` / `sn.sh`), relaunch
  `pkexec-wrapper calamares -D6` in a **separate Konsole tab** (it blocks
  the tab it runs in; typing into that same tab just echoes inertly into
  its blocked stdin). A C++ module change needs an actual rebuild
  (out-of-tree, in the build VM) and redeploying the `.so` — no shortcut.

## Shell pitfalls

`local a=/x b="$a/y"` expands every value before assigning any, so `b` is
`/y`: `calamares-online.sh` wrote the downloaded `steamify.sh` to
`/steamify.sh` and `items.json` to a nonexistent `/qml/`, silently (stderr
went to `/dev/null`), so the Steamify page always ran on build-time rows and
the Summary had no labels. Declare a variable in its own `local` before
using it, and send a step's errors to the launcher's log, not `/dev/null`.

## ISO permissions

`steamify-prepare.sh` fetches `steamify.sh` with `curl -o`, which doesn't
carry the executable bit, and `archiso/profiledef.sh`'s `file_permissions`
map is the only other place permissions get fixed up on the ISO — any path
not listed there stays at whatever `curl`/`cp` gave it. `calamares-online.sh`
execs `steamify.sh` directly (not via `bash`) to regenerate `Items.qml`/
`items.json` at boot; without +x that failed *silently* (its stderr is
redirected to `/dev/null`), so the page kept working off build-time
fallbacks with no visible error. When something the ISO downloads or copies
at build time needs to run directly (not `bash script.sh`), add it to
`file_permissions` — don't assume the source already had the right mode.

## Driving a live/installer session via QMP

- Don't screenshot-poll for VM readiness. Pass `VM_SERIAL=<file>` to
  `run.sh`/`vmisoboot.sh` (logs `console=ttyS0` to a plain text file) and
  grep that instead — near-zero tokens vs. repeated screenshot + image
  analysis. Only screenshot at real decision points (to show the user, or
  to check a layout), not as a polling mechanism.
- The live session's keyboard layout keeps drifting to Dutch (e.g. after
  Calamares' Welcome page's keyboard preview, or after opening System
  Settings), which silently breaks `qmptype.py`'s US-layout character map
  (`/` → `-`, `&`/`>` fail outright) with no error for the common
  substitutions. Check with a no-symbols probe (`echo test123`) after any
  language/keyboard step. Typing `setxkbmap us` via QMP does fix it.
- `qmptype.py` types `&`, `>`, `<`, `?`, `{`, `}` since 2026-09-28 (before,
  `>` raised "no key for" and left half a command in the prompt: send
  Ctrl+C before retyping). Its map is US-layout, see above.
- Send QMP keystrokes one command at a time with a beat (~1-2s) in between.
  Firing several `qmptype.py` calls back-to-back can interleave with the
  guest's own prompt redraw and garble the input (seen as commands merging
  or a stray leading character).
- Calamares page Next/Back buttons move vertically as page content
  grows/shrinks: re-screenshot and re-locate the button after every page
  change, don't reuse a fixed y-coordinate.
- A second `pkexec-wrapper calamares -D6` while an earlier failed
  instance's window is still open just prints "Calamares is already
  running.": close that window first (Cancel/Afbreken, then confirm the
  "really cancel?" dialog).

## Build VM SSH flakiness

The build VM's guest sshd applies OpenSSH's `PerSourcePenalties`: repeated
quick reconnect attempts within its window make `ssh`/`scp` fail instantly
with "Connection closed" (verbose: "Not allowed at this time"), and further
quick retries seem to extend the penalty rather than reset it. Don't
retry-loop through it — that makes it worse. Either back off for a good
while (minutes, not seconds) with zero attempts in between, or just restart
the VM, which clears its in-memory penalty state immediately and is
usually faster than waiting it out.

Large `scp` transfers (e.g. the ~3.2GB built ISO) over this same flaky link
can report "Connection closed" while actually still having copied fully —
check the destination file's size/timestamp before assuming a real
failure, and retry the copy (it's idempotent) rather than the whole build.

## Releases (GitHub tag, ISO built and attached on the Gitea mirror)

Full write-up, with every trap: `steamify-iso-release` in steamify-cachyos-dev. What matters here:

- `.github/workflows/iso-1-github-tag.yml` (GitHub, `workflow_dispatch` only: by hand, or started by a new Steamify
  release, whose `bundle.yml` needs the secret `ISO_DISPATCH_TOKEN`) names the release: the Steamify version plus
  GitHub's UTC time, `vX.Y.Z-[dev.]YYYY.MM.DD-HHMM`, an **annotated** tag and a release with notes and the direct
  download link. `feat/steamify` makes a `dev.` pre-release, `master` a real one.
- `.github/workflows/iso-2-gitea-build.yml` (Gitea, `on: push: tags: v*`, skipped on GitHub) runs four jobs for that
  tag: build the ISO, test it (steamify-cachyos-dev's `scripts/vmbootloadertest.sh --install`, one job per boot loader,
  parallel up to the runner's capacity; needs `/dev/kvm` on the runner and checks out steamify-cachyos-dev `main` and
  steamify-cachyos at the ISO's version from the mirror), then, after those, the suites (`scripts/vmtest.sh cli menu hw installer toggles` on a plain VM installed from the new ISO with `VM_STEAMIFY=skip`, two at a time), and only when all tests passed attach it to the mirror's release. The tag decides everything: Steamify version (`steamify-prepare.sh`
  takes `STEAMIFY_VERSION`), file name (`STEAMIFY_ISO_VERSION` -> `iso_version` in `profiledef.sh`), label
  (`STEAMIFY_BUILD_STAMP`), boot menu and `/etc/steammachine-iso-build`. The build reads no clock; without a
  tag everything says `local`.
- `util-iso.sh` runs `sudo mkarchiso`: sudo drops the environment, so `--preserve-env=STEAMIFY_ISO_VERSION,
  STEAMIFY_BUILD_STAMP` is required (without it the ISO comes out `-local-`).
- Never create a release on the mirror by hand or from a Gitea-only tag: the pull mirror's next sync deletes tags
  GitHub doesn't have, and the release with them. GitHub releases can't hold the ISO (2 GB per file).
- Gitea needs `[repository.release] FILE_MAX_SIZE` above the ISO (413 otherwise) and the runner
  `container: privileged: true` (archiso mounts `/proc`); the workflow's `--privileged` option is ignored.
- Caches (`actions/cache`, the runner's cache server): pacman's package cache per job kind (build, test) and the VMs' packages (`VM_CACHE`, `~/vms/pkg-cache`), keys per ISO week. Each job first installs only node and git, restores the caches, then installs the rest.
- CachyOS's own `Desktop ISO` workflow (`build.yml`) is removed here; the test job of iso-2-gitea-build.yml replaces it.
