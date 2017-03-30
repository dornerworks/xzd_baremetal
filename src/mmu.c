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
#include <types.h>
#include <string.h>
#include <mmu.h>
#include <console.h>

/* these are per the ARMv8 Arch Refe Manual, section D4 */ 
#define VALID_ENTRY	1
#define TYPE_TABLE  2
#define L1_LEAST 	30
#define	L2_LEAST	21
#define L3_LEAST 	12
#define LEVEL_SHIFT	9
#define INDEX_MASK	((1<<9)-1)
#define L1_SIZE (1<<L1_LEAST)
#define L2_SIZE (1<<L2_LEAST)
#define L3_SIZE (1<<L3_LEAST)
#define MAX_VA ((1ULL<<(L1_LEAST+LEVEL_SHIFT))-(1ULL<<(L3_LEAST+LEVEL_SHIFT)))  //top of lower VA range - 2MB
#define LOWER_MASK	((1ULL<<48)-1)
#define UPPER_MASK	(-(1<<12))


#define NUM_STARTING_TABLES	4
#define NUM_TABLES	(512-NUM_STARTING_TABLES)

/* assembly macros */
#define mfcp(reg)	({u64 rval;\
			__asm__ __volatile__("mrs	%0, " #reg : "=r" (rval));\
			rval;\
			})

#define dsb(scope)      asm volatile("dsb " #scope : : : "memory")
#define mb()  dsb(sy)


#define BLOCK_ATTR	(0x400 | VALID_ENTRY)
#define get_mem_attrib_index(t)	(memory_type_to_attrib[t] << 2)								// range checked on entry to public interface
#define get_shareability(t) (t==NORMAL_MEM_OUTER_SHARE?0x200:0x300)

#define get_attrib(t)	(BLOCK_ATTR | get_shareability(t)  | (get_mem_attrib_index(t)))		// calculate the block attributes based on type

static int memory_type_to_attrib[NUM_MEM_TYPES] = {0,1,2,2};								// maps a type to a memory attribute set


/* structures for managing dynamic paging */
typedef struct page { u64 entry[512]; } page_table_t;
//page_table_t page_tables[NUM_TABLES] __attribute__ ((section (".page_tables")));
page_table_t* page_tables = (void*)(0x40200000+NUM_STARTING_TABLES*4096);
static u8 table_index = 0;



void walk_table(u64 base, int level)
{
	u64* table;
	int i, j;

	for(j = 0; j< level; j++)
		print("\t");

	print("base: ");
	print_u64(base); 
	print("\r\n");

	table = (u64*)base;
	level++;

	for(i = 0; i< 512; i++)
	{
		if(table[i] & VALID_ENTRY)
		{
			for(j = 0; j< level; j++)
			{
				print("\t");
			}
			print_u16(i);
			print(": ");
			print_u64(table[i]); 
			print("\r\n");

			if(level < 3 && (table[i] & TYPE_TABLE))
				walk_table(table[i]&~(0xFFF),level);
		}

	}

}



/*
* Simple function to grab a 4KB chunk of memory to use for MMU. Once a table is allocated, it cannot be free'd.
*/
static page_table_t* alloc_table(void)
{
	if(NUM_TABLES == table_index)
		return NULL;
	return &page_tables[table_index++];
}

