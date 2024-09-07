
all:  	  dbasic816.hex


dbasic816.out: dbasic816.asm definitions.asm diskcmds.asm iovect.asm macros.asm messages.asm numconst.asm screencmds.asm tokens.asm zeropage.asm diskcmds.asm screencmds.asm ay38910.asm rtc.asm
	ca65   dbasic816.asm -l dbasic816.lst -o dbasic816.o
	ld65 dbasic816.o -m dbasic816.map -C rom816.cfg -o dbasic816.out


dbasic816.hex: dbasic816.out
	srec_cat  dbasic816.out -binary -offset 0x1000  -o  dbasic816.s19  -data-only -address-length=3
	srec_cat  dbasic816.out -binary -offset 0x1000  -o  dbasic816.hex  -intel -address-length=2
	sed -i -e '$$aS8' dbasic816.s19
	cp dbasic816.hex ../bin/


pretty:
	cp *.asm ./backup
	pretty6502 -p1 -a0 -du -mu -l ./backup/dbasic816.asm dbasic816.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/definitions.asm definitions.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/diskcmds.asm diskcmds.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/iovect.asm iovect.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/messages.asm messages.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/numconst.asm numconst.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/screencmds.asm screencmds.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/tokens.asm tokens.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/zeropage.asm zeropage.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/diskcmds.asm diskcmds.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/screencmds.asm screencmds.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/ay38910.asm ay38910.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/rtc.asm rtc.asm

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
