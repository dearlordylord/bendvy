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
check_source src/ecs/execution-event-family.bend
check_source src/ecs/execution-event-view.bend
check_source src/ecs/execution-event-ops.bend
check_source examples/parallel-events/scenario.bend
check_source examples/parallel-events/controls/positive.bend
reject_source() {
  local case_name=$1 first=$2 second=$3 result
  if check_source "examples/parallel-events/controls/$case_name.bend" > "$example_output/$case_name.log" 2>&1; then
    echo "Expected event authority refusal: $case_name" >&2
    exit 1
  else
    result=$?
  fi
  if [[ $result != 1 ]] || ! grep -Fq 'expected :' "$example_output/$case_name.log" || ! grep -Fq 'observed :' "$example_output/$case_name.log" || ! grep -Fq "$first" "$example_output/$case_name.log" || ! grep -Fq "$second" "$example_output/$case_name.log"; then
    cat "$example_output/$case_name.log" >&2
    exit 1
  fi
}
reject_source reader-duplication 'reader' 'consumed more than once'
reject_source payload-duplication 'payload' 'consumed more than once'
reject_source cross-schema 'P.SchemaA' 'P.SchemaB'
reject_source cross-family '"events"' '"other"'
reject_source write-through-read 'ResourceWrite' 'ResourceRead'
reject_source undeclared 'ResourceRead' 'Unit'
reject_source escape 'State.Scope' 'escape~H'
reject_source affine-view 'expected : Data' 'observed : Type'
reject_source wrapper-schema 'P.SchemaB' 'P.SchemaA'
reject_source wrapper-family '"other"' '"events"'
reject_source wrapper-payload 'U32' 'Array<U32>'
example_emit examples/parallel-events/main.bend "$example_output/main.js"
for repetition in 1 2; do
  example_node "$example_output/main.js" > "$example_output/js$repetition.stdout"
  diff -u examples/parallel-events/expected.stdout "$example_output/js$repetition.stdout"
done
example_emit examples/parallel-events/cases/A-affine-future.bend "$example_output/future.js"
for repetition in 1 2; do
  example_node "$example_output/future.js" > "$example_output/future$repetition.stdout"
  diff -u examples/parallel-events/cases/A-affine-future.expected.stdout "$example_output/future$repetition.stdout"
done
if [[ ${BENDVY_EXAMPLE_NATIVE:-0} == 1 ]]; then
  for case_name in A-affine B-affine A-data B-data A-affine-future; do
    example_emit "examples/parallel-events/cases/$case_name.bend" "$example_output/$case_name.c"
    timeout --signal=KILL 120s "${example_cpu[@]}" "$CLANG" -O3 "$example_output/$case_name.c" -o "$example_output/$case_name.native" -pthread -lm
    for workers in 1 4; do
      for repetition in 1 2; do
        timeout --signal=KILL 5s "${example_cpu[@]}" "$example_output/$case_name.native" --threads "$workers" --gpu off > "$example_output/$case_name-native$workers-$repetition.stdout"
        diff -u "examples/parallel-events/cases/$case_name.expected.stdout" "$example_output/$case_name-native$workers-$repetition.stdout"
      done
    done
  done
fi
