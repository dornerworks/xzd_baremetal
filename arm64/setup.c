#include <page.h>
#include <types.h>
#include <console.h>

/*
 * Shared page for communicating with the hypervisor.
 * Events flags go here, for example.
 */
// shared_info_t *HYPERVISOR_shared_info;

extern char shared_info_page[PAGE_SIZE];

uint64_t physical_address_offset = 0;

/*
 * INITIAL C ENTRY POINT.
 */
void arch_init(void *dtb_pointer, uint64_t physical_offset)
{

	physical_address_offset = physical_offset;
    // TBD: Init Code goes here

	char buf[1024] = "XZD_Bare: Hello World\n";

	print(buf);


    // Start Kernel Here
    // start_kernel();

}

void
arch_fini(void)
{
}

void
arch_do_exit(void)
{
}
