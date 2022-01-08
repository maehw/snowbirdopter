#include "tiptoi.h"

void main()
{
    int nWord;
    char c;

    /* Receive one byte from the serial and echo it back to the sender */
    while(1)
    {
        bootrom_uart_puts("Waiting for serial input (single character).\n");

        bootrom_uart_getc(&nWord);
        c = nWord & 0xFF; /* extract char from word */

        bootrom_uart_puts("Received character. Echoing back: '");
        bootrom_uart_putc(c);
        bootrom_uart_puts("'. Done!\n");
    }
}
