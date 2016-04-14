all:
	$(MAKE) -C boot
	$(MAKE) -C kernel

ima:boot/boot.bin
	dd if=boot/boot.bin of=coreos.ima bs=512 count=2880
	rm -r boot/boot.bin
	mkdir coreos
	mount coreos.ima coreos
	cp -r boot coreos && cp -r kernel coreos
	umount coreos && rm -r coreos
	
clean:
	$(MAKE) clean -C boot
	$(MAKE) clean -C kernel
