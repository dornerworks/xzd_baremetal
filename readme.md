## Overview ##

This project provides a means to take an arbitrary application that:

- Is in an ELF file format
- Runs at EL1 or EL0
- Uses less than 4MB of memory 
- Is linked to, or can otherwise run at, address 0x40400000

and make it so it can run as a Xen guest. Note that the XZD Bare Metal Container (BMC) does some minimal memory mapping to, notably the 4MB starting at 0x40400000, but if the guest is to use passed through peripherals or other memory regions than those addresses must be:

1. Mapped by Xen, allowing the guest IPA to map to the real PA.
1. Mapped by the guest, allowing the application to access a VA that maps to the IPA (that maps to the PA).


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
