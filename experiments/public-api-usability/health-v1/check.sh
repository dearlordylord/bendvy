#!/usr/bin/env bash
# Bounded API prototypes, not production adoption or a performance campaign.
set -euo pipefail
source "$(dirname -- "$0")/../../../examples/common.sh"
here=$(cd -- "$(dirname -- "$0")" && pwd)
mkdir -p "$here/build"
export BEND_NO_TELEMETRY=1
for source_name in app-core app-run single-query single-driver other-single-driver; do
  timeout --signal=KILL 5s "${example_cpu[@]}" "$BEND" "$here/$source_name.bend" > "$here/build/$source_name.check.stdout" 2> "$here/build/$source_name.check.stderr"
done
for negative in write-through-read opaque-world affine-duplication cross-schema; do
  rc=0
  timeout --signal=KILL 5s "${example_cpu[@]}" "$BEND" "$here/$negative.bend" > "$here/build/$negative.stdout" 2> "$here/build/$negative.stderr" || rc=$?
  [[ $rc == 1 ]] || { echo "Unexpected type-control status: $negative/$rc" >&2; exit 1; }
  case "$negative" in
    write-through-read) pattern='Cap.Write<' ;;
    opaque-world) pattern='W.World<' ;;
    affine-duplication) pattern='consumed more than once' ;;
    cross-schema) pattern='W.Handle<S.Schema>' ;;
  esac
  cat "$here/build/$negative.stdout" "$here/build/$negative.stderr" > "$here/build/$negative.diagnostic"
  grep -F -- "$pattern" "$here/build/$negative.diagnostic" >/dev/null
  echo "PASS intended type refusal: $negative"
done
for scenario in app single other-single controls foreign; do
  case "$scenario" in
    app) entry=main; kind=normal ;;
    single) entry=single-main; kind=normal ;;
    other-single) entry=other-single-main; kind=normal ;;
    controls) entry=controls; kind=controls ;;
    foreign) entry=foreign; kind=foreign ;;
  esac
  example_emit "$here/$entry.bend" "$here/build/$scenario.js" > "$here/build/$scenario.emit-js.stdout" 2> "$here/build/$scenario.emit-js.stderr"
  timeout --signal=KILL 5s "${example_cpu[@]}" "$NODE" "$here/build/$scenario.js" > "$here/build/$scenario-js.stdout" 2> "$here/build/$scenario-js.stderr"
  [[ ! -s "$here/build/$scenario-js.stderr" ]]
  python3 "$here/verify.py" "$kind" "$here/build/$scenario-js.stdout"
  if [[ ${BENDVY_EXAMPLE_NATIVE:-0} == 1 ]]; then
    example_emit "$here/$entry.bend" "$here/build/$scenario.c" > "$here/build/$scenario.emit-c.stdout" 2> "$here/build/$scenario.emit-c.stderr"
    timeout --signal=KILL 120s "${example_cpu[@]}" "$CLANG" -O3 "$here/build/$scenario.c" -o "$here/build/$scenario.native" -pthread -lm > "$here/build/$scenario.build.stdout" 2> "$here/build/$scenario.build.stderr"
    timeout --signal=KILL 5s "${example_cpu[@]}" "$here/build/$scenario.native" --threads 1 --gpu off > "$here/build/$scenario-native.stdout" 2> "$here/build/$scenario-native.stderr"
    [[ ! -s "$here/build/$scenario-native.stderr" ]]
    python3 "$here/verify.py" "$kind" "$here/build/$scenario-native.stdout"
    cmp "$here/build/$scenario-js.stdout" "$here/build/$scenario-native.stdout"
  fi
done
cmp "$here/build/app-js.stdout" "$here/build/single-js.stdout"
cmp "$here/build/app-js.stdout" "$here/build/other-single-js.stdout"
echo 'PASS full App / generic single-system helper / second nominal schema'
