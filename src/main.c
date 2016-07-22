#include <main.h>
#define START_ADDR 0x40400000
#define SIZE  (1*1024*1024)/sizeof(unsigned long)
extern void* _payload_start;

int main(void)
{
    void (*fptr)(void) = (void*)START_ADDR;            
    int i;
    unsigned long* src_ptr = (void*)&_payload_start;
    unsigned long* dest_ptr = (void*)START_ADDR;
    
    for(i = 0; i < SIZE; i++)
       dest_ptr[i] = src_ptr[i];
       

    fptr();

	// TBD: Application goes here
	while(1);
}
