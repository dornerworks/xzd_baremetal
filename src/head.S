/*
Copyright DornerWorks 2016

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
following conditions are met:
1.	 Redistributions of source code must retain the above copyright notice, this list of conditions and the 
following disclaimer.

THIS SOFTWARE IS PROVIDED BY DORNERWORKS FOR USE ON THE CONTRACTED PROJECT, AND ANY EXPRESS OR IMPLIED WARRANTY 
IS LIMITED TO THIS USE. FOR ALL OTHER USES THIS SOFTWARE IS PROVIDED ''AS IS'' AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL DORNERWORKS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


/* Offset of the kernel within the RAM. This is a Linux/zImage convention which we
 * rely on for now.
 */

#define STR(x) #x
#define S_FRAME_SIZE 288
#define S_LR 240
#define S_PC 248

.section .text
.globl _stext

_stext:
	add     x13, x18, #0x16
    b       reset
    /* start of zImage header */
    .quad   0x80000               			// Image load offset from start of RAM
	.quad   _end - _stext         			// Effective size of kernel image
	.quad   0                				// Flags
	.quad   0                               // reserved
	.quad   0                               // reserved
	.quad   0                               // reserved
	.byte   0x41                            // Magic number, "ARM\x64"
	.byte   0x52
	.byte   0x4d
	.byte   0x64
	/* end of zImage header */

/* Called at boot time. Sets up MMU, exception vectors and stack, and then calls C arch_init() function.
 * => x2 -> DTB
 * <= never returns
 * Note: this boot code needs to be within the first (1MB - ZIMAGE_KERNEL_OFFSET) of _stext.
 */
reset:
	/* Problem: the C code wants to be at a known address (_stext), but Xen might
	 * load us anywhere. We initialise the MMU (mapping virtual to physical @ addresses)
	 * so everything ends up where the code expects it to be.
	 *
	 * We calculate the offet between where the linker thought _stext would be and where
	 * it actually is and initialise the page tables to have that offset for every page.
	 *
	 * When we turn on the MMU, we're still executing at the old address. We don't want
	 * the code to disappear from under us. So we have to do the mapping in stages:
	 *
	 * 1. set up a mapping to our current page from both its current and desired addresses
	 * 2. enable the MMU
	 * 3. jump to the new address
	 * 4. remap all the other pages with the calculated offset
	 */

	adr	x1, _stext			/* x1 = physical address of _stext 0x40080000 */
	ldr	x3, =_stext			/* x3 = (desired) virtual address of _stext 0xffffffc000080000 */
	sub 	x9, x1, x3		/* x9 = (physical - virtual) offset 0x4040000000 */
	mov x28, x9

	bl	calc_phys_offset

	bl create_pagetables
	bl start_mmu

	ldr	x2, =stage2			/* Virtual address of stage2 */

	/* Enable MMU / SCTLR */
	msr	SCTLR_EL1, x0		/* SCTLR */
	isb

	br	x2

/*
 * Calculate the start of physical memory.
 */
calc_phys_offset:
	adr	x0, 1f
	ldp	x1, x2, [x0]
	sub	x28, x0, x1				// x28 = PHYS_OFFSET - PAGE_OFFSET
	add	x24, x2, x28			// x24 = PHYS_OFFSET
	ret

	.align 3
1:	.quad	.
	.quad	_boot_stack


/*
 * Stack popping (register pairs only). Equivalent to load increment after.
 */
        .macro  pop, xreg1, xreg2
        ldp     \xreg1, \xreg2, [sp], #16
        .endm

/* Called once the MMU is enabled. The boot code and the page table are mapped,
 * but nothing else is yet.
 *
 * => x2 -> dtb (physical)
 *    x7 = virtual address of page table
 *    x8 = section entry template (flags)
 *    x9 = desired physical - virtual offset
 *    pc -> somewhere in newly-mapped virtual code section
 */
stage2:
	/* Set VBAR -> exception_vector_table 
	 * SCTLR.V = 0 
	 */
	adr	x0, exception_vector_table
	msr	VBAR_EL1, x0

	/* Initialise 16 KB stack */
	ldr x0, =_boot_stack_end
	mov	sp, x0

	sub	x0, x2, x28		/* x0 -> device tree (virtual address) */
	mov	x1, x28			/* x1 = physical_address_offset */

	b	arch_init

