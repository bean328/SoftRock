#!/bin/sh
# Boot the ISO headless in QEMU and pass once systemd reaches the graphical
# target with greetd running. Hyprland itself needs a GPU, so this checks
# everything up to the session.
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
	if grep -q "Started greetd" "$LOG" 2>/dev/null && grep -q "Reached target.*Graphical Interface" "$LOG" 2>/dev/null; then
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
	echo "PASS: reached graphical target with greetd in about ${elapsed}s"
	exit 0
fi
echo "FAIL: did not reach graphical target with greetd"
exit 1
