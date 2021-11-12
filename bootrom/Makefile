bootrom_img = bootrom.img
bootrom_rev_mem = bootrom.bytereversed.mem
bootrom_mem = bootrom.mem
bootrom_coe = bootrom.coe

NO_PCI?=0
CPU_SPEED?=0
RTC_FREQ?=0
MEM_SIZE?=0x3f000000
NUM_CORES?=1
CROSS_COMPILE?=riscv64-unknown-elf-
CPP=$(CROSS_COMPILE)cpp
GCC=$(CROSS_COMPILE)gcc
OBJCOPY=$(CROSS_COMPILE)objcopy
OBJDUMP=$(CROSS_COMPILE)objdump
DTC=dtc

all: $(bootrom_img) $(bootrom_mem) $(bootrom_coe) $(bootrom_rev_mem)

%.mem: %.bin
	(echo @00000000; od -tx4 -An -w4 -v $<) > $@

%.bytereversed.mem: %.mem
	cat $< | ./byteReverseMem.py > $@

%.coe: %.bin
	hexdump -e '16/4 "%02x " "\n"' $*.bin > $*.hex
	./genCoe.py > $@

%.img: %.bin
	dd if=$< of=$@ bs=1440 count=1

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

%.dump: %.elf
	$(OBJDUMP) -d $< > $@

%.dtb: %.dts
	$(CPP) -x assembler-with-cpp -DCPU_SPEED=$(CPU_SPEED) -DRTC_FREQ=$(RTC_FREQ) -DMEM_SIZE=$(MEM_SIZE) -DNO_PCI=$(NO_PCI) -DNUM_CORES=$(NUM_CORES) -DPROC_HASH="\"$(PROC_HASH)\"" -DGFE_HASH="\"$(GFE_HASH)\"" $< | $(DTC) -O dtb -o $@

%.elf: %.S linker.ld devicetree.dtb
	$(GCC) -Tlinker.ld $< -nostdlib -static -Wl,--no-gc-sections -o $@

clean:
	rm -f *.coe *.img *.bin *.dump *.elf *.mem.bytereversed *.mem
