"""No-child actual declaration-grant assembly/source diagnostic joins."""
import hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
for path,digest in json.loads((HERE/'source-pins.json').read_text()).items():assert sha(Path(path))==digest
for name,row in json.loads((HERE/'registered-source-join.json').read_text()).items():
 assert sha(HERE/'registered-v1'/name)==row['candidateSha256'] and sha(HERE.parent/'registered-read-v1'/name)==row['baselineSha256']
 if name!='fixture.bend':assert row['unchanged']
for stem in ('main','registered-source-2'):
 assert 'ALL PROOFS CHECK' in (HERE/'evidence'/(stem+'.stdout')).read_text() and (HERE/'evidence'/(stem+'.stderr')).read_bytes()==b''
error=(HERE/'evidence/undeclared-source-1.stderr').read_text()
assert 'Location: reached' in error and 'Request<P.Payload, P.Query, P.Projection>' in error and 'observed : Query.Declaration<C.Schema, P.Payload, Unit>' in error
markers={'args-duplication-negative':'args (consumed more than once)','owner-duplication-negative':'owner (consumed more than once)','write-negative':'expected : Cap.ValueWrite','escape-negative':'Cap.Request<C.Payload, C.Query, C.Projection>'}
for row in json.loads((HERE/'evidence/results.json').read_text()):
 assert row['sourceCapSeconds']==5
 if row['source']=='main.bend':assert row['exit']==0
 else:
  assert row['exit']==1 and (HERE/'evidence'/(Path(row['source']).stem+'.stdout')).read_bytes()==b''
  diagnostic=(HERE/'evidence'/(Path(row['source']).stem+'.stderr')).read_text();assert markers[Path(row['source']).stem] in diagnostic and 'SOME PROOFS FAIL' in diagnostic
print('PASS actual ordinary declaration grant/access assembly, complete source consumers and five intended refusals; no child')
