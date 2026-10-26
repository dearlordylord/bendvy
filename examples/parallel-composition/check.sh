#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/../common.sh"
cd "$example_repo"
example_output=$(mktemp -d)
trap 'rm -rf "$example_output"' EXIT
control_cpu=$("${example_cpu[@]}" python3 -c 'import os; print(min(os.sched_getaffinity(0)))')
control_lock="/tmp/bendvy-source-check-$(id -u)-cpu-$control_cpu.lock"
check_source() {
  flock "$control_lock" timeout --signal=KILL 15s taskset -c "$control_cpu" "$BEND" "$1" --check-only
}
reject_source() {
  local file=$1 first=$2 second=$3 result
  if check_source "$file" > "$example_output/control.log" 2>&1; then
    echo "Expected authority refusal: $file" >&2
    exit 1
  else
    result=$?
  fi
  if [[ $result != 1 ]] || ! grep -Fq 'expected :' "$example_output/control.log" || ! grep -Fq 'observed :' "$example_output/control.log" || ! grep -Fq "$first" "$example_output/control.log" || ! grep -Fq "$second" "$example_output/control.log"; then
    cat "$example_output/control.log" >&2
    exit 1
  fi
}
check_source examples/parallel-composition/main.bend
check_source test-fixtures/execution-composition/service-provision.bend
check_source examples/parallel-execution/controls/actual-refresh.bend
reject_source examples/parallel-composition/controls/duplicate-provision.bend 'incoming' 'consumed more than once'
reject_source examples/parallel-composition/controls/wrong-service-family.bend 'feature-labels.Host' 'Service.Slot<Array<U32>>'
reject_source examples/parallel-composition/controls/cross-schema.bend 'ResourceSlot<Schema.Nominal' 'ResourceSlot<Other'
reject_source examples/parallel-execution/controls/write-through-read.bend 'ComponentWrite' 'ComponentRead'
reject_source examples/parallel-execution/controls/forged-program.bend 'declaration~H' 'observed : @scope:State.Scope'
reject_source examples/parallel-execution/controls/alternate-refresh.bend 'project' 'alternate'
reject_source examples/parallel-execution/controls/alternate-policy.bend 'Fragment.Plain' 'Fragment.Transient'
timeout --signal=KILL 5s python3 examples/parallel-composition/oracle.py > "$example_output/oracle.stdout"
diff -u examples/parallel-composition/expected.stdout "$example_output/oracle.stdout"
example_emit examples/parallel-composition/main.bend "$example_output/main.js"
example_node "$example_output/main.js" > "$example_output/js.stdout"
diff -u examples/parallel-composition/expected.stdout "$example_output/js.stdout"
if [[ ${BENDVY_EXAMPLE_NATIVE:-0} == 1 ]]; then
  example_emit examples/parallel-composition/main.bend "$example_output/main.c"
  timeout --signal=KILL 120s "${example_cpu[@]}" "$CLANG" -O3 "$example_output/main.c" -o "$example_output/main.native" -pthread -lm
  for workers in 1 4; do
    timeout --signal=KILL 5s "${example_cpu[@]}" "$example_output/main.native" --threads "$workers" --gpu off > "$example_output/native$workers.stdout"
    diff -u examples/parallel-composition/expected.stdout "$example_output/native$workers.stdout"
  done
fi
