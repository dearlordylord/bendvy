#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/../common.sh"
cd "$example_repo"
example_output=$(mktemp -d)
trap 'rm -rf "$example_output"' EXIT
check_source() {
  scripts/bend-check "examples/parallel-captures/$1"
}
check_source main.bend
check_source lifecycle.bend
check_source capture-owner.bend
reject_source() {
  local name=$1 first=$2 second=$3 result
  if check_source "controls/$name.bend" > "$example_output/$name.log" 2>&1; then
    echo "Expected authority refusal: $name" >&2
    exit 1
  else
    result=$?
  fi
  if [[ $result != 1 ]] || ! grep -Fq 'expected :' "$example_output/$name.log" || ! grep -Fq 'observed :' "$example_output/$name.log" || ! grep -Fq "$first" "$example_output/$name.log" || ! grep -Fq "$second" "$example_output/$name.log"; then
    cat "$example_output/$name.log" >&2
    exit 1
  fi
}
reject_source duplicate-capture owner 'consumed more than once'
reject_source duplicate-local owner 'consumed more than once'
reject_source cross-schema SchemaA SchemaB
reject_source escape-scope State.Scope 'escape~H'
reject_source undeclared-resource P.Score P.Counter
reject_source write-through-read ResourceWrite ResourceRead
for entry in main lifecycle capture-owner; do
  expected=examples/parallel-captures/$entry.expected.stdout
  if [[ $entry == main ]]; then expected=examples/parallel-captures/expected.stdout; fi
  example_emit "examples/parallel-captures/$entry.bend" "$example_output/$entry.js"
  example_node "$example_output/$entry.js" > "$example_output/$entry.js.stdout"
  diff -u "$expected" "$example_output/$entry.js.stdout"
  if [[ ${BENDVY_EXAMPLE_NATIVE:-0} == 1 && $entry != capture-owner ]]; then
    example_emit "examples/parallel-captures/$entry.bend" "$example_output/$entry.c"
    timeout --signal=KILL 120s "${example_cpu[@]}" "$CLANG" -O3 "$example_output/$entry.c" -o "$example_output/$entry.native" -pthread -lm
    for workers in 1 4; do
      timeout --signal=KILL 5s "${example_cpu[@]}" "$example_output/$entry.native" --threads "$workers" --gpu off > "$example_output/$entry.native$workers.stdout"
      diff -u "$expected" "$example_output/$entry.native$workers.stdout"
    done
  fi
done
