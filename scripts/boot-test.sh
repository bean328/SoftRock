#!/bin/sh
# Boot the ISO headless in QEMU and pass once greetd is running and has
# started the live user's session (autologin). Hyprland itself needs a GPU,
# so this checks everything up to the desktop.
# Usage: scripts/boot-test.sh [iso] [timeout seconds]
set -eu

ISO=${1:-out/softrock-amd64.iso}
TIMEOUT=${2:-900}
WORK=$(mktemp -d)
LOG=${BOOT_LOG:-out/boot.log}

# Take the live kernel and initrd out of the ISO so we can add a serial console.
xorriso -osirrox on -indev "$ISO" \
	-extract /live/vmlinuz "$WORK/vmlinuz" \
	-extract /live/initrd.img "$WORK/initrd.img" >/dev/null 2>&1

ACCEL=tcg
[ -w /dev/kvm ] && ACCEL=kvm
echo "Booting $ISO with $ACCEL, timeout ${TIMEOUT}s"

timeout "$TIMEOUT" qemu-system-x86_64 \
	-machine q35,accel="$ACCEL" -m 3072 -smp 2 \
	-cdrom "$ISO" -kernel "$WORK/vmlinuz" -initrd "$WORK/initrd.img" \
	-append "boot=live components username=softrock hostname=softrock console=ttyS0,115200 systemd.show_status=1" \
	-display none -serial file:"$LOG" -no-reboot &
QEMU=$!

ok=0
elapsed=0
while kill -0 "$QEMU" 2>/dev/null; do
	# systemd colors its status lines, so strip the escape codes before matching.
	sed 's/\x1b\[[0-9;]*m//g' "$LOG" > "$WORK/plain.log" 2>/dev/null || true
	if grep -q "Started greetd.service" "$WORK/plain.log" && grep -q "Created slice user-1000.slice" "$WORK/plain.log"; then
		ok=1
		break
	fi
	sleep 5
	elapsed=$((elapsed + 5))
done
kill "$QEMU" 2>/dev/null || true

echo "---- last lines of serial log ----"
tail -n 40 "$LOG" || true
if [ "$ok" = 1 ]; then
	echo "PASS: greetd started the live session in about ${elapsed}s"
	exit 0
fi
echo "FAIL: greetd did not start the live session"
exit 1
