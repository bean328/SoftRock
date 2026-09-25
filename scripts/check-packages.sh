#!/bin/sh
# Fast preflight: confirm every package in the ISO list exists in Debian 13
# (with backports pinned the same way as the image) and that apt can resolve
# them all together without recommends. Runs in a debian:trixie container.
set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
export DEBIAN_FRONTEND=noninteractive

sed -i 's/^Components: main$/Components: main contrib non-free non-free-firmware/' \
	/etc/apt/sources.list.d/debian.sources
cp "$ROOT/iso/config/archives/backports.list.chroot" /etc/apt/sources.list.d/backports.list
cp "$ROOT/iso/config/archives/backports.pref.chroot" /etc/apt/preferences.d/backports.pref
apt-get update -qq

PKGS=$(grep -hv '^\s*\(#\|$\)' "$ROOT"/iso/config/package-lists/*.list.chroot)

missing=""
for p in $PKGS; do
	apt-cache show "$p" >/dev/null 2>&1 || missing="$missing $p"
done
if [ -n "$missing" ]; then
	echo "Packages not found in trixie or trixie-backports:$missing"
	exit 1
fi

# shellcheck disable=SC2086
apt-get install --dry-run --no-install-recommends -qq $PKGS linux-image-amd64 >/dev/null
echo "All $(echo "$PKGS" | wc -w) packages exist and resolve together."
apt-cache policy hyprland linux-image-amd64 | grep -E '^[a-z]|Candidate'
