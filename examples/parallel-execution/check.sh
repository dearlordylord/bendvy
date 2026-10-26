#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/../common.sh"
cd "$example_repo"
example_output=$(mktemp -d)
trap 'rm -rf "$example_output"' EXIT
control_cpu=$("${example_cpu[@]}" python3 -c 'import os; print(min(os.sched_getaffinity(0)))')
control_lock="/tmp/bendvy-source-check-$(id -u)-cpu-$control_cpu.lock"
check_source() {
  flock "$control_lock" timeout --signal=KILL 15s taskset -c "$control_cpu" "$BEND" "examples/parallel-execution/$1" --check-only
}
check_source main.bend
check_source controls/positive.bend
check_source controls/metadata-preserved.bend
check_source controls/layout-positive.bend
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
reject_source write-through-read 'ComponentWrite' 'ComponentRead'
reject_source undeclared-component 'ComponentWrite' 'ResourceWrite'
reject_source cross-schema 'Handle<SchemaA>' 'Handle<SchemaB>'
reject_source owner-duplication 'local' 'consumed more than once'
reject_source escape-scope 'State.Scope' 'escape~H'
reject_source forged-declaration 'expected : @-H:Type' 'observed : D.Declaration'
reject_source forged-program 'declaration~H' 'observed : @scope:State.Scope'
reject_source discard-metadata 'book' 'consumed more than once'
reject_source reset-metadata 'expected : reset~B' 'observed : Build.Book'
reject_source duplicate-builder-state 'book' 'consumed more than once'
reject_source same-payload-wrong-key '"public"' '"secret"'
reject_source invalid-layout-route 'expected : False{}' 'observed : True{}'
reject_source duplicate-layout 'expected : False{}' 'observed : True{}'
reject_source read-projector 'expected : selection~B' 'observed : @owner:Array<U32>'
example_emit examples/parallel-execution/main.bend "$example_output/main.js"
example_node "$example_output/main.js" > "$example_output/js.stdout"
diff -u examples/parallel-execution/expected.stdout "$example_output/js.stdout"
if [[ ${BENDVY_EXAMPLE_NATIVE:-0} == 1 ]]; then
  example_emit examples/parallel-execution/main.bend "$example_output/main.c"
  timeout --signal=KILL 120s "${example_cpu[@]}" "$CLANG" -O3 "$example_output/main.c" -o "$example_output/main.native" -pthread -lm
  for workers in 1 4; do
    timeout --signal=KILL 5s "${example_cpu[@]}" "$example_output/main.native" --threads "$workers" --gpu off > "$example_output/native$workers.stdout"
    diff -u examples/parallel-execution/expected.stdout "$example_output/native$workers.stdout"
  done
fi
