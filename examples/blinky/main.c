#include "tiptoi.h"

void uart_deinit(void);
inline void delay_1sec(void);

void main()
{
    uart_deinit();

    // initialize GPIOs: write direction bit zero for GPIO as output
    *pREG_GPIO_DIR_1 = *pREG_GPIO_DIR_1 & ~(1 << 13);
    *pREG_GPIO_OUT_1 = *pREG_GPIO_OUT_1 & ~(1 << 13);

    for(;;) // toggle endlessly
    {
        delay_1sec();
        *pREG_GPIO_OUT_1 ^= (1 << 13); // toggle pin
    }
}

void uart_deinit(void)
{
    *pREG_SHARE_PIN_CTRL = *pREG_SHARE_PIN_CTRL & 0xfffffffe;
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
