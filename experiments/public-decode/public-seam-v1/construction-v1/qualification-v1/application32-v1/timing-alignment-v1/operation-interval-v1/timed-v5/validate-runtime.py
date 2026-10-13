#!/usr/bin/env python3
"""Validate one full lifecycle String and timer protocol, without timing criteria."""
from __future__ import annotations

import gzip
import hashlib
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
EXPECTED = HERE / "oracle-v1/derived-v5/expected.timed.stdout.gz"
ORACLE = HERE / "oracle-v1/derived-v5/ORACLE.json"


def fnv1a32(data: bytes) -> int:
    result = 2166136261
    for byte in data:
        result = ((result ^ byte) * 16777619) & 0xFFFFFFFF
    return result


def validate(stdout: bytes, stderr: bytes) -> dict:
    metadata = json.loads(ORACLE.read_text())
    expected = gzip.decompress(EXPECTED.read_bytes())
    assert len(expected) == metadata["timedStdout"]["bytes"]
    assert hashlib.sha256(expected).hexdigest() == metadata["timedStdout"]["sha256"]
    assert stdout == expected, "complete 32-record timed String differs from independent source oracle"
    assert stdout.endswith(b"\n") and not stdout.endswith(b"\n\n")
    text = stdout[:-1].decode("utf-8", errors="strict")
    rows = json.loads(text)
    assert isinstance(rows, list) and len(rows) == 32

    lines = stderr.splitlines()
    assert len(lines) == 1, "one metrics line is required on stderr"
    metrics = json.loads(lines[0].decode("ascii"))
    assert set(metrics) == {"elapsedNs", "bytes", "digest", "intervals"}
    assert isinstance(metrics["elapsedNs"], str) and re.fullmatch(r"[0-9]+", metrics["elapsedNs"])
    assert metrics["bytes"] == len(stdout) == metadata["timing"]["bytes"]
    digest = fnv1a32(stdout)
    assert metrics["digest"] == digest == metadata["timing"]["digest"]
    assert metrics["intervals"] == metadata["timing"]["intervals"] == 1
    return {
        "status": "COMPLETE_TIMED_STRING_AND_INTERVAL_PROTOCOL_PASS",
        "rows": len(rows),
        "stdoutBytes": len(stdout),
        "stdoutSHA256": hashlib.sha256(stdout).hexdigest(),
        "fnv1a32": digest,
        "metrics": metrics,
        "timingScope": "Elapsed nanoseconds are telemetry only; no threshold or ratio is applied.",
    }
