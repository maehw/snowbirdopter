#include "tiptoi.h"

void uart_deinit(void);
void delay_1sec(void);

/* Define which GPIO(s)/LED(s) you want to toggle/blink.
 * Note: GPIO12 and GPIO13 are typically used for UART RX and TX.
 */
#define BLINK_GPIO12 1
#define BLINK_GPIO13 1

void main()
{
    uart_deinit();

    // initialize GPIOs: write direction bit zero for GPIO as output
#if BLINK_GPIO12
    *pREG_GPIO_DIR_1 &= ~(1 << 12);
    *pREG_GPIO_OUT_1 &= ~(1 << 12);
#endif
#if BLINK_GPIO13
    *pREG_GPIO_DIR_1 &= ~(1 << 13);
    *pREG_GPIO_OUT_1 &= ~(1 << 13);
#endif

    for(;;) // toggle endlessly
    {
#if BLINK_GPIO12
        *pREG_GPIO_OUT_1 ^= (1 << 12); // toggle pin GPIO12
#endif
        delay_1sec();
#if BLINK_GPIO13
        *pREG_GPIO_OUT_1 ^= (1 << 13); // toggle pin GPIO13
#endif
    }
}

void uart_deinit(void)
{
    /* clear least significant bit of the register */
    *pREG_SHARE_PIN_CTRL = *pREG_SHARE_PIN_CTRL & 0xfffffffe;
}

inline void delay_1sec(void)
{
    volatile int nDelay = 0;
    /* delay for about 1 second (determined empirically) */
    for(nDelay = 0; nDelay < (1 << 20); nDelay++)
    {
        asm("nop;");
    }
}
