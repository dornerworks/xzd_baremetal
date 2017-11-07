/*
Copyright DornerWorks 2017

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
following conditions are met:
1.   Redistributions of source code must retain the above copyright notice, this list of conditions and the 
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

#include <main.h>
#include <types.h>
#include <string.h>
#include <console.h>
#include <mmu.h>
#include "../xzd_bmc.h"

#define START_ADDR 		0x40400000
#define MAX_PAYLOAD_SIZE    	(4*1024*1024)   


extern void* _payload_start;
extern void* _payload_end;

void* func_base[16] __attribute__ ((section (".bmc_func")));

char* get_version(int* ver)
{
    if(NULL != ver)
    {
        ver[0] = MAJOR_VER;
        ver[1] = MINOR_VER;
        ver[2] = PATCH_VER;
    }

    return VERSION;
}

void print_error(char* string, int rv)
{
    print(string);
    print(": ");
    print_int(rv);
    print("\r\n");
}

int main(void)
{
    void (*fptr)(void) = (void*)START_ADDR;            
    int rv;
    u64* src_ptr = (void*)&_payload_start;
    u64* dest_ptr = (void*)START_ADDR;
    u64* end_ptr = (void*)&_payload_end;

    if( (rv = map_memory((void*)START_ADDR,(void*)START_ADDR, MAX_PAYLOAD_SIZE, NORMAL_MEM_INNER_SHARE) ))
        print_error("RAM",rv);

    func_base[0] = map_memory ;             // register memory mapping function so payload can invoke it
    func_base[1] = print ;                  // register xen print function so payload can invoke it
    func_base[2] = get_version;             // register get_version function so payload app can invoke it   

    while(src_ptr < end_ptr)
    {
        *dest_ptr++ = *src_ptr++;
    }
    
 
    end_ptr = (u64*)(START_ADDR + MAX_PAYLOAD_SIZE);
    while(dest_ptr < end_ptr)
    {
        *dest_ptr++ = 0;
    }

    fptr();

    print("shouldn't be here \r\n");
    
    while(1);

    return 0;
}
