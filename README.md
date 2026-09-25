# SoftRock

SoftRock is a Debian based Linux desktop that aims to look better than anything else on Linux while asking for a fraction of the hardware. Hyprland draws the windows, SoftRock Shell (built on Quickshell) gives it a clean, flat modern look, and every SoftRock tool follows one rule: if it is not doing something for you right now, it is not running.

**Status:** Phase 0, Foundation. The ISO builds and boots in CI. Expect rough edges.

## Targets

| | Linux Mint (Cinnamon) | SoftRock |
|---|---|---|
| Idle memory after login | about 800 MB | 300 MB (Standard), 240 MB (Lite) |
| Minimum RAM | 2 GB | 1 GB |
| Resident SoftRock processes | | 1 (the shell) |

## What is inside

* **Base:** Debian 13 trixie, with the newer kernel, firmware and Hyprland from trixie backports
* **Desktop:** Hyprland, SoftRock Shell on Quickshell 0.3, greetd, Fuzzel launcher, Mako notifications
* **System:** PipeWire, NetworkManager on iwd, BlueZ, power profiles daemon, dbus broker, systemd oomd
* **Memory:** zswap in front of disk swap, multi generational LRU, oomd limits on user sessions
* **Apps:** Firefox ESR, Thunar, Foot, Flatpak
* **Installer:** Calamares

## Repository layout

```
design/      design tokens (tokens.json) and the generator that themes everything
shell/       SoftRock Shell, QML for Quickshell
packaging/   Debian packaging for Quickshell and SoftRock Shell
iso/         Debian live build config: package lists, hooks, system files
scripts/     build, check and QEMU helpers
docs/        the SoftRock plan
```

## Building

Everything builds in a Debian 13 container, so any Linux machine with Docker works.

```sh
make test        # design token tests and generated file check
make tokens      # regenerate theme files after editing design/tokens.json
make packages    # build quickshell and softrock-shell .deb files into out/packages
make iso         # build out/softrock-amd64.iso (needs a privileged container)
make boot-test   # headless QEMU boot check
make run         # boot the ISO in a QEMU window with 3D acceleration
```

Every push also builds everything in GitHub Actions. Open the latest **Build SoftRock** run and download the `softrock-iso` artifact.

## Trying it

Boot the ISO in a VM with 3D acceleration enabled (QEMU with virtio GPU, VirtualBox or VMware with 3D on), or write it to a USB stick. The live session logs you straight into the desktop.

| Keys | Action |
|---|---|
| Super + Space | App launcher |
| Super + Enter | Terminal |
| Super + E | Files |
| Super + B | Firefox |
| Super + Q | Close window |
| Super + V | Toggle floating or tiled |
| Super + 1 to 5 | Switch workspace |
| Super + Shift + E | Log out |

To install, open the launcher and search for **Install**.

## Design

All colors, radii, spacing, fonts and the three visual tiers (Lite, Standard, Ultra) live in `design/tokens.json`. `make tokens` turns them into the QML theme, Hyprland snippets, GTK colors, and the Foot, Fuzzel and Mako configs. Edit the tokens, never the generated files.

## License

GPL 3. See [LICENSE](LICENSE).
