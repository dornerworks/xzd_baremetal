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
#include <console.h>
#include <string.h>
#include <hypercall.h>

void print_digit(u8 val)
{
	char buf[2] = {0};
	if(val < 10)
	{
		buf[0] = val+'0';
		print(buf);
	}
}

void print_int(int val)
{
	int div = 1000000000;
	int v;

	if(val < 0)
	{
		print("-");
		val = -val;
	}

	while(val)
	{
		v = val/div;
		if(v)
			print_digit(v);
		val = val % div;
		div /= 10;
	}
}

void print_hex(u8 val)
{
	int nib;
	char buf[3] = {0,0,0};

		nib = (val>>4)&0xf;
		if(nib < 10)
			buf[0] = '0'+nib;
		else
			buf[0] += 'A'+nib-10;

		nib = val&0xf;
		if(nib < 10)
			buf[1] = '0'+nib;
		else
			buf[1] += 'A'+nib-10;
		print(buf);
}

void print_u16(u16 val)
{
	int i;
	for(i = 1; i >= 0; i--)
		print_hex((val>>(8*i))&0xff);
}

void print_u32(u32 val)
{
	int i;
	for(i = 3; i >= 0; i--)
		print_hex((val>>(8*i))&0xff);
}

void print_u64(u64 val)
{
	int i;
	for(i = 7; i >= 0; i--)
		print_hex((val>>(8*i))&0xff);
}

void print(char *buf)
{
    (void)HYPERVISOR_console_io(CONSOLEIO_write, strlen(buf), buf);
    return;
}
