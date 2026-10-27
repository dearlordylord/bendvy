#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/../common.sh"
cd "$example_repo"
example_output=$(mktemp -d)
trap 'rm -rf "$example_output"' EXIT
example_emit examples/health-decay/main.bend "$example_output/main.js"
example_node "$example_output/main.js" > "$example_output/actual.stdout"
diff -u examples/health-decay/expected.stdout "$example_output/actual.stdout"
bash examples/health-decay/demo/build.sh
