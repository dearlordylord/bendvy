#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/../../common.sh"
cd "$example_repo"
mkdir -p examples/health-decay/demo/dist
example_emit examples/health-decay/demo/api.bend examples/health-decay/demo/dist/api.mjs
