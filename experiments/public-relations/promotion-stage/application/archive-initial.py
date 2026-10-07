"""Lossless initial application/source/log retention; no new execution."""
import hashlib,json,pathlib,tarfile
D=pathlib.Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
files=sorted(p for p in D.rglob('*') if p.is_file() and not any(x in p.parts for x in ['__pycache__','capsules','next-version']))
receipts=[D/'evidence'/name/'receipt.json' for name in ['application-1791375139683468576','application-1791375352671739940']]
inputs={}
for receipt in receipts:
 for name,h in json.loads(receipt.read_text())['pins'].items():
  p=pathlib.Path(name)
  if p.suffix in ['.py','.ts','.mjs','.bend','.c','.js','.json'] and p.is_file():
   assert sha(p)==h,(name,'input drift before retention');inputs[p]=h
members={str(p.relative_to(D)):p for p in files}
for p in inputs:
 if not p.is_relative_to(D):members['bound-inputs/'+str(p).lstrip('/')]=p
hashes={name:sha(p) for name,p in members.items()};out=D/'capsules';out.mkdir(exist_ok=True);archive=out/'initial-application.tar.gz';assert not archive.exists()
with tarfile.open(archive,'w:gz',compresslevel=9) as tar:
 for name,p in sorted(members.items()):tar.add(p,arcname=name,recursive=False)
with tarfile.open(archive) as tar:observed={m.name:hashlib.sha256(tar.extractfile(m).read()).hexdigest() for m in tar if m.isfile()}
assert observed==hashes
assert all(sha(p)==hashes[name] for name,p in members.items())
index={'archive':archive.name,'archiveSHA256':sha(archive),'bytes':archive.stat().st_size,'memberCount':len(hashes),'members':hashes,'receipts':{str(p.relative_to(D)):sha(p) for p in receipts},'boundTextInputPaths':{str(p):h for p,h in inputs.items()},'scope':'All initial local execution/development histories, exact generated stages/products and raw logs; text source/config/helper input snapshots. Invoked binary/library/tool bytes remain exact pinned external requirements, not a bundled toolchain. V3 FAIL and V4 PASS retain distinct attribution; no new execution.'}
(out/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(len(hashes),archive.stat().st_size)
