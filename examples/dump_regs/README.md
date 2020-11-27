# Build and analysis steps

(work in progress)


```
arm-none-eabi-as dumpregs.s -o dumpregs.o
arm-none-eabi-ld dumpregs.o -o dumpregs.elf
arm-none-eabi-objdump --architecture=arm -D dumpregs.elf | less
```

