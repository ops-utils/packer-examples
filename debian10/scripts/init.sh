#!/usr/bin/env bash
set -euo pipefail

# Change these each release
export DEBIAN_STABLE=buster
export DEBIAN_TESTING=bullseye

# The user that gets set up on the machine
export MYUSER="packer"

export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none

apt-get update

apt-wipe() {
  apt-get autoremove -y
  apt-get autoclean
}

upgrade-to-testing() {
  printf "\nUpgrading OS to version alias '%s'...\n\n" "${DEBIAN_TESTING}" > /dev/stderr && sleep 3
  sed -E -i \
    -e "s/stable|${DEBIAN_STABLE}/${DEBIAN_TESTING}/g" \
    -e "s;${DEBIAN_TESTING}/updates;${DEBIAN_TESTING}-security;g" \
  /etc/apt/sources.list
  apt-get update && apt-get dist-upgrade -y
  apt-wipe
}

upgrade-to-unstable() {
  printf "\nUpgrading OS to version alias '%s'...\n\n" "sid" > /dev/stderr && sleep 3
  sed -E -i 's/^(.*)/# \1/g' /etc/apt/sources.list
  echo 'deb http://deb.debian.org/debian sid main contrib non-free' >> /etc/apt/sources.list
  apt-get update && apt-get dist-upgrade -y
  apt-wipe
}

init-sys-packages() {
  printf "\nInstalling system packages...\n\n" > /dev/stderr && sleep 3
  apt-get install -y \
    apt-transport-https \
    build-essential \
    ca-certificates \
    curl \
    gdebi \
    git \
    gnupg-agent \
    htop \
    make \
    nano \
    nmap \
    software-properties-common \
    unzip \
    wget \
    zip
  apt-wipe
}

init-python() {
  printf "\nInstalling Python stuff...\n\n" > /dev/stderr && sleep 3
  apt-get install -y \
    python3 \
    python3-pip \
    python3-venv
  pip3 install \
    flask \
    mypy \
    pylint
  apt-wipe
}

init-golang() {
  printf "\nInstalling Golang...\n\n" > /dev/stderr && sleep 3
  apt-get install -y golang
  command -v go || return 1

  # The following is how you can install the latest version if you're not on
  # Sid/Unstable
  
  # # Download the whole HTML first, so curl doesn't get mad when grep
  # # kills the pipe
  # curl -fsSL -o /tmp/gover.html https://golang.org/dl/
  # GOVER=$(grep 'linux' /tmp/gover.html | head -n1 | sed -E 's/^.*([0-9]+\.[0-9]+\.[0-9]+).*$/\1/')
  # grep -E '[0-9]+\.[0-9]+\.[0-9]+' <(echo "${GOVER}") || {
  #   printf "Could not determine latest Golang version from their website!\n" > /dev/stderr
  #   return 1
  # }
  
  # curl -fsSL -o go.tar.gz "https://dl.google.com/go/go${GOVER}.linux-amd64.tar.gz"
  # tar -C /usr/local -xzf go.tar.gz && rm go.tar.gz
  # echo "export PATH=/usr/local/go/bin/:${PATH}" >> /home/"${MYUSER}"/.bashrc

  # /usr/local/go/bin/go version || return 1
}

init-r() {
  printf "\nInstalling R...\n\n" > /dev/stderr && sleep 3
  apt-get install -y \
    r-base \
    r-base-dev
  apt-wipe
  command -v R || return 1
}

# Installs XFCE4, which should autostart when you next boot
init-xfce4() {
  printf "\nInstalling XFCE...\n\n" > /dev/stderr && sleep 3
  apt-get install -y \
    xfce4 \
    xfce4-goodies
  
  # Configure some desktop defaults
  printf "!!! You still need to finish XFCE configuration !!!\n" > /dev/stderr
  command -v startxfce4 || return 1
}

init-docker() {
  printf "\nInstalling Docker stuff...\n\n" > /dev/stderr && sleep 3
  curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
  # Docker wants to use the distro alias (lsb_release -cs), but there isn't one
  # for Sid/Unstable, so use the stable distro alias instead
  add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/debian \
    ${DEBIAN_STABLE} \
    stable"
  apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io
  usermod -aG docker "${MYUSER}"
  apt-wipe
  command -v docker || return 1

  pip3 install docker-compose
  command -v docker-compose || return 1
}

# Add MSFT repo and install packages like VSCode, etc.
init-msft() {
  printf "\nInstalling Microsoft stuff...\n\n" > /dev/stderr && sleep 3
  curl -fsSL -o vscode.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'
  gdebi -n vscode.deb && rm vscode.deb
  apt-wipe
}

init-aws() {
  printf "\nInstalling AWS stuff...\n\n" > /dev/stderr && sleep 3
  command -v pip3 || return 1
  pip3 install \
    awscli \
    aws-sam-cli
  command -v aws || return 1
  command -v sam || return 1
}

init-firefox() {
  printf "\nInstalling latest Firefox browser...\n\n" > /dev/stderr && sleep 3
  apt-get install -y firefox
  apt-wipe
}

init-qemu-network-interface() {
  # QEMU specifically seems to use a different interface (ens4) during build vs.
  # what's available (ens3) afterwards, so fix that here
  printf "\nauto ens3\nallow-hotplug ens3\niface ens3 inet dhcp\n" >> /etc/network/interfaces
}

main() {
  # upgrade-to-testing
  upgrade-to-unstable
  init-sys-packages
  init-python
  init-golang
  init-r
  init-xfce4
  init-docker
  init-msft
  init-aws
  init-qemu-network-interface
}

main

# printf "Sleeping for 1hr to let you test interactively...\n" && sleep 3600

exit 0
