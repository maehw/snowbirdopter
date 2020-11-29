#include "tiptoi.h"

extern void _still_works(unsigned int* a, unsigned int* b, unsigned char* c, unsigned int d);

unsigned int* myptrs[16];
unsigned char mychars[3570];

void main()
{
    int k;
    for(k = 0; k < sizeof(myptrs)/sizeof(myptrs[0]); k++)
    {
        myptrs[k] = (unsigned int*)0;
    }
    myptrs[13] = (unsigned int*)&mychars[0]; // point to start of valid byte array; as this pointer will be dereferenced by _still_works

    for(k = 0; k < sizeof(mychars)/sizeof(mychars[0]); k++)
    {
        mychars[k] = 'w'; // pre-initialize byte array to 'w' / 0x77
    }

    // call function with four arguments; first argument is stored in r0, fourth argument in r3
	_still_works(myptrs[0], myptrs[13], &mychars[3564], 0xDEADBEEF);
}

