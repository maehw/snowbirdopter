all:
	arm-none-eabi-gcc -T ../../tiptoi.ld -nostdlib main.c -I ../../include -o main.o
	arm-none-eabi-objdump -d main.o
	arm-none-eabi-objcopy -O binary main.o out.bin

clean:
	rm -f *.o *.elf *.bin
