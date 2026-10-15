"""Read-only verification for the #58 source-derived oracle."""
from __future__ import annotations

import gzip
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
CANDIDATE = Path("/workspace/formal-proofs/bendvy-worktrees/snapshot58-ordinary-constructor-save/experiments/public-snapshot/ordinary-constructor-save-v1")
FREEZE_SHA = "18201dcb56944023564506b0d71a395ecb29e372fd2b4da9f2d246d649d72a75"
EXPECTED_SHA = "c381bdeab1e75d6ecbe893baabc2e901ee162499c2e59d838f7cdaa0a9a201dc"


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    basis = json.loads((HERE / "SOURCE-BASIS.json").read_text())
    freeze = CANDIDATE / "SOURCE-FREEZE.json"
    assert sha(freeze) == FREEZE_SHA
    assert basis["sourceInventoryCount"] == 47
    assert basis["localSourceCount"] == 16
    checked = 0
    for item in basis["sourceInventory"]:
        p = Path(item["path"])
        assert p.exists(), p
        assert sha(p) == item["sha256"], p
        checked += 1
    # Import closure entries are exactly the source inventory paths in the
    # frozen packet; this catches a missing reached module without executing it.
    assert set(basis["importClosure"]) == set(item["path"] for item in basis["sourceInventory"])
    import sys
    sys.path.insert(0, str(HERE))
    import expected
    state = expected.selfcheck()
    data = (HERE / "expected.stdout").read_bytes()
    assert data == expected.compact_bytes()
    assert len(data) == 9605
    assert sha(HERE / "expected.stdout") == EXPECTED_SHA
    assert data.endswith(b"\n") and data.count(b"\n") == 1
    assert json.loads(data) == expected.expected_object()
    assert gzip.decompress((HERE / "expected.stdout.gz").read_bytes()) == data
    assert sha(HERE / "expected.json") == "a73fafb487385764fa1aeb44ee72b55ce41e88c610ad76e45e5e797240ebd216"
    print(json.dumps({"sourceFilesChecked": checked, **state, "gzipRoundTrip": True}, sort_keys=True))


if __name__ == "__main__":
    main()
