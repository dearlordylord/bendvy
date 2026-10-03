#!/bin/sh
set -eu
cd "$(dirname "$0")"
export LC_ALL=C
build=$(mktemp -d ./build-XXXXXX)
trap 'rm -r "$build"' EXIT HUP INT TERM
check=../t01/bend-check
# Fresh baseline verification includes compiler/Base and all reference pins.
../rc1-query/run.sh > "$build/baseline.log" 2>&1
printf 'R-A/R-C1 baseline freshly verified (including confinement controls and reference pins)\n'
node controls.mjs "$build"
for name in main alternatives mutant; do
  $check "$name.bend" --check-only > "$build/$name-check.log" 2>&1
  rg -q '^ALL PROOFS CHECK$' "$build/$name-check.log"
  $check "$name.bend" -o "$build/$name-native"
  $check "$name.bend" -o "$build/$name.js"
  timeout --signal=KILL 5 "$build/$name-native" --threads 1 --gpu off > "$build/$name-native.out"
  timeout --signal=KILL 5 node "$build/$name.js" > "$build/$name-js.out"
  cmp "$build/$name-native.out" "$build/$name-js.out"
done
timeout --signal=KILL 5 node reference.mjs > "$build/reference.out"
cmp observed.txt "$build/reference.out"
cmp "$build/reference.out" "$build/main-native.out"
cmp alternatives.txt "$build/alternatives-native.out"
node compare-mutant.mjs "$build/main-native.out" "$build/mutant-native.out"
cat "$build/main-native.out" "$build/alternatives-native.out"
printf 'T04 bounded owned-array experiment PASS; general payload/rollback/performance gates OPEN\n'
