#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/../../../examples/common.sh"
here=$(cd -- "$(dirname -- "$0")" && pwd)
mkdir -p "$here/build"
export BEND_NO_TELEMETRY=1
scenarios=("$@")
if [[ ${#scenarios[@]} == 0 ]]; then scenarios=(normal other missing local foreign failure); fi
for scenario in "${scenarios[@]}"; do
  kind=$scenario
  case "$scenario" in
    normal) entry=main ;;
    other) entry=other-main; kind=normal ;;
    missing|local|foreign|failure) entry="$scenario-main" ;;
    *) echo "Unknown scenario: $scenario" >&2; exit 2 ;;
  esac
  example_emit "$here/$entry.bend" "$here/build/$scenario.js" > "$here/build/$scenario.emit-js.stdout" 2> "$here/build/$scenario.emit-js.stderr"
  timeout --signal=KILL 5s "${example_cpu[@]}" "$NODE" "$here/build/$scenario.js" > "$here/build/$scenario-js.stdout" 2> "$here/build/$scenario-js.stderr"
  [[ ! -s "$here/build/$scenario-js.stderr" ]]
  python3 "$here/verify.py" --kind "$kind" "$here/build/$scenario-js.stdout"
  if [[ ${BENDVY_EXAMPLE_NATIVE:-0} == 1 ]]; then
    example_emit "$here/$entry.bend" "$here/build/$scenario.c" > "$here/build/$scenario.emit-c.stdout" 2> "$here/build/$scenario.emit-c.stderr"
    timeout --signal=KILL 120s "${example_cpu[@]}" "$CLANG" -O3 "$here/build/$scenario.c" -o "$here/build/$scenario.native" -pthread -lm > "$here/build/$scenario.build.stdout" 2> "$here/build/$scenario.build.stderr"
    timeout --signal=KILL 5s "${example_cpu[@]}" "$here/build/$scenario.native" --threads 1 --gpu off > "$here/build/$scenario-native.stdout" 2> "$here/build/$scenario-native.stderr"
    [[ ! -s "$here/build/$scenario-native.stderr" ]]
    python3 "$here/verify.py" --kind "$kind" "$here/build/$scenario-native.stdout"
    cmp "$here/build/$scenario-js.stdout" "$here/build/$scenario-native.stdout"
  fi
done
