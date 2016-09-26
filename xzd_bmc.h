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

/*
This header file should be included by payload applications wanting to use any of
the built-in BMC functions functions below.
*/
#ifndef __XZD_BMC_H__
#define __XZD_BMC_H__

#define STR_HELPER(x) #x
#define STR(x) STR_HELPER(x)

#define MAJOR_VER     2
#define MINOR_VER     1
#define PATCH_VER     0
#define VERSION 	"v" STR(MAJOR_VER) "." STR(MINOR_VER) "." STR(PATCH_VER)


typedef int (*func0)(void* phys_addr_ptr, void* virt_addr_ptr, u32 size, int type);
typedef void (*func1)(char* str) ;
typedef char* (*func2)(int* ver);

#define FUNC_BASE	((void**)0xffffffc000090000)		// this address is set in xzd_bare.lds
#define bmc_mem_mapper	((func0)(FUNC_BASE[0]))
#define bmc_xen_print	((func1)(FUNC_BASE[1]))
#define bmc_get_version	((func2)(FUNC_BASE[2]))

static inline int check_compat(void)
{
	int ver[3];
	bmc_get_version(ver);

	return (ver[0] == MAJOR_VER);
}

#endif
