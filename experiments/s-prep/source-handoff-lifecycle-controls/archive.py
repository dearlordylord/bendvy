#!/usr/bin/env python3
"""Compact immutable diagnostic receipts; no execution or acceptance inference."""
import hashlib,json,tarfile,io
from pathlib import Path
here=Path(__file__).resolve().parent
roots=[('/tmp/bendvy-handoff-independent-one-v7','positive')]
for n in ['one-raw','two','two-raw','none','none-raw','alias','alias-raw','missing','missing-raw','absent','present','optional']:roots.append(('/tmp/bendvy-handoff-independent-matrix-v7/'+n,'positive'))
roots.append(('/tmp/bendvy-handoff-independent-retained-one-v7-r2','positive'))
for n in ['retained-one-raw','retained-two','retained-two-raw']:roots.append(('/tmp/bendvy-handoff-independent-retained-matrix-v7/'+n,'positive'))
for n in ['recovery','recovery-raw','lost-owner','order','pair-undo']:roots.append(('/tmp/bendvy-handoff-independent-continuation-v7/'+n,'mutant' if n in ['lost-owner','order','pair-undo'] else 'positive'))
roots += [('/tmp/bendvy-handoff-independent-pending-v7-r2','mutant'),('/tmp/bendvy-handoff-independent-recovery-owner-v7','mutant')]
for n in ['one','two','recovery']:roots.append(('/tmp/bendvy-handoff-independent-physical-initial-'+n+'-v7','physical'))
for n in ['one-v1','alias-divergence-v2','ragged-divergence-v2','one-v5','one-v6','recovery-v6-r2','physical-one-v7']:roots.append(('/tmp/bendvy-handoff-independent-'+n,'history'))
roots += [('/tmp/bendvy-handoff-independent-matrix-v7/retained','history'),('/tmp/bendvy-handoff-independent-continuation-v7/pending','history')]
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
for directory in ['/tmp/bendvy-slot-host-v1','/tmp/bendvy-slot-host-handoff-v7']:
 for p in sorted(Path(directory).rglob('*')):
  if p.is_file() and p.suffix in ['.bend','.json']:add(p,'frozen-source')
for p in Path('/workspace/formal-proofs/bendvy/experiments/s-prep/source-packed-paired-finish-controls/templates').glob('cache-tx-*-controls.bend.gz'):add(p,'original-template')
with tarfile.open(here/'evidence.tar.gz','w:gz') as tar:
 for h,b in sorted(objects.items()):
  t=tarfile.TarInfo('objects/'+h);t.size=len(b);t.mtime=0;tar.addfile(t,io.BytesIO(b))
index={'scope':'Finite source-specific diagnostics; no full22, proof, API or performance acceptance','archiveSHA256':hashlib.sha256((here/'evidence.tar.gz').read_bytes()).hexdigest(),'subjects':subjects,'files':files,'counts':{k:sum(x['kind']==k for x in subjects) for k in ['positive','mutant','physical','history']}}
(here/'evidence-index.json').write_text(json.dumps(index,indent=2)+'\n')
print(index['counts'],len(files),len(objects),(here/'evidence.tar.gz').stat().st_size)
