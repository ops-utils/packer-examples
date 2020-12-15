#!/usr/bin/env bash
set -euo pipefail

sed -E -i \
  -e 's/stable|buster/testing/g' \
  -e 's;testing/updates;testing-security;g' \
  /etc/apt/sources.list

export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
apt-get update && apt-get dist-upgrade -y
