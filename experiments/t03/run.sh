#!/bin/sh
set -eu
cd "$(dirname "$0")"
export LC_ALL=C
build=$(mktemp -d ./build-XXXXXX)
trap 'rm -rf "$build"' EXIT HUP INT TERM
check=../t01/bend-check
[ "$(bend version)" = 'bend 2.0.34' ]
[ "$(node --version)" = 'v24.20.0' ]
[ "$(sha256sum "${BEND_BASE:-${HOME}/.bend/bend2/base.bend}" | cut -d ' ' -f1)" = c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661 ]
node - <<'JS'
const fs=require('node:fs'), cp=require('node:child_process');
const manifest=JSON.parse(fs.readFileSync('../../.references/sources.json'));
for(const [name,s] of Object.entries(manifest.sources)) {
 const actual=cp.execFileSync('git',['-C','/workspace/formal-proofs/bendvy/.references/'+name,'rev-parse','HEAD'],{encoding:'utf8'}).trim();
 if(actual!==s.commit) throw Error(name+' reference mismatch');
 console.log(name+' '+actual);
}
JS
bend version
node --version
clang --version | head -1
bend guide > "$build/guide.txt"
for control in control undeclared-control cross-schema-control; do
  $check "$control.bend" --check-only > "$build/$control.log" 2>&1
  rg -q '^ALL PROOFS CHECK$' "$build/$control.log"
done
for fixture in read-write undeclared cross-schema; do
  rc=0
  $check "$fixture.bend" --check-only > "$build/$fixture.log" 2>&1 || rc=$?
  [ "$rc" = 1 ]
  rg -q '^SOME PROOFS FAIL$' "$build/$fixture.log"
  if [ "$fixture" = cross-schema ]; then
    rg -q 'expected : A.MotionToken' "$build/$fixture.log"
    rg -q 'observed : A.HealthToken' "$build/$fixture.log"
  else
    rg -q 'expected : A.WriteMotion' "$build/$fixture.log"
    rg -q 'observed : A.ReadMotion' "$build/$fixture.log"
  fi
  cat "$build/$fixture.log"
done
for name in main forge; do
  $check "$name.bend" -o "$build/$name-native"
  $check "$name.bend" -o "$build/$name.js"
  timeout --signal=KILL 5 "$build/$name-native" --threads 1 --gpu off > "$build/$name-native.out"
  timeout --signal=KILL 5 node "$build/$name.js" > "$build/$name-js.out"
  cmp "$build/$name-native.out" "$build/$name-js.out"
done
printf '99\n' > "$build/forge.expected"
cmp "$build/forge.expected" "$build/forge-native.out"
timeout --signal=KILL 5 node reference.mjs > "$build/reference.out"
printf '6,2\n11,3,1\n' > "$build/expected.out"
cmp "$build/expected.out" "$build/reference.out"
cmp "$build/reference.out" "$build/main-native.out"
cat "$build/main-native.out"
cat "$build/forge-native.out"
printf 'REPRODUCED: finite two-schema final match; constructor capability bypass; T03 capability gate FAILED\n'
