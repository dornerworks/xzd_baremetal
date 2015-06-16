/* Offset of the kernel within the RAM. This is a Linux/zImage convention which we
 * rely on for now.
 */

#include <page.h>

#define ZIMAGE_KERNEL_OFFSET 0x8000
#define EL1_MEM_ATTR_MASK   0b1001101011000000
#define EL1_MEM_ATTR_FLAGS  0b0110010100000000

#define S_FRAME_SIZE 288
#define S_LR 240
#define S_PC 248


#define CONFIG_ARM64_VA_BITS 39
#define VA_BITS			(CONFIG_ARM64_VA_BITS)
#define CONFIG_SMP


#define PTRS_PER_PTE		(1 << (PAGE_SHIFT - 3))


	.macro	pgtbl, ttb0, ttb1, virt_to_phys
	ldr	\ttb1, =swapper_pg_dir
	ldr	\ttb0, =idmap_pg_dir
	add	\ttb1, \ttb1, \virt_to_phys
	add	\ttb0, \ttb0, \virt_to_phys
	.endm

/*
 * PMD_SHIFT determines the size a level 2 page table entry can map.
 */
#if CONFIG_ARM64_PGTABLE_LEVELS > 2
#define PMD_SHIFT		((PAGE_SHIFT - 3) * 2 + 3)
#define PMD_SIZE		(1 << PMD_SHIFT)
#define PMD_MASK		(~(PMD_SIZE-1))
#define PTRS_PER_PMD		PTRS_PER_PTE
#endif

/*
 * PUD_SHIFT determines the size a level 1 page table entry can map.
 */
#if CONFIG_ARM64_PGTABLE_LEVELS > 3
#define PUD_SHIFT		((PAGE_SHIFT - 3) * 3 + 3)
#define PUD_SIZE		(1 << PUD_SHIFT)
#define PUD_MASK		(~(PUD_SIZE-1))
#define PTRS_PER_PUD		PTRS_PER_PTE
#endif

/*
 * PGDIR_SHIFT determines the size a top-level page table entry can map
 * (depending on the configuration, this level can be 0, 1 or 2).
 */
#define PGDIR_SHIFT		((PAGE_SHIFT - 3) * CONFIG_ARM64_PGTABLE_LEVELS + 3)
#define PGDIR_SIZE		(1 << PGDIR_SHIFT)
#define PGDIR_MASK		(~(PGDIR_SIZE-1))
#define PTRS_PER_PGD		(1 << (VA_BITS - PGDIR_SHIFT))

/*
 * Section address mask and size definitions.
 */
#define SECTION_SHIFT		PMD_SHIFT
#define SECTION_SIZE		(1 << SECTION_SHIFT)
#define SECTION_MASK		(~(SECTION_SIZE-1))

/*
 * Hardware page table definitions.
 *
 * Level 1 descriptor (PUD).
 */
#define PUD_TYPE_TABLE		(3 << 0)
#define PUD_TABLE_BIT		(1 << 1)
#define PUD_TYPE_MASK		(3 << 0)
#define PUD_TYPE_SECT		(1 << 0)

/*
 * Level 2 descriptor (PMD).
 */
#define PMD_TYPE_MASK		(3 << 0)
#define PMD_TYPE_FAULT		(0 << 0)
#define PMD_TYPE_TABLE		(3 << 0)
#define PMD_TYPE_SECT		(1 << 0)
#define PMD_TABLE_BIT		(1 << 1)

/*
 * Section
 */
#define PMD_SECT_VALID		(1 << 0)
#define PMD_SECT_PROT_NONE	(1 << 58)
#define PMD_SECT_USER		(1 << 6)		/* AP[1] */
#define PMD_SECT_RDONLY		(1 << 7)		/* AP[2] */
#define PMD_SECT_S		(3 << 8)
#define PMD_SECT_AF		(1 << 10)
#define PMD_SECT_NG		(1 << 11)
#define PMD_SECT_PXN		(1 << 53)
#define PMD_SECT_UXN		(1 << 54)

