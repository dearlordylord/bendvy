"""No-child generic request/affine Args source evidence joins."""
import hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
for path,digest in json.loads((HERE/'source-pins.json').read_text()).items():assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==digest
assert (HERE/'evidence/positive-source-1.stderr').read_bytes()==b''
assert 'ALL PROOFS CHECK' in (HERE/'evidence/positive-source-1.stdout').read_text()
markers={'args-duplication-negative':['args (consumed more than once)','Location: body'], 'owner-duplication-negative':['owner (consumed more than once)','Location: body'], 'write-negative':['expected : Cap.ValueWrite','observed : Cap.Request','Location: body'], 'escape-negative':['Cap.Request<C.Payload, C.Query, C.Projection>','Cap.Request<H, C.Query, C.Projection>','Location: reached']}
rows=json.loads((HERE/'evidence/results.json').read_text());assert len(rows)==4
for row in rows:
 stem=Path(row['source']).stem;assert row['exit']==1 and row['sourceCapSeconds']==5
 assert (HERE/'evidence'/(stem+'.stdout')).read_bytes()==b''
 error=(HERE/'evidence'/(stem+'.stderr')).read_text();assert 'SOME PROOFS FAIL' in error and all(s in error for s in markers[stem])
 assert 'ParseError' not in error and 'not found' not in error
print('PASS source-current generic affine Query/Args + Bool/String projections and four intended refusals; no child')
