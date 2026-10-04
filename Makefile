# C/ARM build of the admitted GCC 2.96 source. See README.md.
.DEFAULT_GOAL := all
ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
HOST := $(shell uname -s)-$(shell uname -m)
ifneq ($(HOST),Darwin-arm64)
$(error The admitted native build currently supports Darwin-arm64)
endif
HEADERS := auto-host.h config.h hconfig.h tm_p.h options.h specs.h gencheck.h
CONFIG := $(addprefix build/gcc/,$(HEADERS)) build/gcc/tconfig.h build/gcc/tm.h build/libiberty/config.h
.PHONY: all clean gcc libiberty
all: gcc
libiberty: $(CONFIG)
	$(MAKE) -C build/libiberty -f $(ROOT)/config/libiberty-build.mk
gcc: libiberty
	$(MAKE) -C build/gcc -f $(ROOT)/config/arm-build.mk
build/gcc/tconfig.h: config/arm/tconfig.h
	mkdir -p build/gcc
	cp $< $@
build/gcc/tm.h: config/arm/tm.h
	mkdir -p build/gcc
	cp $< $@
build/gcc/%: config/darwin-arm64/%
	mkdir -p build/gcc
	cp $< $@
build/libiberty/config.h: config/darwin-arm64/libiberty-config.h
	mkdir -p build/libiberty
	cp $< $@
clean:
	rm -rf build
