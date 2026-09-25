#!/bin/sh
# Boot the ISO in QEMU with a virtual (software rendered) GPU.
# Pass once greetd has started the live user's session (autologin).
# With SCREENSHOTS=1 it then waits for the desktop, drives it with key presses
# and saves PNG screenshots to out/screenshots/.
# Usage: scripts/boot-test.sh [iso] [timeout seconds]
set -eu

ISO=${1:-out/softrock-amd64.iso}
TIMEOUT=${2:-900}
WORK=$(mktemp -d)
LOG=${BOOT_LOG:-out/boot.log}
SHOTS=out/screenshots
MON="$WORK/monitor.sock"
mkdir -p "$(dirname "$LOG")"

# Take the live kernel and initrd out of the ISO so we can add a serial console.
xorriso -osirrox on -indev "$ISO" \
	-extract /live/vmlinuz "$WORK/vmlinuz" \
	-extract /live/initrd.img "$WORK/initrd.img" >/dev/null 2>&1

ACCEL=tcg
[ -w /dev/kvm ] && ACCEL=kvm
echo "Booting $ISO with $ACCEL, timeout ${TIMEOUT}s"

timeout "$TIMEOUT" qemu-system-x86_64 \
	-machine q35,accel="$ACCEL" -cpu max -m 4096 -smp 4 \
	-cdrom "$ISO" -kernel "$WORK/vmlinuz" -initrd "$WORK/initrd.img" \
	-append "boot=live components username=softrock hostname=softrock console=ttyS0,115200 systemd.show_status=1" \
	-vga none -device virtio-vga,xres=1600,yres=900 -display none \
	-monitor unix:"$MON",server,nowait \
	-serial file:"$LOG" -no-reboot &
QEMU=$!

monitor() {
	printf '%s\n' "$1" | socat - UNIX-CONNECT:"$MON" >/dev/null 2>&1 || true
}

shot() {
	monitor "screendump $PWD/$SHOTS/$1.png -f png"
	sleep 1
	echo "screenshot: $SHOTS/$1.png"
}

# Type text into the guest one key at a time.
type_text() {
	printf '%s' "$1" | fold -w1 | while IFS= read -r ch; do
		case "$ch" in
			" ") key=spc ;;
			-) key=minus ;;
			\;) key=semicolon ;;
			.) key="dot" ;;
			/) key=slash ;;
			\|) key=shift-backslash ;;
			*) key=$ch ;;
		esac
		monitor "sendkey $key"
	done
}

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

if [ "$ok" = 1 ] && [ "${SCREENSHOTS:-0}" = 1 ]; then
	mkdir -p "$SHOTS"
	echo "Session started after ${elapsed}s, waiting for the desktop"
	sleep 45
	shot 1-desktop
	monitor "sendkey meta_l-spc"
	sleep 4
	shot 2-launcher
	monitor "sendkey esc"
	sleep 1
	monitor "sendkey meta_l-ret"
	sleep 4
	type_text "free -m; pgrep -a hypr; pgrep -a quickshell"
	monitor "sendkey ret"
	sleep 3
	shot 3-terminal
fi

kill "$QEMU" 2>/dev/null || true

echo "---- last lines of serial log ----"
tail -n 40 "$LOG" || true
if [ "$ok" = 1 ]; then
	echo "PASS: greetd started the live session in about ${elapsed}s"
	exit 0
fi
echo "FAIL: greetd did not start the live session"
exit 1
