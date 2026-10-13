"""Derive repeated complete-report streams from the independent v5 oracle."""
from __future__ import annotations

import argparse
import gzip
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASE = HERE.parents[1] / "timed-v5/oracle-v1/derived-v5/expected.timed.stdout.gz"
BASE_METADATA = HERE.parents[1] / "timed-v5/oracle-v1/derived-v5/ORACLE.json"
SCALES = (1, 2, 4)


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def fnv1a32(data: bytes) -> int:
    value = 2166136261
    for byte in data:
        value = ((value ^ byte) * 16777619) & 0xFFFFFFFF
    return value


def derive(output: Path) -> dict:
    output = output.resolve()
    base_archive = BASE.read_bytes()
    base = gzip.decompress(base_archive)
    source = json.loads(BASE_METADATA.read_text())
    assert source["status"] == "SOURCE_DERIVED_NO_RUNTIME_INPUTS"
    assert len(base) == source["timedStdout"]["bytes"] == 501886
    assert sha(base) == source["timedStdout"]["sha256"] == "d5c1e6d70d03842985a7fb6ebc6b41614a82a74f24a50e6833ac7207be8fe96d"
    assert base.endswith(b"\n") and not base.endswith(b"\n\n")
    output.mkdir(parents=True, exist_ok=False)
    rows = {}
    for count in SCALES:
        expected = base * count
        destination = output / f"expected-{count}.stdout.gz"
        with destination.open("wb") as target:
            with gzip.GzipFile(fileobj=target, mode="wb", filename="", mtime=0) as zipped:
                zipped.write(expected)
        archive = destination.read_bytes()
        rows[str(count)] = {
            "applications": count,
            "completeRecords": 32 * count,
            "bytes": len(expected),
            "sha256": sha(expected),
            "fnv1a32": fnv1a32(expected),
            "gzipPath": str(destination),
            "gzipBytes": len(archive),
            "gzipSha256": sha(archive),
        }
    metadata = {
        "status": "SOURCE_DERIVED_REPETITION_OF_COMPLETE_FRESH_APPLICATION_ORACLE",
        "method": "Repeat the independently derived complete one-application UTF-8 String plus its output LF; no runtime output is read.",
        "baseOracle": {
            "archive": str(BASE),
            "archiveSha256": sha(base_archive),
            "metadata": str(BASE_METADATA),
            "metadataSha256": sha(BASE_METADATA.read_bytes()),
            "rawBytes": len(base),
            "rawSha256": sha(base),
            "records": 32,
        },
        "repetitions": rows,
        "timingProtocol": [
            "one process per selected repetition count",
            "one fresh complete application and one interval per repetition",
            "full report String construction and byte capture occur before each interval ends",
            "final buffered output occurs after the final interval ends",
            "elapsed values are telemetry only; this oracle defines no threshold or ratio",
        ],
    }
    (output / "ORACLE.json").write_text(json.dumps(metadata, indent=2) + "\n")
    return metadata


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(derive(args.output), sort_keys=True))


if __name__ == "__main__":
    main()