/*
 * AttrIndx[2:0] encoding (mapping attributes defined in the MAIR* registers).
 */
#define PMD_ATTRINDX(t)		((t) << 2)
#define PMD_ATTRINDX_MASK	(7 << 2)

/*
 * Level 3 descriptor (PTE).
 */
#define PTE_TYPE_MASK		(3 << 0)
#define PTE_TYPE_FAULT		(0 << 0)
#define PTE_TYPE_PAGE		(3 << 0)
#define PTE_TABLE_BIT		(1 << 1)
#define PTE_USER		(1 << 6)		/* AP[1] */
#define PTE_RDONLY		(1 << 7)		/* AP[2] */
#define PTE_SHARED		(3 << 8)		/* SH[1:0], inner shareable */
#define PTE_AF			(1 << 10)	/* Access Flag */
#define PTE_NG			(1 << 11)	/* nG */
#define PTE_PXN			(1 << 53)	/* Privileged XN */
#define PTE_UXN			(1 << 54)	/* User XN */

/*
 * AttrIndx[2:0] encoding (mapping attributes defined in the MAIR* registers).
 */
#define PTE_ATTRINDX(t)		((t) << 2)
#define PTE_ATTRINDX_MASK	(7 << 2)

/*
 * 2nd stage PTE definitions
 */
#define PTE_S2_RDONLY		(1 << 6)   /* HAP[2:1] */
#define PTE_S2_RDWR		(3 << 6)   /* HAP[2:1] */

#define PMD_S2_RDWR		(3 << 6)   /* HAP[2:1] */

/*
 * Memory Attribute override for Stage-2 (MemAttr[3:0])
 */
#define PTE_S2_MEMATTR(t)	((t) << 2)
#define PTE_S2_MEMATTR_MASK	(0xf << 2)


#ifdef CONFIG_ARM64_64K_PAGES
#define BLOCK_SHIFT	PAGE_SHIFT
#define BLOCK_SIZE	PAGE_SIZE
#define TABLE_SHIFT	PMD_SHIFT
#else
#define BLOCK_SHIFT	SECTION_SHIFT
#define BLOCK_SIZE	SECTION_SIZE
#define TABLE_SHIFT	PUD_SHIFT
#endif

#ifndef CONFIG_SMP
#define PTE_FLAGS	PTE_TYPE_PAGE | PTE_AF
#define PMD_FLAGS	PMD_TYPE_SECT | PMD_SECT_AF
#else
#define PTE_FLAGS	PTE_TYPE_PAGE | PTE_AF | PTE_SHARED
#define PMD_FLAGS	PMD_TYPE_SECT | PMD_SECT_AF | PMD_SECT_S
#endif

#ifdef CONFIG_ARM64_64K_PAGES
#define MM_MMUFLAGS	(4 << 2) | PTE_FLAGS
#else
#define MM_MMUFLAGS	(4 << 2) | PMD_FLAGS
#endif


#define MAIR(attr, mt)	((attr) << ((mt) * 8))

#define MT_DEVICE_nGnRnE	0
#define MT_DEVICE_nGnRE		1
#define MT_DEVICE_GRE		2
#define MT_NORMAL_NC		3
#define MT_NORMAL		4

#define TCR_TxSZ(x)		(((64 - (x)) << 16) | ((64 - (x)) << 0))
#define TCR_IRGN_NC		((0 << 8) | (0 << 24))
#define TCR_IRGN_WBWA		((1 << 8) | (1 << 24))
#define TCR_IRGN_WT		((2 << 8) | (2 << 24))
#define TCR_IRGN_WBnWA		((3 << 8) | (3 << 24))
#define TCR_IRGN_MASK		((3 << 8) | (3 << 24))
#define TCR_ORGN_NC		((0 << 10) | (0 << 26))
#define TCR_ORGN_WBWA		((1 << 10) | (1 << 26))
#define TCR_ORGN_WT		((2 << 10) | (2 << 26))
#define TCR_ORGN_WBnWA		((3 << 10) | (3 << 26))
#define TCR_ORGN_MASK		((3 << 10) | (3 << 26))
#define TCR_SHARED		((3 << 12) | (3 << 28))
#define TCR_TG0_4K		(0 << 14)
#define TCR_TG0_64K		(1 << 14)
#define TCR_TG0_16K		(2 << 14)
#define TCR_TG1_16K		(1 << 30)
#define TCR_TG1_4K		(2 << 30)
#define TCR_TG1_64K		(3 << 30)
#define TCR_ASID16		(1 << 36)
#define TCR_TBI0		(1 << 37)

