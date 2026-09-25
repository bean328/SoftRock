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
# Hyprland refuses to run as root, so verify as a normal user.
id hyprcheck >/dev/null 2>&1 || useradd --create-home hyprcheck
CONF=/tmp/softrock-hyprland.conf
cp "$ROOT/iso/config/includes.chroot/etc/skel/.config/hypr/hyprland.conf" "$CONF"
chmod 644 "$CONF"
RUNTIME=$(mktemp -d)
chown hyprcheck "$RUNTIME"
su hyprcheck -s /bin/sh -c "XDG_RUNTIME_DIR=$RUNTIME Hyprland --verify-config --config $CONF"

# QML syntax.
QMLFORMAT=$(command -v qmlformat || echo /usr/lib/qt6/bin/qmlformat)
for f in "$ROOT"/shell/*.qml; do
	"$QMLFORMAT" "$f" >/dev/null
done
echo "Hyprland config and QML files parse cleanly."
