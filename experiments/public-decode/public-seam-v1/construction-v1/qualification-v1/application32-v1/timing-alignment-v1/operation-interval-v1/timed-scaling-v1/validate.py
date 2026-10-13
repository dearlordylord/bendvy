"""Validate complete repeated reports and timer counters for a scale canary."""
from __future__ import annotations

import gzip
import hashlib
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
ORACLE = HERE / "oracle/derived-v1/ORACLE.json"


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def fnv1a32(data: bytes) -> int:
    value = 2166136261
    for byte in data:
        value = ((value ^ byte) * 16777619) & 0xFFFFFFFF
    return value


def validate(scale: int, stdout: bytes, stderr: bytes) -> dict:
    metadata = json.loads(ORACLE.read_text())
    item = metadata["repetitions"][str(scale)]
    archive = Path(item["gzipPath"])
    if not archive.is_absolute():
        archive = HERE / archive
    expected = gzip.decompress(archive.read_bytes())
    assert len(expected) == item["bytes"]
    assert sha(expected) == item["sha256"]
    assert stdout == expected, "complete repeated report stream differs from independent source oracle"
    block = metadata["baseOracle"]["rawBytes"]
    assert len(stdout) == block * scale
    for index in range(scale):
        report = stdout[index * block:(index + 1) * block]
        assert report.endswith(b"\n") and not report.endswith(b"\n\n")
        rows = json.loads(report[:-1].decode("utf-8", errors="strict"))
        assert isinstance(rows, list) and len(rows) == 32

    lines = stderr.splitlines()
    assert len(lines) == 1, "one timer summary is required on stderr"
    metrics = json.loads(lines[0].decode("ascii"))
    assert set(metrics) == {"elapsedNs", "bytes", "digest", "intervals"}
    assert isinstance(metrics["elapsedNs"], str) and re.fullmatch(r"[0-9]+", metrics["elapsedNs"])
    digest = fnv1a32(stdout)
    assert metrics["bytes"] == len(stdout) == item["bytes"]
    assert metrics["digest"] == digest == item["fnv1a32"]
    assert metrics["intervals"] == scale
    return {
        "status": "COMPLETE_REPEATED_REPORT_AND_INTERVAL_PROTOCOL_PASS",
        "applications": scale,
        "records": 32 * scale,
        "stdoutBytes": len(stdout),
        "stdoutSHA256": sha(stdout),
        "fnv1a32": digest,
        "metrics": metrics,
        "timingScope": "One fresh complete application and full report capture per interval; elapsed time is telemetry only.",
    }
