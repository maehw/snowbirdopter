#ifndef __TIPTOI_REGS_H__
#define __TIPTOI_REGS_H__

// The following hardware registers have been found and (mostly) understood what they are used for
volatile int* const pREG_BOOT_MODE = (int*)0x04000054;
volatile int* const pREG_SHARE_PIN_CTRL = (int*)0x4000074; /* value in UART boot is read as 0x00005001; it seems that bit 0 is responsible for UART TX */

#endif /* __TIPTOI_REGS_H__ */

