
all:  	  scrm816.hex rombios816.hex testiec.s19 testkbd.s19 testsnd.s19


scrm816.out: scrm816.asm
	ca65   scrm816.asm -l scrm816.lst -o scrm816.o
	ld65 scrm816.o -m scrm816.map -C rom816.cfg -o scrm816.out

testiec.out: testiec.asm
	ca65   testiec.asm -l testiec.lst -o testiec.o
	ld65 testiec.o -m testiec.map -C rom816.cfg -o testiec.out

testkbd.out: testkbd.asm
	ca65   testkbd.asm -l testkbd.lst -o testkbd.o
	ld65 testkbd.o -m testkbd.map -C rom816.cfg -o testkbd.out

testsnd.out: testsnd.asm
	ca65   testsnd.asm -l testsnd.lst -o testsnd.o
	ld65 testsnd.o -m testsnd.map -C rom816.cfg -o testsnd.out

rombios816.out: rombios816.asm conserial.asm iec.asm conlocal.asm macros.asm
	ca65   rombios816.asm -l rombios816.lst -o rombios816.o
	ld65 rombios816.o -m rombios816.map -C rom816.cfg -o rombios816.out


rombios816.hex: rombios816.out
	srec_cat  rombios816.out -binary -offset 0x0200 -exclude 0x0000 0xE000 -o  rombios816.s19  -data-only -address-length=3
	srec_cat  rombios816.out -binary -offset 0x0200 -exclude 0x0000 0xE000 -o  rombios816.hex  -intel -address-length=2
	sed -i -e '$$aS8' rombios816.s19
	cp rombios816.hex ../bin/

scrm816.hex: scrm816.out
	srec_cat  scrm816.out -binary -offset 0x0200 -exclude 0x0000 0xE000 -o  scrm816.s19  -data-only -address-length=3
	srec_cat  scrm816.out -binary -offset 0x0200 -exclude 0x0000 0xE000 -o  scrm816.hex  -intel -address-length=2
	sed -i -e '$$aS8' scrm816.s19
	cp scrm816.hex ../bin/

testiec.s19: testiec.out
	srec_cat  testiec.out -binary -offset 0x0200  -o  testiec.s19  -data-only -address-length=3
	sed -i -e '$$aS8' testiec.s19
	cp testiec.s19 ../bin/

testkbd.s19: testkbd.out
	srec_cat  testkbd.out -binary -offset 0x0200  -o  testkbd.s19  -data-only -address-length=3
	sed -i -e '$$aS8' testiec.s19
	cp testkbd.s19 ../bin/

testsnd.s19: testsnd.out
	srec_cat  testsnd.out -binary -offset 0x0200  -o  testsnd.s19  -data-only -address-length=3
	sed -i -e '$$aS8' testsnd.s19
	cp testsnd.s19 ../bin/

pretty:
	cp *.asm ./backup
	pretty6502 -p1 -a0 -du -mu -l ./backup/conserial.asm conserial.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/conlocal.asm conlocal.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/iec.asm iec.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/rombios816.asm rombios816.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/scrm816.asm scrm816.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/testiec.asm testiec.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/testsnd.asm testsnd.asm
	pretty6502 -p1 -a0 -du -mu -l ./backup/testkbd.asm testkbd.asm



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
