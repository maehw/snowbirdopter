#include "tiptoi.h"

void main()
{
    int nWord;
    char cBootMode;
    int nBootMode;

    /* Read the boot mode register and print its value;
     * print via UART bootrom functions
     */
    nBootMode = *pREG_BOOT_MODE;
    bootrom_uart_puts("Boot mode register: ");
    bootrom_uart_put_num2hex(nBootMode);
    bootrom_uart_puts(". Boot will be redirected. Which bode mode to use? m/M=massboot, u/U=usbboot, s/S=SPI flash boot, n/N=NAND flash boot (default).\n");

    /* Wait for user input */
    bootrom_uart_getc(&nWord);
    cBootMode = nWord & 0xFF;

    /* Decide what to do dependent on user input;
     * call bootrom function for boot mode selected by user input
     * (not the hardware boot mode)
     */
    switch( cBootMode )
    {
        case 'm':
        case 'M':
            bootrom_uart_puts("Trying to boot via massboot.\n");
            bootrom_massboot();
            break;
        case 'u':
        case 'U':
            bootrom_uart_puts("Trying to boot via usbboot.\n");
            bootrom_usbboot();
            break;
        case 's':
        case 'S':
            bootrom_uart_puts("Trying to boot via SPI flash.\n");
            bootrom_spiflash_boot();
            break;
        case 'l':
        case 'L':
            bootrom_uart_puts("Trying to boot via UART boot.\n");
            bootrom_uartboot();
        case 'n':
        case 'N':
        default:
            bootrom_uart_puts("Trying to boot via NAND flash.\n");
            bootrom_nandflash_boot();
            break;
    }
}
