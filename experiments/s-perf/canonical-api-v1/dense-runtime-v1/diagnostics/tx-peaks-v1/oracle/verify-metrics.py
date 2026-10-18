"""Verify one produced metric artifact; reused collector captures this receipt."""
import hashlib
import json
from pathlib import Path
import stat
import sys

actual, expected = map(Path, sys.argv[1:])
assert actual.resolve() != expected.resolve()
before = actual.lstat()
assert stat.S_ISREG(before.st_mode) and not actual.is_symlink()
raw = actual.read_bytes()
value = json.loads(raw)
after = actual.lstat()
assert (before.st_dev, before.st_ino, before.st_mode, before.st_size, before.st_mtime_ns) == (after.st_dev, after.st_ino, after.st_mode, after.st_size, after.st_mtime_ns)
gold = expected.read_bytes()
matched = raw == gold
receipt = {"status": "METRICS_PASS" if matched else "METRICS_REJECT", "actualPath": str(actual), "actualBytes": len(raw), "actualSHA256": hashlib.sha256(raw).hexdigest(), "expectedPath": str(expected), "expectedSHA256": hashlib.sha256(gold).hexdigest(), "stableRegularFile": True, "stats": value}
print(json.dumps(receipt, separators=(",", ":")))
print(receipt["status"], file=sys.stderr)
sys.exit(0 if matched else 1)
