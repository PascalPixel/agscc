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
- A disabled garbage collector in cc1, for host stability.
- A post-reload constant lookup fix, reverted because it changed 8 bytes of
  credited code.
- Symbol and label hashing in cselib by content, not address, so the output
  does not depend on where the host places memory.
- Two Thumb options for The Lost Age only: `-mthumb-split-constants` (002c421)
  and `-mthumb-call-via-lr` (a3964ae). They reconstruct habits found across
  that game's code; no known GCC release has them. They are under the study
  below and stay as they are until its verdict.

Each patch's commit message records its justification. No other allocator,
scheduler, literal-pool or alignment change is included. No GCC 3 or agbcc
source is included. Alchemy consumes pret/agbcc separately.

## The Lost Age compiler study

Registered on 2026-09-30, before any candidate is built, as Pascal decided.

**Question.** Does a public GCC from 2000–2002, with stock options, produce
The Lost Age's code, so that the two reconstructed options can go?

**Candidates.** Public GNU GCC from gcc.gnu.org only: one mainline snapshot a
month from 2000-06 to 2002-05, and the releases 2.95.3, 3.0, 3.0.4 and 3.1.
Each gets this repository's host ports and nothing else, and only stock
options vary. First, the public `config/arm` history is searched for Thumb
constant splitting beyond negation or shifts, and for an indirect call through
a lone BL suffix to lr; snapshots around any hit are added.

**Corpora, fixed now.**

- A: The Lost Age functions whose The Broken Seal twin is linked C, compiled
  from the unchanged The Broken Seal text. Functions whose start address has
  bit 2 clear are the design half; the rest are held out.
- B: every credited The Lost Age function, for regressions only.
- C: every credited The Broken Seal C object, which must stay byte-identical
  under that game's own route.
- Canaries: DeriMura_TalkShopkeeper's load-versus-constant order; the 107
  constant sequences agscc splits differently (such as 0x7784 in
  recon/tla/raw/0816b6ec.s); the 1,537 pool loads of splittable numbers; and
  The Lost Age drafts within five halfwords of The Broken Seal C.

**Metric.** Exact functions on held-out A, then total instruction edits,
scored with the scorer behind Alchemy's `make drafts`.

**Pass mark.** Compiler X replaces a3964ae and the two options for The Lost
Age only if all of these hold: C is unchanged; B loses no function, or the
study re-matches it; X beats a3964ae with the options on held-out A; X closes
at least half of the canaries; and the neighbouring snapshots agree.

**Outcomes.** If X passes, The Lost Age uses X and both options are deleted.
If none passes, Pascal chooses: keep the options, renamed so they cannot pass
for real GCC options and documented with the study's counts, or remove them,
which returns 33 credited The Lost Age functions to drafts.

**Dates.** The study stops on 2026-10-12 whatever the result, and the
verdict goes to Pascal on 2026-10-13. No compiler change lands before his
answer.

**Verdict (2026-09-30).** No public GCC from 2000–2002 can produce either
habit, so the options stay. The study read all 417 changes to `gcc/config/arm`
from 1999-12 to 2002-12, on trunk and the 2.95, 3.0 and 3.1 branches, and
the ARM backend of all 28 candidates. Every one builds a Thumb constant
inline only with mov, mov and neg, or mov and lsl, and loads anything else
from the pool; every one calls through a register with a `_call_via_rX`
stub, and none uses the lone BL-suffix call. Measured with the permuter's
scorer, a3964ae with the options matches 88 of 348 held-out A functions and
all 300 of B, and leaves C unchanged; without them it matches 83 and loses 37
of B, each one an inline constant turned back into a pool load. The 2000-08
snapshot, built with these host ports, reproduces a3964ae without the
options function for function; the 2000-09 and 2000-10 snapshots break 152
and 163 of B and change 1,470 and 1,661 of C's objects.

Pascal chose on 2026-09-30 to keep both options under their GCC-style names,
as Camelot's own changes to the Thumb backend. Why a person at Camelot made
them: each habit runs through the whole of The Lost Age, so it belongs to the
compiler and not to some functions; neither is in The Broken Seal, built a
year earlier with the same compiler family; no public GCC of the time has
either; and each is a small, local backend change a toolchain engineer makes
for speed. The first skips a slow cartridge-ROM load for the constant; the
second skips a stub on every indirect call, and works only because The Lost
Age's game code no longer interworks with ARM code. That makes them one
coherent change to one compiler. Alchemy's AGENTS.md (K1 to K3) holds the
standard: a compiler change is admitted only when one option set explains a
game's code as a whole, never a file or a function.

The Lost Age's remaining instruction-order difference (for example
DeriMura_TalkShopkeeper's one reordered load) is the same with or without
the options and in the 2000-08 snapshot, and later snapshots make it worse,
so it too points at a local change rather than a later public GCC. It gets no
option until a whole-game rule for it is found.

**The Broken Seal is settled.** a3964ae with Alchemy's flags reproduces all
2,260 credited The Broken Seal objects byte for byte. No compiler variant that
keeps them identical improves any of its drafts, and four July 2000 ChangeLog
reversions are no-ops for Thumb.

**A reproducible build.** The approved binaries are rebuilt from this source
so that they no longer depend on the folder they were built in. Their
fingerprints change; every credited file must stay byte-identical.

Compiler build success is not ROM equivalence. Alchemy owns compiler selection,
staging, approved executable digests, and full linked-byte verification.

Preserve the upstream COPYING and COPYING.LIB notices and provide corresponding
source when distributing compiler binaries. Original game data does not belong
in this repository.
