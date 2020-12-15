SHELL := /usr/bin/env bash

build:
	set -eu; \
	packer validate "$${os}"/manifest.json \
	&& packer build -force "$${os}"/manifest.json
