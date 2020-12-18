Ubuntu 20.04
============

This one's weird -- for Virtualbox etc. local builds, Ubuntu's new `subiquity`
installer isn't able to see the HTTP server that Packer starts (to grab the
autoinstall files), so you'll see `floppy_files` and `floppy_label` keys in the
manifest. These get attached as a floppy drive, which `subiquity` is able to
pick up on.

See [this discussion on Github](https://github.com/hashicorp/packer/issues/9115)
for more context, and [this
Gist](https://gist.github.com/DVAlexHiggs/03cdbef887736f03dcfe6d1749c18669) from
the [same
discussion](https://github.com/hashicorp/packer/issues/9115#issuecomment-678144803)
for a working example that inspired this one.
