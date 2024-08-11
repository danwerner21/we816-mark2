
all:  	  scrm816.hex rombios816.hex


scrm816.out: scrm816.asm
	ca65   scrm816.asm -l scrm816.lst -o scrm816.o
	ld65 scrm816.o -m scrm816.map -C rom816.cfg -o scrm816.out

rombios816.out: rombios816.asm conserial.asm iec.asm macros.asm
	ca65   rombios816.asm -l rombios816.lst -o rombios816.o
	ld65 rombios816.o -m rombios816.map -C rom816.cfg -o rombios816.out


rombios816.hex: rombios816.out
	srec_cat  rombios816.out -binary -offset 0x0200 -exclude 0x0000 0xE000 -o  rombios816.s19  -data-only -address-length=3
	srec_cat  rombios816.out -binary -offset 0x0200 -exclude 0x0000 0xE000 -o  rombios816.hex  -intel -address-length=2
	sed -i -e '$$aS8' rombios816.s19

scrm816.hex: scrm816.out
	srec_cat  scrm816.out -binary -offset 0x0200 -exclude 0x0000 0xE000 -o  scrm816.s19  -data-only -address-length=3
	srec_cat  scrm816.out -binary -offset 0x0200 -exclude 0x0000 0xE000 -o  scrm816.hex  -intel -address-length=2
	sed -i -e '$$aS8' scrm816.s19


pretty:
	cp *.asm ./backup
	pretty6502 -p1 -a0 -du -mu -l ./backup/conserial.asm conserial.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/iec.asm iec.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/rombios816.asm rombios816.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/scrm816.asm scrm816.asm

clean:
	@rm -f *.o
	@rm -f *.bin
	@rm -f *.lis
	@rm -f *.err
	@rm -f *.out
	@rm -f *.com
	@rm -f *.co6
	@rm -f *.map
	@rm -f *.lst
	@rm -f *.hex
	@rm -f *.s19
	@rm -f *.s19a
	@rm -f *.sys
	@rm -f *.s

cleandust:
	@rm -f *.o
	@rm -f *.out
	@rm -f *.map
	@rm -f *.lst
