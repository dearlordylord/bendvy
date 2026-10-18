"""Transcode only the sealed independent Health64 LC1 bytes."""
import gzip
import hashlib
from pathlib import Path
import sys
from codec import LC1, encode_report

INPUT=Path(__file__).resolve().parents[2]/'lc1-v1/health-v1/health64/expected.stdout.gz'

def generate():
    raw=gzip.decompress(INPUT.read_bytes())
    assert len(raw)==7504674
    assert hashlib.sha256(raw).hexdigest()=='3fb1cc9df9a978c26010e3368fce7bb84ef38cd9a7567f7296d3ad43f9cfc2d6'
    return encode_report(LC1.decode_report(raw))

if __name__=='__main__':
    sys.stdout.buffer.write(generate())
