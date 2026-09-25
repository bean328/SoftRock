# SoftRock developer commands.
DEBIAN := debian:trixie

.PHONY: tokens test shellcheck lint packages iso boot-test run clean

tokens:
	python3 design/generate.py

test:
	python3 design/generate.py --check
	cd design && python3 -m unittest -v

shellcheck:
	shellcheck -s sh scripts/*.sh shell/softrock-shell iso/auto/* iso/config/hooks/live/*.chroot \
		iso/config/includes.chroot/usr/bin/softrock-session \
		iso/config/includes.chroot/usr/lib/live/config/*

lint: test shellcheck

packages:
	docker run --rm -v "$(CURDIR):/src" -w /src $(DEBIAN) scripts/build-packages.sh /src/out/packages

iso:
	docker run --rm --privileged -v "$(CURDIR):/src" -w /src $(DEBIAN) scripts/build-iso.sh /src/out/packages

boot-test:
	scripts/boot-test.sh out/softrock-amd64.iso

run:
	scripts/run-qemu.sh out/softrock-amd64.iso

clean:
	rm -rf build out
