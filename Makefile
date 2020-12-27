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

write-to-device:
	@printf "\nYou can write the .img created with the 'convert-vbox-to-raw' target to a \n" > /dev/stderr
	@printf "physical disk by running (for example) the 'dd' or 'pv' tools: \n\n" > /dev/stderr
	@printf "$$ dd if=./disk.img of=/dev/sdX status=progress \n" > /dev/stderr
	@printf "# or \n" > /dev/stderr
	@printf "$$ pv < ./disk.img > /dev/sdX \n\n" > /dev/stderr
	@printf "both of which specify '/dev/sdX' as the target device to write to. \n\n" > /dev/stderr
