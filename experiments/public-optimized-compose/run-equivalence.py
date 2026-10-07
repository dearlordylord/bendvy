"""Compare original selected producer and its Required/all-live specialization."""
import hashlib
import json
import os
import pathlib
import subprocess
import tempfile
from freeze import ROOT, freeze

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
from task_runner import run as _run_command


expected = "[1, 3, 7, 3, 11, 19, 4, 23, 29]|[1, 3, 7, 3, 11, 19, 4, 23, 29]|[1, 3, 7, 2, 999, 999, 3, 11, 19, 4, 23, 29, 1, 3, 4]|[1, 3, 7, 2, 999, 999, 3, 11, 19, 4, 23, 29]"
with tempfile.TemporaryDirectory(prefix="bendvy-compose30-equivalence-") as temporary:
    stage = pathlib.Path(temporary)
    receipt = freeze(stage / "original")
    source = (ROOT / "experiments/public-optimized-compose/equivalence-control.bend.in").read_text()
    source = source.replace("@@ARCHIVE@@", str(stage / "original")).replace("@@ROOT@@", str(ROOT))
    source = source.replace("@@COLUMN@@", str(ROOT / "src/ecs/column.bend"))
    main = stage / "equivalence.bend"
    main.write_text(source)
    env = dict(os.environ, BENDVY_CLANG19_ROOT="/tmp/bendvy-clang19-diagnostic/root")
    commands = [(["bend", str(main), "--check-only"], 5, False),
                (["bend", str(main)], 5, True),
                (["bend", str(main), "-o", str(stage / "program.js")], 30, False),
                (["node", str(stage / "program.js")], 5, True),
                (["bend", str(main), "-o", str(stage / "program.c")], 30, False),
                (["/tmp/bendvy-clang19-diagnostic/clang19", "-O3", str(stage / "program.c"),
                  "-o", str(stage / "program"), "-pthread", "-lm"], 120, False),
                ([str(stage / "program")], 5, True)]
    receipt["columnSHA256"] = hashlib.sha256((ROOT / "src/ecs/column.bend").read_bytes()).hexdigest()
    receipt["commands"] = []
    for command, limit, observation in commands:
        result = _run_command(command, timeout=limit, capture_output=True, text=True, env=env)
        receipt["commands"].append({"command": command, "limit": limit,
                                    "exit": result.returncode, "stdout": result.stdout,
                                    "stderr": result.stderr})
        assert result.returncode == 0, result.stderr
        if observation:
            assert result.stdout.strip() == expected, result.stdout
    receipt["scope"] = "finite producer/recovery equivalence: three full Type Array owners, hole, ascending IDs; original recovery IDs retained as reference observation"
    print(json.dumps(receipt, indent=2))
