#!/usr/bin/env bash
set -euo pipefail

# This script runs after the VirtualBox image is built, and will create a user
# VM using the image artifact

basefolder="$(pwd)/vbox-vms"

# Generally pulled from here:
# https://www.andreafortuna.org/2019/10/24/how-to-create-a-virtualbox-vm-from-command-line/
create-vbox-vm() {
  mkdir -p ./vbox-vms
  vboxmanage createvm \
    --name "${vmname}" \
    --ostype "Debian_64" \
    --register \
    --basefolder "${basefolder}"
  
  # Set memory and network
  vboxmanage modifyvm "${vmname}" --ioapic on
  vboxmanage modifyvm "${vmname}" --memory 1024 --vram 128
  vboxmanage modifyvm "${vmname}" --nic1 nat
  # Create SATA controller and attach .vmdk to it
  vboxmanage storagectl "${vmname}" --name "SATA Controller" --add sata --controller IntelAhci
  vboxmanage storageattach "${vmname}" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium ./output*/*debian-*.vmdk
}

# This is the fallback if 
delete-vbox-vm() {
  vboxmanage unregistervm "${vmname}" || rm -rf "${basefolder}"
}

main() {
  create-vbox-vm || delete-vbox-vm
}

main
