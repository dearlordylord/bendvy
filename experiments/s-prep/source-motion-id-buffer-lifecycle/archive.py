#!/usr/bin/env python3
"""Compact immutable diagnostic receipts; no execution or acceptance inference."""
import hashlib,json,tarfile,io
from pathlib import Path
here=Path(__file__).resolve().parent
roots=[]
for p in sorted(Path('/tmp').glob('bendvy-split-direct-*-r[1234]')):
 if (p/'evidence.json').exists():
  d=json.loads((p/'evidence.json').read_text());kind='history' if d['status']=='FAIL' else 'mutant' if d.get('mutation') else 'physical' if 'physical' in p.name else 'positive'
  roots.append((str(p),kind))
for n in ['high-depth-v10','hostile-depth-v12','one-v12','two-v12','none-v12','empty-v12','optional-v12','present-v12','missing-v12','alias-v12','id-undersize-v12']:
 roots.append(('/tmp/bendvy-split-id-'+n,'history'))
objects={};files=[];subjects=[]
def add(p,label):
 b=p.read_bytes();h=hashlib.sha256(b).hexdigest();objects[h]=b;files.append({'path':str(p),'label':label,'SHA256':h,'bytes':len(b)})
for directory,kind in roots:
 root=Path(directory);e=root/'evidence.json';assert e.exists(),root
 data=json.loads(e.read_text());cases=[x for x in data.get('cases',[]) if 'backend' in x]
 if kind!='history':assert 'FAIL' not in data['status'],(root,data['status'])
 subjects.append({'root':directory,'kind':kind,'status':data['status'],'receiptSHA256':hashlib.sha256(e.read_bytes()).hexdigest(),'closure':data.get('candidateClosureSHA256'),'cases':cases})
 for p in sorted(root.rglob('*')):
  if p.is_file() and (p.suffix in ['.json','.jsonl','.bend','.txt','.stdout','.stderr'] or p.name=='executed-recipe.py'):add(p,kind)
for directory in ['/tmp/bendvy-slot-host-v1','/tmp/bendvy-slot-host-motion-id-buffer-direct-v1','/tmp/bendvy-slot-host-motion-id-buffer-v12','/tmp/bendvy-slot-host-motion-id-buffer-v10']:
 for p in sorted(Path(directory).rglob('*')):
  if p.is_file() and p.suffix in ['.bend','.json']:add(p,'frozen-source')
for p in Path('/workspace/formal-proofs/bendvy/experiments/s-prep/source-packed-paired-finish-controls/templates').glob('cache-tx-*-controls.bend.gz'):add(p,'original-template')
with tarfile.open(here/'evidence.tar.gz','w:gz') as tar:
 for h,b in sorted(objects.items()):
  t=tarfile.TarInfo('objects/'+h);t.size=len(b);t.mtime=0;tar.addfile(t,io.BytesIO(b))
index={'scope':'Finite source-specific diagnostics; no full22, proof, API or performance acceptance','archiveSHA256':hashlib.sha256((here/'evidence.tar.gz').read_bytes()).hexdigest(),'subjects':subjects,'files':files,'counts':{k:sum(x['kind']==k for x in subjects) for k in ['positive','mutant','physical','history']}}
(here/'evidence-index.json').write_text(json.dumps(index,separators=(',',':'))+'\n')
print(index['counts'],len(files),len(objects),(here/'evidence.tar.gz').stat().st_size)
