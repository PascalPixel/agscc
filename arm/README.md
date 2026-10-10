# Stock ARM compiler study

This builds the C frontend and ARM backend of GNU GCC 2.95.2 (1999-10-24).
It is a separate stock compiler candidate; the existing GCC 2.96 Thumb
compiler and The Lost Age's two Thumb options are unchanged.

Run `make -C arm`. The output is `arm/build/gcc/cc1`. The recipe downloads
the official GNU source archive and checks its SHA-256 before extraction.
It builds only host tools, without target runtime libraries or headers.
On macOS it builds an x86-64 executable, runnable through Rosetta on Apple
Silicon. On Linux it uses the native Clang host compiler. The historical
i686 descriptor selects GCC's host integer model, not the target CPU.

`host.patch` contains two compatibility changes:

- Assign the underlying `arm_prgmode` variable instead of its cast macro;
  current host compilers no longer accept cast expressions as lvalues.
- Match Darwin's `const int sys_nerr` declaration in its system headers.

Neither changes target instruction selection, allocation or scheduling.
The source retains GNU's license notices. Distributing a compiler binary
requires providing its corresponding source and these host changes.

The 2026-10-10 study found that the separately consumed agbcc ARM compiler
identifies itself as `2.9-arm-000512` and lacks the general zero-cost
anti/output-dependence scheduling rule already present in upstream GCC
2.95.2 and agscc's GCC 2.96. Adding that rule to an isolated agbcc prototype
identified the scheduling difference; the prototype is not used here.

Stock GCC 2.95.2, with one setting for all game ARM C,
`-O2 -mthumb-interwork -fomit-frame-pointer -fcall-used-r4`, matches
`UiText_DrawGlyphArm` in all six TBS editions and `Tile_BuildMetatiles`
in all twelve editions. The glyph candidate removes several source devices;
it contains no inline assembly, fixed-register variables or asm barriers.
The current compiler-shaped game ARM corpus consists of these two routines.
The earlier seven-routine comparison also included five routines subsequently
proved handwritten; those are not evidence about compiler output.

GCC 2.96 already contains the scheduler rule, but its ARM backend is not a
drop-in replacement for these sources: it changes both routines with stock
ARM flags, including with `-mno-apcs-frame`. This does not rule out different
source forms matching 2.96, nor establish Camelot's exact historical version.
Alchemy's full linked ROM comparisons and Pascal's compiler decision remain
separate gates; object matches alone do not admit a new compiler.
