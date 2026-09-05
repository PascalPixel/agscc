# agscc

GCC 2.96 (2000-07-31 snapshot), prepared for Alchemy's ARM/Thumb reconstruction.
This is a host-adapted compiler, not a claim of unmodified GCC or recovered
original game tooling.

## Build

Run `sh build.sh`. Requires a native C compiler and Make. Outputs are
`build/gcc/cc1`, `xgcc`, `cpp0`, and `tradcpp0`. `AGSCC_JOBS` controls build
parallelism (default 8). Building does not install or replace another compiler.
The initial supported build is native ARM64 macOS. The historical i686 host
descriptor selects the old integer model; it does not describe the host CPU.

## Provenance

The root imports GCC upstream revision
`04179d4a511b13cef92eacdb10a51bcd124fea7a` from
<https://github.com/gcc-mirror/gcc>, preserving the recorded GCC 2.96 tree from
PascalPixel/alchemy-gcc. Commit two deletes unused subprojects without changing
any retained file. Subsequent commits separately record:

- Parser generation using unmodified GNU Bison 1.28.
- Fixed-arity generator calls for the Apple ARM64 calling convention.
- Per-slot real-constant copies for 64-bit host pointers.
- Internal linkage for the generated keyword lookup.
- Darwin system-header compatibility.
- This build entry point and documentation.

Each patch's commit message records its justification. No custom allocator,
scheduler, literal-pool, alignment, or target-option changes are included.
No GCC 3 or agbcc source is included. Alchemy consumes pret/agbcc separately.

Compiler build success is not ROM equivalence. Alchemy owns compiler selection,
staging, approved executable digests, and full linked-byte verification.

Preserve the upstream COPYING and COPYING.LIB notices and provide corresponding
source when distributing compiler binaries. Original game data does not belong
in this repository.
