#ifndef __PAGE_H__
#define __PAGE_H__

#include <types.h>

#ifndef __ASSEMBLY__

extern uint64_t physical_address_offset;
#endif

#define CONFIG_ARM64_PGTABLE_LEVELS 	3

/* PAGE_SHIFT determines the page size */
#ifdef CONFIG_ARM64_64K_PAGES
#define PAGE_SHIFT		16
#else
#define PAGE_SHIFT		12
#endif
#define PAGE_SIZE		(1 << PAGE_SHIFT)
#define PAGE_MASK		(~(PAGE_SIZE-1))

/*
 * The idmap and swapper page tables need some space reserved in the kernel
 * image. Both require pgd, pud (4 levels only) and pmd tables to (section)
 * map the kernel. With the 64K page configuration, swapper and idmap need to
 * map to pte level. The swapper also maps the FDT (see __create_page_tables
 * for more information).
 */
#ifdef CONFIG_ARM64_64K_PAGES
#define SWAPPER_PGTABLE_LEVELS	(CONFIG_ARM64_PGTABLE_LEVELS)
#else
#define SWAPPER_PGTABLE_LEVELS	(CONFIG_ARM64_PGTABLE_LEVELS - 1)
#endif

#define SWAPPER_DIR_SIZE	(SWAPPER_PGTABLE_LEVELS * PAGE_SIZE)
#define IDMAP_DIR_SIZE		(SWAPPER_DIR_SIZE)

#endif