#!/bin/sh
set -eu
cd "$(dirname "$0")/../.."
examples/arena/build.sh
scripts/bend-check examples/arena/fixtures.bend
timeout --signal=KILL 30s bend examples/arena/fixtures.bend -o examples/arena/dist/fixtures.mjs
node examples/arena/test.mjs
node examples/arena/host-smoke.mjs
