#include "tiptoi.h"

typedef void func(void);

void uart_dump_mem(unsigned int* pInputStartAddr, unsigned int* pInputEndAddr)
{
    unsigned int *pDataAddress;
    unsigned int nDataValue;
    unsigned int nCnt = 1;
    char dumpHeader[] = "   Adress \t    0   \t     4    \t     8    \t     c\n";

    bootrom_uart_puts(dumpHeader);
    pDataAddress = pInputStartAddr;
    while(pDataAddress <= pInputEndAddr)
    {
        /* read memory from given address */
        nDataValue = *pDataAddress;

        /* dump the value in a human-readable format */
        if( (nCnt & 3) == 1 )
        {
            bootrom_uart_puts("0x");
            bootrom_uart_put_num2hex((unsigned int)pDataAddress);
            bootrom_uart_puts(": 0x");
            bootrom_uart_put_num2hex(nDataValue);
        }
        else
        {
            bootrom_uart_puts("\t0x");
            bootrom_uart_put_num2hex(nDataValue);
        }
        if( (nCnt & 3) == 0 )
        {
            bootrom_uart_putc('\n');
        }

        pDataAddress++;
        nCnt++;
    }
}

void main()
{
    int nRxWord;
    int nSuccess;
    char c;
    unsigned int* pStartAddress = (unsigned int*)0x08000000;
    unsigned int* pEndAddress   = (unsigned int*)0x080001ff;
    func* run_software_bios = (func*)0x08000000;

    unsigned int* pAddress = pStartAddress;
    unsigned int nWordCount;
    const unsigned int nInitializeZeros = 1; /* flag to decide if memory shall be zeroed or not */

    if( nInitializeZeros )
    {
        /* initialize the whole BIOS memory region to zeros, i.e. 0x08000000..0x0800FFFF (64 Kbyte) */
        for( nWordCount = 0; nWordCount < 16384; nWordCount++ )
        {
            *pAddress++ = 0;
        }
    }

    bootrom_uart_puts("Program to load software BIOS from NAND flash. Send char to dump memory from address 0x08000000.\n");
    bootrom_uart_getc(&nRxWord);

    bootrom_uart_puts("Rx'ed character. Dumping memory from address 0x08000000 (should read zeros or garbage)...\n");
    /* dump memory using bootrom's UART functions */
    uart_dump_mem(pStartAddress, pEndAddress);

    bootrom_uart_puts("Done. Send another character to load the software BIOS via bootrom and then dump again.\n");
    bootrom_uart_getc(&nRxWord);

    nSuccess = bootrom_nandflash_loadbios();
    if( nSuccess )
    {
        bootrom_uart_puts("Successfully loaded software BIOS from NAND flash.");
    }
    else
    {
        bootrom_uart_puts("Failed to load software BIOS from NAND flash.");
    }
    bootrom_uart_puts(" Dumping same memory region again (should read BIOS code)...\n");
    uart_dump_mem(pStartAddress, pEndAddress);

    bootrom_uart_puts("Done. Run the loaded BIOS? [y/n]\n");
    bootrom_uart_getc(&nRxWord);
    c = nRxWord & 0xFF;

    if( c == 'y' || c == 'Y' )
    {
        run_software_bios(); /* run the software BIOS loaded at address 0x08000000 by calling run_software_bios() */
    }
    else
    {
        bootrom_uartboot(); /* "reboot" via uartboot: if called over and over again this may build up a larger stack and potentially lead to a stack overflow at some point in time */
    }
}