/*
* Allocates a next level table and adds a pointer to it in the entry passed to it.
*/
static int add_table(u64* entry)
{
	page_table_t* val;

	val = alloc_table();
	if(val == NULL)
		return OUT_OF_TABLES;
	
	memset((void*)val, 0, 4096);
	
	*entry = ((u64)val & -(1<<12) & ((1ULL<<48)-1)) | VALID_ENTRY | TYPE_TABLE;

	mb();
	// todo, cache?
	return OK;
}
/*
* Maps a single 1GB, 2MB, or 4KB block of memory.
*/
static int map_memory_block(u64 phys_addr, u64 virt_addr, u32 size, int type)
{
	u64* table;
	u64  entry;
	u16 index;
	int rv;
	int shift;

	// check virt_addr
	if(virt_addr > MAX_VA)
	{
		return VA_INVALID;
	}

	if(L1_SIZE != size && L2_SIZE != size && L3_SIZE != size)
	{
		return SIZE_BAD;
	}

	shift = L1_LEAST;
	entry = (u64)mfcp(TTBR0_EL1);
	
	do
	{
		// find table entry
		table = (u64*)(entry & UPPER_MASK);  		// mask off lower 12 bits
		index = virt_addr >> shift;		   	    	// l1 indexed by bits 38:30
		index &= INDEX_MASK;						// mask off all but lower 9 bits
	
		entry = table[index];
	
		if(1 == (entry & VALID_ENTRY))	
		{
			if((1ULL << shift) == size)				// check if this is the target size
			{
				return 	ENTRY_IN_USE;
			}
			//	else
			if(0 == (entry & TYPE_TABLE))
			{
				return ENTRY_IS_BLOCK;
			}
		}
		else
		{
			if((1ULL << shift) == size)
			{
				entry = phys_addr & (-(1<<shift));
				entry &= LOWER_MASK;
				entry |= get_attrib(type);

				if(size == L3_SIZE)
				{
					entry |= TYPE_TABLE;	// have to set the table bit for level-3 entries
				}
				table[index]= entry;	
				// done adding a block
				break;
			}
			else
			{
				if((rv = add_table( &table[index]) ))
				{
					return rv;
				}
				entry = table[index];
			}
		}
		shift -= LEVEL_SHIFT;
	}while(shift >= L3_LEAST);

	mb();
	// todo, cache?
	return OK;
}

/*
* Function to map a VA to a given PA. Any size can be given, but any "leftovers" will mapped via a 4KB page, so the rest of that 4KB region
* will also be mapped.
*/
#define NUM_JOBS 5
int map_memory(void* phys_addr_ptr, void* virt_addr_ptr, u32 size, int type)
{
	struct 
	{
		int num_blocks;
		u32 block_size;		
	} jobs[] = {{0,L3_SIZE},{0,L2_SIZE},{0,L1_SIZE},{0,L2_SIZE},{0,L3_SIZE},{0,0}};	// 4KB, 2MB, 1GB, 2MB, 4KB

	u32 block_size;
	u64 phys_addr;
	u64 virt_addr;
	int rv;
	int i, j;
	u64 max_addr;
	u64 curr_addr;

#ifdef DEBUG
	print_u64((u64)phys_addr_ptr);
	print("  ");
	print_u64((u64)virt_addr_ptr);
	print("  ");
	print_u32(size);
	print("\r\n");
#endif

	if(type >= NUM_MEM_TYPES)
	{
		return INVALID_MEM_TYPE;
	}
	
	phys_addr = (u64)phys_addr_ptr;
	virt_addr = (u64)virt_addr_ptr;

	max_addr = phys_addr + size;
	curr_addr = phys_addr & (-L3_SIZE);	//round down to the nearest page

	for(i = 0; i < NUM_JOBS && curr_addr < max_addr; i++)
	{
		if(jobs[i].block_size < jobs[i+1].block_size)
		{
			// check to see if need to handle padding up to next larger block size
			u64 next_addr = (curr_addr & (-jobs[i+1].block_size)) + jobs[i+1].block_size;
			next_addr = next_addr > max_addr ? max_addr: next_addr;
			if((next_addr-curr_addr)%jobs[i+1].block_size) // need to pad to get to next larger size
				jobs[i].num_blocks = (next_addr - curr_addr) / jobs[i].block_size; //when handling left overs, the math handles it
			//else num_blocks left at 0
		}
		else 
		{
			// do as many blocks as can at the current block size
			jobs[i].num_blocks = (max_addr - curr_addr) / jobs[i].block_size; 
		}
		

		curr_addr += jobs[i].num_blocks * jobs[i].block_size;	
	}


	for(j = 0; j < NUM_JOBS; j++)
	{	
#ifdef DEBUG
	print_u16(j);
	print("-");
	print_u32(jobs[j].num_blocks);
	print(", ");
	print_u32(jobs[j].block_size);
	print("\n");
#endif 
		block_size = jobs[j].block_size;
		for(i = 0; i < jobs[j].num_blocks; i++)
		{
			if((rv = map_memory_block( phys_addr, virt_addr, block_size, type)))
			{
				return rv;
			}
			phys_addr += block_size;
			virt_addr += block_size;
		}
	}

	return OK;
}

