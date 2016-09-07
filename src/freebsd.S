/*-
 * Copyright (c) 2012-2014 Andrew Turner
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 * $FreeBSD$
 */
 /*
Copyright DornerWorks 2016

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
following conditions are met:
1.	 Redistributions of source code must retain all above copyright notice(s), this list of conditions and the 
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
#define L0_SHIFT 39
#define L1_SHIFT 30
#define L2_SHIFT 21
#define L3_SHIFT 12

#define L2_SIZE  (1<<L2_SHIFT)

#define Ln_ADDR_MASK 0x1FF
#define L2_BLOCK_MASK (-(1<<L2_SHIFT))


#define L0_TABLE 	0x3
#define L1_TABLE 	0x3
#define L2_TABLE 	0x3

#define L1_BLOCK 	1
#define L2_BLOCK 	1

#define	DEVICE_MEM	0
#define	NORMAL_UNCACHED	1
#define	NORMAL_MEM	2
#define ATTR_AF 	(1<<10)

#define PAGE_SHIFT						12
#define PAGE_SIZE						(1 << PAGE_SHIFT)
#define VIRT_BITS						39


#define MAIR_ATTR(attr, mt)	((attr) << ((mt) * 8))


#define TCR_TxSZ(x)		(((x) << 16) |  (x) )
#define TCR_IRGN_WBWA	((1 << 8) | (1 << 24))
#define TCR_ORGN_WBWA	((1 << 10) | (1 << 26))
#define TCR_SHARED		((3 << 12) | (3 << 28))
#define TCR_TG0_4K		(0 << 14)
#define TCR_TG0_64K		(1 << 14)
#define TCR_TG1_4K		(2 << 30)
#define TCR_TG1_64K		(3 << 30)
#define TCR_ASID_16		(1 << 36)
#define TCR_TBI0		(1 << 37)
#define TCR_SMP_ATTRS	TCR_SHARED

/* PTWs cacheable, inner/outer WBWA */
#define TCR_CACHE_ATTRS	TCR_IRGN_WBWA | TCR_ORGN_WBWA
#define SCTLR_UCI	(1<<26)
#define SCTLR_EE 	(1<<25)
#define SCTLR_EOE	(1<<24)
#define SCTLR_WXN	(1<<19)
#define SCTLR_nTWE	(1<<18)
#define SCTLR_nTWI	(1<<16)
#define SCTLR_UCT	(1<<15)
#define SCTLR_DZE	(1<<14)
#define SCTLR_I    	(1<<12)
#define SCTLR_UMA	(1<<9)
#define SCTLR_SED	(1<<8)
#define SCTLR_ITD	(1<<7)
#define SCTLR_THEE	(1<<6)			//marked as reserved in the ARMv8 Arch Ref Man
#define SCTLR_CP15BEN	(1<<5)
#define SCTLR_SA0	(1<<4)
#define SCTLR_SA  	(1<<3)
#define SCTLR_C 	(1<<2)
#define SCTLR_A  	(1<<1)
#define SCTLR_M 	(1<<0)

.globl  create_pagetables
.globl	start_mmu

create_pagetables:
	/* Save the Link register */
	mov	x5, x30

	/* Clean the page table */
	ldr	x6, =init_page_table
	add x6, x6, x28
	mov	x26, x6
	ldr x27, =init_page_table_end
	add x27, x27, x28
1:
	stp	xzr, xzr, [x6], #16
	stp	xzr, xzr, [x6], #16
	stp	xzr, xzr, [x6], #16
	stp	xzr, xzr, [x6], #16
	cmp	x6, x27
	b.lo	1b

#if 1
	/* Find the size of the kernel */
	adr	x6, _boot_stack
	adr	x7, _end
	// round up if necessary, 
	//					(addr + L2_SIZE - 1) >> L2_SHIFT rounds down to addr/L2_SIZE if add%L2_SIZE == 0
	//					but if addr$L2_SIZE != 0, then (addr + L2_SIZE-1) >> L2_SHIFT rounds up to (addr/L2_SIZE)+1	
	mov x8, #(L2_SIZE-1)
	add x7, x7, x8
	
	lsr x6, x6, #(L2_SHIFT)
	lsr x7, x7, #(L2_SHIFT)
	/* Find the end - begin */
	sub	x4, x7, x6
#endif 

	/*
	 * Build the TTBR1 maps.
	 */


	/*
	 * Map the BMC starting at PHYS_OFFSET
	 */
	mov	x6, x26						// pagetable[0]
	mov	x7, #NORMAL_MEM				// 0x2
	ldr	x8, =_text					// VA = .text section 
	mov	x9, x24						// PA = PHYS_OFFSET, determined in __calc_phys_offset
									//x10, number of 2MB blocks

	mov x10, x4
	bl	build_l2_block_pagetable

	/* Move to the l1 table */
	add	x26, x26, #PAGE_SIZE

	/* Link the l1 -> l2 table */
									//x8, VA, still set to _text
	mov	x9, x6 						// L2 PA, pagetable[0]
	mov	x6, x26						// pagetable[1]
	bl	link_l1_pagetable

	// x26 used for ttbr1_el1

	/*
	 * Build the TTBR0 maps.
	 */
	add	x27, x26, #PAGE_SIZE		// pagetable[2]



	// Map ??
	mov	x6, x27						// L2 table
	mov x7, #NORMAL_UNCACHED		// 0x2
	adr x8, _boot_stack				// VA
	mov x9, x8						// PA = VA
	mov x10, x4
	bl build_l2_block_pagetable

	// need 2 MB for additional page tables later
	mov	x6, x27						// L2 table
	mov	x7, #NORMAL_MEM 			// 0x2
	ldr	x8, =0x40200000				// VA
	mov x9, x8						// PA = VA
	mov x10, #1						// Rounds up to 4 MB
	bl	build_l2_block_pagetable

	/* Move to the l1 table */
	add	x27, x27, #PAGE_SIZE		// pagetable[3]

	/* Link the l1 -> l2 table */
									//x8, VA, still set to .text
	mov	x9, x6 						// L2 PA, pagetable[2]
	mov	x6, x27						// pagetable[3]
	bl	link_l1_pagetable

	// x27 used for ttbr0_el1

	/* Restore the Link register */
	mov	x30, x5
	ret


