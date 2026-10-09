"""No-child actual source-current authority diagnostic and source joins."""
import hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
for path,digest in json.loads((HERE/'source-pins.json').read_text()).items():assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==digest
results=json.loads((HERE/'evidence/results.json').read_text());assert len(results)==5
expected={
 'cross-schema-negative':('expected : Ev.Reader<F.Schema>','observed : Ev.Reader<OtherSchema>','Location: reached'),
 'escape-negative':('Location: reached','Cap.Request<P.Payload, U32, U32>','Cap.Request<H, U32, U32>'),
 'owner-duplication-negative':('owner (consumed more than once)','Location: duplicate'),
 'write-negative':('expected : Cap.ValueWrite','observed : Cap.Request','Location: write'),
}
for row in results:
 stem=Path(row['source']).stem
 assert row['sourceCapSeconds']==5 and row['argv'][:3]==['flock','/tmp/bendvy-parity-heavy.lock','scripts/bend-check']
 out=(HERE/'evidence'/(stem+'.stdout')).read_text();error=(HERE/'evidence'/(stem+'.stderr')).read_text()
 if stem=='positive-owned-output':assert row['exit']==0 and 'ALL PROOFS CHECK' in out and error==''
 else:
  assert row['exit']==1 and out=='' and 'SOME PROOFS FAIL' in error
  assert all(marker in error for marker in expected[stem])
  assert 'ParseError' not in error and 'not found' not in error
print('PASS source-current actual Log.read owned-output and four intended affine/capability/nominal refusals; no child')
