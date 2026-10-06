#!/usr/bin/env python3
from pathlib import Path
import argparse,json,hashlib,tarfile
H=Path(__file__).resolve().parent;p=argparse.ArgumentParser();p.add_argument('--input',type=Path,required=True);a=p.parse_args();sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r=json.loads((a.input/'source-bound-receipt.json').read_text());assert r['status']=='FRESH_GENERIC_AFFINE_STORAGE_ORIGINAL_NEGATIVES_THREE_MUTANTS_PASS';e=json.loads((a.input/'evidence.json').read_text());assert e['status']=='ACTUAL_FINAL_STORAGE_FIELDS_OWNERSHIP_MUTANTS_PASS';entries={}
for f in a.input.rglob('*'):
 if f.is_file() and (f.suffix in ['.bend','.json','.txt','.c','.js']):entries[str(f.relative_to(a.input))]=f
script=Path('/workspace/formal-proofs/bendvy/experiments/s-prep/fivehour-connected-gates/owned-storage-run.py');assert sha(script)==r['protectedRunnerSHA256'];entries['protected-owned-storage-run.py']=script
entries['history/logger-bytes-v1-receipt.json']=Path('/tmp/bendvy-slot-host-owned-storage-v1/source-bound-receipt.json')
for n,h in r['sourcePins'].items():assert sha(a.input/'input/candidate'/Path(n).name)==h
for c in r['commands']:
 for key,suffix in [('stdoutSHA256','stdout'),('stderrSHA256','stderr')]:
  if key in c:
   f=a.input/('command-'+str(r['commands'].index(c))+'-'+suffix+'.txt');assert sha(f)==c[key]
binaries={n:sha(a.input/'work'/n) for n in ['original','wrong-slot','wrong-growth','lost-growth-owner']}
out=H/'owned-storage.tar.gz'
with tarfile.open(out,'w:gz') as t:
 for n,f in sorted(entries.items()):t.add(f,arcname=n,recursive=False)
pins={n:sha(f) for n,f in entries.items()}
with tarfile.open(out,'r:gz') as t:assert {m.name:hashlib.sha256(t.extractfile(m).read()).hexdigest() for m in t.getmembers()}==pins
(H/'owned-storage-manifest.json').write_text(json.dumps({'scope':r['scope'],'status':r['status'],'archiveSHA256':sha(out),'decodedSHA256Verified':True,'nativeExecutablePins':binaries,'members':pins},indent=2)+'\n');print(len(pins),out.stat().st_size)
