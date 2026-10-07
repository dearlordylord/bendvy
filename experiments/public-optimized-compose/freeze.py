"""Verify and materialize the exact selected optimized route; never rebase it."""
import argparse
import hashlib
import json
import pathlib
import tarfile

ROOT = pathlib.Path(__file__).resolve().parents[2]
SELECTED = "a4672d110446195e3ac92911c6f41166b62025811df8816878356d0eafd08a55"

def freeze(destination):
    source = ROOT / "experiments/s-prep/source-concrete-owner-handoff"
    recipe = json.loads((source / "source-recipe.json").read_text())
    expected = recipe["sources"]
    closure = hashlib.sha256(json.dumps(expected, sort_keys=True, separators=(",", ":")).encode()).hexdigest()
    if closure != SELECTED or recipe["sourceClosureSHA256"] != SELECTED:
        raise ValueError("Selected source closure changed")
    with tarfile.open(source / "source-v3.tar.xz") as archive:
        members = archive.getmembers()
        if set(m.name for m in members) != set(expected):
            raise ValueError("Archive inventory differs from frozen source recipe")
        for member in members:
            path = pathlib.PurePosixPath(member.name)
            if not member.isfile() or path.is_absolute() or ".." in path.parts:
                raise ValueError("Unsafe archive member")
            data = archive.extractfile(member).read()
            if hashlib.sha256(data).hexdigest() != expected[member.name]:
                raise ValueError("Frozen module digest differs: " + member.name)
        destination.mkdir(parents=True, exist_ok=False)
        for member in members:
            target = destination / member.name
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(archive.extractfile(member).read())
    return {"closure": closure, "modules": len(expected), "sources": expected}

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("destination", type=pathlib.Path)
    args = parser.parse_args()
    print(json.dumps(freeze(args.destination), indent=2))
