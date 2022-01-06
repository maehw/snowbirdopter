#include "tiptoi.h"

extern void _dump_regs(void);

/* These functions are interface compatible with the Boot ROM functions */
int uart_init(void);
int uart_putc(int c);
void uart_puts(char* pcString);
void uart_put_num2hex(int nNum);

void delay_1sec(void);


void main()
{
    // the following lines should blink/toggle GPIO13 endlessly
    *pREG_SHARE_PIN_CTRL = *pREG_SHARE_PIN_CTRL & 0xfffffffe;

    // initialize GPIOs: write direction bit zero for GPIO as output
    *pREG_GPIO_DIR_1 = *pREG_GPIO_DIR_1 & ~(1 << 13);
    *pREG_GPIO_OUT_1 = *pREG_GPIO_OUT_1 & ~(1 << 13);

    for(;;) // toggle endlessly
    {
        delay_1sec();
        *pREG_GPIO_OUT_1 ^= (1 << 13); // toggle pin
    }
}

inline void delay_1sec(void)
{
    volatile int nDelay = 0;
    /* delay for about 1 second (empirical) */
    for(nDelay = 0; nDelay < (1 << 20); nDelay++)
    {
        asm("nop;");
    }
}

#if 0

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

#endif

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
