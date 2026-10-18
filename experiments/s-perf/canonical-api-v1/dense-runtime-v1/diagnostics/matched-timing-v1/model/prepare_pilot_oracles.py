"""Seal B1 full semantic streams from independent model only, before subject runs."""
import gzip
import hashlib
import json
from pathlib import Path
from pilot_oracle import expected_common, canonical

here = Path(__file__).resolve().parent
cells, fold, final, audits = expected_common()
compact = lambda value: json.dumps(value, separators=(',', ':'))
sha = lambda value: hashlib.sha256(value).hexdigest()
# Preserve existing independent first-world oracle exactly.
root = Path('/workspace/formal-proofs/bendvy/experiments/s-perf/canonical-api-oracle-v1/dense-runtime-v1')
assert canonical(1) == gzip.decompress((root / 'motion/expected.stdout.gz').read_bytes())
full = dict(final=final, audits=audits, statuses=[{'ok': True} for _ in audits],
            worksum=sum(a['readsum'] for a in audits) % 2**32,
            ids=[r['rawId'] for r in final['rows']],
            finalSha256=sha(compact(final).encode()), oracleSha256=sha(compact(final).encode()),
            fullFieldsCompared=len(final['rows']), samples=dict(first=final['rows'][0], last=final['rows'][-1]))
bend, ts = [], []
for label, namespace in [('WARMUP', 1), ('SAMPLE', 2)]:
    bend.append(f'{label}\nFORCE:{fold}\nTUPLE:{json.dumps(cells)}\nCANONICAL-BEGIN\n'.encode()
                + canonical(namespace) + b'CANONICAL-END\n')
    ts.append(f'{label}\nFORCE:{fold}\nTUPLE:{compact(cells)}\nFULL:{compact(full)}\n'.encode())
metadata = {'scope': 'First B1 DenseMotion64 method-pilot exact deterministic semantic streams; no timing qualification',
            'tupleValues': len(cells), 'fold': fold, 'records': 2, 'warmupNamespace': 1, 'sampleNamespace': 2,
            'sharedFields': 'all actual ordered Main/Aux/Flag fields, Ledger,64 complete per-row audit lists/sums/counts and64 actual statuses',
            'namespaceBasis': 'WorldIO process-local allocator produces1 then2; namespaces/generations preserved in canonical raw report; shared actor id is actual1-based index == rawTSid, no +1 normalization',
            'models': {str(p): sha(p.read_bytes()) for p in [here/'model.py', here/'state.py', here/'pilot_oracle.py']}, 'oracles': {}}
for role, chunks in [('bend', bend), ('ts', ts)]:
    raw = b''.join(chunks)
    path = here / (role + '-expected.stdout.gz')
    path.write_bytes(gzip.compress(raw, mtime=0))
    metadata['oracles'][role] = dict(path=str(path), bytes=len(raw), sha256=sha(raw), gzipSHA256=sha(path.read_bytes()))
(here/'PILOT-ORACLE-BASIS.json').write_text(json.dumps(metadata, indent=2)+'\n')
print(json.dumps(metadata['oracles']))
