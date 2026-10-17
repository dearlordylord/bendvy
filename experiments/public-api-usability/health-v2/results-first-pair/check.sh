#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/../../../examples/common.sh"
here=$(cd -- "$(dirname -- "$0")" && pwd)
mkdir -p "$here/build"
export BEND_NO_TELEMETRY=1
example_emit "$here/main.bend" "$here/build/normal.js" > "$here/build/normal.emit-js.stdout" 2> "$here/build/normal.emit-js.stderr"
timeout --signal=KILL 5s "${example_cpu[@]}" "$NODE" "$here/build/normal.js" > "$here/build/normal-js.stdout" 2> "$here/build/normal-js.stderr"
[[ ! -s "$here/build/normal-js.stderr" ]]
python3 "$here/verify.py" "$here/build/normal-js.stdout"
if [[ ${BENDVY_EXAMPLE_NATIVE:-0} == 1 ]]; then
  example_emit "$here/main.bend" "$here/build/normal.c" > "$here/build/normal.emit-c.stdout" 2> "$here/build/normal.emit-c.stderr"
  timeout --signal=KILL 120s "${example_cpu[@]}" "$CLANG" -O3 "$here/build/normal.c" -o "$here/build/normal.native" -pthread -lm > "$here/build/normal.build.stdout" 2> "$here/build/normal.build.stderr"
  timeout --signal=KILL 5s "${example_cpu[@]}" "$here/build/normal.native" --threads 1 --gpu off > "$here/build/normal-native.stdout" 2> "$here/build/normal-native.stderr"
  [[ ! -s "$here/build/normal-native.stderr" ]]
  python3 "$here/verify.py" "$here/build/normal-native.stdout"
  cmp "$here/build/normal-js.stdout" "$here/build/normal-native.stdout"
fi
