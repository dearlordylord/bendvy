#!/usr/bin/env python3
from pathlib import Path
import argparse,json,hashlib,tarfile
H=Path(__file__).resolve().parent;p=argparse.ArgumentParser();p.add_argument('--motion',type=Path,required=True);p.add_argument('--health',type=Path,required=True);a=p.parse_args();sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();entries={}
def add(p,n):assert p.is_file();entries[n]=p
for schema,d in [('motion',a.motion),('health',a.health)]:
 e=json.loads((d/'evidence.json').read_text());assert e['status']=='FRESH_ORIGINAL_SLOT_HOST_SCHEMA_BOTH_CAPTURES_BOTH_BACKENDS_PASS';ad=json.loads((d/'adapted/adaptation.json').read_text());core=d/'adapted/core';assert all(sha(core/Path(n).name)==h for n,h in e['sourcePins'].items());assert all(sha(core/n)==h for n,h in ad['fixturePins'].items())
 for n,h in e['generatedPins'].items():assert sha(d/n)==h
 if schema=='motion':
  for n in e['sourcePins']:add(core/Path(n).name,'source/'+Path(n).name)
 for n in ad['fixturePins']:add(core/n,schema+'/fixtures/'+n)
 for file in d.glob('*'):
  if file.is_file() and file.suffix in ['.json','.txt','.js','.c']:add(file,schema+'/'+file.name)
 add(d/'adapted/adaptation.json',schema+'/adaptation.json')
add(H/'reference-receipt.json','reference/receipt.json');add(H/'original-reference.json.gz','reference/original.json.gz');out=H/'original-host.tar.gz'
with tarfile.open(out,'w:gz') as t:
 for n,p in sorted(entries.items()):t.add(p,arcname=n,recursive=False)
pins={n:sha(p) for n,p in entries.items()}
with tarfile.open(out,'r:gz') as t:assert {m.name:hashlib.sha256(t.extractfile(m).read()).hexdigest() for m in t.getmembers()}==pins
(H/'original-host-manifest.json').write_text(json.dumps({'scope':'Fresh original Slot Host4lanes bothbackends; mutants separate','archiveSHA256':sha(out),'decodedSHA256Verified':True,'members':pins},indent=2)+'\n');print(len(pins),out.stat().st_size)
