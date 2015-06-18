# Xen Zynq Distribution Bare Metal Guest How To Guide

## Introduction
The XZD Bare Metal guest provides a container for a bare metal application, so it can be used as a Xen guest on the Xilinx Zynq UltraScale+ MPSoC. The container provides virtual memory mapping, a stack, catching faults, and printing to Xen's console. The bare metal application will be limited to the memory that Xen provides it.

## Resources
The source code for the XZD Bare Metal container can be found at: *TBD* 
Instructions on downloading, installing, and sourcing the Petalinux toolset can be found in the XZD User Manual at http://dornerworks.com/wp-content/uploads/2015/04/XilinxXenUsersManual.pdf.

## Bare Metal Guide

### Bare Metal Bootup
The bare metal guest enters into `src/head.S` and initializes everything the guest needs. 

Next, the bare metal guest branches to the `arch_init` function in `src/setup.c`. This is the first C code that gets executed. Here the physical offset is saved to a globabl variable so it can be used for any direct memory writes. Then a hello world message gets printed on Xen's console. This is done using a hypercall. 

After this, the bare metal guest calls the `main` function in `src/main.c`. Here the bare metal guest sits in an infinite loop because there is nothing else of interest for the container to do. 

### Adding a Bare Metal Application to the Container
Code can be modified in the `src/setup.c` and `src/main.c` and the application should begin at the `main` function. Any new C file can be added to the `src` directory and the Makefile will include it in the build without modifying any Makefiles or config files. The `include` directory is the only include directory, so that is where header files should be placed. 

Because of the nature of Xen, the bare metal guest only has access to it's memory and nothing else. There are a couple of options to get access to a device: 

**Direct Passthrough** - This gives a guest direct and exclusive access to a device. Information on device passthrough can be found in the XZD User Manual.

**Paravirtualized Devices** - Dom0 provides a front-end for some devices. To talk to these, a back-end needs to be implemented in the bare metal. This requires support for the Xenstore, event channels, shared memory, and all of the related Hypercalls. Instead of implementing all of these, it may be easier to use MiniOS as a container for the bare metal application instead. It takes up more space, but it has all of these PV drivers implemented.  

### Building the Guest Image
To build the bare metal image, run the following command:

```bash
$ make CROSS_COMPILE=aarch64-linux-gnu-
```

This generates an `xzd_bare` ELF file and an `xzd_bare.img` binary image. The binary image is the file that will be used as the `kernel` for the Xen guest. The ELF file can be used for debugging the bare metal guest. 

### Installing and Booting the Guest Image in the XZD
Install the `xzd_bare.img` kernel as described in the XZD user manual. Then create a configuration file for the bare metal guest.

Example Configuration File (/etc/xen/bare.cfg):
```
name = "bare"
kernel = "/root/xzd_bare.img"
memory = 128
vcpus = 1
```

Boot up the XZD and in Dom0 start up the bare metal guest with the following command:

```bash
$ xl create -c /etc/xen/bare.cfg
```

## Troubleshooting
For more help, visit http://dornerworks.com/services/xilinxxen
