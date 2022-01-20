#include "tiptoi.h"

void delay_halfsec(void);

#define GPIO_USB_DETECT       (1 << 8)
#define HEADPHONE_DETECT      (1 << 7)
#define GPIO_KEY_VOLUME_DOWN  (1 << 1)
#define GPIO_KEY_VOLUME_UP    (1 << 0)

void main()
{
    /* set pin direction to input pins;
     * it seems that only reading GPIO_USB_DETECT works so far;
     * probably need to set internal pull-up/down resistors for the other GPIO
     * input pins - but how?
     */
    *pREG_GPIO_DIR_1 |= (GPIO_USB_DETECT | HEADPHONE_DETECT | GPIO_KEY_VOLUME_DOWN | GPIO_KEY_VOLUME_UP);

    for(;;) // toggle endlessly
    {
        int regval = *pREG_GPIO_IN_1;

        bootrom_uart_puts("USB_DET=");
        if( regval & GPIO_USB_DETECT )
        {
            bootrom_uart_putc('1');
        }
        else
        {
            bootrom_uart_putc('0');
        }

        bootrom_uart_puts(",HEADPHONE_DETECT=");
        if( regval & HEADPHONE_DETECT )
        {
            bootrom_uart_putc('1');
        }
        else
        {
            bootrom_uart_putc('0');
        }

        bootrom_uart_puts(",GPIO_KEY_VOLUME_DOWN=");
        if( regval & GPIO_KEY_VOLUME_DOWN )
        {
            bootrom_uart_putc('1');
        }
        else
        {
            bootrom_uart_putc('0');
        }

        bootrom_uart_puts(",GPIO_KEY_VOLUME_UP=");
        if( regval & GPIO_KEY_VOLUME_UP )
        {
            bootrom_uart_putc('1');
        }
        else
        {
            bootrom_uart_putc('0');
        }

        bootrom_uart_putc('\n');

        delay_halfsec();
    }
}

inline void delay_halfsec(void)
{
    volatile int nDelay = 0;
    /* delay for about 0.5 seconds (determined empirically) */
    for(nDelay = 0; nDelay < (1 << 19); nDelay++)
    {
        asm("nop;");
    }
}
