#include "tiptoi.h"

//extern void _still_works(unsigned int* a, unsigned int* b, unsigned char* c, unsigned int d);

int my_uart_init(void);
int my_uart_putc(int c);

void main()
{
    my_uart_init();
    my_uart_putc('X');
    my_uart_putc('Y');
    my_uart_putc('Z');
    my_uart_putc('\n');
    while(1) {};
    /* Note: dumpregs.s is currently not used */
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

