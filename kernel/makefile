FILES=$(patsubst %.asm,%,$(wildcard *.asm))

all:
	for i in $(FILES);do nasm -f elf $$i.asm -o $$i.o;done
	gcc -c -fno-builtin *.c
	ld -s -Ttext 0x30400 -o kernel.bin *.o

clean:
	rm -f *.o *.bin
