SHELL := /usr/bin/env bash

build:
	set -eu; packer validate "$${manifest}" && packer build -force "$${manifest}"
