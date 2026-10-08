#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../../.."
scripts/bend-check examples/health-decay/demo/api.bend
mkdir -p examples/health-decay/demo/dist
timeout --signal=KILL 30s bend examples/health-decay/demo/api.bend -o examples/health-decay/demo/dist/api.mjs
