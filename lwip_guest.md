# Xen Zynq Distribution (XZD) lwIP Echo Server Guest 

Revision: `Beta_04_01_2016`

## Introduction 
This 'how-to' demonstrates how to port an application to the XZD Bare Metal container and used as as guest on a Zynq MPSoC running XZD. The "lwIP Echo Server" application from Xilinx's SDK is ported to the bare metal container. In addition CPU time and RAM, the application requires a UART, Gigabit Ethernet Controller (GEM), and a Triple-Timer Counter (TTC) which will be provided as passthrough devices to the guest.

## Resources 
- Xilinx SDK, 2015.4
- petalinux-2015.4
- https://github.com/dornerworks/xzd_baremetal
	- bm_enet branch
- https://github.com/dornerworks/lwip_update
- ZCU102 development board,Rev A, with appropriate USB-UART and USB-JTAG cables
- 8GB SD card
- Ethernet cable

## lwIP Echo Server Guest Guide 

### Installing and Booting Guest
1. Follow UM instructions for creating an SD card with XZD filesystem on it.
1. Mount SD card on host machine.
1. Copy `xzd_bare.img` to mounted SD card. 
1. Copy `bare_enet.cfg` to same directory as `xzd_bare.img` on SD card.
1. Eject SD card.
1. Insert SD card into slot on ZCU102 development board. 
2. Copy `xen.dtb` to your local tftp directory, presumably `/tftpboot`
1. Boot ZCU102-Rev A following procedure in UM.
2. Open a serial connection to the first two serial devices on the quad-uart cable.
1. Login to dom0 following UM procedures via the first serial connection.
2. `cd` to location of `bare_enet.cfg`.
3. `$ xl create bare_enet.cfg`

The guest application is now running and should be displaying something similar to:

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

Connecting to the IP address at port 7 via `telnet` or `nc` will result in data sent to the target to be echoed back to the sender.


## Building lwIP Echo Server Guest

### Overview of Components
- lwip.elf : Built by the Xilinx SDK, used as an input into xzd_baremetal
	- Modified to avoid using privileged instructions and to use correct addresses for DMA transactions.
- xzd_bare.img : The application payload and start-up/initialization code. 

The `xzd_bare.img` file is referenced by the `bare_enet.cfg` configuration file. 

### Building components

#### Building lwip.elf
Assumes Xilinx SDK has been installed and is running.

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
3. Select `lwIP Echo Server` and click on `Finish`.
4. Copy files from https://github.com/dornerworks/lwip_update over existing ones in the Xilinx SDK workspace.
5. In Xilinx SDK, `Ctrl+B` to rebuild.
6. Copy the `lwip.elf` In the Xilinx SDK workspace under lwip/Debug 

#### Building xzd_bare
1. `git clone https://github.com/dornerworks/xzd_baremetal`
2. `cd xzd_baremetal`
3. `git checkout bm_enet`
3. Copy `lwip.elf` from `[your Xilinx SDK workspace]/lwip/Debug/` to this directory
4. `source [your petalinux-2015.4 directory]/settings.sh`
5. `aarch64-none-elf-objcopy -O binary lwip.elf lwip.bin`
5. `aarch64-none-elf-objcopy -I binary -O elf64-littleaarch64 -B 
aarch64 --rename .data=.payload\_data --redefine-sym \_binary\_lwip\_bin\_start=\_payload\_start --redefine-sym \_binary\_lwip\_bin\_end=_payload\_end --redefine-sym \_binary\_lwip\_bin\_size=\_payload\_size lwip.bin payload.o`
6. `make CROSS_COMPILE=aarch64-none-elf-`

A new version of `xzd_bare.img` will now be available in the directory that can be copied to an SD card for execution on target.

####

## Troubleshooting
For more help, visit [http://dornerworks.com/services/xilinxxen](http://dornerworks.com/services/xilinxxen)