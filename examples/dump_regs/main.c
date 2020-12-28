#include "tiptoi.h"

extern void _dump_regs(void);

int my_uart_init(void);
int my_uart_putc(int c);

void main()
{
    int nRegVal = 0;

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

    // Dump some more registers
    bootrom_uart_puts("REG_SHARE_PIN_CTRL:");
    nRegVal = *pREG_SHARE_PIN_CTRL;
    bootrom_uart_put_num2hex(nRegVal);
	bootrom_uart_putc(',');
	
	//asm("mov pc, #0x0;");

    bootrom_uart_puts("REG_GPIO_DIR_1:");
    nRegVal = *pREG_GPIO_DIR_1;
    bootrom_uart_put_num2hex(nRegVal);
	bootrom_uart_putc(',');

    bootrom_uart_puts("REG_GPIO_OUT_1:");
    nRegVal = *pREG_GPIO_OUT_1;
    bootrom_uart_put_num2hex(nRegVal);
	bootrom_uart_putc(',');

    bootrom_uart_puts("REG_GPIO_DIR_2:");
    nRegVal = *pREG_GPIO_DIR_2;
    bootrom_uart_put_num2hex(nRegVal);
	bootrom_uart_putc(',');

    bootrom_uart_puts("REG_GPIO_OUT_2:");
    nRegVal = *pREG_GPIO_OUT_2;
    bootrom_uart_put_num2hex(nRegVal);
	bootrom_uart_putc(',');

    bootrom_uart_puts("REG_TBD:");
    nRegVal = *pREG_TBD;
    bootrom_uart_put_num2hex(nRegVal);
	bootrom_uart_putc(',');

    bootrom_uart_puts("REG_UART_CFG1:");
    nRegVal = *pREG_UART_CFG1;
    bootrom_uart_put_num2hex(nRegVal);
	bootrom_uart_putc(',');

    bootrom_uart_puts("REG_UART_TXRX_BUF_THRESHOLD:");
    nRegVal = *pREG_UART_TXRX_BUF_THRESHOLD;
    bootrom_uart_put_num2hex(nRegVal);
	bootrom_uart_putc(',');

    my_uart_init();

    // Print the string character by character (i.e. byte by byte) to the serial
    my_uart_putc('w');
	//bootrom_uart_putc('w');

	bootrom_uart_putc('o');

    my_uart_putc('r');
	//bootrom_uart_putc('r');

	bootrom_uart_putc('l');

	my_uart_putc('d');
	//bootrom_uart_putc('d');

	bootrom_uart_putc('!');
	bootrom_uart_putc('\n');
}

int my_uart_init(void)
{
    *pREG_SHARE_PIN_CTRL = *pREG_SHARE_PIN_CTRL | 1;
    *pREG_TBD = *pREG_TBD & 0xfc0fffff;
    *pREG_TBD = *pREG_TBD | 0x2f00020;
    *pREG_UART_CFG1 = 0x30200619;
    *pREG_UART_TXRX_BUF_THRESHOLD = 0;
    return 0;
}

int my_uart_putc(int c)
{
    int a;

    *((int*)0x0802FA80) = c;
    *((int*)0x0802FABC) = 0;
    *pREG_UART_CFG1 |= 0x10000000; // set .TX_STA_CLR
    *pREG_UART_CFG2 = 0x00010010; // set .TX_BYT_CNT_VLD and .TX_BYT_CNT
    do
    {
    } while( *pREG_UART_DATA_CFG & 0x1FFF ); // ignore 19 MSBit, leave 13 LSBit

    return 1;
}

