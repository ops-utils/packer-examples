SHELL := /usr/bin/env bash

ifdef only
onlystr = -only=$(only)
endif

build: validate
	set -eu; \
	packer build \
		-var-file "$${os}"/vars.json \
		-force \
		$(onlystr) \
		-- \
		"$${os}"/manifest.json

validate:
	set -eu; \
	packer validate \
		-var-file "$${os}"/vars.json \
		"$${os}"/manifest.json
