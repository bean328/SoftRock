# The SoftRock plan

SoftRock is a Debian 13 based desktop with a Hyprland compositor, a custom Quickshell shell and SoftRock's own tools. The goal: look better than Linux Mint and use about a quarter of its idle memory.

## Principles

1. **Idle means idle.** SoftRock tools start through systemd timers, sockets or DBus activation, and exit when done. Only the shell stays resident.
2. **Debian underneath.** Debian stays untouched at the core. SoftRock adds its own packages on top, so every Debian guide still applies.
3. **One design language.** One token file themes the shell, apps, GTK, Qt, terminal, login and boot.
4. **Beautiful everywhere.** Full effects on capable GPUs, a calmer version of the same look on old hardware.
5. **Never break a user.** Every update takes a Btrfs snapshot first.
6. **Measure, then claim.** Every efficiency target is a release gate with a number.

## Design: flat modern

Clean flat surfaces, rounded cards, a single indigo accent ("Quartz"), dark by default with a matching light theme. Contrast is tested in CI: body text meets WCAG AA on every surface. Fonts: Lexend for headings, Figtree for the interface, JetBrains Mono for code.

Three visual tiers, chosen from the hardware at first boot:

| Tier | For | Blur | Shadows | Idle target |
|---|---|---|---|---|
| Lite | 1 to 2 GB RAM, older graphics | off | off | 240 MB |
| Standard | most machines from 2015 on | panels only, 1 pass | soft | 300 MB |
| Ultra | dedicated GPUs, recent APUs | everywhere, 3 passes | deep | 340 MB |

## Stack

| Layer | Choice |
|---|---|
| Base | Debian 13 trixie, full firmware, Btrfs with Snapper |
| Kernel | Debian's signed kernel from trixie backports (7.0 series) |
| Session | Hyprland (from backports, pinned per release), greetd |
| Shell | SoftRock Shell on Quickshell 0.3, built with jemalloc |
| Services | PipeWire, NetworkManager on iwd, BlueZ, power profiles daemon, dbus broker, systemd oomd |
| Apps | Firefox, Thunar, Foot, Flatpak with Flathub |
| Installer | Calamares |

## Efficiency, ranked by impact

1. **Session design.** Hyprland plus one Quickshell process instead of a full desktop environment. No extra session manager layer.
2. **Memory under pressure.** zswap in front of a real swap file (better than zram when a disk exists), multi generational LRU, oomd limits so a runaway app dies before the desktop freezes.
3. **Scheduling.** scx_lavd through sched_ext, following the power profile. Default only if it beats the stock scheduler on every reference machine.
4. **Graphics and power.** Hyprland renders only on change, hardware video decode in the browser, effects scale by tier, runtime power management on a safe allow list.
5. **Boot.** Lean initramfs, hidden boot menu, precompiled font, icon and QML caches in the image.
6. **Targeted compiler work.** LTO and profile guided builds for the compositor, shell and SoftRock apps only. An optional SoftRock kernel for enthusiasts.

## SoftRock apps

| App | Runs |
|---|---|
| SoftRock Shell: bar, dock, launcher, notifications, quick settings, lock screen | always |
| Settings | on open |
| Update, with snapshots and one click rollback | daily timer check |
| Drivers | on open and at first boot |
| Store for Debian packages and Flathub | on open |
| Welcome | first login |
| Tune: hardware detection and tier choice | first boot, then on open |
| Rescue: restore a snapshot | only when something broke |

## How the OS is built

1. **Package.** `scripts/build-packages.sh` builds Quickshell (pinned upstream release) and SoftRock Shell as Debian packages in a clean Debian 13 container.
2. **Assemble.** `scripts/build-iso.sh` runs Debian live build with the config in `iso/`: Debian trixie plus backports, the package list, SoftRock's system files and hooks, and the packages from step 1.
3. **Check.** CI verifies every package exists and resolves, Hyprland parses the config, and every QML file parses.
4. **Boot test.** QEMU boots the ISO headless and waits for the graphical target with greetd running.
5. **Publish.** The ISO and its checksum are uploaded from every CI run. A signed SoftRock apt repository comes in Phase 2.

## Roadmap

| Phase | When | Goal | Exit |
|---|---|---|---|
| 0 Foundation | Oct to Nov 2026 | tokens, packaging, first ISO, CI | ISO boots on real hardware |
| 1 Shell | Dec 2026 to Mar 2027 | bar, dock, launcher, notifications, quick settings, greeter, lock screen, tiers | daily drivable under 320 MB idle |
| 2 Tools | Mar to Jun 2027 | Settings, Update, Rescue, Drivers, Store, Welcome, branded installer, own apt repo | non technical tester installs without a terminal |
| 3 Beta | Jul to Aug 2027 | public beta, hardware reports, optional kernel | all release gates pass on reference machines |
| 4 SoftRock 1.0 | Sep 2027 | stable channel, then rebase on Debian 14 | 2.0 within two months of Debian 14 |

## Release gates

| Gate | Target |
|---|---|
| Idle memory, Standard | 320 MB or less, 60 s after login |
| Idle memory, Lite | 260 MB or less, and at most a quarter of Mint Cinnamon on the same machine |
| Boot to greeter | 8 s or less on a SATA SSD |
| Idle CPU | 0.0% over five idle minutes |
| Resident SoftRock processes | 1 |
| Rollback | a broken update restores from the boot menu |

Reference machines: a 2014 ThinkPad with 4 GB, an Intel N100 mini PC, a Ryzen 7040 laptop and a desktop with a recent NVIDIA card.

## Phase 0 status

* [x] Design tokens, generator and contrast tests
* [x] Live build config with backports, firmware and the SoftRock package set
* [x] zswap, multi generational LRU, oomd and service diet
* [x] SoftRock Shell first version: workspaces, window title, battery, clock
* [x] Debian packaging for Quickshell and SoftRock Shell
* [x] CI: checks, packages, ISO build, QEMU boot test
* [ ] First boot on real hardware
