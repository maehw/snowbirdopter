#include "tiptoi.h"

// [0] http://gcc.gnu.org/onlinedocs/gcc/Return-Address.html
// [1] https://stackoverflow.com/questions/2114163/reading-a-register-value-into-a-c-variable
void main()
{
    // Variant 1) the lr is copied to r0 in this specific startup.s
    //register unsigned long nAddr asm("r0");

    // Variant 2) Determine and store the address of the caller by using a GCC builtin,
    //            this will however only return the address of the BL instruction in the startup.s
    unsigned long lr = (unsigned long)__builtin_extract_return_addr( __builtin_return_address(0) );

    // The link register then contains the address to be loaded into the pc after the function call, 
    // therefore the call is one 32-bit word earlier, i.e. subtract 4 bytes.
    //nAddr -= 4; // Var 1)
    unsigned long nAddr = lr - 4; // Var 2) no variable declared yet

	bootrom_uart_puts("called from 0x");
    bootrom_uart_put_num2hex(nAddr);
}

