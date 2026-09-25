#!/bin/sh
# Download the SoftRock UI fonts (SIL Open Font License) into the image tree.
set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
DEST="$ROOT/iso/config/includes.chroot/usr/share/fonts/truetype/softrock"
BASE=https://raw.githubusercontent.com/google/fonts/main/ofl
mkdir -p "$DEST"

fetch() {
	[ -s "$DEST/$2" ] || curl -fsSL --retry 3 -o "$DEST/$2" "$BASE/$1"
}
fetch "figtree/Figtree%5Bwght%5D.ttf" Figtree.ttf
fetch "figtree/Figtree-Italic%5Bwght%5D.ttf" Figtree-Italic.ttf
fetch "lexend/Lexend%5Bwght%5D.ttf" Lexend.ttf
fetch "figtree/OFL.txt" OFL-Figtree.txt
fetch "lexend/OFL.txt" OFL-Lexend.txt
ls -l "$DEST"
