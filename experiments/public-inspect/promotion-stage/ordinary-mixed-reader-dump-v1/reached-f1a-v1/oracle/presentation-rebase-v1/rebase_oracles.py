from __future__ import annotations

import gzip
import hashlib
import io
import json
import os
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASE = HERE.parent.parent
COPY_MAP = BASE / "SOURCE-COPY-MAP.json"
PLAN = BASE / "native01" / "plan.json"
ADAPTER = BASE / "source" / "ecs" / "ordinary-app-event-family-dump.bend"
CORE_ROOT = Path("/workspace/formal-proofs/bendvy/src/ecs")
MANIFEST = HERE / "PRESENTATION-REBASE.json"


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def file_sha(path: Path) -> str:
    return sha(path.read_bytes())


def gzip_deterministic(data: bytes) -> bytes:
    output = io.BytesIO()
    with gzip.GzipFile(filename="", mode="wb", compresslevel=9, mtime=0, fileobj=output) as stream:
        stream.write(data)
    return output.getvalue()


copy_map = json.loads(COPY_MAP.read_text())
plan = json.loads(PLAN.read_text())
entries = [row for row in copy_map["copies"] if Path(row["logicalPath"]).name == "entry.bend"]
if len(entries) != 1:
    raise SystemExit(f"expected exactly one original entry copy, found {len(entries)}")
old_entry = Path(entries[0]["logicalPath"])
new_entry = Path(plan["entrypoint"])
if new_entry.resolve() != (BASE / "source/fixture/entry.bend").resolve():
    raise SystemExit("plan entrypoint no longer names the copied fixture entry")

# The copied adapter's absolute core imports establish the common module directory.
imports = []
for line in ADAPTER.read_text().splitlines():
    stripped = line.strip()
    if stripped.startswith("import /workspace/formal-proofs/bendvy/src/ecs/"):
        imports.append(stripped.split()[1])
if len(imports) != 9:
    raise SystemExit(f"expected the nine pinned absolute core imports, found {len(imports)}")
if any(Path(module).parent != CORE_ROOT for module in imports):
    raise SystemExit("absolute core imports no longer share the pinned ECS directory")

old_prefix = os.path.relpath(CORE_ROOT, old_entry.parent) + "/"
new_prefix = os.path.relpath(CORE_ROOT, new_entry.parent) + "/"
if old_prefix.count("../") != 6 or new_prefix.count("../") != 9:
    raise SystemExit(f"unexpected source-relative prefix depths: {old_prefix!r} -> {new_prefix!r}")
old_bytes = old_prefix.encode("utf-8")
new_bytes = new_prefix.encode("utf-8")

inputs = {
    "counter": BASE / "oracle" / "expected.stdout.gz",
    "normal": BASE / "oracle" / "normal.stdout.gz",
}
outputs = {
    "counter": HERE / "counter.stdout.gz",
    "normal": HERE / "normal.stdout.gz",
}
records = {}
for role, source in inputs.items():
    compressed = source.read_bytes()
    raw = gzip.decompress(compressed)
    if old_bytes not in raw or new_bytes in raw:
        raise SystemExit(f"{role} oracle does not contain only the source-derived old prefix")
    count = raw.count(old_bytes)
    relocated = raw.replace(old_bytes, new_bytes)
    if relocated.replace(new_bytes, old_bytes) != raw:
        raise SystemExit(f"{role} oracle relocation is not bijective")
    packed = gzip_deterministic(relocated)
    outputs[role].write_bytes(packed)
    records[role] = {
        "inputPath": str(source),
        "inputGzipSHA256": sha(compressed),
        "inputBytes": len(raw),
        "inputSHA256": sha(raw),
        "replacements": count,
        "outputPath": str(outputs[role]),
        "outputGzipSHA256": sha(packed),
        "outputBytes": len(relocated),
        "outputSHA256": sha(relocated),
        "reverseMappingRestoresInput": True,
    }

manifest = {
    "purpose": "Relocate only compiler-rendered core-module QName path prefixes in the two independent source-derived full oracles.",
    "runtimeOutputRead": False,
    "generatorPath": str(Path(__file__).resolve()),
    "generatorSHA256": file_sha(Path(__file__).resolve()),
    "sourceDerivation": {
        "copyMapPath": str(COPY_MAP),
        "copyMapSHA256": file_sha(COPY_MAP),
        "frozenPlanPath": str(PLAN),
        "frozenPlanSHA256": file_sha(PLAN),
        "originalEntryPath": str(old_entry),
        "successorEntryPath": str(new_entry),
        "fixedAbsoluteCoreRoot": str(CORE_ROOT),
        "absoluteCoreImports": imports,
        "originalRelativeCorePrefix": old_prefix,
        "successorRelativeCorePrefix": new_prefix,
        "method": "POSIX relative path from each entry module's parent directory to the same absolute ECS core module directory; preserve all bytes except that exact prefix substitution.",
        "adapterPath": str(ADAPTER),
        "adapterSHA256": file_sha(ADAPTER),
    },
    "oracles": records,
}
MANIFEST.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")
print(json.dumps({"manifest": str(MANIFEST), "manifestSHA256": file_sha(MANIFEST), "sourceDerivation": manifest["sourceDerivation"], "oracles": records}, indent=2))
