#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/../common.sh"
cd "$example_repo"
example_output=$(mktemp -d)
trap 'rm -rf "$example_output"' EXIT
control_cpu=$("${example_cpu[@]}" python3 -c 'import os; print(min(os.sched_getaffinity(0)))')
control_lock="/tmp/bendvy-source-check-$(id -u)-cpu-$control_cpu.lock"
check_source() {
  flock "$control_lock" timeout --signal=KILL 15s taskset -c "$control_cpu" "$BEND" "examples/parallel-commands/$1" --check-only
}
reject_source() {
  local case_name=$1 first=$2 second=$3 result
  if check_source "controls/$case_name.bend" > "$example_output/$case_name.log" 2>&1; then
    echo "Expected authority refusal: $case_name" >&2
    exit 1
  else
    result=$?
  fi
  if [[ $result != 1 ]] || ! grep -Fq 'expected :' "$example_output/$case_name.log" || ! grep -Fq 'observed :' "$example_output/$case_name.log" || ! grep -Fq "$first" "$example_output/$case_name.log" || ! grep -Fq "$second" "$example_output/$case_name.log"; then
    cat "$example_output/$case_name.log" >&2
    exit 1
  fi
}
check_source controls/positive.bend
check_source controls/registered.bend
reject_source cross-schema 'W.Handle<SchemaA>' 'W.Handle<SchemaB>'
reject_source escape-buffer 'B.Buffer' 'bad~Q'
reject_source duplicate-buffer 'queue' 'consumed more than once'
reject_source plain-leaf 'execution-system.Owner' 'Cmd.Owner'
reject_source undeclared-family 'P.Token' 'Other'
for consumer in ordinary visibility; do
  python3 "examples/parallel-commands/$consumer-reference.py" > "$example_output/$consumer.expected.stdout"
  diff -u "examples/parallel-commands/$consumer.expected.stdout" "$example_output/$consumer.expected.stdout"
done
for consumer in plan ordinary main; do
  expected=$consumer
  if [[ $consumer == main ]]; then expected=visibility; fi
  check_source "$consumer.bend"
  example_emit "examples/parallel-commands/$consumer.bend" "$example_output/$consumer.js"
  example_node "$example_output/$consumer.js" > "$example_output/$consumer.js.stdout"
  diff -u "examples/parallel-commands/$expected.expected.stdout" "$example_output/$consumer.js.stdout"
  if [[ ${BENDVY_EXAMPLE_NATIVE:-0} == 1 ]]; then
    example_emit "examples/parallel-commands/$consumer.bend" "$example_output/$consumer.c"
    timeout --signal=KILL 120s "${example_cpu[@]}" "$CLANG" -O3 "$example_output/$consumer.c" -o "$example_output/$consumer.native" -pthread -lm
    for workers in 1 4; do
      timeout --signal=KILL 5s "${example_cpu[@]}" "$example_output/$consumer.native" --threads "$workers" --gpu off > "$example_output/$consumer.native$workers.stdout"
      diff -u "examples/parallel-commands/$expected.expected.stdout" "$example_output/$consumer.native$workers.stdout"
    done
  fi
done
