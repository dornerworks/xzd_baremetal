# Xen Zynq Distribution (XZD) lwIP Echo Server Guest 

Revision: `Beta_04_01_2016`

## Introduction 
This How-To documents porting an application to the XZD Bare Metal container to be used as as guest on a Zynq MPSoC running Xen. The target application for this How-To is Xilinx's "lwIP Echo Server" application found on their SDK 2015.4 version. This application was chosen because in addition to CPU time and RAM, the "lwIP Echo Server" also requires a UART, Gigabit Ethernet Controller (GEM), and a Triple-Timer Counter (TTC), providing the opportunity to demonstrate configuring those peripherals as passthrough devices assigned to the guest.

## Resources 
- XZD User's Manual, <http://dornerworks.com/wp-content/uploads/2016/02/XilinxXenUsersManual.pdf>
- Xilinx SDK, 2015.4 (see <www.xilinx.com> for more details)
- Xilinx petalinux-2015.4 (see <www.xilinx.com>  for more details)
- XZD Bare Metal container, <https://github.com/dornerworks/xzd_baremetal>
	- bm_enet branch
- Updates to the lwIP Echo Server application, <https://github.com/dornerworks/lwip_update>
- ZCU102 development board,Rev A, with appropriate USB-UART and USB-JTAG cables
- 8GB SD card
- Ethernet cable

## lwIP Echo Server Guest Guide

### Guest Boot Sequence
As described in previous Bare Metal How-To's, the sequence for starting up a guest on a Xen-based system goes through _dom0_'s command line via the `xl create <configuration>` command, part of xl toolstack. This command parses the configuration file to generates the necessary hypercalls to Xen which creates the guest's memory space, configures the SMMU, and copies the bare metal image into that memory space using information provided in the image's header.

The bare metal guest enters into `src/head.S` and initializes everything the guest needs. This includes mapping register space for the peripheral devices and the interrupt controller (GIC) interfaces to allow the application to use. A 4MB block of RAM is also mapped so the lwIP Echo Server can run at a known virtual address, which for this example was mapped 1:1 with the intermediate physical address at 0x40400000.

Next, the bare metal guest branches to the `arch_init` function in `src/setup.c`. This is the first C code that gets executed. Here the physical offset is saved to a global variable so it can be used for any direct memory writes. Then a message gets printed on Xen's console. This is done using the `console_io` hypercall. This call places a length and a character buffer in the correct registers and then interrupts into Xen. Xen then prints that buffer onto its own console. 

After this, the bare metal guest calls the `main` function in `src/main.c`. Here the bare metal guest copies the application payload to 0x40400000 and passes execution to it. At this point the modified lwIP Echo Server code is running.


### Installing and Using lwIP Echo Server Guest
1. Populate an 8GB SD card with the XZD filesystem per the User Manual section 4.2, step 1.
1. Mount SD card on host machine.
1. Copy `xzd_bare.img` to the mounted SD card. 
1. Copy `bare_enet.cfg` to the same directory as `xzd_bare.img` on the SD card.
1. Eject SD card.
1. Copy `xen.dtb` to your local tftp directory, presumably `/tftpboot`
1. Boot the ZCU102-Rev A board following user Manual instructions in section 4.2, steps 3 through.
1. Connect to the second serial connection using terminal program of your choice
	1. For example, if first serial connection for _dom0_ was found on COM4, then the second serial connection is most likely on COM5.		
1. Once logged into _dom0_, execute the following:
	1. `cd <location of bare_enet.cfg>`
	1. `$ xl create bare_enet.cfg`

The guest application is now running and should be displaying something similar to on the second serial connection:

    -----lwIP TCP echo server ------
    TCP packets sent to port 6001 will be echoed back
    Start PHY autonegotiation
    Waiting for PHY to complete autonegotiation.
    autonegotiation complete
    link speed for phy address 21: 1000
    Board IP: 172.27.13.180
    Netmask : 255.255.0.0
    Gateway : 172.27.0.12
    TCP echo server started @ port 7

Any data sent to the IP address above at port 7 will be echoed back to the sender. This can be tested with programs like `telnet` or `nc`.


## Building lwIP Echo Server Guest

### Overview of Components
- lwip.elf : Built by the Xilinx SDK, used as an input into xzd_baremetal
	- Modified to avoid using instructions with a higher privilege than EL1 (mostly in boot.S),  to use correct addresses for DMA transactions with the GEM driver, and to work around some timing issues with the lwIP code base for ZynqMP in 2015.4.
- xzd_bare.img : The application payload and start-up/initialization code. 
- xen.dtb : Device Tree Blob, updated configuration for Xen and _dom0_ for passthrough devices
- bare_enet.cfg : XL configuration file defining the location of the bare metal image, the amount of memory to allocate to it, the VCPU to assign it to, and the passthrough configuration data.
  - Example: 
```
name = "bare1"
kernel = "xzd_bare.img"
memory = 8
vcpus = 1
cpus = [1]
dtdev = [ "/amba/serial@ff010000","/amba/ethernet@ff0e0000", "/amba/timer@ff110000" ]
irqs = [ 54, 95, 68, 69, 70 ]
iomem = [ "0xff010,1", "0xff0e0,1", "0xff110,1" ]
```

The `xzd_bare.img` file is referenced by the `bare_enet.cfg` configuration file. 

### Building lwip.elf
These instructions assumes that Xilinx SDK and petalinux have been installed on a Linux host machine.

1. Start Xilinx SDK, `$ xsdk`
2. File -> New -> Application Project (`Alt+Shift+n`)
	1. `Project name:`, enter `lwip`
	2. `OS Platform:`, select `standalone`
	3. `Hardware Platform:`, select `ZynqMP_ZCU102_hw_platform(pre-defined)`
	4. `Processor:`, select `psu_cortexa53_0`
	5. `Language:`, click the `C` radio button
	6. `Compiler:`, select `64-bit`
	7. `Board Support Package:`, click `Create New` and use default name of `lwip_bsp`
	8. Click on `Next >`
3. Select `lwIP Echo Server` and click on `Finish`
4. Copy files from https://github.com/dornerworks/lwip_update over existing ones in the Xilinx SDK workspace
5. In Xilinx SDK, `Ctrl+B` to rebuild

### Building xzd_bare.img
1. `git clone https://github.com/dornerworks/xzd_baremetal`
2. `cd xzd_baremetal`
3. `git checkout bm_enet`
4. Copy `lwip.elf` from `[your Xilinx SDK workspace]/lwip/Debug/` to this directory
5. `source [your petalinux-2015.4 directory]/settings.sh`
6. `aarch64-none-elf-objcopy -O binary lwip.elf lwip.bin`
7. 
`aarch64-none-elf-objcopy -I binary -O elf64-littleaarch64 -B aarch64 --rename .data=.payload\_data`
`--redefine-sym \_binary\_lwip\_bin\_start=\_payload\_start`
`--redefine-sym \_binary\_lwip\_bin\_end=\_payload\_end`
`--redefine-sym \_binary\_lwip\_bin\_size=\_payload\_size lwip.bin ~/xzd\_baremetal/payload.o`

8. `make CROSS_COMPILE=aarch64-none-elf-`

This generates an `xzd_bare` ELF and a new `xzd_bare.img` binary image, which can be copied  to an SD card for deployment on target.

####

## Troubleshooting

For more help, visit [http://dornerworks.com/services/xilinxxen](http://dornerworks.com/services/xilinxxen)