#!/usr/bin/env bash
# Shared example build commands; no installed configuration is changed.
example_repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
if [[ -z ${BEND:-} ]]; then
  if [[ -x /home/node/.bend/bin/bend-2.0.35 ]]; then BEND=/home/node/.bend/bin/bend-2.0.35; else BEND=bend; fi
fi
NODE=${NODE:-node}
CLANG=${CLANG:-clang}
example_cpu=()
if [[ -n ${BENDVY_EXAMPLE_CPU:-} ]]; then example_cpu=(taskset -c "$BENDVY_EXAMPLE_CPU"); fi
if [[ ${BENDVY_EXAMPLE_LOCK_HELD:-0} != 1 ]]; then
  exec 9>/tmp/bendvy-parity-heavy.lock
  flock -n 9 || { echo 'Backend checks are already running; retry later.' >&2; exit 75; }
  export BENDVY_EXAMPLE_LOCK_HELD=1
fi
example_emit() {
  timeout --signal=KILL 30s "${example_cpu[@]}" "$BEND" "$1" -o "$2"
}
example_node() {
  timeout --signal=KILL 30s "${example_cpu[@]}" "$NODE" "$@"
}
