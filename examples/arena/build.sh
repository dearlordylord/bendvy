#!/bin/sh
set -eu
cd "$(dirname "$0")/../.."
scripts/bend-check examples/arena/game.bend
mkdir -p examples/arena/dist
# The development checker above has its own five-second limit. Code emission
# is a separate build operation, bounded to avoid leaving runaway processes.
timeout --signal=KILL 30s bend examples/arena/game.bend -o examples/arena/dist/game.mjs
