#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/../common.sh"
cd "$example_repo"
mkdir -p examples/arena/dist
example_emit examples/arena/game.bend examples/arena/dist/game.mjs
