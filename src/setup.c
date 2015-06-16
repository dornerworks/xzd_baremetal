#include <page.h>
#include <types.h>
#include <console.h>
#include <main.h>

uint64_t physical_address_offset = 0;

/*
 * INITIAL C ENTRY POINT.
 */
void arch_init(void *dtb_pointer, uint64_t physical_offset)
{
	// Get the physical offset for any translations
	physical_address_offset = physical_offset;

	char buf[1024] = "XZD_Bare: Hello World\n";
	print(buf);

    // Start Bare Metal Application
    main();
}
