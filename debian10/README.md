Debian 10 "Buster"
==================

The gold standard in terms of ["follow the
docs"](https://wiki.debian.org/DebianInstaller/Preseed) for raw VM setup.

The `amazon-ebs` builder starts with a base AMI that [the Debian team
maintains](https://wiki.debian.org/Cloud/AmazonEC2Image). This base image
doesn't come with much of what the Ubuntu AMIs do (SSM agent, etc), so bear that
in mind when reviewing the contents of the `scripts/` directory. Ideally, I'd
like to get the `amazon-ebssurrogate` builder working (I can't get the AMI to
boot), so that if the Debian team ever stops publishing AMIs then the OS would
still be buildable, but it's working now, so.

The `qemu` builder has `"disk_interface": "virtio-scsi"` instead of the default
`virtio`, because the `grub` install can't seem to find `/dev/sda` on my laptop.
Not sure about other machines just yet.

`make build` expects a file named `vars.json` to be in this directory -- there
is not one here now, to prevent committing potentiall-sensitive data. Be sure to
add one if you use the Make targets!
