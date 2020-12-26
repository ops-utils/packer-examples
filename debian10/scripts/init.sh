#!/usr/bin/env bash
set -euo pipefail

# Change these each release
export DEBIAN_CURRENT=buster
export DEBIAN_TESTING=bullseye

export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none

apt-get update

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

init-xfce4() {
  # Install XFCE4. This should autostart the DM when you next boot
  apt-get install -y \
    xfce4 \
    xfce4-goodies
  
  # Configure some desktop defaults
  printf "You need to finish XFCE configuration\n" > /dev/stderr
  return 1
}

main() {
  # update-upgrade-to-testing
  init-python
}

main

exit 0
