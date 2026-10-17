#!/usr/bin/env bash
set -euo pipefail
side_dir=$(cd -- "$(dirname -- "$0")" && pwd)
backend=${1:-js}
compiler=${BEND:-/home/node/.bend/bin/bend-2.0.35}
node_bin=${NODE:-/home/node/.local/share/mise/installs/node/24.20.0/bin/node}
clang_bin=${CLANG:-/tmp/bendvy-clang19-diagnostic/clang19}
export BENDVY_CLANG19_ROOT=${BENDVY_CLANG19_ROOT:-/tmp/bendvy-clang19-diagnostic/root}
mkdir -p "$side_dir/build"
# Do not compete with the main thread's serialized backend checks.
exec 9>/tmp/bendvy-parity-heavy.lock
flock -n 9 || { echo 'Main thread owns the backend queue; retry later.' >&2; exit 75; }
case "$backend" in
  js)
    timeout --signal=KILL 30s taskset -c 10 "$compiler" "$side_dir/main.bend" -o "$side_dir/build/main.js"
    timeout --signal=KILL 5s taskset -c 10 "$node_bin" "$side_dir/build/main.js" > "$side_dir/build/js.stdout"
    ;;
  native)
    timeout --signal=KILL 30s taskset -c 10 "$compiler" "$side_dir/main.bend" -o "$side_dir/build/main.c"
    timeout --signal=KILL 120s taskset -c 10 "$clang_bin" -O3 "$side_dir/build/main.c" -o "$side_dir/build/main.native" -pthread -lm
    timeout --signal=KILL 5s taskset -c 10 "$side_dir/build/main.native" --threads 1 --gpu off > "$side_dir/build/native.stdout"
    ;;
  *) echo 'usage: bash run.sh [js|native]' >&2; exit 2 ;;
esac
cat "$side_dir/build/$backend.stdout"
python3 "$side_dir/verify.py" "$side_dir/build/$backend.stdout"
