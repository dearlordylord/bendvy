#!/usr/bin/env python3
"""Export a pinned ECS source tree using BendHub's underscore-only file paths.

Usage: python3 scripts/package-bendhub.py COMMIT NEW_OUTPUT_DIRECTORY
The source checkout is unchanged. Publish OUTPUT/bendvy.bend, not src/ecs directly.
"""
import argparse
import hashlib
import io
import json
from pathlib import Path
import re
from task_runner import check_output
import tarfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("commit")
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    if not re.fullmatch(r"[0-9a-fA-F]{7,40}", args.commit):
        parser.error("use an immutable Git commit hash")
    repo = Path(__file__).resolve().parent.parent
    revision = check_output(
        ["git", "-C", str(repo), "rev-parse", "--verify", args.commit + "^{commit}"],
        text=True, timeout=30,
    ).strip()
    archive = check_output(
        ["git", "-C", str(repo), "archive", revision, "src/ecs"], timeout=30
    )
    files, mapping = {}, {}
    with tarfile.open(fileobj=io.BytesIO(archive)) as source:
        for member in source.getmembers():
            if not member.isfile():
                continue
            original = Path(member.name).relative_to("src/ecs")
            if original.suffix not in {".bend", ".c", ".js"} and original.name != "LICENSE":
                continue
            target = str(original).replace("-", "_")
            if target in files:
                raise ValueError("package path collision: " + target)
            text = source.extractfile(member).read().decode("utf-8-sig")
            if original.suffix == ".bend":
                def imported(match):
                    lead, quote, path, end = match.groups()
                    if path != "Base" and "@" not in path and not path.startswith("0x"):
                        path = path.replace("-", "_")
                    return lead + quote + path + end
                text = re.sub(r'(?m)^(\s*import\s+)("?)([^\s"]+)("?)', imported, text)
            files[target] = text.encode()
            mapping[str(original)] = target
    if "LICENSE" not in files or "bendvy.bend" not in files:
        raise ValueError("entry and LICENSE must be committed before packaging")
    args.output.mkdir(parents=True, exist_ok=False)
    for name, data in files.items():
        target = args.output / name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
    print(json.dumps({"sourceCommit": revision, "output": str(args.output),
                      "paths": mapping,
                      "sha256": {p: hashlib.sha256(b).hexdigest() for p, b in files.items()}},
                     indent=2))


if __name__ == "__main__":
    main()
