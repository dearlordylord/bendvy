#!/usr/bin/env python3
"""No-runtime source-pin and deterministic-output checks for the per-mode oracle."""
from __future__ import annotations
import gzip
import hashlib
import json
import runpy
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASIS = HERE / "SOURCE-BASIS.json"
MODEL = HERE / "model.py.source"


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    basis = json.loads(BASIS.read_text(encoding="utf-8"))
    checked = []
    for path, expected in sorted(basis["sourceInventory"].items()):
        actual = sha(Path(path))
        if actual != expected:
            raise AssertionError(f"source pin mismatch: {path}: {actual} != {expected}")
        checked.append(path)
    module = runpy.run_path(str(MODEL), run_name="named_schedule_mode_oracle")
    outputs = []
    for mode, debug in (("enabled", True), ("disabled", False)):
        for scale in (1, 2, 4):
            raw_path = HERE / f"expected-{mode}-scale-{scale}.stdout"
            gz_path = HERE / f"expected-{mode}-scale-{scale}.stdout.gz"
            raw = raw_path.read_bytes()
            regenerated = module["generate_mode"](scale, debug)
            if regenerated != raw:
                raise AssertionError(f"regeneration mismatch at {mode} scale {scale}")
            if gzip.decompress(gz_path.read_bytes()) != raw:
                raise AssertionError(f"gzip mismatch at {mode} scale {scale}")
            parsed = json.loads(raw)
            if len(parsed) != 2 * scale:
                raise AssertionError(f"scene count mismatch at {mode} scale {scale}")
            if sum(len(scene["records"]) for scene in parsed) != 52 * scale:
                raise AssertionError(f"record count mismatch at {mode} scale {scale}")
            if any(scene["debug"] is not debug for scene in parsed):
                raise AssertionError(f"mode mismatch at {mode} scale {scale}")
            if not raw.endswith(b"\n") or raw.endswith(b"\n\n"):
                raise AssertionError(f"terminal LF mismatch at {mode} scale {scale}")
            outputs.append({
                "mode": mode,
                "scale": scale,
                "bytes": len(raw),
                "sha256": sha(raw_path),
                "gzip_bytes": gz_path.stat().st_size,
                "gzip_sha256": sha(gz_path),
                "scenes": len(parsed),
                "records": sum(len(scene["records"]) for scene in parsed),
            })
    result = {
        "status": "PASS",
        "runtime_consulted": False,
        "source_files_checked": len(checked),
        "source_inventory_sha256": basis["sourceInventorySha256"],
        "model_sha256": sha(MODEL),
        "outputs": outputs,
    }
    (HERE / "SELFTEST.json").write_text(json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(json.dumps(result, sort_keys=True))


if __name__ == "__main__":
    main()
