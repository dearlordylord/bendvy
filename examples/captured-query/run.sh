#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/../common.sh"
example_dir=$(cd -- "$(dirname -- "$0")" && pwd)
backend=${1:-js}
mkdir -p "$example_dir/build"
case "$backend" in
  js)
    timeout --signal=KILL 60s "${example_cpu[@]}" "$BEND" "$example_dir/main.bend" -o "$example_dir/build/main.js"
    timeout --signal=KILL 180s "${example_cpu[@]}" "$NODE" "$example_dir/build/main.js" > "$example_dir/build/js.stdout"
    ;;
  native)
    timeout --signal=KILL 60s "${example_cpu[@]}" "$BEND" "$example_dir/main.bend" -o "$example_dir/build/main.c"
    timeout --signal=KILL 120s "${example_cpu[@]}" "$CLANG" -O3 "$example_dir/build/main.c" -o "$example_dir/build/main.native" -pthread -lm
    timeout --signal=KILL 180s "${example_cpu[@]}" "$example_dir/build/main.native" --threads 1 --gpu off > "$example_dir/build/native.stdout"
    ;;
  *) echo 'usage: bash run.sh [js|native]' >&2; exit 2 ;;
esac
cat "$example_dir/build/$backend.stdout"