#ifdef CONFIG_ARM64_64K_PAGES
#define TCR_TG_FLAGS	TCR_TG0_64K | TCR_TG1_64K
#else
#define TCR_TG_FLAGS	TCR_TG0_4K | TCR_TG1_4K
#endif

#ifdef CONFIG_SMP
#define TCR_SMP_FLAGS	TCR_SHARED
#else
#define TCR_SMP_FLAGS	0
#endif

/* PTWs cacheable, inner/outer WBWA */
#define TCR_CACHE_FLAGS	TCR_IRGN_WBWA | TCR_ORGN_WBWA



.section .text

.globl _stext
_stext:
	/* zImage header */
	add     x13, x18, #0x16
    b       reset
    .quad   0x80000               // Image load offset from start of RAM, little-endian
	.quad   _end - _stext                 // Effective size of kernel image, little-endian
	.quad   0                // Informative flags, little-endian
	.quad   0                               // reserved
	.quad   0                               // reserved
	.quad   0                               // reserved
	.byte   0x41                            // Magic number, "ARM\x64"
	.byte   0x52
	.byte   0x4d
	.byte   0x64
	/* end of zImage header
	.long	pe_header - _stext		// Offset to the PE header.
	.align 3
pe_header:
	.ascii	"PE"
	.short 	0
coff_header:
	.short	0xaa64				// AArch64
	.short	2				// nr_sections
	.long	0 				// TimeDateStamp
	.long	0				// PointerToSymbolTable
	.long	1				// NumberOfSymbols
	.short	section_table - optional_header	// SizeOfOptionalHeader
	.short	0x206				// Characteristics.
						// IMAGE_FILE_DEBUG_STRIPPED |
						// IMAGE_FILE_EXECUTABLE_IMAGE |
						// IMAGE_FILE_LINE_NUMS_STRIPPED
optional_header:
	.short	0x20b				// PE32+ format
	.byte	0x02				// MajorLinkerVersion
	.byte	0x14				// MinorLinkerVersion
	.long	_end - reset			// SizeOfCode
	.long	0				// SizeOfInitializedData
	.long	0				// SizeOfUninitializedData
	.long	efi_stub_entry - _stext	// AddressOfEntryPoint
	.long	reset - _stext		// BaseOfCode

extra_header_fields:
	.quad	0				// ImageBase
	.long	0x20				// SectionAlignment
	.long	0x8				// FileAlignment
	.short	0				// MajorOperatingSystemVersion
	.short	0				// MinorOperatingSystemVersion
	.short	0				// MajorImageVersion
	.short	0				// MinorImageVersion
	.short	0				// MajorSubsystemVersion
	.short	0				// MinorSubsystemVersion
	.long	0				// Win32VersionValue

	.long	_end - _stext			// SizeOfImage

	// Everything before the kernel image is considered part of the header
	.long	reset - _stext		// SizeOfHeaders
	.long	0				// CheckSum
	.short	0xa				// Subsystem (EFI application)
	.short	0				// DllCharacteristics
	.quad	0				// SizeOfStackReserve
	.quad	0				// SizeOfStackCommit
	.quad	0				// SizeOfHeapReserve
	.quad	0				// SizeOfHeapCommit
	.long	0				// LoaderFlags
	.long	0x6				// NumberOfRvaAndSizes

	.quad	0				// ExportTable
	.quad	0				// ImportTable
	.quad	0				// ResourceTable
	.quad	0				// ExceptionTable
	.quad	0				// CertificationTable
	.quad	0				// BaseRelocationTable

	// Section table
section_table:

	/*
	 * The EFI application loader requires a relocation section
	 * because EFI applications must be relocatable.  This is a
	 * dummy section as far as we are concerned.
	 */
	.ascii	".reloc"
	.byte	0
	.byte	0			// end of 0 padding of section name
	.long	0
	.long	0
	.long	0			// SizeOfRawData
	.long	0			// PointerToRawData
	.long	0			// PointerToRelocations
	.long	0			// PointerToLineNumbers
	.short	0			// NumberOfRelocations
	.short	0			// NumberOfLineNumbers
	.long	0x42100040		// Characteristics (section flags)


	.ascii	".text"
	.byte	0
	.byte	0
	.byte	0        		// end of 0 padding of section name
	.long	_end - reset		// VirtualSize
	.long	reset - _stext	// VirtualAddress
	.long	_edata - reset		// SizeOfRawData
	.long	reset - _stext	// PointerToRawData

	.long	0		// PointerToRelocations (0 for executables)
	.long	0		// PointerToLineNumbers (0 for executables)
	.short	0		// NumberOfRelocations  (0 for executables)
	.short	0		// NumberOfLineNumbers  (0 for executables)
	.long	0xe0500020	// Characteristics (section flags)
	.align 5


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

	adr	x1, _stext		/* x1 = physical address of _stext 0x40408000 */
	ldr	x3, =_stext		/* x3 = (desired) virtual address of _stext 0x408000 */
	sub 	x9, x1, x3		/* x9 = (physical - virtual) offset 0x40000000 */
	mov x28, x9

	ldr	x7, =_page_dir		/* x7 = (desired) virtual addr of translation table 0x404000 */
	add	x1, x7, x9		/* x1 = physical addr of translation table 0x40404000 */


