.section .text
.global _dump_regs

_dump_regs:
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

    @ dump r15/pc from within this function
    mov r0, sp
    bl 0x159C

    mov r0, #49
    bl 0x1504

    mov r0, #53
    bl 0x1504

    mov r0, #58
    bl 0x1504

    mov r0, pc @ offset as we are in the middle of this function
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

    ldr r0, [r4]
    bl 0x1810

    mov r0, #44
    bl 0x1504


    @ dump r13/sp from within this function
    mov r0, sp
    bl 0x159C

    mov r0, #49
    bl 0x1504

    mov r0, #51
    bl 0x1504

    mov r0, #58
    bl 0x1504

    mov r0, r4 @ offset by number of stored registers
    bl 0x1810

    mov r0, #10
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

    ldr r0, [r4, #4]
    bl 0x1810

    mov r0, #44
    bl 0x1504


    @ dump stored r11
    mov r0, sp
    bl 0x159C

    mov r0, #49
    bl 0x1504

    mov r0, #50
    bl 0x1504
    bl 0x1504

    ldr r0, [r4, #8]
    bl 0x1810

    mov r0, #44
    bl 0x1504


    pop {r0}
    pop {r0}
    pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, pc}

