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

convert-vbox-to-raw:
	@set -eu; \
	vboxmanage clonemedium disk "$${disk}" "$${disk}".img --format RAW
