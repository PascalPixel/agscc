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
- Post-reload CSE: look up a mode-less constant using its assignment's
  destination mode, matching the existing value-recording path.

Each patch's commit message records its justification. No custom allocator,
scheduler, literal-pool, alignment, or target-option changes are included.
No GCC 3 or agbcc source is included. Alchemy consumes pret/agbcc separately.

### Post-reload constant lookup correction

`reload_cse_simplify_set` passed `VOIDmode` to `cselib_lookup`, although
`cselib_record_sets` records the same assignment source using the destination
mode. `CONST_INT` has no intrinsic mode; cselib explicitly requires its caller
to supply that context and includes it in the hash. The inconsistent query
could miss a recorded value or find it accidentally through a hash collision.
Fresh compiler processes consequently emitted different, semantically equivalent
assembly for identical preprocessed input.

The correction supplies `GET_MODE (SET_DEST (set))` at that one lookup. It does
not change hashing, equality, allocation, scheduling, target options, or output
bytes after compilation. Keeping mode-dependent hashing avoids conflating the
same integer used in different machine modes. This is an independently justified
compiler bug fix, not a rule for matching any game's instructions. Compiler
repeatability and complete downstream ROM equivalence are separate checks.

The ordinary-C regression is `gcc/testsuite/gcc.dg/cselib-constant-mode.c`.
It checks reuse after an inlined call wrapper and preserves HI/SI stores. On
hosts without DejaGNU, run the bounded fresh-process check from this directory:

```sh
rustc contrib/check-cselib.rs -o build/check-cselib
build/check-cselib build/gcc/xgcc gcc/testsuite/gcc.dg/cselib-constant-mode.c build/cselib-check
```

This performs 300 compilations and checks both assembly invariants and identical
output. It does not execute ARM code or prove other programs byte-exact.

Compiler build success is not ROM equivalence. Alchemy owns compiler selection,
staging, approved executable digests, and full linked-byte verification.

Preserve the upstream COPYING and COPYING.LIB notices and provide corresponding
source when distributing compiler binaries. Original game data does not belong
in this repository.
