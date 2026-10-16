#!/usr/bin/env python3
"""Bind frozen source and reproduce complete independent oracle, without Bend."""
from pathlib import Path
import argparse
import gzip
import hashlib
import json
import model

HERE = Path(__file__).resolve().parent
SOURCE = Path('/tmp/bendvy-recovery-resource-field/experiments/public-recovery/resource-field-v1')


def sha(data):
    return hashlib.sha256(data).hexdigest()


def verify_source(basis):
    freeze_bytes = (SOURCE / 'SOURCE-FREEZE.json').read_bytes()
    assert sha(freeze_bytes) == basis['sourceFreeze']['sha256']
    freeze = json.loads(freeze_bytes)
    assert freeze['sourceInventory'] == basis['sourceInventory']
    assert freeze['sourcePins'] == basis['sourcePins']
    for path, digest in freeze['sourcePins'].items():
        assert sha(Path(path).read_bytes()) == digest, path
    # Only the source-check receipt identity is read, not its raw diagnostics.
    assert sha((SOURCE / 'SOURCE-CHECK.json').read_bytes()) == basis['sourceCheck']['sha256']
    for filename, digest in basis['modelSources'].items():
        assert sha((HERE / filename).read_bytes()) == digest


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    parser.add_argument('--selftest', action='store_true')
    args = parser.parse_args()
    basis = json.loads((HERE / 'SOURCE-BASIS.json').read_bytes())
    verify_source(basis)
    raw, states = model.selftest()
    zipped = gzip.compress(raw, mtime=0)
    if args.write:
        (HERE / 'expected.stdout').write_bytes(raw)
        (HERE / 'expected.stdout.gz').write_bytes(zipped)
        (HERE / 'state-trace.json').write_text(json.dumps(states, indent=2) + '\n')
    if args.selftest:
        assert (HERE / 'expected.stdout').read_bytes() == raw
        assert (HERE / 'expected.stdout.gz').read_bytes() == zipped
        assert gzip.decompress(zipped) == raw
        assert json.loads((HERE / 'state-trace.json').read_text()) == json.loads(json.dumps(states))
    if not (args.write or args.selftest):
        parser.error('choose --write or --selftest')
    print(json.dumps({'status': 'SOURCE_DERIVED_ORACLE_PASS', 'bytes': len(raw),
                      'sha256': sha(raw), 'gzipBytes': len(zipped),
                      'gzipSHA256': sha(zipped), 'sourceModules': len(basis['sourceInventory']),
                      'sourcePins': len(basis['sourcePins'])}))


if __name__ == '__main__':
    main()
