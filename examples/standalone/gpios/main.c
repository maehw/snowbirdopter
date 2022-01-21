#include "tiptoi.h"

void delay_halfsec(void);

#define GPIO_USB_DETECT       (1 << 8)
#define HEADPHONE_DETECT      (1 << 7)
#define GPIO_KEY_VOLUME_DOWN  (1 << 1)
#define GPIO_KEY_VOLUME_UP    (1 << 0)

/*
 * Note: Please remember that you execute this code on your own risk!
 */
void main()
{
    /* set pin direction to input pins;
     * it seems that only reading GPIO_USB_DETECT works so far;
     * probably need to set internal pull-up/down resistors for the other GPIO
     * input pins - but how?
     */
    *pREG_GPIO_DIR_1 |= (GPIO_USB_DETECT | HEADPHONE_DETECT | GPIO_KEY_VOLUME_DOWN | GPIO_KEY_VOLUME_UP);

    int regval1 = -1;
    int regval2 = -1;
    int regval = -1;

    for(;;) // dump contents of what we assume to be the GPIO input value registers
    {
        regval = *pREG_GPIO_IN_1;
        bootrom_uart_puts("GPIO1:");
        bootrom_uart_put_num2hex(regval);
        if( regval1 != regval )
        {
          bootrom_uart_puts(" - changed");
        }
        regval1 = regval;

        regval = *pREG_GPIO_IN_2;
        bootrom_uart_puts(", GPIO2:");
        bootrom_uart_put_num2hex(regval);
        if( regval2 != regval )
        {
          bootrom_uart_puts(" - changed");
        }
        regval2 = regval;

        bootrom_uart_putc('\n');
        /*
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
        */

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
