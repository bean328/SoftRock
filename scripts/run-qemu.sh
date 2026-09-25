#!/bin/sh
# Boot the ISO in a QEMU window with 3D acceleration so Hyprland can render.
set -eu
ISO=${1:-out/softrock-amd64.iso}
exec qemu-system-x86_64 -enable-kvm -machine q35 -cpu host -m 4096 -smp 4 \
	-cdrom "$ISO" -boot d \
	-device virtio-vga-gl -display gtk,gl=on \
	-audiodev pa,id=snd -device intel-hda -device hda-duplex,audiodev=snd
