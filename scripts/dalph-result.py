"""Emit a final result from the current Dalph attempt ref without transcribing IDs.

This beta harness supports the verified part-* ref encoding. Unknown encodings
fail closed; Dalph still independently validates the emitted correlation/commit.
"""

import json
import re
import subprocess


def git(*args):
    return subprocess.check_output(["git", *args], text=True).strip()


parts = git("symbolic-ref", "--short", "HEAD").split("/")
if parts[0] != "dalph" or parts[-1] != "_leaf":
    raise SystemExit("Not a supported Dalph attempt ref")
if not all(part.startswith("part-") for part in parts[1:-1]):
    raise SystemExit("Invalid attempt ref segments")
body = "".join(part[len("part-") :] for part in parts[1:-1])
match = re.fullmatch(
    r"run-(\d+)-([0-9a-f]+)-task-(\d+)-([0-9a-f]+)-attempt-(\d+)", body
)
if match is None or len(match[2]) != int(match[1]) or len(match[4]) != int(match[3]):
    raise SystemExit("Invalid attempt ref encoding/lengths")
run_id = bytes.fromhex(match[2]).decode("ascii")
task_id = bytes.fromhex(match[4]).decode("ascii")
if not run_id.startswith("r1.") or not task_id.startswith("t1."):
    raise SystemExit("Unsupported Run/task identity versions")
commit = git("rev-parse", "HEAD")
if re.fullmatch(r"[0-9a-f]{40}", commit) is None:
    raise SystemExit("Invalid candidate commit")
print(json.dumps({"commit": commit, "correlation": {"runId": run_id, "attemptId": "attempt:" + body}}, separators=(",", ":")))
