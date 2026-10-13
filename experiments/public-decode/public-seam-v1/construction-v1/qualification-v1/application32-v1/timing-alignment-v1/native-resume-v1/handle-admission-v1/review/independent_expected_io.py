#!/usr/bin/env python3
"""Source-derived successor oracle including the pinned IO.print effect.

The immutable v1 model derives the 22 complete rows and its model string ends
with one LF because it mirrors main.bend's explicit final ``++ "\n"``.  The
pinned IO.print implementations independently append one more LF.  This
successor models that source-defined effect; it never reads runtime output.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

from independent_expected import expected_lines

ROOT = Path(__file__).resolve().parents[1]
MAIN = ROOT / "main.bend"
PRINT_JS = Path("/home/node/.bend/bend2/effs/print.js")
PRINT_C = Path("/home/node/.bend/bend2/effs/print.c")

EXPECTED_SOURCE_SHA256 = {
    "main.bend": "43845b7faaa61280e1211af7b3ed22069b0267193cde2dc62bc29fc6ff35ce83",
    "print.js": "814ceba4efbaa291b7b6a9ff29aa20e3a23c06eb4fa165c69ee0bd22878adaa9",
    "print.c": "28552d3b56aee6f6cdb66326aaa49ad0df35e4476e08c548c908efcbfafbd3e7",
}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def source_identity() -> dict[str, str]:
    paths = {"main.bend": MAIN, "print.js": PRINT_JS, "print.c": PRINT_C}
    missing = [name for name, path in paths.items() if not path.is_file()]
    if missing:
        raise FileNotFoundError(", ".join(missing))
    actual = {name: sha256(path) for name, path in paths.items()}
    if actual != EXPECTED_SOURCE_SHA256:
        raise AssertionError({"expected": EXPECTED_SOURCE_SHA256, "actual": actual})
    return actual


def model_string() -> bytes:
    rows = expected_lines()
    assert len(rows) == 22
    assert rows[:11] == rows[11:]
    return ("\n".join(rows) + "\n").encode("utf-8")


def io_print_stdout() -> bytes:
    inner = model_string()
    # main.bend:61 supplies the first LF; both pinned print.js:5 and
    # print.c:8 append exactly one LF to the IO.print argument.
    assert inner.endswith(b"\n")
    return inner + b"\n"


def metadata() -> dict[str, object]:
    identity = source_identity()
    inner = model_string()
    outer = io_print_stdout()
    return {
        "schema": "bendvy-handle-admission-independent-oracle-io-v2",
        "rows": 22,
        "runtimeOutputInputsUsed": False,
        "ioPrintSourceIdentity": identity,
        "mainStringEndsWithLF": True,
        "printJSAppendsLF": True,
        "printCAppendsLF": True,
        "sourcePrefixEquality": outer[:-1] == inner,
        "modelBytesBeforeIOPrint": len(inner),
        "modelSHA256BeforeIOPrint": hashlib.sha256(inner).hexdigest(),
        "stdoutBytesAfterIOPrint": len(outer),
        "stdoutSHA256AfterIOPrint": hashlib.sha256(outer).hexdigest(),
        "finalBytes": list(outer[-2:]),
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--emit", action="store_true", help="emit source-derived bytes")
    args = parser.parse_args()
    if args.emit:
        source_identity()
        print(io_print_stdout().decode("utf-8"), end="")
    else:
        print(json.dumps(metadata(), sort_keys=True))


if __name__ == "__main__":
    main()
