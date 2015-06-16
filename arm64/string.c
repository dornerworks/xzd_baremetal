#include <types.h>

void * memset(void * s,int c,size_t count)
{
        char *xs = (char *) s;

        while (count--)
                *xs++ = c;

        return s;
}

size_t strlen(const char * s)
{
	const char *sc;

	for (sc = s; *sc != '\0'; ++sc)
		/* nothing */;
	return sc - s;
}