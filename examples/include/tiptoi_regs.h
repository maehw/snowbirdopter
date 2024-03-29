#ifndef __TIPTOI_REGS_H__
#define __TIPTOI_REGS_H__

// The following hardware registers have been found and (mostly) understood what they are used for
volatile int* const pREG_CLOCK_DIV1              = (int*)0x04000004;
volatile int* const pREG_CLOCK_DIV2              = (int*)0x04000008;
volatile int* const pREG_BOOT_MODE               = (int*)0x04000054;
volatile int* const pREG_SHARE_PIN_CTRL          = (int*)0x04000074; /* value in UART boot is read as 0x00005001; it seems that bit 0 is responsible for UART TX */
volatile int* const pREG_GPIO_DIR_1              = (int*)0x0400007c;
volatile int* const pREG_GPIO_DIR_2              = (int*)0x04000084;
volatile int* const pREG_GPIO_OUT_1              = (int*)0x04000080;
volatile int* const pREG_GPIO_OUT_2              = (int*)0x04000088;
volatile int* const pREG_GPIO_GPIO_PULL_UD_1     = (int*)0x0400009C;
volatile int* const pREG_GPIO_GPIO_PULL_UD_2     = (int*)0x040000A0;
volatile int* const pREG_GPIO_IN_1               = (int*)0x040000BC;
volatile int* const pREG_GPIO_IN_2               = (int*)0x040000C0;
volatile int* const pREG_TBD                     = (int*)0x0401C000;
volatile int* const pREG_UART_CFG1               = (int*)0x04036000;
volatile int* const pREG_UART_CFG2               = (int*)0x04036004;
volatile int* const pREG_UART_DATA_CFG           = (int*)0x04036008;
volatile int* const pREG_UART_TXRX_BUF_THRESHOLD = (int*)0x0403600C;

#endif /* __TIPTOI_REGS_H__ */
