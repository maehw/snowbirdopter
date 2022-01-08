all:
	arm-none-eabi-as dumpregs.s -o dumpregs.o
	arm-none-eabi-gcc -T ../../tiptoi.ld -nostdlib main.c dumpregs.o -I ../../include -o main.o
	arm-none-eabi-objdump -d main.o
	arm-none-eabi-objcopy -O binary main.o out.bin

clean:
	rm -f *.o *.elf *.bin
