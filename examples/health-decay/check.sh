#!/usr/bin/env bash
# Focused example check; generated artifacts stay outside the working tree.
set -euo pipefail
repo_dir=$(cd "$(dirname "$0")/../.." && pwd)
example_output=$(mktemp -d)
trap 'rm -rf "$example_output"' EXIT
cd "$repo_dir"
scripts/bend-check examples/health-decay/main.bend
# Compilation is separate from the five-second development checker.
timeout --signal=KILL 30s bend examples/health-decay/main.bend -o "$example_output/main.js"
timeout --signal=KILL 5s node "$example_output/main.js" > "$example_output/actual.stdout"
diff -u examples/health-decay/expected.stdout "$example_output/actual.stdout"