/*
 * Builds an L1 -> L2 table descriptor
 *
 * This is a link for a 1GiB block of memory with up to 2MiB regions mapped
 * within it by build_l2_block_pagetable.
 *
 *  x6  = L1 table
 *  x8  = Virtual Address
 *  x9  = L2 PA (trashed)
 *  x11, x12 and x13 are trashed
 */
link_l1_pagetable:
	/*
	 * Link an L1 -> L2 table entry.
	 */
	/* Find the table index */
	lsr	x11, x8, #L1_SHIFT
	and	x11, x11, #Ln_ADDR_MASK

	/* Build the L1 block entry */
	mov	x12, #L1_TABLE

	/* Only use the output address bits */
	lsr	x9, x9, #PAGE_SHIFT
	orr	x13, x12, x9, lsl #PAGE_SHIFT

	/* Store the entry */
	str	x13, [x6, x11, lsl #3]

	ret
/*
 * Builds count 2 MiB page table entry
 *  x6  = L2 table
 *  x7  = Type (0 = Device, 1 = Normal)
 *  x8  = VA start
 *  x9  = PA start (trashed)
 *  x10 = Entry count
 *  x11, x12 and x13 are trashed
 */
 #define	ATTR_SH(x)	((x) << 8)
 #define	 ATTR_SH_IS	3		/* Inner-shareable */

build_l2_block_pagetable:
	/*
	 * Build the L2 table entry.
	 */
	/* Find the table index */
	lsr	x11, x8, #L2_SHIFT
	and	x11, x11, #Ln_ADDR_MASK

	/* Build the L2 block entry */
	lsl	x12, x7, #2
	orr	x12, x12, #L2_BLOCK
	orr	x12, x12, #(ATTR_AF)
	orr	x12, x12, ATTR_SH(ATTR_SH_IS)

	/* Only use the output address bits */
	lsr	x9, x9, #L2_SHIFT

	/* Set the physical address for this virtual address */
1:	orr	x13, x12, x9, lsl #L2_SHIFT

	/* Store the entry */
	str	x13, [x6, x11, lsl #3]

	sub	x10, x10, #1
	add	x11, x11, #1
	add	x9, x9, #1
	cbnz	x10, 1b

	ret

start_mmu:
	dsb	sy

#if 0
	/* Load the exception vectors */
	ldr	x2, =exception_vectors
	msr	vbar_el1, x2
#endif

	/* Load ttbr0 and ttbr1 */
	msr	ttbr0_el1, x27
	msr	ttbr1_el1, x26
	isb

	/* No traps from floating point or advanced SIMD */
	mov	x0, #3 << 20
	msr	cpacr_el1, x0			
	
	/* Clear the Monitor Debug System control register */
	msr	mdscr_el1, xzr

	/* Invalidate the TLB */
	tlbi	vmalle1is


	/* set up memory attributes */
	ldr	x2, mair
	msr	mair_el1, x2

	/*
	 * Setup TCR according to PARange bits from ID_AA64MMFR0_EL1.
	 */
	ldr	x2, tcr
	mrs	x3, id_aa64mmfr0_el1
	bfi	x2, x3, #32, #3
	msr	tcr_el1, x2

	/* Setup SCTLR */
	ldr	x2, sctlr_set
	ldr	x3, sctlr_clear
	mrs	x1, sctlr_el1
	bic	x1, x1, x3	/* Clear the required bits */
	orr	x1, x1, x2	/* Set the required bits */
	mov x0, x1 		/* save off in x0 to be used in calling function */

	isb
	
	ret

	.align 3

mair:
	/* Device            Normal, no cache     Normal, write-back */
	.quad	MAIR_ATTR(0x00, 0) | MAIR_ATTR(0x44, 1) | MAIR_ATTR(0xff, 2)
tcr:
	.quad (TCR_TxSZ(64 - VIRT_BITS) | TCR_ASID_16 | TCR_TG1_4K | \
	    TCR_CACHE_ATTRS | TCR_SMP_ATTRS | TCR_TBI0)

sctlr_set:
	/* Bits to set */
	.quad (SCTLR_UCI | SCTLR_nTWE | SCTLR_nTWI | SCTLR_UCT | SCTLR_DZE | \
	    SCTLR_I | SCTLR_SED | SCTLR_SA0 | SCTLR_SA | SCTLR_C | SCTLR_M)
sctlr_clear:
	/* Bits to clear */
	.quad (SCTLR_EE | SCTLR_EOE | SCTLR_WXN | SCTLR_UMA | SCTLR_ITD | \
	    SCTLR_THEE | SCTLR_CP15BEN | SCTLR_A)
#if 0
pagetable:				// ttbr1, L2
	.space	PAGE_SIZE
pagetable_l1_ttbr1:		// ttbr1, L1
	.space	PAGE_SIZE
pagetable_l2_ttbr0:		// ttbr0, L2
	.space	PAGE_SIZE
pagetable_l1_ttbr0:		// ttbr0, L1
	.space	PAGE_SIZE
pagetable_end:
#endif