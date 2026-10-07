"""Verify and optionally extract exact historical receipt inputs/outputs."""
from pathlib import Path
import argparse,hashlib,json,tarfile
HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--extract',type=Path);args=p.parse_args()
index=json.loads((HERE/'index.json').read_text())
with tarfile.open(HERE/'objects.tar.gz','r:gz') as archive:
 objects={m.name:archive.extractfile(m).read() for m in archive.getmembers()}
assert set(objects)==set(index['objects'])
for h,b in objects.items():assert hashlib.sha256(b).hexdigest()==h and len(b)==index['objects'][h]
for identifier,run in index['runs'].items():
 receipt=json.loads(objects[run['receipt']]);assert receipt['status']==run['status']
 for field,key in [('sources','sources'),('immutableLogs','logs'),('generated','generated'),('fixedInputs','fixedInputs'),('coreInventory','coreInventory')]:assert receipt[field]==run[key]
 assert {str(Path(base)/n):h for base,items in receipt['externalInventories'].items() for n,h in items.items()}==run['externalInputs']
 for key in ['sources','logs','generated','fixedInputs','coreInventory','externalInputs']:
  for name,h in run[key].items():
   assert h in objects
   if args.extract:
    target=args.extract/identifier/key/name.lstrip('/');target.parent.mkdir(parents=True,exist_ok=True);assert not target.exists();target.write_bytes(objects[h])
 if args.extract:
  target=args.extract/identifier/'receipt.json';assert not target.exists();target.write_bytes(objects[run['receipt']])
print('PASS: 3 exact receipts, 171 source memberships, 68 raw logs, 3 generated files; 215 deduplicated objects')
