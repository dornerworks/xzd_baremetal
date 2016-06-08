/******************************************************************************
 *
 * (c) Copyright 2014 Xilinx, Inc. All rights reserved.
 *
 * This file contains confidential and proprietary information  of Xilinx, Inc.
 * and is protected under U.S. and  international copyright and other
 * intellectual property  laws.
 *
 * DISCLAIMER
 * This disclaimer is not a license and does not grant any  rights to the
 * materials distributed herewith. Except as  otherwise provided in a valid
 * license issued to you by  Xilinx, and to the maximum extent permitted by
 * applicable law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND  WITH ALL
 * FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES  AND CONDITIONS, EXPRESS,
 * IMPLIED, OR STATUTORY, INCLUDING  BUT NOT LIMITED TO WARRANTIES OF
 * MERCHANTABILITY, NON-  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE;
 * and
 * (2) Xilinx shall not be liable (whether in contract or tort,  including
 * negligence, or under any other theory of liability) for any loss or damage
 * of any kind or nature  related to, arising under or in connection with these
 * materials, including for any direct, or any indirect,  special, incidental,
 * or consequential loss or damage  (including loss of data, profits,
 * goodwill, or any type of  loss or damage suffered as a result of any
 * action brought  by a third party) even if such damage or loss was
 * reasonably foreseeable or Xilinx had been advised of the  possibility
 * of the same.
 *
 * CRITICAL APPLICATIONS
 * Xilinx products are not designed or intended to be fail-  safe, or for use
 * in any application requiring fail-safe  performance, such as life-support
 * or safety devices or  systems, Class III medical devices, nuclear
 * facilities,  applications related to the deployment of airbags, or any
 * other applications that could lead to death, personal  injury, or severe
 * property or environmental damage  (individually and collectively,
 * "Critical  Applications"). Customer assumes the sole risk and  liability
 * of any use of Xilinx products in Critical  Applications, subject only to
 * applicable laws and  regulations governing limitations on product liability.
 *
 * THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS  PART
 * OF THIS FILE AT ALL TIMES.
 *
 ******************************************************************************/
/*
  PMU - PCW handoff file
  Auto generated file from PCW-Vivado tools to be consumed in PMU firmware  
*/


#define XPFW_CFG_MASTER_APU                                     0
#define XPFW_CFG_MASTER_RPU                                     1
#define XPFW_CFG_MASTER_PMU                                     2
#define XPFW_CFG_MASTER_CSU                                     3
#define XPFW_CFG_MASTER_S_AXI_HP1_FPD                           4
#define XPFW_CFG_MASTER_S_AXI_HP2_FPD                           5
#define XPFW_CFG_MASTER_S_AXI_HP3_FPD                           6
#define XPFW_CFG_MASTER_S_AXI_LPD                               7
#define XPFW_CFG_MASTER_MAX                                     8

