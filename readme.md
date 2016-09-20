## Overview ##

This project provides a means to take an arbitrary application that:

- Is in an ELF file format
- Runs at EL1 or EL0
- Uses less than 4MB of memory 
and transform it into a Xen guest.

Simply run `build_it` targetting the ELF file you want to run as a Xen guest. 

See [https://github.com/dornerworks/xzd_baremetal/blob/master/docs/index.md ](https://github.com/dornerworks/xzd_baremetal/blob/master/docs/index.md)for more details.


## Releases ##

**v2.0.0.0**
 
- BMC helper functions
  - map_memory : Add VA to IPA entries to the MMU table
  - xen_print : Print to the Xen debug console

- Replacement of GPLv2 with FreeBSD code.


## Branches ##

For most of your Bare Metal Container needs, the `master` branch is what you want. DornerWorks retains other branches in order to support various examples or to experiment with a a feature. Any branch other than `master` can and will be deleted without notice.

## Requirements ##
- Python 2.7 or 3.4 
- mkdocs: `pip install mkdocs`
