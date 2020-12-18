#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none

update-upgrade() {
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
  update-upgrade
  init-python
}

main

exit 0
