#include "tiptoi.h"
#include <stdbool.h>

void swuart_init(void);
void swuart_putc(char c);
void swuart_bitdelay(void);
void swuart_putbit(bool bHighLow);
void swuart_puts(char* pcString);

/* Allow querying of USB detection pin (GPIO8) as application demo for this example;
 * when commenting out the following line, a simple 'Hello world' message will be
 * printed.
 */
#define CHECK_USB_CABLE

/* The main purpose of this demo is to show that we can toggle the UART TX GPIO
 * pin to send characters serially without initializing the UART peripheral or
 * using bootrom code.
 */
void main()
{
    swuart_init();

    swuart_puts("Hello world!\n");
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
