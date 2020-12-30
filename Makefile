SHELL := /usr/bin/env bash

# If you pass 'only=<builder>', it will get sent to the '-only=' flag for
# 'packer build'
ifdef only
onlyflag = -only=$(only)
endif

build: validate
	set -eu; \
	packer build \
		-var-file "$${os}"/vars.json \
		-force \
		$(onlyflag) \
		-- \
		"$${os}"/manifest.json

validate:
	set -eu; \
	packer validate \
		-var-file "$${os}"/vars.json \
		"$${os}"/manifest.json

convert-vbox-to-raw-img:
	@set -eu; \
	vboxmanage clonemedium disk --format RAW "$${disk}" "$${disk}".img

# Some of these flags need to be set explicitly here; e.g.:
#
# * if RAM is too low you get a kernel panic on boot
#
# * QEMU should know how to handle user-mode networking automatically, but I've
#   had to set the netdev manually to the same that Packer uses at build time
start-qemu:
	set -eu; \
	qemu-system-x86_64 \
		-drive file="$${disk}" \
		-smp cpus=2 \
		-m size=2048 \
		-device VGA,vgamem_mb=128 \
		-enable-kvm
# Still trying to get the following to work:
# -netdev user,id=user.0 -device virtio-net,netdev=user.0 \
# -device virtio-net,netdev=network0 -netdev tap,id=network0,ifname=tap0,script=no,downscript=no,vhost=on \

write-to-device:
	@printf "\nYou can write the .img created with the 'convert-vbox-to-raw' target to a \n" > /dev/stderr
	@printf "physical disk by running (for example) the 'dd' or 'pv' tools: \n\n" > /dev/stderr
	@printf "$$ dd if=./disk.img of=/dev/sdX status=progress \n" > /dev/stderr
	@printf "# or \n" > /dev/stderr
	@printf "$$ pv < ./disk.img > /dev/sdX \n\n" > /dev/stderr
	@printf "both of which specify '/dev/sdX' as the target device to write to. \n\n" > /dev/stderr
