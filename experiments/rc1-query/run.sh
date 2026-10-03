#!/bin/sh
set -eu
cd "$(dirname "$0")"
export LC_ALL=C
build=$(mktemp -d ./build-XXXXXX)
trap 'rm -rf "$build"' EXIT HUP INT TERM
check=../t01/bend-check
# R-A controls, compiler/Base identities, all three reference HEADs, guide.
../ra-provider/run.sh > "$build/ra.log" 2>&1
cat "$build/ra.log"
node controls.mjs "$build"
for name in motion health mutant; do
  $check "$name.bend" --check-only > "$build/$name-check.log" 2>&1
  rg -q '^ALL PROOFS CHECK$' "$build/$name-check.log"
  $check "$name.bend" -o "$build/$name-native"
  $check "$name.bend" -o "$build/$name.js"
  timeout --signal=KILL 5 "$build/$name-native" --threads 1 --gpu off > "$build/$name-native.out"
  timeout --signal=KILL 5 node "$build/$name.js" > "$build/$name-js.out"
  cmp "$build/$name-native.out" "$build/$name-js.out"
done
timeout --signal=KILL 5 node reference.mjs > "$build/reference.out"
cat "$build/motion-native.out" "$build/health-native.out" > "$build/native.out"
cat "$build/motion-js.out" "$build/health-js.out" > "$build/js.out"
# Recorded actual transcript also guards accidental loss/omission of checkpoints.
cmp observed.txt "$build/reference.out"
cmp "$build/reference.out" "$build/native.out"
cmp "$build/reference.out" "$build/js.out"
node compare-mutant.mjs "$build/motion-native.out" "$build/mutant-native.out"
cat "$build/native.out"
printf 'R-C1: 62 ordered checkpoints, 28 paired controls, native/JS/reference and compiling mutant PASS; bounded experimental gate only\n'
