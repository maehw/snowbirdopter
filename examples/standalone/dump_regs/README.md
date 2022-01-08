# Build and analysis steps

see Makefile, the following `arm-none-eabi-*` tools are used:

* as,
* ld,
* objdump and
* objcopy



# Execute

Enter UART boot mode.

Execute the binary using snowbirdopter:

```$ python3 snowbirdopter.py -p /dev/ttyUSB0 -c exec -f ./examples/dump_regs/out.bin -a 08010000```

The command line and the output should look similar to:

```$ python3 snowbirdopter.py -p /dev/ttyUSB0 -c exec -f ./examples/dump_regs/out.bin -a 08010000
[DEBUG] payload length: 2312, overall download length: 2318
[INFO] Loading binfile succeeded.
[DEBUG] go to address 0x08010000
[INFO] Read from serial: b'Hello Tiptoi! Hello reg r0:00000001,reg r1:0802ee84,reg r2:04036004,reg r3:00000000,reg r4:db7997e3,reg r5:45bd17df,reg r6:06be7e3d,reg r7:1b66cc1f,reg r8:57cff67f,reg r9:1bfdeccf,reg r10:f7c6dbe1,reg r11:0802ee80,reg r12:0802ee74,reg r13:0802ee3c,reg r14:080100c0,reg r15:080107c8,REG_SHARE_PIN_CTRL:00005001,REG_GPIO_DIR_1:ffffffff,REG_GPIO_OUT_1:00000000,REG_GPIO_DIR_2:ffffffff,REG_GPIO_OUT_2:00000000,REG_TBD:02f00024,REG_UART_CFG1:00200619,REG_UART_TXRX_BUF_THRESHOLD:00000000,world!\n'
```

