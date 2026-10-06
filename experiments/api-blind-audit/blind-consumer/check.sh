#!/bin/sh
set -u
cd /tmp/bendvy-blind-api-audit-v1
for name in import-query structural lifecycle query-constant-control read-control owner-control schema-control system-control; do
  timeout 5s bend "consumer/$name.bend" > "evidence/$name-check.log" 2>&1
  result=$?
  printf '%s\texit=%s\n' "timeout 5s bend consumer/$name.bend" "$result"
  [ "$result" = 0 ] || exit 1
done
for name in attempt-unerased-query minimal undeclared-access write-through-read duplicate-owner cross-schema system-registration; do
  timeout 5s bend "consumer/$name.bend" > "evidence/$name-check.log" 2>&1
  result=$?
  printf '%s\texit=%s\n' "timeout 5s bend consumer/$name.bend" "$result"
  [ "$result" = 1 ] || exit 1
done
timeout 30s bend consumer/lifecycle.bend -o consumer/lifecycle.mjs > evidence/lifecycle-emit.log 2>&1
result=$?
printf '%s\texit=%s\n' 'timeout 30s bend consumer/lifecycle.bend -o consumer/lifecycle.mjs' "$result"
[ "$result" = 0 ] || exit 1
timeout 5s node consumer/run-lifecycle.mjs > evidence/lifecycle-runtime.log 2>&1
result=$?
printf '%s\texit=%s\n' 'timeout 5s node consumer/run-lifecycle.mjs' "$result"
exit "$result"
