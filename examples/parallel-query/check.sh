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
check_source examples/parallel-query/main.bend
check_source examples/parallel-query/commands.bend
check_source examples/parallel-query/controls/positive.bend
check_source examples/parallel-query/controls/layout-positive.bend
check_source examples/parallel-query/controls/output-positive.bend
check_source test-fixtures/chunk-column/output.bend
reject_source() {
  local case_name=$1 first=$2 second=$3 result
  if check_source "examples/parallel-query/controls/$case_name.bend" > "$example_output/$case_name.log" 2>&1; then
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
reject_source cross-schema 'Each<Second' 'Each<First'
reject_source duplicate-query-key 'expected : False{}' 'observed : True{}'
reject_source escape-scope 'State.Scope' 'escape~H'
reject_source invalid-query-pair 'ColumnSlot' 'Unit'
reject_source owner-duplication 'expected : Data' 'observed : Type'
reject_source same-payload-wrong-key '"public"' '"secret"'
reject_source undeclared-component 'ComponentRead' 'Query.Each'
reject_source write-through-read '@_:U32' '@read:Payload.Input'
reject_source wrong-view-type '@_:U32' '@read:OtherView'
reject_source output-cross-schema 'W.Handle<First>' 'W.Handle<Second>'
reject_source output-duplication 'expected : Data' 'observed : Type'
reject_source output-escape 'Array<U32>' 'escape~O'
reject_source output-undeclared 'Local.Commands' 'Query.OutputEach'
check_backend() {
  local case_name=$1 entry=$2 oracle=$3 workers
  python3 "$oracle" > "$example_output/$case_name.expected"
  example_emit "$entry" "$example_output/$case_name.js"
  example_node "$example_output/$case_name.js" > "$example_output/$case_name.js.stdout"
  diff -u "$example_output/$case_name.expected" "$example_output/$case_name.js.stdout"
  if [[ ${BENDVY_EXAMPLE_NATIVE:-0} == 1 ]]; then
    example_emit "$entry" "$example_output/$case_name.c"
    timeout --signal=KILL 120s "${example_cpu[@]}" "$CLANG" -O3 "$example_output/$case_name.c" -o "$example_output/$case_name.native" -pthread -lm
    for workers in 1 4; do
      timeout --signal=KILL 5s "${example_cpu[@]}" "$example_output/$case_name.native" --threads "$workers" --gpu off > "$example_output/$case_name.native$workers.stdout"
      diff -u "$example_output/$case_name.expected" "$example_output/$case_name.native$workers.stdout"
    done
  fi
}
check_backend basic examples/parallel-query/main.bend examples/parallel-query/oracle.py
check_backend commands examples/parallel-query/commands.bend examples/parallel-query/commands-oracle.py
check_backend output test-fixtures/chunk-column/output.bend test-fixtures/chunk-column/output-oracle.py
