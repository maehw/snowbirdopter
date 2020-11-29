#include "tiptoi.h"

extern void _still_works(unsigned int a, unsigned int b, unsigned int c, unsigned int d);

void main()
{
    // call function with four arguments; first argument is stored in r0, fourth argument in r3
	_still_works(0x11234567, 0x22DEADBF, 0x33BAD1DE, 0x44C0FFEE);
}

