/*
  Copyright (c) DornerWorks 2016

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
  following conditions are met:
  1.	 Redistributions of source code must retain the above copyright notice, this list of conditions and the
  following disclaimer.

  THIS SOFTWARE IS PROVIDED ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
  DORNERWORKS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
  OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#ifndef __MMU_H__
#define __MMU_H__
#include <types.h>

#define OK				0
#define VA_INVALID		-1
#define SIZE_BAD		-2
#define ENTRY_IS_BLOCK	-3
#define ENTRY_IN_USE	-4
#define OUT_OF_TABLES	-5
#define INVALID_MEM_TYPE	-6	

#define	DEVICE_MEM				0
#define	NORMAL_UNCACHED			1
#define	NORMAL_MEM_INNER_SHARE	2
#define NORMAL_MEM_OUTER_SHARE	3
#define NUM_MEM_TYPES			4


void walk_table(u64 base, int level);
int map_memory(void* phys_addr_ptr, void* virt_addr_ptr, u32 size, int type);

#endif
