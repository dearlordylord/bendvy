#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/../common.sh"
cd "$example_repo"
bash examples/arena/build.sh
