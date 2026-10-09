"""Exact ordered byte concatenation; no normalization or synthesized observations."""
import gzip
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
WHOLE = '810259f78227f2b3d158c02644978b6c7ecf58b40a4b2fb398a816005b2867e2'


def expected_members():
    manifest = json.loads((HERE / 'oracle-partition.json').read_text())
    members = []
    for row in manifest['members']:
        raw = gzip.decompress((HERE / (row['name'] + '-expected.txt.gz')).read_bytes())
        if len(raw) != row['bytes'] or hashlib.sha256(raw).hexdigest() != row['sha256']:
            raise ValueError('Partition expectation drift')
        members.append((row['name'], raw))
    whole = gzip.decompress((HERE.parent / 'complete-expected.txt.gz').read_bytes())
    if len(whole) != 5077477 or hashlib.sha256(whole).hexdigest() != WHOLE:
        raise ValueError('Whole oracle drift')
    if b''.join(raw for _, raw in members) != whole:
        raise ValueError('Partitions do not preserve whole oracle')
    return members


def compare(actual):
    expected = expected_members()
    if [name for name, _ in actual] != [name for name, _ in expected]:
        raise ValueError('Missing, duplicate or reordered nominal schema')
    for (name, raw), (_, authored) in zip(actual, expected):
        if not isinstance(raw, bytes) or raw != authored:
            raise ValueError('Complete actual schema output differs: ' + name)
    joined = b''.join(raw for _, raw in actual)
    if hashlib.sha256(joined).hexdigest() != WHOLE:
        raise ValueError('Complete aggregate mismatch')
    return joined
