#!/bin/sh
# Run from any directory. No installation, downloads or dependency additions.
set -eu
cd "$(dirname "$0")"
export LC_ALL=C
build=$(mktemp -d ./build-XXXXXX)
trap 'rm -rf "$build"' EXIT HUP INT TERM
[ "$(bend version)" = 'bend 2.0.34' ] || { echo 'Bend version mismatch' >&2; exit 1; }
base=${BEND_BASE:-${HOME}/.bend/bend2/base.bend}
[ "$(sha256sum "$base" | cut -d ' ' -f1)" = c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661 ] || exit 1
bend version
clang --version | head -1
node --version
bend guide > "$build/guide.txt"
for mode in ordinary verdict; do
  flag=--check-only
  [ "$mode" != verdict ] || flag=--verdict
  ./bend-check true.bend "$flag" > "$build/true.log" 2>&1
  cat "$build/true.log"
  rg -q '^ALL PROOFS CHECK$' "$build/true.log"
  rc=0
  ./bend-check false.bend "$flag" > "$build/false.log" 2>&1 || rc=$?
  cat "$build/false.log"
  [ "$rc" = 1 ]
  rg -q '^SOME PROOFS FAIL$' "$build/false.log"
  rg -q 'expected : 2n' "$build/false.log"
  rg -q 'observed : 3n' "$build/false.log"
  rg -q 'Location: canary' "$build/false.log"
  printf '%s: true rc=0, false rc=1\n' "$mode"
done
./bend-check main.bend -o "$build/native"
./bend-check main.bend -o "$build/main.js"
timeout --signal=KILL 5 "$build/native" --threads 1 --gpu off > "$build/native.out"
timeout --signal=KILL 5 node "$build/main.js" > "$build/js.out"
printf '42\n' > "$build/expected.out"
cmp "$build/expected.out" "$build/native.out"
cmp "$build/native.out" "$build/js.out"
printf 'native CPU workers=1; JS single event loop, no workers; input=6; output='
cat "$build/native.out"
printf 'PASS: T01 infrastructure smoke only\n'