#define XPFW_CFG_SLAVE_DDR                                     0
#define XPFW_CFG_SLAVE_OCM                                     1
#define XPFW_CFG_SLAVE_PCIe                                    2
#define XPFW_CFG_SLAVE_SATA                                    3
#define XPFW_CFG_SLAVE_GPU                                     4
#define XPFW_CFG_SLAVE_DPORT                                   5
#define XPFW_CFG_SLAVE_QSPI_Linear_Address                     6
#define XPFW_CFG_SLAVE_UART0                                   7
#define XPFW_CFG_SLAVE_UART1                                   8
#define XPFW_CFG_SLAVE_I2C0                                    9
#define XPFW_CFG_SLAVE_I2C1                                    10
#define XPFW_CFG_SLAVE_SPI0                                    11
#define XPFW_CFG_SLAVE_SPI1                                    12
#define XPFW_CFG_SLAVE_CAN0                                    13
#define XPFW_CFG_SLAVE_CAN1                                    14
#define XPFW_CFG_SLAVE_GPIO                                    15
#define XPFW_CFG_SLAVE_GEM0                                    16
#define XPFW_CFG_SLAVE_GEM1                                    17
#define XPFW_CFG_SLAVE_GEM2                                    18
#define XPFW_CFG_SLAVE_GEM3                                    19
#define XPFW_CFG_SLAVE_QSPI                                    20
#define XPFW_CFG_SLAVE_NAND                                    21
#define XPFW_CFG_SLAVE_TTC0                                    22
#define XPFW_CFG_SLAVE_TTC1                                    23
#define XPFW_CFG_SLAVE_TTC2                                    24
#define XPFW_CFG_SLAVE_TTC3                                    25
#define XPFW_CFG_SLAVE_SWDT                                    26
#define XPFW_CFG_SLAVE_SD0                                     27
#define XPFW_CFG_SLAVE_SD1                                     28
#define XPFW_CFG_SLAVE_IOU_SLCR                                29
#define XPFW_CFG_SLAVE_IOU_SECURE_SLCR                         30
#define XPFW_CFG_SLAVE_IOU_SCNTR                               31
#define XPFW_CFG_SLAVE_IOU_SCNTRS                              32
#define XPFW_CFG_SLAVE_IPI                                     33
#define XPFW_CFG_SLAVE_LPD_SLCR                                34
#define XPFW_CFG_SLAVE_LPD_SLCR_SECURE                         35
#define XPFW_CFG_SLAVE_CRL_APB                                 36
#define XPFW_CFG_SLAVE_OCM_SLCR                                37
#define XPFW_CFG_SLAVE_LPD_XPPU                                38
#define XPFW_CFG_SLAVE_RPU                                     39
#define XPFW_CFG_SLAVE_AFIFM6                                  40
#define XPFW_CFG_SLAVE_LPD_XPPU_SINK                           41
#define XPFW_CFG_SLAVE_USB3_0                                  42
#define XPFW_CFG_SLAVE_USB3_1                                  43
#define XPFW_CFG_SLAVE_APM0                                    44
#define XPFW_CFG_SLAVE_APM1                                    45
#define XPFW_CFG_SLAVE_AMS                                     46
#define XPFW_CFG_SLAVE_RTC                                     47
#define XPFW_CFG_SLAVE_OCM_XMPU_CFG                            48
#define XPFW_CFG_SLAVE_ADMA_0                                  49
#define XPFW_CFG_SLAVE_ADMA_1                                  50
#define XPFW_CFG_SLAVE_ADMA_2                                  51
#define XPFW_CFG_SLAVE_ADMA_3                                  52
#define XPFW_CFG_SLAVE_ADMA_4                                  53
#define XPFW_CFG_SLAVE_ADMA_5                                  54
#define XPFW_CFG_SLAVE_ADMA_6                                  55
#define XPFW_CFG_SLAVE_ADMA_7                                  56
#define XPFW_CFG_SLAVE_CSU_ROM                                 57
#define XPFW_CFG_SLAVE_CSU_LOCAL                               58
#define XPFW_CFG_SLAVE_PUF                                     59
#define XPFW_CFG_SLAVE_CSU_RAM                                 60
#define XPFW_CFG_SLAVE_CSU_IOMODULE                            61
#define XPFW_CFG_SLAVE_CSUDMA                                  62
#define XPFW_CFG_SLAVE_CSU                                     63
#define XPFW_CFG_SLAVE_CSU_WDT                                 64
#define XPFW_CFG_SLAVE_EFUSE                                   65
#define XPFW_CFG_SLAVE_BBRAM                                   66
#define XPFW_CFG_SLAVE_RSA_CORE                                67
#define XPFW_CFG_SLAVE_MBISTJTAG                               68
#define XPFW_CFG_SLAVE_PMU_ROM                                 69
#define XPFW_CFG_SLAVE_PMU_IOMODULE                            70
#define XPFW_CFG_SLAVE_PMU_LOCAL                               71
#define XPFW_CFG_SLAVE_PMU_GLOBAL                              72
#define XPFW_CFG_SLAVE_PMU_RAM                                 73
#define XPFW_CFG_SLAVE_R5_0_ATCM                               74
#define XPFW_CFG_SLAVE_R5_0_ATCM_lockstep                      75
#define XPFW_CFG_SLAVE_R5_0_BTCM                               76
#define XPFW_CFG_SLAVE_R5_0_BTCM_lockstep                      77
#define XPFW_CFG_SLAVE_R5_0_Instruction_Cache                  78
#define XPFW_CFG_SLAVE_R5_0_Data_Cache                         79
#define XPFW_CFG_SLAVE_R5_1_ATCM                               80
#define XPFW_CFG_SLAVE_R5_1_BTCM                               81
#define XPFW_CFG_SLAVE_R5_1_Instruction_Cache                  82
#define XPFW_CFG_SLAVE_R5_1_Data_Cache                         83
#define XPFW_CFG_SLAVE_IOU_GPV                                 84
#define XPFW_CFG_SLAVE_LPD_GPV                                 85
#define XPFW_CFG_SLAVE_USB3_0_XHCI                             86
#define XPFW_CFG_SLAVE_USB3_1_XHCI                             87
#define XPFW_CFG_SLAVE_Coresight                               88
#define XPFW_CFG_SLAVE_IPI0                                    89
#define XPFW_CFG_SLAVE_IPI1                                    90
#define XPFW_CFG_SLAVE_IPI2                                    91
#define XPFW_CFG_SLAVE_IPI3                                    92
#define XPFW_CFG_SLAVE_IPI4                                    93
#define XPFW_CFG_SLAVE_IPI5                                    94
#define XPFW_CFG_SLAVE_IPI6                                    95
#define XPFW_CFG_SLAVE_IPI7                                    96
#define XPFW_CFG_SLAVE_IPI8                                    97
#define XPFW_CFG_SLAVE_IPI9                                    98
#define XPFW_CFG_SLAVE_IPI10                                   99
#define XPFW_CFG_SLAVE_MAX                                     100

/* MASTER LIST 
Shared resources like DDR will be powered off by the PMUFW, if no active user for such a resource is present. In order to be able to determine whether no user is present, 
PMUFW needs to be aware of all possible users. These include:
1.  APU  / Independent A53s
2.  RPU lockstep/independent
3.  PL Soft-Cores
So a list of all active Masters in the System should be exported to PMU FW */
unsigned char XPfw_ConfigActMasters[XPFW_CFG_MASTER_MAX] = {'1','1','1','1','1','1','1','1'};

/* SLAVE LIST
It is expected that unused resources are statically turned off by the FSBL during boot. Everything else that is used during run-time needs to be known to the
PMUFW in order to execute PM-related functionality on it. So a list of all active slaves on the system should be exported to the PMU FW */ 
unsigned char XPfw_ConfigActSlaves[XPFW_CFG_SLAVE_MAX] = 
{'1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1'};

/* Ownership Information
PMU_Master_Slave_Isolation[C_MASTER_PSS_CORTEX_APU][PSS_DDR_0] = 1 */
unsigned char XPfw_ConfigTable[XPFW_CFG_MASTER_MAX][XPFW_CFG_SLAVE_MAX] = {
{'1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0','0','0','0','0'} ,
{'1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','1','1','0','0','0','0','0','0','0','0'} ,
{'1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','1','1','1','1','0','0','0','0'} ,
{'1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0','0','0','0','0','0'} ,
{'1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0','0','1','0','0','0'} ,
{'1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0','0','0','1','0','0'} ,
{'1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0','0','0','0','1','0'} ,
{'1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','0','0','0','0','0','0','0','0','0','0','1'} ,
};
