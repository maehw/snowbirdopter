#ifndef __TIPTOI_BOOTROM_H__
#define __TIPTOI_BOOTROM_H__

// The following functions have been found in the BOOT ROM
int (*bootrom_strcmp)(char*,char*)   = (void*)0x00000140;
void (*bootrom_memcpy)(unsigned int*,unsigned int*,unsigned int) = (void*)0x000001EC;
void (*bootrom_uartboot)(void)       = (void*)0x00000830;
int (*bootrom_uart_hex2num)(char)    = (void*)0x0000103C;
int (*bootrom_uart_init)(void)       = (void*)0x000010D8;
int (*bootrom_uart_getc)(int*)       = (void*)0x000013A8;
int (*bootrom_uart_putc)(char)       = (void*)0x00001504;
int (*bootrom_uart_puts)(char*)      = (void*)0x0000159C;
void (*bootrom_uart_put_num2hex)(unsigned int) = (void*)0x00001810;
void (*bootrom_massboot)(void)       = (void*)0x00000098;
void (*bootrom_spiflash_boot)(void)  = (void*)0x00000064;
void (*bootrom_nandflash_boot)(void) = (void*)0x0000007C;
void (*bootrom_usbboot)(void)        = (void*)0x00002840;
void (*bootrom_nandflash_loadbios_init)(void) = (void*)0x000019A4;
void (*bootrom_nandflash_config_12bit_param)(unsigned int) = (void*)0x00001AA4;
int (*bootrom_nandflash_loadbios)(void) = (void*)0x00000A68;

#endif /* __TIPTOI_BOOTROM_H__ */

