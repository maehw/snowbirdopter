#include "tiptoi.h"

extern void _dump_regs(void);

/* These functions are interface compatible with the Boot ROM functions */
int uart_init(void);
int uart_putc(int c);
void uart_puts(char* pcString);
void uart_put_num2hex(int nNum);

void main()
{
    int nRegVal = 0;

    uart_init();
	uart_puts("CPU register dump: ");

	_dump_regs();

    // Dump some more registers
    uart_puts("Peripherals register dump:");

    uart_puts("REG_CLOCK_DIV1:");
    nRegVal = *pREG_CLOCK_DIV1;
    uart_put_num2hex(nRegVal);
	uart_putc(',');

    uart_puts("REG_CLOCK_DIV2:");
    nRegVal = *pREG_CLOCK_DIV2;
    uart_put_num2hex(nRegVal);
	uart_putc(',');

    uart_puts("REG_SHARE_PIN_CTRL:");
    nRegVal = *pREG_SHARE_PIN_CTRL;
    uart_put_num2hex(nRegVal);
	uart_putc(',');
	
    uart_puts("REG_BOOT_MODE:");
    nRegVal = *pREG_BOOT_MODE;
    uart_put_num2hex(nRegVal);
	uart_putc(',');

    uart_puts("REG_GPIO_DIR_2:");
    nRegVal = *pREG_GPIO_DIR_2;
    uart_put_num2hex(nRegVal);
	uart_putc(',');

    uart_puts("REG_GPIO_OUT_2:");
    nRegVal = *pREG_GPIO_OUT_2;
    uart_put_num2hex(nRegVal);
	uart_putc(',');

    uart_puts("REG_TBD:");
    nRegVal = *pREG_TBD;
    uart_put_num2hex(nRegVal);
	uart_putc(',');

    uart_puts("REG_UART_CFG1:");
    nRegVal = *pREG_UART_CFG1;
    uart_put_num2hex(nRegVal);
	uart_putc(',');

    uart_puts("REG_UART_TXRX_BUF_THRESHOLD:");
    nRegVal = *pREG_UART_TXRX_BUF_THRESHOLD;
    uart_put_num2hex(nRegVal);

	uart_putc('\n');
}

int uart_init(void)
{
    int nBaudRateDiv = 0x0619; // leads to a baud rate of 38400; 0xC32 = 2*0x619: leads to baud rate of 19200
    *pREG_SHARE_PIN_CTRL = *pREG_SHARE_PIN_CTRL | 1;
    *pREG_TBD = *pREG_TBD & 0xfc0fffff;
    *pREG_TBD = *pREG_TBD | 0x2f00020;
    *pREG_UART_CFG1 = 0x30200000 | nBaudRateDiv;
    *pREG_UART_TXRX_BUF_THRESHOLD = 0;
    return 0;
}

int uart_putc(int c)
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

void uart_puts(char* pcString)
{
    char* pcChar = pcString;
    while(*pcChar != '\0')
    {
        uart_putc(*pcChar++);
    }
}

void uart_put_num2hex(int nNum)
{
    int nNibble;
    char cChar;

    /* print additional prefix? */
    //uart_putc( '0' );
    //uart_putc( 'x' );

    /* iterate through the 8 nibbles and print each nibble separately */
    for(nNibble = 7; nNibble >= 0; nNibble--)
    {
        cChar = (nNum >> (nNibble*4)) & 0xf;
        if(cChar >= 0x0 && cChar < 0xa)
        {
            uart_putc( 0x30 + cChar );
        }
        else /* if(cChar >= 0xa && cChar <= 0xf) */
        {
            uart_putc( 0x61 - 0xa + cChar );
        }
    }
}


