"""Independent prototype oracle. Inputs are prior independent gold, never candidate output."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import re

MASK = (1 << 32) - 1
VERSION = b"PROTOTYPE:typed-observation-v1\n"

def mix(acc, value):
    return (33 * acc + value) & MASK

def natural(acc, value):
    assert type(value) is int and value >= 0
    while True:
        acc = mix(acc, value & MASK)
        value >>= 32
        if not value:
            return mix(acc, MASK)

def string(acc, value):
    acc = natural(acc, len(value))
    for char in value:
        scalar = ord(char)
        assert not 0xD800 <= scalar <= 0xDFFF
        acc = mix(acc, scalar)
    return acc

def typed(acc, value):
    tasks = [(False, value)]
    while tasks:
        key, item = tasks.pop()
        if key:
            acc = string(acc, item)
        elif item is None:
            acc = mix(acc, 0)
        elif type(item) is bool:
            acc = mix(mix(acc, 1), int(item))
        elif type(item) is int:
            acc = natural(mix(acc, 2), item)
        elif type(item) is str:
            acc = string(mix(acc, 3), item)
        elif type(item) is list:
            acc = natural(mix(acc, 4), len(item))
            tasks.extend((False, child) for child in reversed(item))
        elif type(item) is dict:
            acc = natural(mix(acc, 5), len(item))
            for name, child in reversed(list(item.items())):
                tasks.append((False, child))
                tasks.append((True, name))
        else:
            raise TypeError(type(item).__name__)
    return acc

def controls():
    cases = [[], [None, False, True, 0, MASK, 1 << 32, (1 << 48) - 1,
                  "", "A\né😀", [], {}, {"a": [1, {"x": '\\"'}], "b": None}],
             [{"a": 1, "b": 2}], [{"b": 2, "a": 1}]]
    return [{"values": v, "token": typed(0, v)} for v in cases]

def wire_records(line, prefix):
    assert line.startswith(prefix + b"[") and line.endswith(b"]\n")
    # Parse every cell, retaining at most the current JSON record's characters.
    body = line[len(prefix) + 1:-2]
    cells = iter(int(m.group()) for m in re.finditer(rb"[0-9]+", body))
    def decimal():
        digits = []
        for cell in cells:
            if cell == 0:
                assert digits and (len(digits) == 1 or digits[0] != "0")
                return int("".join(digits))
            assert 48 <= cell <= 57
            digits.append(chr(cell))
        raise ValueError("unterminated framing")
    count = decimal()
    for _ in range(count):
        length = decimal()
        chars = []
        for _ in range(length):
            c = next(cells)
            assert c <= 0x10FFFF and not 0xD800 <= c <= 0xDFFF
            chars.append(chr(c))
        def unique_object(pairs):
            names = [name for name, _ in pairs]
            assert len(names) == len(set(names)), "duplicate field would lose an observation"
            return dict(pairs)
        value = json.loads("".join(chars), object_pairs_hook=unique_object)
        yield count, value
    assert next(cells, None) is None

def derive(source, target, expected_sha):
    digest = hashlib.sha256()
    tokens = {}
    phase = None
    routes = {b"TUPLE:": b"FORCE:", b"FOREIGN-TUPLE:": b"FOREIGN-FORCE:",
              b"PUBLIC-TUPLE:": b"PUBLIC-FORCE:"}
    with gzip.open(source, "rb") as stream:
        for line in stream:
            digest.update(line)
            if line in (b"WARMUP\n", b"SAMPLE\n"):
                phase = line.strip().decode()
            for prefix, label in routes.items():
                if line.startswith(prefix):
                    acc = None
                    seen = 0
                    for count, value in wire_records(line, prefix):
                        if acc is None:
                            acc = natural(mix(0, 4), count)
                        acc = typed(acc, value)
                        seen += 1
                    assert seen and seen == count and phase
                    tokens[(phase, label)] = acc
    assert digest.hexdigest() == expected_sha, "independent input identity changed"
    assert len(tokens) == 6
    out_hash = hashlib.sha256()
    size = 0
    def write(out, data):
        nonlocal size
        out.write(data)
        out_hash.update(data)
        size += len(data)
    with gzip.open(source, "rb") as inp, open(target, "xb") as raw:
        with gzip.GzipFile(filename="", mode="wb", fileobj=raw, mtime=0) as out:
            write(out, VERSION)
            for line in inp:
                if line in (b"WARMUP\n", b"SAMPLE\n"):
                    phase = line.strip().decode()
                label = line.split(b":", 1)[0] + b":"
                if label in routes.values():
                    line = label + str(tokens[(phase, label)]).encode() + b"\n"
                write(out, line)
    return {"source": str(source), "sourceSHA256": expected_sha,
            "path": str(target), "bytes": size, "sha256": out_hash.hexdigest(),
            "gzipSHA256": hashlib.sha256(Path(target).read_bytes()).hexdigest(),
            "tokens": [{"phase": p, "label": l.decode(), "value": v}
                       for (p, l), v in tokens.items()]}

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--source")
    parser.add_argument("--target")
    parser.add_argument("--sha256")
    args = parser.parse_args()
    if args.source:
        result = derive(Path(args.source), Path(args.target), args.sha256)
    else:
        result = controls()
    print(json.dumps(result, ensure_ascii=False, indent=2))
