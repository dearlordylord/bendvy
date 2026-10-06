#!/usr/bin/env python3
"""Retain exact diagnostic outputs, with deterministic gzip and decoded pins."""
import argparse
import gzip
import hashlib
import json
import tarfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
p = argparse.ArgumentParser()
p.add_argument('--input', type=Path, action='append', required=True)
p.add_argument('--overlay', type=Path, required=True)
a = p.parse_args()
target = HERE / 'evidence'
target.mkdir(exist_ok=True)
pins = {}
for source in a.input:
    assert source.exists() and not source.is_symlink(), source
    files = sorted(source.rglob('*')) if source.is_dir() else [source]
    for f in files:
        if not f.is_file():
            continue
        assert not f.is_symlink(), f
        if '__pycache__' in f.parts:
            continue
        relative = Path(source.name) / f.relative_to(source) if source.is_dir() else Path(source.name)
        out = target / (str(relative) + '.gz')
        assert not out.exists(), out
        data = f.read_bytes()
        out.parent.mkdir(parents=True, exist_ok=True)
        encoded = gzip.compress(data, compresslevel=9, mtime=0)
        out.write_bytes(encoded)
        assert gzip.decompress(out.read_bytes()) == data
        pins[str(relative)] = {'decodedSHA256': hashlib.sha256(data).hexdigest(),
                               'decodedBytes': len(data),
                               'archiveSHA256': hashlib.sha256(encoded).hexdigest()}
archive = HERE / 'overlay-v1.tar.gz'
assert not archive.exists()
with archive.open('wb') as raw:
    with gzip.GzipFile(fileobj=raw, mode='wb', mtime=0, filename='') as gz:
        with tarfile.open(fileobj=gz, mode='w') as tar:
            for f in sorted(a.overlay.rglob('*')):
                if not f.is_file() or '__pycache__' in f.parts:
                    continue
                assert not f.is_symlink(), f
                info = tar.gettarinfo(str(f), arcname=str(f.relative_to(a.overlay)))
                info.uid = info.gid = info.mtime = 0
                info.uname = info.gname = ''
                with f.open('rb') as stream:
                    tar.addfile(info, stream)
(HERE / 'archive-pins.json').write_text(json.dumps({'scope': 'Exact finite diagnostics; no performance acceptance',
    'files': pins, 'overlayArchiveSHA256': hashlib.sha256(archive.read_bytes()).hexdigest()}, indent=2) + '\n')
print('ARCHIVE_DECODED_BYTES_VERIFIED', len(pins))
