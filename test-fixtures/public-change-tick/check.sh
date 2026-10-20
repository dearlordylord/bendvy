#!/usr/bin/env bash
set -euo pipefail
fixture_dir=$(cd -- "$(dirname -- "$0")" && pwd)
source "$fixture_dir/../../examples/common.sh"
output_dir=$(mktemp -d "${TMPDIR:-/tmp}/bendvy-change-tick.XXXXXX")
trap 'rm -rf "$output_dir"' EXIT
for backend in "${@:-js}"; do
  case "$backend" in
    js)
      example_emit "$fixture_dir/main.bend" "$output_dir/main.js"
      example_node "$output_dir/main.js" > "$output_dir/js.stdout"
      ;;
    native)
      example_emit "$fixture_dir/main.bend" "$output_dir/main.c"
      timeout --signal=KILL 120s "${example_cpu[@]}" "$CLANG" -O3 "$output_dir/main.c" -o "$output_dir/main.native" -pthread -lm
      timeout --signal=KILL 5s "${example_cpu[@]}" "$output_dir/main.native" --threads 1 --gpu off > "$output_dir/native.stdout"
      ;;
    *) echo 'usage: check.sh [js] [native]' >&2; exit 2 ;;
  esac
  cmp "$fixture_dir/expected.stdout" "$output_dir/$backend.stdout"
done
