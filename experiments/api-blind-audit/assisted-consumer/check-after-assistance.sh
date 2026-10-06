#!/bin/sh
set -u
cd /tmp/bendvy-blind-api-audit-v1
for name in template-query template-array-query public-setter-control; do
  timeout 5s bend "consumer/$name.bend" > "evidence/$name-check.log" 2>&1
  result=$?
  printf '%s\texit=%s\n' "timeout 5s bend consumer/$name.bend" "$result"
  [ "$result" = 0 ] || exit 1
done
timeout 5s bend consumer/template-public-setter-negative.bend > evidence/template-public-setter-negative-check.log 2>&1
result=$?
printf '%s\texit=%s\n' 'timeout 5s bend consumer/template-public-setter-negative.bend' "$result"
[ "$result" = 1 ] || exit 1
timeout 30s bend consumer/template-query.bend -o consumer/template-query.mjs > evidence/template-query-emit.log 2>&1
result=$?
printf '%s\texit=%s\n' 'timeout 30s bend consumer/template-query.bend -o consumer/template-query.mjs' "$result"
[ "$result" = 0 ] || exit 1
timeout 5s node consumer/run-template-query.mjs > evidence/template-query-runtime.log 2>&1
result=$?
printf '%s\texit=%s\n' 'timeout 5s node consumer/run-template-query.mjs' "$result"
exit "$result"
