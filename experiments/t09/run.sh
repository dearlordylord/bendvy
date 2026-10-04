#!/bin/sh
set -eu
cd "$(dirname "$0")"
export LC_ALL=C
build=$(mktemp -d ./build-XXXXXX)
trap 'rm -rf "$build"' EXIT HUP INT TERM
check=../t01/bend-check
# Re-execute confinement evidence and pinned environment/reference checks.
../ra-provider/run.sh > "$build/ra.log"
cat "$build/ra.log"
reject() {
  fixture=$1 expected=$2 observed=$3
  "$check" "$fixture-control.bend" --check-only > "$build/positive.log" 2>&1
  rg -q '^ALL PROOFS CHECK$' "$build/positive.log"
  rc=0
  "$check" "$fixture.bend" --check-only > "$build/negative.log" 2>&1 || rc=$?
  [ "$rc" = 1 ]
  rg -q '^SOME PROOFS FAIL$' "$build/negative.log"
  rg -qFx -- "- expected : $expected" "$build/negative.log"
  rg -qFx -- "- observed : $observed" "$build/negative.log"
  rg -qFx 'Location: bad' "$build/negative.log"
  printf '%s: paired rejection PASS\n' "$fixture"
}
reject read-write A.Cell R
reject undeclared A.Service R
reject cross-schema A.Token A.OtherToken
reject incompatible A.Service A.Cell
reject reconstruct R A.Cell
reject affine-repeat callback 'callback (consumed more than once)'
for name in main success mutant; do
  "$check" "$name.bend" --check-only > "$build/$name.log" 2>&1
  rg -q '^ALL PROOFS CHECK$' "$build/$name.log"
  "$check" "$name.bend" -o "$build/$name-native"
  "$check" "$name.bend" -o "$build/$name.js"
  timeout --signal=KILL 5 "$build/$name-native" --threads 1 --gpu off > "$build/$name-native.out"
  timeout --signal=KILL 5 node "$build/$name.js" > "$build/$name-js.out"
  cmp "$build/$name-native.out" "$build/$name-js.out"
done
cmp expected.txt "$build/main-native.out"
cmp success.txt "$build/success-native.out"
cmp mutant.txt "$build/mutant-native.out"
if cmp -s "$build/main-native.out" "$build/mutant-native.out"; then exit 1; fi
timeout --signal=KILL 5 node reference.mjs > "$build/reference.out"
cat "$build/main-native.out" "$build/success-native.out" > "$build/combined.out"
cmp "$build/reference.out" "$build/combined.out"
cat "$build/main-native.out"
cat "$build/success-native.out"
printf 'T09: bounded schedule probe PASS; full core/proofs/performance OPEN\n'
