.section .text
.global _still_works
.global _dump_regs

_still_works:
    push {r4, r5, r6, r7, r8, r9, sl, lr}
    bl _dump_regs
    ldr r5, [r0, #52]    @ 0x34
    mov r0, #255         @ 0xff
    strb r0, [r5, #3564] @ 0xdec
    pop {r4, r5, r6, r7, r8, r9, sl, pc}

_dump_regs:
    @ https://stackoverflow.com/questions/47109767/push-and-pop-order-in-arm/47109995:
    @ "When you PUSH or POP a bunch of registers, they always go into memory in the same relative positions, regardless of direction.
    @  The lowest-numberd register is stored at and loaded from the lowest address."
    push {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, lr} @ r10/sl, r11/fp, r12/ip, r14/lr; do not store r13/sp and r15/pc on the stack!

    mov r4, sp

    mov r0, #0x00000072
    push {r0} @ '\0\0\0r' (reverse byte order of "r")

    orr r0, #0x00006500
    orr r0, #0x00670000
    orr r0, #0x20000000
    push {r0} @ ' ger' (reverse byte order of "reg ")


    @ init the UART
    bl 0x10D8


    @ dump stored r0
    mov r0, sp
    bl 0x159C

    mov r0, #48
    bl 0x1504

    mov r0, #58
    bl 0x1504

    ldr r0, [r4, #0]
    bl 0x1810

    mov r0, #44
    bl 0x1504


    @ dump stored r1
    mov r0, sp
    bl 0x159C

    mov r0, #49
    bl 0x1504

    mov r0, #58
    bl 0x1504

    ldr r0, [r4, #4]
    bl 0x1810

    mov r0, #44
    bl 0x1504


    @ dump stored r2
    mov r0, sp
    bl 0x159C

    mov r0, #50
    bl 0x1504

    mov r0, #58
    bl 0x1504

    ldr r0, [r4, #8]
    bl 0x1810

    mov r0, #44
    bl 0x1504


    @ dump stored r3
    mov r0, sp
    bl 0x159C

    mov r0, #51
    bl 0x1504

    mov r0, #58
    bl 0x1504

    ldr r0, [r4, #12]
    bl 0x1810

    mov r0, #44
    bl 0x1504


    @ dump stored r4
    mov r0, sp
    bl 0x159C

    mov r0, #52
    bl 0x1504

    mov r0, #58
    bl 0x1504

    ldr r0, [r4, #16]
    bl 0x1810

    mov r0, #44
    bl 0x1504


    @ dump stored r5
    mov r0, sp
    bl 0x159C

    mov r0, #53
    bl 0x1504

    mov r0, #58
    bl 0x1504

    ldr r0, [r4, #20]
    bl 0x1810

    mov r0, #44
    bl 0x1504


    @ dump stored r6
    mov r0, sp
    bl 0x159C

    mov r0, #54
    bl 0x1504

    mov r0, #58
    bl 0x1504

    ldr r0, [r4, #24]
    bl 0x1810

    mov r0, #44
    bl 0x1504


    @ dump stored r7
    mov r0, sp
    bl 0x159C

    mov r0, #55
    bl 0x1504

    mov r0, #58
    bl 0x1504

    ldr r0, [r4, #28]
    bl 0x1810

    mov r0, #44
    bl 0x1504


    @ dump stored r8
    mov r0, sp
    bl 0x159C

    mov r0, #56
    bl 0x1504

    mov r0, #58
    bl 0x1504

    ldr r0, [r4, #32]
    bl 0x1810

    mov r0, #44
    bl 0x1504


    @ dump stored r9
    mov r0, sp
    bl 0x159C

    mov r0, #57
    bl 0x1504

    mov r0, #58
    bl 0x1504

    ldr r0, [r4, #36]
    bl 0x1810

    mov r0, #44
    bl 0x1504


    @ dump stored r10
    mov r0, sp
    bl 0x159C

    mov r0, #49
    bl 0x1504

    mov r0, #48
    bl 0x1504

    mov r0, #58
    bl 0x1504

    ldr r0, [r4, #40]
    bl 0x1810

    mov r0, #44
    bl 0x1504


    @ dump stored r11
    mov r0, sp
    bl 0x159C

    mov r0, #49
    bl 0x1504

    mov r0, #49
    bl 0x1504

    mov r0, #58
    bl 0x1504

    ldr r0, [r4, #44]
    bl 0x1810

    mov r0, #44
    bl 0x1504


    @ dump stored r12
    mov r0, sp
    bl 0x159C

    mov r0, #49
    bl 0x1504

    mov r0, #50
    bl 0x1504

    mov r0, #58
    bl 0x1504

    ldr r0, [r4, #48]
    bl 0x1810

    mov r0, #44
    bl 0x1504


    @ dump stored r13/sp
    mov r0, sp
    bl 0x159C

    mov r0, #49
    bl 0x1504

    mov r0, #51
    bl 0x1504

    mov r0, #58
    bl 0x1504

    mov r0, r4 @ use stack pointer (sp) stored after epilog
    bl 0x1810

    mov r0, #44
    bl 0x1504


    @ dump stored r14/lr
    mov r0, sp
    bl 0x159C

    mov r0, #49
    bl 0x1504

    mov r0, #52
    bl 0x1504

    mov r0, #58
    bl 0x1504

    ldr r0, [r4, #52]
    bl 0x1810

    mov r0, #44
    bl 0x1504


    @ dump current r15/pc
    mov r0, sp
    bl 0x159C

    mov r0, #49
    bl 0x1504

    mov r0, #53
    bl 0x1504

    mov r0, #58
    bl 0x1504

    mov r0, pc
    bl 0x1810

    mov r0, #44
    bl 0x1504


    mov r0, #10
    bl 0x1504


    add sp, #8 @ to pop 2 elements with constant string
    pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, pc}

