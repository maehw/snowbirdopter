#include "tiptoi.h"

void compare_strings(void);

void main()
{
    compare_strings();

    /* more functions to be added in the future */
}

void compare_strings(void)
{
    char sString1[] = "Foo";
    char sString2[] = "Bar";
    char sString3[] = "Foo";
    
    if( bootrom_strcmp(sString1, sString2) )
    {
	    bootrom_uart_puts("Strings 1 and 2 do not match. ");
    }
    else
    {
	    bootrom_uart_puts("Strings 1 and 2 do match. ");
    }
    
    if( bootrom_strcmp(sString1, sString3) )
    {
	    bootrom_uart_puts("Strings 1 and 3 do not match.\n");
    }
    else
    {
	    bootrom_uart_puts("Strings 1 and 3 do match.\n");
    }
}
