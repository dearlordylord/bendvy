#!/usr/bin/env python3
"""Reproduce and verify the frozen source-derived omission counter."""
from pathlib import Path
import argparse,gzip,hashlib,json
import counter_model
HERE=Path(__file__).resolve().parent
SOURCE=Path('/tmp/bendvy-recovery-resource-field/experiments/public-recovery/resource-field-v1/replacement-owner-loss-v1')
sha=lambda data:hashlib.sha256(data).hexdigest()


def main():
    p=argparse.ArgumentParser();p.add_argument('--selftest',action='store_true');args=p.parse_args()
    basis=json.loads((HERE/'SOURCE-BASIS.json').read_bytes())
    freeze=(SOURCE/'SOURCE-FREEZE.json').read_bytes();assert sha(freeze)==basis['sourceFreeze']['sha256']
    f=json.loads(freeze);assert f['sourceInventory']==basis['sourceInventory']and f['sourcePins']==basis['sourcePins']
    for path,digest in f['sourcePins'].items():assert sha(Path(path).read_bytes())==digest
    for name,digest in basis['counterModelSources'].items():assert sha((HERE/name).read_bytes())==digest
    for name,digest in basis['normalModelSources'].items():assert sha((HERE.parent/name).read_bytes())==digest
    assert sha((SOURCE/'MUTATION.diff').read_bytes())==basis['mutationDiffSHA256']
    raw,traces=counter_model.selftest();z=gzip.compress(raw,mtime=0)
    assert raw==(HERE/'expected.stdout').read_bytes()
    assert z==(HERE/'expected.stdout.gz').read_bytes()
    assert json.loads(json.dumps(traces))==json.loads((HERE/'state-trace.json').read_text())
    print(json.dumps({'status':'SOURCE_DERIVED_COUNTER_PASS','bytes':len(raw),'sha256':sha(raw),
                      'gzipBytes':len(z),'gzipSHA256':sha(z),'sourceModules':len(f['sourceInventory']),
                      'sourcePins':len(f['sourcePins'])}))


if __name__=='__main__':main()
