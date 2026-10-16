#!/usr/bin/env python3
"""Freeze entry closure, following both bare and explicit-relative imports."""
from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
HERE = Path(__file__).resolve().parent
ENTRY = HERE / "main.bend"
IMPORT = re.compile(r'^\s*import\s+(?:"([^"]+)"|([^\s]+))')
seen: set[Path] = set()


def visit(path: Path) -> None:
    path = path.resolve(strict=True)
    if path in seen:
        return
    seen.add(path)
    if path.suffix != ".bend":
        return
    for line in path.read_text().splitlines():
        match = IMPORT.match(line)
        if not match:
            continue
        target = match.group(1) or match.group(2)
        if target == "Base":
            continue  # Compiler/Base pin is supplied by the execution runner.
        if not target.endswith((".bend", ".c", ".js")):
            raise ValueError(f"unclassified import {target!r} in {path}")
        visit(path.parent / target)


visit(ENTRY)
records = [
    {"path": str(path.relative_to(ROOT)), "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}
    for path in sorted(seen)
]
sidecars = [row for row in records if row["path"].endswith((".c", ".js"))]
if len(sidecars) != 2:
    raise ValueError(f"expected the two namespace CNI sidecars, found {len(sidecars)}")
result = {
    "base": "1bf6b8595",
    "entry": str(ENTRY.relative_to(ROOT)),
    "sources": records,
    "bend_count": len(records) - len(sidecars),
    "cni_sidecar_count": len(sidecars),
    "import_policy": "recursive bare/relative Bend imports plus quoted CNI sidecars; Base uses runner pin",
}
(HERE / "source-manifest.json").write_text(json.dumps(result, indent=2) + "\n")
