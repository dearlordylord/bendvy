#!/usr/bin/env bash
set -euo pipefail
bash "$(dirname -- "$0")/run.sh" js
if [[ ${BENDVY_EXAMPLE_NATIVE:-0} == 1 ]]; then
  bash "$(dirname -- "$0")/run.sh" native
  cmp "$(dirname -- "$0")/build/js.stdout" "$(dirname -- "$0")/build/native.stdout"
fi