#if 0

	/* Tell the system where our page table is located. */
	/* msr	TTBR0_EL1, x1	 set TTBx0 */

	/*
	 * This is the 16 KB top-level translation table, in which
	 * each word maps one 1MB virtual section to a physical section.
	 * Note: We leave TTBCR as 0, meaning that only TTBx0 is used and
	 * we use the short-descriptor format (32-bit physical addresses).
	 */
	mrs x0, TCR_EL1 /* Get EL1 Translation Control */

	/* 64KB, Outer Sharable, Inner/Outer Write-Back Write-Allocate Cacheable  */
	ldr x18, =EL1_MEM_ATTR_MASK
	bic x0, x0, x18
	ldr x18, =EL1_MEM_ATTR_FLAGS
	orr x0, x0, x18
	msr TCR_EL1, x0 /* Set EL1 Translation Control */


	/* Template (flags) for a 1 MB page-table entry.
	 * TEX[2:0] C B = 001 1 1 (outer and inner write-back, write-allocate)
	 */
	ldr	x8, =(0x2 +  		/* Section entry */ \
		      0xc +  		/* C B */ \
		      (3 << 10) + 	/* Read/write */ \
		      (1 << 12) +	/* TEX */ \
		      (1 << 16) +	/* Sharable */ \
		      (1<<19))		/* Non-secure */
	/* x8 = template page table entry */

	/* Add an entry for the current physical section, at the old and new
	 * addresses. It's OK if they're the same.
	 */

	adr	x0, _stext

	lsr	x12, x0, #29
	and	x12, x12, #((1<<19)-1)	// table index
	add	x13, x1, #(1 << 16)
	orr	x13, x13, #(3<<0)	// address of next table and entry type
	str	x13, [x1, x12, lsl #3]
	add	x1, x1, #(1 << 16)	// next level table page

	lsr x0, x0, #16
	orr	x3, x8, x0, lsl #16			/* x3 = table entry for this section */
	and	x5, x0, #((1<<13)-1)
	str	x3, [x1, x5, lsl #3]	/* map current section to this code too */

	ldr	x4, =_stext		/* x4 = desired virtual address of this section */

	lsr	x12, x4, #29
	and	x12, x12, #((1<<19)-1)	// table index
	add	x13, x1, #(1 << 16)
	orr	x13, x13, #(3<<0)	// address of next table and entry type
	str	x13, [x1, x12, lsl #3]
	add	x1, x1, #(1 << 16)	// next level table page

	lsr x5, x4, #16
	and	x5, x5, #((1<<13)-1)
	str	x3, [x1, x5, lsl #3] 	/* map desired virtual section to this code */

	/* Invalidate TLB */
	dsb sy				/* Caching is off, but must still prevent reordering */
	tlbi    vmalle1is	/* Invalidate all EL1 TLB entries */
#endif

	bl	__calc_phys_offset
	bl	__create_page_tables


	msr	ttbr0_el1, x25			// load TTBR0
	msr	ttbr1_el1, x26			// load TTBR1
	isb

	bl __cpu_setup

	ldr	x2, =stage2		/* Virtual address of stage2 */

	/* Enable MMU / SCTLR */
	msr	SCTLR_EL1, x0	/* SCTLR */
	isb

	br	x2

/*
 * Macro to create a table entry to the next page.
 *
 *	tbl:	page table address
 *	virt:	virtual address
 *	shift:	#imm page table shift
 *	ptrs:	#imm pointers per table page
 *
 * Preserves:	virt
 * Corrupts:	tmp1, tmp2
 * Returns:	tbl -> next level table page address
 */
	.macro	create_table_entry, tbl, virt, shift, ptrs, tmp1, tmp2
	lsr	\tmp1, \virt, #\shift
	and	\tmp1, \tmp1, #\ptrs - 1	// table index
	add	\tmp2, \tbl, #PAGE_SIZE
	orr	\tmp2, \tmp2, #PMD_TYPE_TABLE	// address of next table and entry type
	str	\tmp2, [\tbl, \tmp1, lsl #3]
	add	\tbl, \tbl, #PAGE_SIZE		// next level table page
	.endm

/*
 * Macro to populate the PGD (and possibily PUD) for the corresponding
 * block entry in the next level (tbl) for the given virtual address.
 *
 * Preserves:	tbl, next, virt
 * Corrupts:	tmp1, tmp2
 */
	.macro	create_pgd_entry, tbl, virt, tmp1, tmp2
	create_table_entry \tbl, \virt, PGDIR_SHIFT, PTRS_PER_PGD, \tmp1, \tmp2
#if SWAPPER_PGTABLE_LEVELS == 3
	create_table_entry \tbl, \virt, TABLE_SHIFT, PTRS_PER_PTE, \tmp1, \tmp2
#endif
	.endm

/*
 * Macro to populate block entries in the page table for the start..end
 * virtual range (inclusive).
 *
 * Preserves:	tbl, flags
 * Corrupts:	phys, start, end, pstate
 */
	.macro	create_block_map, tbl, flags, phys, start, end
	lsr	\phys, \phys, #BLOCK_SHIFT
	lsr	\start, \start, #BLOCK_SHIFT
	and	\start, \start, #PTRS_PER_PTE - 1	// table index
	orr	\phys, \flags, \phys, lsl #BLOCK_SHIFT	// table entry
	lsr	\end, \end, #BLOCK_SHIFT
	and	\end, \end, #PTRS_PER_PTE - 1		// table end index
9999:	str	\phys, [\tbl, \start, lsl #3]		// store the entry
	add	\start, \start, #1			// next entry
	add	\phys, \phys, #BLOCK_SIZE		// next block
	cmp	\start, \end
	b.ls	9999b
	.endm

/*
 * dcache_line_size - get the minimum D-cache line size from the CTR register.
 */
	.macro	dcache_line_size, reg, tmp
	mrs	\tmp, ctr_el0			// read CTR
	ubfm	\tmp, \tmp, #16, #19		// cache line size encoding
	mov	\reg, #4			// bytes per word
	lsl	\reg, \reg, \tmp		// actual cache line size
	.endm

/*
 *	__inval_cache_range(start, end)
 *	- start   - start address of region
 *	- end     - end address of region
 */
__inval_cache_range:
	/* FALLTHROUGH */

/*
 *	__dma_inv_range(start, end)
 *	- start   - virtual start address of region
 *	- end     - virtual end address of region
 */
__dma_inv_range:
	dcache_line_size x2, x3
	sub	x3, x2, #1
	tst	x1, x3				// end cache line aligned?
	bic	x1, x1, x3
	b.eq	1f
	dc	civac, x1			// clean & invalidate D / U line
1:	tst	x0, x3				// start cache line aligned?
	bic	x0, x0, x3
	b.eq	2f
	dc	civac, x0			// clean & invalidate D / U line
	b	3f
2:	dc	ivac, x0			// invalidate D / U line
3:	add	x0, x0, x2
	cmp	x0, x1
	b.lo	2b
	dsb	sy
	ret

/*
 * Calculate the start of physical memory.
 */
__calc_phys_offset:
	adr	x0, 1f
	ldp	x1, x2, [x0]
	sub	x28, x0, x1			// x28 = PHYS_OFFSET - PAGE_OFFSET
	add	x24, x2, x28			// x24 = PHYS_OFFSET
	ret

	.align 3
1:	.quad	.
	.quad	_boot_stack


/*
 * Setup the initial page tables. We only setup the barest amount which is
 * required to get the kernel running. The following sections are required:
 *   - identity mapping to enable the MMU (low address, TTBR0)
 *   - first few MB of the kernel linear mapping to jump to once the MMU has
 *     been enabled
 *   - pgd entry for fixed mappings (TTBR1)
 */
__create_page_tables:
	pgtbl	x25, x26, x28			// idmap_pg_dir and swapper_pg_dir addresses
	mov	x27, x30

	/*
	 * Invalidate the idmap and swapper page tables to avoid potential
	 * dirty cache lines being evicted.
	 */
	mov	x0, x25
	add	x1, x26, #SWAPPER_DIR_SIZE
	bl	__inval_cache_range

	/*
	 * Clear the idmap and swapper page tables.
	 */
	mov	x0, x25
	add	x6, x26, #SWAPPER_DIR_SIZE
1:	stp	xzr, xzr, [x0], #16
	stp	xzr, xzr, [x0], #16
	stp	xzr, xzr, [x0], #16
	stp	xzr, xzr, [x0], #16
	cmp	x0, x6
	b.lo	1b

	ldr	x7, =MM_MMUFLAGS

	/*
	 * Create the identity mapping.
	 */
	mov	x0, x25				// idmap_pg_dir
	adr	x3, _boot_stack
	create_pgd_entry x0, x3, x5, x6
	adr	x6, _end
	mov	x5, x3				// __pa(KERNEL_START)
	create_block_map x0, x7, x3, x5, x6

	/*
	 * Map the kernel image (starting with PHYS_OFFSET).
	 */

	mov	x0, x26				// swapper_pg_dir
	ldr	x5, =_text
	create_pgd_entry x0, x5, x3, x6
	ldr	x6, =_end
	mov	x3, x24				// phys offset
	create_block_map x0, x7, x3, x5, x6

	/*
	 * Since the page tables have been populated with non-cacheable
	 * accesses (MMU disabled), invalidate the idmap and swapper page
	 * tables again to remove any speculatively loaded cache lines.
	 */
	mov	x0, x25
	add	x1, x26, #SWAPPER_DIR_SIZE
	bl	__inval_cache_range

	ret x27

/*
 *	__cpu_setup
 *
 *	Initialise the processor for turning the MMU on.  Return in x0 the
 *	value of the SCTLR_EL1 register.
 */
__cpu_setup:
	ic	iallu				// I+BTB cache invalidate
	tlbi	vmalle1is			// invalidate I + D TLBs
	dsb	ish

	mov	x0, #3 << 20
	msr	cpacr_el1, x0			// Enable FP/ASIMD
	msr	mdscr_el1, xzr			// Reset mdscr_el1
	/*
	 * Memory region attributes for LPAE:
	 *
	 *   n = AttrIndx[2:0]
	 *			n	MAIR
	 *   DEVICE_nGnRnE	000	00000000
	 *   DEVICE_nGnRE	001	00000100
	 *   DEVICE_GRE		010	00001100
	 *   NORMAL_NC		011	01000100
	 *   NORMAL		100	11111111
	 */
	ldr	x5, =MAIR(0x00, MT_DEVICE_nGnRnE) | \
		     MAIR(0x04, MT_DEVICE_nGnRE) | \
		     MAIR(0x0c, MT_DEVICE_GRE) | \
		     MAIR(0x44, MT_NORMAL_NC) | \
		     MAIR(0xff, MT_NORMAL)
	msr	mair_el1, x5
	/*
	 * Prepare SCTLR
	 */
	adr	x5, crval
	ldp	w5, w6, [x5]
	mrs	x0, sctlr_el1
	bic	x0, x0, x5			// clear bits
	orr	x0, x0, x6			// set bits
	/*
	 * Set/prepare TCR and TTBR. We use 512GB (39-bit) address range for
	 * both user and kernel.
	 */
	ldr	x10, =TCR_TxSZ(VA_BITS) | TCR_CACHE_FLAGS | TCR_SMP_FLAGS | \
			TCR_TG_FLAGS | TCR_ASID16 | TCR_TBI0
	/*
	 * Read the PARange bits from ID_AA64MMFR0_EL1 and set the IPS bits in
	 * TCR_EL1.
	 */
	mrs	x9, ID_AA64MMFR0_EL1
	bfi	x10, x9, #32, #3
	msr	tcr_el1, x10
	ret					// return to head.S

	/*
	 *                 n n            T
	 *       U E      WT T UD     US IHBS
	 *       CE0      XWHW CZ     ME TEEA S
	 * .... .IEE .... NEAI TE.I ..AD DEN0 ACAM
	 * 0011 0... 1101 ..0. ..0. 10.. .... .... < hardware reserved
	 * .... .1.. .... 01.1 11.1 ..01 0001 1101 < software settings
	 */
	.type	crval, #object
crval:
	.word	0x000802e2			// clear
	.word	0x0405d11d			// set

/*
 * Stack pushing/popping (register pairs only). Equivalent to store decrement
 * before, load increment after.
 */
        .macro  push, xreg1, xreg2
        stp     \xreg1, \xreg2, [sp, #-16]!
        .endm

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


.globl __arch_switch_threads
/* => x0 = &prev->sp
 *    x1 = &next->sp
 * <= returns to next thread's saved return address
 */
__arch_switch_threads:
	/* Store callee-saved registers to old thread's stack */
	push    x28, x29
    push    x26, x27
    push    x24, x25
    push    x22, x23
    push    x20, x21
    push    x18, x19
    push    x16, x17
    push    x14, x15
    push    x12, x13
    push    x10, x11
    push    x8, x9
    push    x6, x7
    push    x4, x5
    mov 	x4, sp
	stp    	x4, x30, [x0] /* Store current sp and ip to prev's struct thread */

	ldp x4, x30, [x1] 	/* Load new sp, ip from next's struct thread */
	mov sp, x4
	/* Load callee-saved registers from new thread's stack */
    pop     x4, x5
    pop     x6, x7
    pop     x8, x9
    pop     x10, x11
    pop     x12, x13
    pop     x14, x15
    pop     x16, x17
    pop     x18, x19
    pop     x20, x21
    pop     x22, x23
    pop     x24, x25
    pop     x26, x27
    pop     x28, x29

	ret

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
