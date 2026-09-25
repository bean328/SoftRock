#!/bin/sh
# Build the SoftRock .deb packages inside a Debian 13 system.
# Usage: scripts/build-packages.sh [outdir]   (default: out/packages)
set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
OUT=$(realpath -m "${1:-$ROOT/out/packages}")
WORK=$(mktemp -d)
mkdir -p "$OUT"

export DEBIAN_FRONTEND=noninteractive
# Build against the same archives as the image: trixie plus backports
# (Quickshell needs the newer wayland-protocols from backports).
cp "$ROOT/iso/config/archives/backports.list.chroot" /etc/apt/sources.list.d/backports.list
cp "$ROOT/iso/config/archives/backports.pref.chroot" /etc/apt/preferences.d/backports.pref
sed -i 's/^Components: main$/Components: main contrib non-free non-free-firmware/' \
	/etc/apt/sources.list.d/debian.sources
apt-get update
apt-get install -y --no-install-recommends \
	build-essential devscripts equivs git ca-certificates dpkg-dev

install_build_deps() {
	mk-build-deps --install --remove \
		--tool 'apt-get -y --no-install-recommends' debian/control
}

# Quickshell: upstream source at the version in debian/changelog.
QS_VERSION=$(dpkg-parsechangelog -l "$ROOT/packaging/quickshell/debian/changelog" -S Version | cut -d- -f1)
cd "$WORK"
git clone --depth 1 --branch "v$QS_VERSION" https://git.outfoxxed.me/quickshell/quickshell.git quickshell \
	|| git clone --depth 1 --branch "v$QS_VERSION" https://github.com/quickshell-mirror/quickshell.git quickshell
tar --exclude=.git -czf "quickshell_$QS_VERSION.orig.tar.gz" quickshell
cp -r "$ROOT/packaging/quickshell/debian" quickshell/debian
(cd quickshell && install_build_deps && dpkg-buildpackage -b -us -uc)

# SoftRock Shell: native package built from this repository.
mkdir -p "$WORK/softrock-shell"
cp -r "$ROOT/shell" "$ROOT/packaging/softrock-shell/debian" "$WORK/softrock-shell/"
(cd "$WORK/softrock-shell" && install_build_deps && dpkg-buildpackage -b -us -uc)

cp "$WORK"/*.deb "$OUT"/
rm -f "$OUT"/*-build-deps_*.deb "$OUT"/*-dbgsym_*.deb
ls -l "$OUT"
