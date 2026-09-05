#!/bin/sh
set -eu

compiler_source=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
compiler_build="$compiler_source/build"
compiler_jobs=${AGSCC_JOBS:-8}
export CFLAGS='-O2 -fno-pie -no-pie -Wno-narrowing -Wno-implicit-int -Wno-implicit-function-declaration -Wno-pointer-arith -Wno-int-conversion -Wno-format -Wno-error -std=gnu17 -Wno-incompatible-pointer-types -fcommon'
export CXXFLAGS='-O2 -fno-pie -no-pie -Wno-narrowing -Wno-error -std=gnu++17'
export LDFLAGS='-no-pie'

if [ ! -f "$compiler_build/gcc/Makefile" ]; then
    # Use the checked-in Bison 1.28 output, not the host's parser generator.
    find "$compiler_source/gcc" -type f \( -name configure.in -o -name c-parse.y -o -name c-gperf.gperf -o -name acconfig.h \) -exec touch -t 200001010000 {} +
    find "$compiler_source/gcc" -type f \( -name configure -o -name c-parse.c -o -name c-parse.h -o -name c-gperf.h -o -name cstamp-h.in -o -name config.in -o -name cexp.c -o -name tradcif.c \) -exec touch {} +
fi
mkdir -p "$compiler_build/libiberty" "$compiler_build/gcc"
if [ ! -f "$compiler_build/libiberty/Makefile" ]; then
    (cd "$compiler_build/libiberty" && "$compiler_source/libiberty/configure" \
        --srcdir="$compiler_source/libiberty" --prefix="$compiler_build/install" \
        --build=i686-unknown-linux-gnu --host=i686-unknown-linux-gnu \
        --target=arm-elf --disable-shared --disable-nls)
fi
make -C "$compiler_build/libiberty" -j"$compiler_jobs"
if [ ! -f "$compiler_build/gcc/Makefile" ]; then
    (cd "$compiler_build/gcc" && "$compiler_source/gcc/configure" \
        --srcdir="$compiler_source/gcc" --prefix="$compiler_build/install" \
        --build=i686-unknown-linux-gnu --host=i686-unknown-linux-gnu \
        --target=arm-elf --with-cpu=arm7tdmi --enable-multilib --enable-interwork \
        --enable-languages=c --without-headers --disable-shared --disable-threads \
        --disable-nls --with-gnu-as --with-gnu-ld --disable-checking)
fi
make -C "$compiler_build/gcc" -j"$compiler_jobs" \
    CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS" cc1 xgcc cpp0 tradcpp0
