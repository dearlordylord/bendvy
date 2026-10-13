#!/usr/bin/env python3
"""Independent source-derived byte oracle for authority-controls-v2/main.bend.

This models the two declared-binding branches and one fresh-world readonly
query for each nominal schema. It does not read runtime output.
"""
from __future__ import annotations

import gzip
import hashlib
from pathlib import Path


def entry_text(key: str, name: str) -> str:
    return f"Entry{{kind=Component,key={key},name={name}}}"


def bound_text(*, present: bool, key: str, name: str) -> str:
    """Follow SF.bind_declared: validate entries, then check required entries."""
    entries = [entry_text(key, name)] if present else []
    if not present:
        error = f"UndeclaredDescriptor{{kind=Component,key={key},name={name}}}"
        rendered_entries = ";".join(entries)
        fragment = f"Fragment{{entries=[{rendered_entries}],owners=Unit{{}}}}"
        return f"BindRejected{{error={error},fragment={fragment}}}"
    # The one entry is valid (no duplicate key/name); requirements finds it,
    # so bind_checked invokes the closed builder on the original Unit owner.
    return "Built{output=launched}"


def readonly_text() -> str:
    """Trace reserve -> activate/populate -> public readonly grant -> get."""
    # W.factory starts at namespace 1. W.create starts nextId at 1;
    # reserve_id returns Handle{1,1}, which spawn_apply activates and populates.
    # H.project then exposes all three payload fields as D.Raw; the query's
    # actual Cap.Read reaches Component.get and returns Found{value}.
    raw = "{cells:[u32:7,u32:8],name:str:seed,target:null}"
    return f"Found{{value={raw}}}"


def expected_stdout() -> bytes:
    # Identity.component stores the same declared key/name for each nominal
    # schema; the distinct S invocations preserve two source-level branches.
    key = name = "HandlePayload"
    output_rows = [
        "first-missing=" + bound_text(present=False, key=key, name=name),
        "first-present=" + bound_text(present=True, key=key, name=name),
        "second-missing=" + bound_text(present=False, key=key, name=name),
        "second-present=" + bound_text(present=True, key=key, name=name),
        "first-read=" + readonly_text(),
        "second-read=" + readonly_text(),
    ]
    # main.bend's argument ends in LF; the pinned IO.print effect appends LF.
    return ("\n".join(output_rows) + "\n\n").encode()


def main() -> None:
    data = expected_stdout()
    here = Path(__file__).resolve().parent
    (here / "expected.stdout").write_bytes(data)
    (here / "expected.stdout.gz").write_bytes(gzip.compress(data, mtime=0))
    print(f"bytes={len(data)} sha256={hashlib.sha256(data).hexdigest()}")


if __name__ == "__main__":
    main()
