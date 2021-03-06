CC=gcc
LD ?= ld
OBJCOPY ?= objcopy
RUSTC := rustc --cfg libc -Z no-landing-pads -O --target i386-intel-linux
NASM=nasm
QEMU=qemu-system-i386
BUILDDIR=./build
OBJDIR=$(BUILDDIR)/obj


OBJS := $(OBJDIR)/runtime.asm.o $(OBJDIR)/main.o $(OBJDIR)/isr_wrapper.asm.o

all: $(BUILDDIR)/floppy.img

.SUFFIXES:

.SUFFIXES: .o .rs .asm

.PHONY: clean run

$(OBJDIR)/%.asm.o: src/%.asm
	mkdir -p $(OBJDIR)
	$(NASM) -f elf -o $@ $<

$(OBJDIR)/%.bc: src/%.rs
	mkdir -p $(OBJDIR)
	$(RUSTC) src/rust-core/core/lib.rs --out-dir $(BUILDDIR)
	$(RUSTC) --emit bc -L $(BUILDDIR) -o $@ $<

$(OBJDIR)/%.o: $(OBJDIR)/%.bc
	clang -c -O2 -o $@ $<


$(BUILDDIR)/loader.bin: src/loader.asm
	mkdir -p $(BUILDDIR)
	$(NASM) -o $@ -f bin $<

$(BUILDDIR)/main.elf: src/linker.ld $(OBJS) 
	mkdir -p $(BUILDDIR)
	$(LD) -Map=$(BUILDDIR)/linker.map -o $@ -T $^ "-(" build/libcore-caef0f5f-0.0.rlib "-)"

$(BUILDDIR)/main.bin: $(BUILDDIR)/main.elf
	mkdir -p $(BUILDDIR)
	$(OBJCOPY) -O binary $< $@

$(BUILDDIR)/floppy.img: $(BUILDDIR)/loader.bin $(BUILDDIR)/main.bin
	cat $^ > $@

run: $(BUILDDIR)/floppy.img
	$(QEMU) -serial stdio -fda $<

debug: $(BUILDDIR)/floppy.img
	$(QEMU) -monitor stdio -fda $<

clean:
	-rm -rf $(BUILDDIR)
