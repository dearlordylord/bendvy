"""Dense Motion64 metric model from baseline source; no subject/output input."""
import json
from pathlib import Path

COUNT = 64
ITERATIONS = 64
# Seed queues one spawn and its pending-state inverse per successful reservation.
# One ordinary query Tx spans all rows; each body journals Main and Ledger once.
samples = [{"kind": "seed", "undo": COUNT, "commands": COUNT, "events": 0}]
samples += [{"kind": "query-loop", "undo": 2 * COUNT, "commands": 0, "events": 0} for _ in range(ITERATIONS)]
Path(__file__).with_name("expected.stats.json").write_text(json.dumps({"samples": samples}, separators=(",", ":")) + "\n")
