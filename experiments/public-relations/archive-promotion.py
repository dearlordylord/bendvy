"""Retain reviewed Query slices as compressed decoded-hash-verifiable capsules."""
from pathlib import Path
import hashlib,json,tarfile

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
import task_runner

HERE=Path(__file__).resolve().parent;STAGE=HERE/'promotion-stage';OUT=HERE/'promotion-capsules'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def members(root):return [p for p in sorted(root.rglob('*')) if p.is_file() and '__pycache__' not in p.parts]
def main():
 OUT.mkdir(exist_ok=True);items=[]
 for name,root in [('query',STAGE/'evidence/query-1791368619238781128'),('lifetime',STAGE/'query-lifetime/evidence/1791369196701030146')]:
  files=members(root);receipt=root/'receipt.json';r=json.loads(receipt.read_text());assert r['status'] in ['FINITE_REGISTERED_RELATION_QUERY_PASS','FINITE_REGISTERED_QUERY_LIFETIME_PASS']
  expected={str(p.relative_to(HERE)):sha(p) for p in files};target=OUT/(name+'.tar.gz');assert not target.exists()
  with tarfile.open(target,'w:gz',compresslevel=9) as tar:
   for p in files:tar.add(p,arcname=str(p.relative_to(HERE)),recursive=False)
  with tarfile.open(target,'r:gz') as tar:
   actual={m.name:hashlib.sha256(tar.extractfile(m).read()).hexdigest() for m in tar.getmembers() if m.isfile()}
  assert actual==expected;assert all(sha(HERE/path)==h for path,h in expected.items());items.append({'archive':str(target.relative_to(HERE)),'sha256':sha(target),'bytes':target.stat().st_size,'members':expected,'receipt':str(receipt.relative_to(HERE)),'receiptSHA256':sha(receipt),'status':r['status']})
 sourcefiles=[p for p in sorted(STAGE.glob('*')) if p.is_file()]+list((STAGE/'modules').glob('*.bend'))+[p for p in (STAGE/'query-lifetime').glob('*') if p.is_file()]
 sourcefiles += [HERE.parents[1]/'scripts/receipt-logs.py',HERE.parents[1]/'scripts/task_runner.py']
 target=OUT/'sources.tar.gz';assert not target.exists();expected={}
 with tarfile.open(target,'w:gz',compresslevel=9) as tar:
  for p in sourcefiles:
   try:key=str(p.relative_to(HERE))
   except ValueError:key='shared/'+str(p.relative_to(HERE.parents[1]))
   assert key not in expected;expected[key]=sha(p);tar.add(p,arcname=key,recursive=False)
 with tarfile.open(target,'r:gz') as tar:actual={m.name:hashlib.sha256(tar.extractfile(m).read()).hexdigest() for m in tar.getmembers() if m.isfile()}
 assert actual==expected;items.append({'archive':str(target.relative_to(HERE)),'sha256':sha(target),'bytes':target.stat().st_size,'members':expected,'scope':'current source/helper snapshot; reviewed receipts remain distinct'})
 (OUT/'index.json').write_text(json.dumps({'scope':'Integrity/retention only; no new execution, proof, production or performance acceptance','recipeSHA256':sha(Path(__file__)),'capsules':items},indent=2)+'\n')
 print(sum(item['bytes'] for item in items))
if __name__=='__main__':main()
