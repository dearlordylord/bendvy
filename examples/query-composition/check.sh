#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/../common.sh"
cd "$example_repo"
example_name=$(basename -- "$(dirname -- "$0")")
example_output=$(mktemp -d)
trap 'rm -rf "$example_output"' EXIT
example_emit "examples/$example_name/main.bend" "$example_output/main.js"
timeout --signal=KILL 5s "${example_cpu[@]}" "$NODE" "$example_output/main.js" > "$example_output/actual.json"
python3 "examples/$example_name/verify.py" "$example_output/actual.json"
# The separate measurement entry is compiled but never used for timing here.
example_emit "examples/$example_name/timing-main.bend" "$example_output/timing.js"
if [[ -f "examples/$example_name/array-controls.bend" ]]; then
  example_emit "examples/$example_name/array-controls.bend" "$example_output/arrays.js"
  example_node "$example_output/arrays.js" > "$example_output/arrays.stdout"
  python3 - "$example_output/arrays.stdout" <<'PYTHON'
import json
import sys
from pathlib import Path
actual = json.loads(Path(sys.argv[1]).read_text())
expected = [{'value': 99, 'owned': list(range(1, count + 1))} for count in (0, 9, 17)]
assert actual == expected, (actual, expected)
print('Complete array payload checks: PASS')
PYTHON
fi
