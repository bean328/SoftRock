#!/bin/sh
# Build the SoftRock ISO with Debian live build. Runs as root in a privileged
# debian:trixie container (see make iso) or directly on a Debian 13 machine.
# Usage: scripts/build-iso.sh [packages dir with extra .deb files]
set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
DEBS=${1:-$ROOT/out/packages}
BUILD=$ROOT/build/iso
OUT=$ROOT/out

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
	live-build debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin \
	mtools dosfstools syslinux isolinux ca-certificates curl

"$ROOT/scripts/fetch-fonts.sh"

rm -rf "$BUILD"
mkdir -p "$BUILD" "$OUT"
cp -a "$ROOT/iso/." "$BUILD/"
if ls "$DEBS"/*.deb >/dev/null 2>&1; then
	cp "$DEBS"/*.deb "$BUILD/config/packages.chroot/"
else
	echo "No SoftRock .deb files in $DEBS; building without the shell."
fi

cd "$BUILD"
lb clean
lb config
lb build

mv softrock-amd64.hybrid.iso "$OUT/softrock-amd64.iso"
cd "$OUT"
sha256sum softrock-amd64.iso > softrock-amd64.iso.sha256
ls -lh "$OUT"
