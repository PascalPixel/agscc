# Stock GCC 2.95.2 ARM compiler. Host compatibility only; no target changes.
.DEFAULT_GOAL := all
ROOT := $(abspath .)
VERSION := 2.95.2
SHA256 := 064e1cb06ea5d2f4a07ec46c1c64d771f74d04f404b6a6766bca2477f7d72482
ARCHIVE := sources/gcc-$(VERSION).tar.gz
SOURCE := sources/gcc-$(VERSION)
BUILD := build
JOBS ?= 8
HOST_OS := $(shell uname -s)
HOST_CC := clang
ifeq ($(HOST_OS),Darwin)
HOST_CC += -arch x86_64
endif
HOST_CFLAGS := -O2 -std=gnu89 -Wno-implicit-function-declaration -Wno-int-conversion -Wno-incompatible-pointer-types -Wno-deprecated-non-prototype -fcommon

.PHONY: all clean verify-source
all: $(BUILD)/Makefile
	$(MAKE) -C $(BUILD) all-libiberty
	$(MAKE) -C $(BUILD)/gcc -j$(JOBS) cc1

$(ARCHIVE):
	mkdir -p sources
	curl --fail --location --silent --show-error https://ftp.gnu.org/gnu/gcc/gcc-$(VERSION).tar.gz --output $@.download
	printf '%s  %s\n' '$(SHA256)' '$@.download' | shasum -a 256 -c -
	mv $@.download $@

verify-source: $(ARCHIVE)
	printf '%s  %s\n' '$(SHA256)' '$(ARCHIVE)' | shasum -a 256 -c -

$(SOURCE)/.prepared: $(ARCHIVE) host.patch
	printf '%s  %s\n' '$(SHA256)' '$(ARCHIVE)' | shasum -a 256 -c -
	rm -rf $(SOURCE)
	tar -xzf $(ARCHIVE) -C sources
	cd $(SOURCE) && patch -p1 < $(ROOT)/host.patch
	touch $@

$(BUILD)/Makefile: $(SOURCE)/.prepared Makefile
	mkdir -p $(BUILD)
	cd $(BUILD) && CC='$(HOST_CC) $(HOST_CFLAGS)' CFLAGS='-O2' ../$(SOURCE)/configure --target=arm-elf --host=i686-pc-linux-gnu --build=i686-pc-linux-gnu --enable-languages=c --disable-nls --without-headers

clean:
	rm -rf $(BUILD)
