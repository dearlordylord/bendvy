"""Bind a comparator to a delivery manifest before preparing child execution.

Selection and byte identity are checked here. The originating receipt supplies
semantic acceptance; listing a file in a manifest does not prove its behavior.
"""
import hashlib
import json
from pathlib import Path


def _sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def binding(root, manifest, entry):
    root = Path(root).resolve()
    manifest = Path(manifest).resolve()
    requested = root / entry
    try:
        relative = requested.relative_to(root)
    except ValueError as error:
        raise RuntimeError("reference is outside the source root") from error
    if ".." in relative.parts:
        raise RuntimeError("reference is outside the source root or not normalized")
    key = relative.as_posix()
    manifest_bytes = manifest.read_bytes()
    selected = json.loads(manifest_bytes)["files"]
    if key not in selected:
        raise RuntimeError(f"reference not selected by delivery manifest: {key}")
    candidate = requested.resolve()
    if candidate != requested:
        raise RuntimeError(f"selected reference uses a path alias: {key}")
    if _sha(candidate) != selected[key]:
        raise RuntimeError(f"selected reference bytes changed: {key}")
    return {
        "manifest": str(manifest),
        "manifestSHA256": hashlib.sha256(manifest_bytes).hexdigest(),
        "reference": str(candidate),
        "referenceSHA256": selected[key],
    }


def verify(root, expected):
    candidate = Path(expected["reference"])
    current = binding(root, expected["manifest"], candidate)
    if current != expected:
        raise RuntimeError("selected reference binding changed")
    return current
