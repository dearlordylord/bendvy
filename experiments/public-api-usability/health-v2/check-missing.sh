#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/../../../examples/common.sh"
here=$(cd -- "$(dirname -- "$0")" && pwd)
mkdir -p "$here/build"
export BEND_NO_TELEMETRY=1
example_emit "$here/missing-main.bend" "$here/build/missing.js" > "$here/build/missing.emit-js.stdout" 2> "$here/build/missing.emit-js.stderr"
timeout --signal=KILL 5s "${example_cpu[@]}" "$NODE" "$here/build/missing.js" > "$here/build/missing-js.stdout" 2> "$here/build/missing-js.stderr"
[[ ! -s "$here/build/missing-js.stderr" ]]
python3 "$here/verify.py" --kind missing "$here/build/missing-js.stdout"
if [[ ${BENDVY_EXAMPLE_NATIVE:-0} == 1 ]]; then
  example_emit "$here/missing-main.bend" "$here/build/missing.c" > "$here/build/missing.emit-c.stdout" 2> "$here/build/missing.emit-c.stderr"
  timeout --signal=KILL 120s "${example_cpu[@]}" "$CLANG" -O3 "$here/build/missing.c" -o "$here/build/missing.native" -pthread -lm > "$here/build/missing.build.stdout" 2> "$here/build/missing.build.stderr"
  timeout --signal=KILL 5s "${example_cpu[@]}" "$here/build/missing.native" --threads 1 --gpu off > "$here/build/missing-native.stdout" 2> "$here/build/missing-native.stderr"
  [[ ! -s "$here/build/missing-native.stderr" ]]
  python3 "$here/verify.py" --kind missing "$here/build/missing-native.stdout"
  cmp "$here/build/missing-js.stdout" "$here/build/missing-native.stdout"
fi
