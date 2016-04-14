FILES=$(patsubst %.asm,%,$(wildcard *.asm))

all:
	for i in $(FILES);do nasm $$i.asm -o $$i.bin;done

clean:
	rm -r *.bin
