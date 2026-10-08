"""Validate exact executed sources and one separately recorded EOF correction.

This preserves the executed-source claim. The candidate's EOF correction is
joined byte-for-byte to its archived subject, never substituted into a receipt.
"""
import hashlib
import json
import tarfile
from pathlib import Path

HERE = Path(__file__).resolve().parent

def validate_sources(pins):
    correction = json.loads((HERE / 'candidate-source-correction.json').read_text())
    geometry = (HERE / 'geometry.bend').resolve()
    for filename, expected in pins.items():
        path = Path(filename)
        current = path.read_bytes()
        if hashlib.sha256(current).hexdigest() == expected:
            continue
        assert path.resolve() == geometry, ('Executed source drift', filename)
        assert expected == correction['executedSha256']
        assert hashlib.sha256(current).hexdigest() == correction['candidateSha256']
        with tarfile.open(HERE / 'development-evidence.tar.gz', 'r:gz') as archive:
            member = archive.getmember(correction['executedArchiveMember'])
            assert member.isfile()
            executed = archive.extractfile(member).read()
        assert hashlib.sha256(executed).hexdigest() == expected
        assert executed == current + b'\n', 'Correction exceeds one EOF LF'
