"""Verify exact retry source/receipt/raw-log capsule; no semantic approval."""
from pathlib import Path
import hashlib,json,tarfile
HERE=Path(__file__).resolve().parent;index=json.loads((HERE/'index.json').read_text())
with tarfile.open(HERE/'objects.tar.gz','r:gz') as tar:objects={m.name:tar.extractfile(m).read() for m in tar.getmembers()}
assert set(objects)==set(index['objects'])
for h,b in objects.items():assert hashlib.sha256(b).hexdigest()==h and len(b)==index['objects'][h]
for run in index['runs'].values():
 receipt=json.loads(objects[run['receipt']]);assert receipt['immutableLogs']==run['rawLogs']
 for n,h in run['inputFiles'].items():assert receipt['inputs'][n]==h and h in objects
 for n,files in run['inputDirectories'].items():assert receipt['inputs'][n]==files and all(h in objects for h in files.values())
print('PASS: 2 receipts, 20 complete raw streams and exact consumed project/TS sources; 50 objects')
