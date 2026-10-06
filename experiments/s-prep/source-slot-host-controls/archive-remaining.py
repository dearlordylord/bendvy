#!/usr/bin/env python3
from pathlib import Path
import argparse,json,hashlib,tarfile
H=Path(__file__).resolve().parent;p=argparse.ArgumentParser();p.add_argument('--e11-adapted',type=Path,required=True);p.add_argument('--e11',type=Path,required=True);p.add_argument('--access',type=Path,required=True);a=p.parse_args();sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();e=json.loads((a.e11/'evidence.json').read_text());x=json.loads((a.access/'evidence.json').read_text());assert e['status']=='FRESH_ORIGINAL_SLOT_E11_20_CASES_MUTANTS_PENDING' and len(e['actual'])==20 and len(e['publicReference'])==10;assert x['status']=='FRESH_NINE_SLOT_HOST_SCOPED_ACCESS_BOUNDARIES_PASS' and len(x['cases'])==9 and all(c['status']=='INTENDED_CHECKER_BOUNDARY_PASS' for c in x['cases']);assert e['sourcePins']==x['sourcePins'];entries={}
def add(p,n):assert p.is_file();entries[n]=p
ad=json.loads((a.e11_adapted/'adaptation.json').read_text());assert ad['sourcePins']==e['sourcePins'];add(a.e11_adapted/'adaptation.json','e11/adaptation.json')
for n,h in ad['fixturePins'].items():assert sha(a.e11_adapted/'core'/n)==h;add(a.e11_adapted/'core'/n,'e11/fixtures/'+n)
if (a.e11_adapted/'source-reachability.json').exists():add(a.e11_adapted/'source-reachability.json','e11/source-reachability.json')
for n,h in e['generatedPins'].items():assert sha(a.e11/n)==h
for f in a.e11.glob('*'):
 if f.is_file() and f.suffix in ['.json','.txt','.js','.c']:add(f,'e11/'+f.name)
add(a.access/'evidence.json','access/evidence.json')
for case in x['cases']:
 d=a.access/case['label'];add(d/'checker.txt','access/'+case['label']+'/checker.txt');add(d/'core/integrated-access-positive.bend','access/'+case['label']+'/entry.bend');assert sha(d/'core/integrated-access-positive.bend')==case['entrySHA256'];assert sha(d/'core'/case['target'])==case['targetSHA256'];add(d/'core'/case['target'],'access/'+case['label']+'/target.bend')
# Preserve actual prior failures, rather than converting them into passing controls.
for name,d in [('e11-pure-barrier-v1',Path('/tmp/bendvy-slot-host-retention-original-v1')),('access-parser-v1',Path('/tmp/bendvy-slot-host-access-v1')),('access-qualified-guard-v2',Path('/tmp/bendvy-slot-host-access-v2'))]:
 add(d/'evidence.json','history/'+name+'/evidence.json')
 for f in d.rglob('*.txt'):add(f,'history/'+name+'/'+str(f.relative_to(d)))
 if name.startswith('access'):
  for f in d.glob('*/core/integrated-access-positive.bend'):add(f,'history/'+name+'/'+str(f.relative_to(d)))
add(Path('/tmp/bendvy-slot-host-retention-adapted-v1/adaptation.json'),'history/e11-pure-barrier-v1/adaptation.json')
add(Path('/tmp/bendvy-slot-host-retention-adapted-v1/core/host-retention-controls-slice-host-batch-invoker.bend'),'history/e11-pure-barrier-v1/host-batch.bend')
out=H/'e11-original-access.tar.gz'
with tarfile.open(out,'w:gz') as t:
 for n,p in sorted(entries.items()):t.add(p,arcname=n,recursive=False)
pins={n:sha(p) for n,p in entries.items()}
with tarfile.open(out,'r:gz') as t:assert {m.name:hashlib.sha256(t.extractfile(m).read()).hexdigest() for m in t.getmembers()}==pins
(H/'e11-original-access-manifest.json').write_text(json.dumps({'scope':'Fresh E11original20cases and9scopedaccesssubjects; mutations separate; notfull22','archiveSHA256':sha(out),'decodedSHA256Verified':True,'members':pins},indent=2)+'\n');print(len(pins),out.stat().st_size)
