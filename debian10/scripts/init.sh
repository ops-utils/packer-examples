#!/usr/bin/env bash
set -euo pipefail

# Change these each release
export DEBIAN_CURRENT=buster
export DEBIAN_TESTING=bullseye

export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none

update-upgrade-to-testing() {
  # Update release to Debian testing
  sed -E -i \
    -e "s/stable|${DEBIAN_CURRENT}/${DEBIAN_TESTING}/g" \
    -e "s;${DEBIAN_TESTING}/updates;${DEBIAN_TESTING}-security;g" \
  /etc/apt/sources.list
  apt-get update && apt-get dist-upgrade -y
}

init-python() {
  apt-get install -y \
    python3 \
    python3-pip \
    python3-venv
  pip3 install \
    flask \
    mypy \
    pylint
}

main() {
  # update-upgrade-to-testing
  init-python
}

main

exit 0
