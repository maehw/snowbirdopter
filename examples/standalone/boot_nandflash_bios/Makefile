all:
	arm-none-eabi-gcc -T ../tiptoi.ld -nostdlib startup.s main.c -I ../include
	arm-none-eabi-objdump -d a.out 	
	arm-none-eabi-objcopy -O binary a.out out.bin

clean:
	rm -f out.bin a.out

