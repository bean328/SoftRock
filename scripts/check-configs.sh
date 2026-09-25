#!/bin/sh
# Validate generated configs with the real tools from Debian 13:
# Hyprland parses the SoftRock config, qmlformat parses every QML file.
# Run after scripts/check-packages.sh (it sets up backports).
set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
export DEBIAN_FRONTEND=noninteractive
apt-get install -y -qq --no-install-recommends hyprland qt6-declarative-dev-tools >/dev/null

# Hyprland: install SoftRock defaults where the config expects them, then verify.
cp -r "$ROOT/iso/config/includes.chroot/usr/share/softrock" /usr/share/
XDG_RUNTIME_DIR=$(mktemp -d)
export XDG_RUNTIME_DIR
Hyprland --verify-config --config "$ROOT/iso/config/includes.chroot/etc/skel/.config/hypr/hyprland.conf"

# QML syntax.
QMLFORMAT=$(command -v qmlformat || echo /usr/lib/qt6/bin/qmlformat)
for f in "$ROOT"/shell/*.qml; do
	"$QMLFORMAT" "$f" >/dev/null
done
echo "Hyprland config and QML files parse cleanly."
