#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/../common.sh"
cd "$example_repo"
bash examples/arena/build.sh
example_emit examples/arena/fixtures.bend examples/arena/dist/fixtures.mjs
example_node examples/arena/test.mjs
example_node examples/arena/host-smoke.mjs
