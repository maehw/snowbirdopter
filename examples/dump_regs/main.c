#include "tiptoi.h"

extern void _dump_regs(void);

void main()
{
	// Define a string on the stack
	char* pcString = "Hello Tiptoi!";

    // Print the string
	bootrom_uart_puts(pcString);

	bootrom_uart_putc(' ');
	bootrom_uart_putc('H');
	bootrom_uart_putc('e');
	bootrom_uart_putc('l');
	bootrom_uart_putc('l');
	bootrom_uart_putc('o');
	bootrom_uart_putc(' ');

	_dump_regs();

    // Print the string character by character (i.e. byte by byte) to the serial
	bootrom_uart_putc('w');
	bootrom_uart_putc('o');
	bootrom_uart_putc('r');
	bootrom_uart_putc('l');
	bootrom_uart_putc('d');
	bootrom_uart_putc('!');
	bootrom_uart_putc('\n');
	
}

