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
for control in read-write undeclared cross-schema reconstruct fabricate-setter fabricate-provider fabricate-restored; do
  $check "$control-control.bend" --check-only > "$build/$control-control.log" 2>&1
  rg -q '^ALL PROOFS CHECK$' "$build/$control-control.log"
done
$check provision-control.bend --check-only > "$build/provision.log" 2>&1
rg -q '^ALL PROOFS CHECK$' "$build/provision.log"
reject() {
  fixture=$1 expected=$2 observed=$3 location=$4
  rc=0
  $check "$fixture.bend" --check-only > "$build/$fixture.log" 2>&1 || rc=$?
  [ "$rc" = 1 ]
  rg -q '^SOME PROOFS FAIL$' "$build/$fixture.log"
  rg -qF -- "- expected : $expected" "$build/$fixture.log"
  rg -qF -- "- observed : $observed" "$build/$fixture.log"
  rg -qF -- "Location: $location" "$build/$fixture.log"
  cat "$build/$fixture.log"
}
reject read-write A.PositionCell P bad
reject undeclared A.VelocityCell P bad
reject cross-schema A.MotionToken A.OtherToken bad
reject reconstruct P A.PositionCell forge
reject fabricate-setter P A.PositionCell bad
reject fabricate-provider P A.Motion bad
reject fabricate-restored P A.Motion bad
for name in main mutant; do
  $check "$name.bend" --check-only > "$build/$name.log" 2>&1
  rg -q '^ALL PROOFS CHECK$' "$build/$name.log"
  $check "$name.bend" -o "$build/$name-native"
  $check "$name.bend" -o "$build/$name.js"
  timeout --signal=KILL 5 "$build/$name-native" --threads 1 --gpu off > "$build/$name-native.out"
  timeout --signal=KILL 5 node "$build/$name.js" > "$build/$name-js.out"
  cmp "$build/$name-native.out" "$build/$name-js.out"
done
timeout --signal=KILL 5 node reference.mjs > "$build/reference.out"
printf '2\n4\n6\n' > "$build/expected.out"
cmp "$build/expected.out" "$build/reference.out"
cmp "$build/reference.out" "$build/main-native.out"
printf '0\n0\n0\n' > "$build/mutant.expected"
cmp "$build/mutant.expected" "$build/mutant-native.out"
if cmp -s "$build/expected.out" "$build/mutant-native.out"; then
  echo 'ERROR: planted no-update defect survived' >&2
  exit 1
fi
cat "$build/main-native.out"
printf 'R-A: bounded abstract-provider controls and finite checkpoints PASS; full T03/R2/proof/performance gates OPEN\n'
