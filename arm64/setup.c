#include <page.h>

/*
 * Shared page for communicating with the hypervisor.
 * Events flags go here, for example.
 */
// shared_info_t *HYPERVISOR_shared_info;

extern char shared_info_page[PAGE_SIZE];

/*
 * INITIAL C ENTRY POINT.
 */
void arch_init(void *dtb_pointer, unsigned long long physical_offset)
{

    // TBD: Init Code goes here

    

    // TBD: Start Kernel Here
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
