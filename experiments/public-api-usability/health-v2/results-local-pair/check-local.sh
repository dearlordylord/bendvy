#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/../../../examples/common.sh"
here=$(cd -- "$(dirname -- "$0")" && pwd)
mkdir -p "$here/build"
export BEND_NO_TELEMETRY=1
example_emit "$here/local-main.bend" "$here/build/local.js" > "$here/build/local.emit-js.stdout" 2> "$here/build/local.emit-js.stderr"
timeout --signal=KILL 5s "${example_cpu[@]}" "$NODE" "$here/build/local.js" > "$here/build/local-js.stdout" 2> "$here/build/local-js.stderr"
[[ ! -s "$here/build/local-js.stderr" ]]
python3 "$here/verify.py" --kind local "$here/build/local-js.stdout"
if [[ ${BENDVY_EXAMPLE_NATIVE:-0} == 1 ]]; then
  example_emit "$here/local-main.bend" "$here/build/local.c" > "$here/build/local.emit-c.stdout" 2> "$here/build/local.emit-c.stderr"
  timeout --signal=KILL 120s "${example_cpu[@]}" "$CLANG" -O3 "$here/build/local.c" -o "$here/build/local.native" -pthread -lm > "$here/build/local.build.stdout" 2> "$here/build/local.build.stderr"
  timeout --signal=KILL 5s "${example_cpu[@]}" "$here/build/local.native" --threads 1 --gpu off > "$here/build/local-native.stdout" 2> "$here/build/local-native.stderr"
  [[ ! -s "$here/build/local-native.stderr" ]]
  python3 "$here/verify.py" --kind local "$here/build/local-native.stdout"
  cmp "$here/build/local-js.stdout" "$here/build/local-native.stdout"
fi
