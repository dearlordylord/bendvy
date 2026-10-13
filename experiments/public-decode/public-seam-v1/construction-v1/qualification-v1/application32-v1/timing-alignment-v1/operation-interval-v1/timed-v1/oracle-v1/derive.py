"""Derive the timed raw-String oracle from the accepted pure public wire."""
from __future__ import annotations

import argparse
import gzip
import hashlib
import json
from pathlib import Path

COMMON_WIRE = Path(
    "/workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/"
    "experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/"
    "application32-v1/timing-alignment-v1/native-resume-v1/independent-oracle-v1/"
    "adopt-original-v1/observer-format-v3/common.stdout.gz"
)
WIRE_SOURCE = Path(
    "/workspace/formal-proofs/bendvy-worktrees/decode46-native-resume-v1/"
    "experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/"
    "application32-v1/timing-alignment-v1/wire.mjs"
)
COMMON_SHA256 = "a7b1e9d98061cd4ed89a01d6daf8bc9f4be56ce630c3781587301dbf36c95d4b"
COMMON_WIRE_SHA256 = "ac4be8d768a1b64def3fe8ea2608830a45d5565bd4f18cf742605576b92f5221"
WIRE_SHA256 = "dc20d74f35f826274f901077fd8c64ac1e725b1df70e9106534abfb0e00c5148"
EXPECTED_BYTES = 501886
EXPECTED_SHA256 = "d5c1e6d70d03842985a7fb6ebc6b41614a82a74f24a50e6833ac7207be8fe96d"
EXPECTED_FNV1A32 = 909256459


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def fnv1a32(data: bytes) -> int:
    result = 2166136261
    for byte in data:
        result = ((result ^ byte) * 16777619) & 0xFFFFFFFF
    return result


def derive(destination: Path) -> dict:
    common_archive = COMMON_WIRE.read_bytes()
    common_wire = gzip.decompress(common_archive)
    wire_source = WIRE_SOURCE.read_bytes()
    assert sha256(common_archive) == COMMON_SHA256, "accepted oracle archive changed"
    assert sha256(common_wire) == COMMON_WIRE_SHA256, "accepted complete oracle changed"
    assert sha256(wire_source) == WIRE_SHA256, "public wire decoder changed"
    wire_text = wire_source.decode("utf-8")
    assert "JSON.parse(raw.slice(0,-1))" in wire_text
    assert "Array.isArray(value)||value.length!==32" in wire_text

    # This is the pinned Bend display codec: an escaped outer JSON string and
    # one display LF. The timer receives the decoded String, then adds its own LF.
    assert common_wire.endswith(b"\n") and not common_wire.endswith(b"\n\n")
    complete_string = json.loads(common_wire[:-1].decode("utf-8"))
    assert isinstance(complete_string, str)
    assert complete_string != "SERIALIZATION_INCOMPLETE"
    rows = json.loads(complete_string)
    assert isinstance(rows, list) and len(rows) == 32
    expected = (complete_string + "\n").encode("utf-8")
    actual_sha = sha256(expected)
    actual_fnv = fnv1a32(expected)
    assert len(expected) == EXPECTED_BYTES
    assert actual_sha == EXPECTED_SHA256
    assert actual_fnv == EXPECTED_FNV1A32

    destination.mkdir(parents=True, exist_ok=False)
    compressed_path = destination / "expected.timed.stdout.gz"
    with compressed_path.open("wb") as output:
        with gzip.GzipFile(fileobj=output, mode="wb", filename="", mtime=0) as archive:
            archive.write(expected)
    compressed = compressed_path.read_bytes()
    metadata = {
        "status": "SOURCE_DERIVED_NO_RUNTIME_INPUTS",
        "operation": "Decode accepted Bend public String wire, then append the timer's single output LF",
        "completeRecords": len(rows),
        "inputs": {
            str(COMMON_WIRE): {
                "gzipBytes": len(common_archive),
                "gzipSha256": sha256(common_archive),
                "wireBytes": len(common_wire),
                "wireSha256": sha256(common_wire),
            },
            str(WIRE_SOURCE): {"bytes": len(wire_source), "sha256": sha256(wire_source)},
        },
        "timedStdout": {
            "path": str(compressed_path),
            "encoding": "gzip of UTF-8 decoded public String followed by one LF",
            "bytes": len(expected),
            "sha256": actual_sha,
            "fnv1a32": actual_fnv,
            "gzipBytes": len(compressed),
            "gzipSha256": sha256(compressed),
        },
        "timing": {
            "intervals": 1,
            "elapsedNs": "nonnegative integer string; telemetry only",
            "bytes": len(expected),
            "digest": actual_fnv,
        },
    }
    (destination / "ORACLE.json").write_text(json.dumps(metadata, indent=2) + "\n")
    return metadata


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(derive(args.output), sort_keys=True))


if __name__ == "__main__":
    main()
