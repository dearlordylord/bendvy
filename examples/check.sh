#!/usr/bin/env bash
# All runnable examples, on every core/example change in CI.
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
exec 9>/tmp/bendvy-parity-heavy.lock
flock -n 9 || { echo 'Backend checks are already running; retry later.' >&2; exit 75; }
export BENDVY_EXAMPLE_LOCK_HELD=1
# Discover every example directory rather than maintaining a second entry list.
for example_dir in examples/*/; do
  [[ -f "$example_dir/main.bend" || -f "$example_dir/game.bend" ]] || continue
  [[ -f "$example_dir/check.sh" ]] || continue
  bash "$example_dir/check.sh"
done
