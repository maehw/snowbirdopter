#include "tiptoi.h"

void main()
{
    int nWord;
    char c;

	bootrom_uart_puts("Waiting for input.\n");

    bootrom_uart_getc(&nWord);
    c = nWord & 0xFF; /* extract char from word */

	bootrom_uart_puts("Received character. Echoing back: '");
	bootrom_uart_putc(c);
	bootrom_uart_puts("'. Done!\n");
}

