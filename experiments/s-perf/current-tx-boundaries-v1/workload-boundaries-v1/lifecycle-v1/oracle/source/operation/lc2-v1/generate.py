"""Transcode only the sealed independent Motion64 LC1 oracle, never ECS state."""
import gzip
import hashlib
from pathlib import Path
import sys
from codec import LC1, encode_report

INPUT = Path(__file__).resolve().parent.parent / 'lc1-v1/motion64/expected.stdout.gz'
INPUT_SHA256 = 'd344134b5a4973d1b2bb199242e3d900c6e3dd68d76a18e2e336e15d0fc44a88'


def generate():
    raw = gzip.decompress(INPUT.read_bytes())
    assert len(raw) == 7297970 and hashlib.sha256(raw).hexdigest() == INPUT_SHA256
    return encode_report(LC1.decode_report(raw))


if __name__ == '__main__':
    sys.stdout.buffer.write(generate())
