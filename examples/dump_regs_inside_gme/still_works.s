.section .text
.global _still_works

_still_works:
    push {r4, r5, r6, r7, r8, r9, sl, lr}
    bl _dump_regs
    ldr r5, [r0, #52]    @ 0x34
    mov r0, #255         @ 0xff
    strb r0, [r5, #3564] @ 0xdec
    pop {r4, r5, r6, r7, r8, r9, sl, pc}

