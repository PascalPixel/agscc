#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-or-later
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cc="$root/build/gcc/xgcc"
test -x "$cc"
tmp=$(mktemp -d "${TMPDIR:-/tmp}/agscc-gs2-test.XXXXXX")
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

cat >"$tmp/call.c" <<'EOF'
extern int (*callback)(int);
int call_callback(int value) { return callback(value); }
EOF

cat >"$tmp/constant.c" <<'EOF'
int materialize(int value) { return value + 0x7fff; }
EOF

PATH="$root/build/gcc:$PATH"

"$cc" -mthumb -S -o "$tmp/call-default.s" "$tmp/call.c"
grep -q 'bl[[:space:]]*_call_via_' "$tmp/call-default.s"
! grep -q '\.short[[:space:]]*0xf800' "$tmp/call-default.s"

"$cc" -mthumb -mgs2 -S -o "$tmp/call-gs2.s" "$tmp/call.c"
grep -q 'mov[[:space:]]*lr, r[0-9].*\.short[[:space:]]*0xf800' "$tmp/call-gs2.s"

"$cc" -mthumb -mgs2 -mno-gs2 -S -o "$tmp/call-disabled.s" "$tmp/call.c"
grep -q 'bl[[:space:]]*_call_via_' "$tmp/call-disabled.s"
! grep -q '\.short[[:space:]]*0xf800' "$tmp/call-disabled.s"

"$cc" -mthumb -mgs2 -mthumb-interwork -S -o "$tmp/call-interwork.s" "$tmp/call.c"
grep -q 'bl[[:space:]]*_call_via_' "$tmp/call-interwork.s"
! grep -q '\.short[[:space:]]*0xf800' "$tmp/call-interwork.s"

"$cc" -mthumb -S -o "$tmp/constant-default.s" "$tmp/constant.c"
grep -q '\.word[[:space:]]*32767' "$tmp/constant-default.s"

"$cc" -mthumb -mgs2 -S -o "$tmp/constant-gs2.s" "$tmp/constant.c"
grep -q 'mov[[:space:]]*r[0-9], #254' "$tmp/constant-gs2.s"
grep -q 'lsl[[:space:]]*r[0-9], r[0-9], #7' "$tmp/constant-gs2.s"
grep -q 'add[[:space:]]*r[0-9], r[0-9], #255' "$tmp/constant-gs2.s"
! grep -q '\.word[[:space:]]*32767' "$tmp/constant-gs2.s"

echo "GS2 option/codegen tests passed"
