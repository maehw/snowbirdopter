#include "tiptoi.h"
#include <stdbool.h>

void swuart_init(void);
void swuart_putc(char c);
inline void swuart_bitdelay(void);
inline void swuart_putbit(bool bHighLow);
void swuart_puts(char* pcString);

void main()
{
    swuart_init();

    for(;;)
    {
        swuart_puts("Hello world!\n");
    }
}

void swuart_init(void)
{
    // do not use UART TX pin with UART peripheral but as GPIO pin
    *pREG_SHARE_PIN_CTRL = *pREG_SHARE_PIN_CTRL & 0xfffffffe;

    // initialize GPIOs: write direction bit zero for GPIO as output
    *pREG_GPIO_DIR_1 = *pREG_GPIO_DIR_1 & ~(1 << 13);

    // take some time to settle on a high level before the SW UART can be used
    swuart_putbit(true);
    swuart_putbit(true);
    swuart_putbit(true);
}

void swuart_putc(char c)
{
    int nBitPos;
    
    swuart_putbit(false); /* start bit */
    
    for(nBitPos = 0; nBitPos <= 7; nBitPos++)
    {
        swuart_putbit( (c >> nBitPos) & 0x1 );
    }
    
    swuart_putbit(true); /* stop bit */
}

inline void swuart_bitdelay(void)
{
    int k;
    
    /* delay for approximately 26 useconds to get a baud rate of 38400 */
    for(k = 0; k < 25; k++)
    {
        asm("nop;");
        asm("nop;");
        asm("nop;");
        asm("nop;");
        asm("nop;");
        asm("nop;");
        asm("nop;");
        asm("nop;");
        asm("nop;");
        asm("nop;");
        asm("nop;");
        asm("nop;");
        asm("nop;");
    }
}

inline void swuart_putbit(bool bHighLow)
{
    if(bHighLow)
    {
        *pREG_GPIO_OUT_1 |=  (1 << 13);
    }
    else
    {
        *pREG_GPIO_OUT_1 &= ~(1 << 13);
    }
    swuart_bitdelay();
}

void swuart_puts(char* pcString)
{
    char* pcChar = pcString;
    while(*pcChar != '\0')
    {
        swuart_putc(*pcChar++);
    }
}

