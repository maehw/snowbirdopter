.section .text
.global _dump_regs

_dump_regs:
    @ https://stackoverflow.com/questions/47109767/push-and-pop-order-in-arm/47109995:
    @ "When you PUSH or POP a bunch of registers, they always go into memory in the same relative positions, regardless of direction.
    @  The lowest-numberd register is stored at and loaded from the lowest address."
    @
    @ make sure that the UART has already been initialized by the caller
    push {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, lr} @ r10/sl, r11/fp, r12/ip, r14/lr; do not store r13/sp and r15/pc on the stack!

    @ first operand of 'mov' instruction is the destination registers; so store sp in r4
    mov r4, sp

    @ load immediate value 0x00000072 into r0
    @ where 0x00000072 represents the characters '\0\0\0r' (reverse byte order of NULL-terminated C string "r")
    mov r0, #0x00000072
    push {r0}

    orr r0, #0x00006500
    orr r0, #0x00670000
    orr r0, #0x20000000
    @ load immediate value 0x20676500 which represents the characters ' ger' (reverse byte order of the C string "reg ")
    push {r0}

    @ print the string that we've just pushed onto the stack
    mov r0, sp
    bl uart_puts

    mov r0, #48  @ represents the ASCII character for '0'
    bl uart_putc

    mov r0, #58  @ represents the ASCII character for a colon ':'
    bl uart_putc

    ldr r0, [r4, #0]  @ dump register r0 which has been stored on the stack; location is pointed to by r4 (the old sp)
    bl uart_put_num2hex

    mov r0, #44  @ ASCII character ','
    bl uart_putc


    @ dump stored r1, starting with the prefix string
    mov r0, sp
    bl uart_puts

    mov r0, #49
    bl uart_putc

    mov r0, #58
    bl uart_putc

    ldr r0, [r4, #4]
    bl uart_put_num2hex

    mov r0, #44
    bl uart_putc


    @ dump stored r2
    mov r0, sp
    bl uart_puts

    mov r0, #50
    bl uart_putc

    mov r0, #58
    bl uart_putc

    ldr r0, [r4, #8]
    bl uart_put_num2hex

    mov r0, #44
    bl uart_putc


    @ dump stored r3
    mov r0, sp
    bl uart_puts

    mov r0, #51
    bl uart_putc

    mov r0, #58
    bl uart_putc

    ldr r0, [r4, #12]
    bl uart_put_num2hex

    mov r0, #44
    bl uart_putc


    @ dump stored r4
    mov r0, sp
    bl uart_puts

    mov r0, #52
    bl uart_putc

    mov r0, #58
    bl uart_putc

    ldr r0, [r4, #16]
    bl uart_put_num2hex

    mov r0, #44
    bl uart_putc


    @ dump stored r5
    mov r0, sp
    bl uart_puts

    mov r0, #53
    bl uart_putc

    mov r0, #58
    bl uart_putc

    ldr r0, [r4, #20]
    bl uart_put_num2hex

    mov r0, #44
    bl uart_putc


    @ dump stored r6
    mov r0, sp
    bl uart_puts

    mov r0, #54
    bl uart_putc

    mov r0, #58
    bl uart_putc

    ldr r0, [r4, #24]
    bl uart_put_num2hex

    mov r0, #44
    bl uart_putc


    @ dump stored r7
    mov r0, sp
    bl uart_puts

    mov r0, #55
    bl uart_putc

    mov r0, #58
    bl uart_putc

    ldr r0, [r4, #28]
    bl uart_put_num2hex

    mov r0, #44
    bl uart_putc


    @ dump stored r8
    mov r0, sp
    bl uart_puts

    mov r0, #56
    bl uart_putc

    mov r0, #58
    bl uart_putc

    ldr r0, [r4, #32]
    bl uart_put_num2hex

    mov r0, #44
    bl uart_putc


    @ dump stored r9
    mov r0, sp
    bl uart_puts

    mov r0, #57
    bl uart_putc

    mov r0, #58
    bl uart_putc

    ldr r0, [r4, #36]
    bl uart_put_num2hex

    mov r0, #44
    bl uart_putc


    @ dump stored r10
    mov r0, sp
    bl uart_puts

    mov r0, #49
    bl uart_putc

    mov r0, #48
    bl uart_putc

    mov r0, #58
    bl uart_putc

    ldr r0, [r4, #40]
    bl uart_put_num2hex

    mov r0, #44
    bl uart_putc


    @ dump stored r11
    mov r0, sp
    bl uart_puts

    mov r0, #49
    bl uart_putc

    mov r0, #49
    bl uart_putc

    mov r0, #58
    bl uart_putc

    ldr r0, [r4, #44]
    bl uart_put_num2hex

    mov r0, #44
    bl uart_putc


    @ dump stored r12
    mov r0, sp
    bl uart_puts

    mov r0, #49
    bl uart_putc

    mov r0, #50
    bl uart_putc

    mov r0, #58
    bl uart_putc

    ldr r0, [r4, #48]
    bl uart_put_num2hex

    mov r0, #44
    bl uart_putc


    @ dump stored r13/sp
    mov r0, sp
    bl uart_puts

    mov r0, #49
    bl uart_putc

    mov r0, #51
    bl uart_putc

    mov r0, #58
    bl uart_putc

    mov r0, r4 @ use stack pointer (sp) stored after epilog
    bl uart_put_num2hex

    mov r0, #44
    bl uart_putc


    @ dump stored r14/lr
    mov r0, sp
    bl uart_puts

    mov r0, #49
    bl uart_putc

    mov r0, #52
    bl uart_putc

    mov r0, #58
    bl uart_putc

    ldr r0, [r4, #52]
    bl uart_put_num2hex

    mov r0, #44
    bl uart_putc


    @ dump current r15/pc
    mov r0, sp
    bl uart_puts

    mov r0, #49
    bl uart_putc

    mov r0, #53
    bl uart_putc

    mov r0, #58
    bl uart_putc

    mov r0, pc
    bl uart_put_num2hex

    mov r0, #44
    bl uart_putc

    add sp, #8 @ to pop 2 elements with constant string
    pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, pc}