/*
 * Entry into OS from exception or IRQ. Needed to properly 
 * switch contexts
 */
	.macro	os_entry
	sub	sp, sp, #S_FRAME_SIZE
	stp	x0, x1, [sp, #16 * 0]
	stp	x2, x3, [sp, #16 * 1]
	stp	x4, x5, [sp, #16 * 2]
	stp	x6, x7, [sp, #16 * 3]
	stp	x8, x9, [sp, #16 * 4]
	stp	x10, x11, [sp, #16 * 5]
	stp	x12, x13, [sp, #16 * 6]
	stp	x14, x15, [sp, #16 * 7]
	stp	x16, x17, [sp, #16 * 8]
	stp	x18, x19, [sp, #16 * 9]
	stp	x20, x21, [sp, #16 * 10]
	stp	x22, x23, [sp, #16 * 11]
	stp	x24, x25, [sp, #16 * 12]
	stp	x26, x27, [sp, #16 * 13]
	stp	x28, x29, [sp, #16 * 14]

	add	x21, sp, #S_FRAME_SIZE
	mrs	x22, elr_el1
	mrs	x23, spsr_el1
	stp	x30, x21, [sp, #S_LR]
	stp	x22, x23, [sp, #S_PC]

	/*
	 * Registers that may be useful after this macro is invoked:
	 *
	 * x21 - aborted SP
	 * x22 - aborted PC
	 * x23 - aborted PSTATE
	*/
	.endm

/*
 * Exit from OS after exception or IRQ handling. Needed to properly 
 * switch contexts
 */
	.macro	os_exit
	ldp	x21, x22, [sp, #S_PC]		// load ELR, SPSR
	
	msr	elr_el1, x21			// set up the return data
	msr	spsr_el1, x22

	ldp	x0, x1, [sp, #16 * 0]
	ldp	x2, x3, [sp, #16 * 1]
	ldp	x4, x5, [sp, #16 * 2]
	ldp	x6, x7, [sp, #16 * 3]
	ldp	x8, x9, [sp, #16 * 4]
	ldp	x10, x11, [sp, #16 * 5]
	ldp	x12, x13, [sp, #16 * 6]
	ldp	x14, x15, [sp, #16 * 7]
	ldp	x16, x17, [sp, #16 * 8]
	ldp	x18, x19, [sp, #16 * 9]
	ldp	x20, x21, [sp, #16 * 10]
	ldp	x22, x23, [sp, #16 * 11]
	ldp	x24, x25, [sp, #16 * 12]
	ldp	x26, x27, [sp, #16 * 13]
	ldp	x28, x29, [sp, #16 * 14]
	ldr	x30, [sp, #S_LR]
	add	sp, sp, #S_FRAME_SIZE		// restore sp
	eret					// return to kernel
	.endm


.pushsection .bss
/* Note: calling arch_init zeroes out this region. */
.align 12
.globl shared_info_page
shared_info_page:
	.fill (1024), 4, 0x0

.align 3
.globl irqstack
.globl irqstack_end
irqstack:
	.fill (1024), 4, 0x0
irqstack_end:

fault_dump:
	.fill 18, 4, 0x0		/* On fault, we save the registers + CPSR + handler address */

.popsection

fault:
	msr daifset, #7		/* Disable interrupts */

	os_entry

	/* bl	dump_registers
	 * b	do_exit
	 */
1:
	b 1b

/* We want to store a unique value to identify this handler, without corrupting
 * any of the registers. So, we store x15 (which will point just after the branch).
 * Later, we subtract 12 so the user gets pointed at the start of the exception
 * handler.
 */
#define FAULT(name)			\
.globl fault_##name;			\
fault_##name:				\
	ldr	x13, =fault_dump;	\
	str	x15, [x13, #17 << 2];	\
	b	fault

FAULT(reset)
FAULT(undefined_instruction)
FAULT(svc)
FAULT(prefetch_call)
FAULT(prefetch_abort)
FAULT(data_abort)

/* exception base address */
.align 5
.globl exception_vector_table
/* Note: remember to call CLREX if returning from an exception:
 * "The architecture enables the local monitor to treat any exclusive store as
 *  matching a previous LDREX address. For this reason, use of the CLREX
 *  instruction to clear an existing tag is required on context switches."
 * -- ARM Cortex-A Series Programmer’s Guide (Version: 4.0)
 */
exception_vector_table:
	b	fault_reset
	b	fault_undefined_instruction
	b	fault_svc
	b	fault_prefetch_call
	b	fault_prefetch_abort
	b	fault_data_abort
	b	irq_handler /* IRQ */
	.word 0xe7f000f0    /* abort on FIQ */

/* Call fault_undefined_instruction in "Undefined mode" */
bug:
	.word	0xe7f000f0    	/* und/udf - a "Permanently Undefined" instruction */

irq_handler:
	os_entry

	ldr	x0, IRQ_handler
	cmp	x0, #0
	beq	bug
	blr	x0		/* call handler */

	/* Return from IRQ */
	os_exit
	clrex
	subs	x30, x30, #4
	ret

.globl IRQ_handler
IRQ_handler:
	.long	0x0

/* This is called if you try to divide by zero. For now, we make a supervisor call,
 * which will make us halt.
 */
.globl raise
raise:
	svc	0

.globl arm_start_thread
arm_start_thread:
	pop	x0, x1
	/* x0 = user data */
	/* x1 -> thread's main function */
	/* ldr	x30, =exit_thread */
	ret	x1

efi_stub_entry:
	/*
	 * Create a stack frame to save FP/LR with extra space
	 * for image_addr variable passed to efi_entry().
	 */
	stp	x29, x30, [sp, #-32]!
