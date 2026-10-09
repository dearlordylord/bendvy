#!/bin/sh
set -u
root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
for subject in main source-consumer negative-undeclared negative-read-write negative-cross-schema negative-owner-duplication; do
  flock /tmp/bendvy-parity-heavy.lock taskset -c 5 timeout --signal=KILL 5s /home/node/.bend/bin/bend-2.0.35 "$root/$subject.bend" --check-only > "$root/evidence/final-$subject.stdout" 2> "$root/evidence/final-$subject.stderr"
  rc=$?
  printf '%s %s\n' "$subject" "$rc"
done
