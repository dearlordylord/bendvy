#!/usr/bin/env python3
from pathlib import Path
import argparse,json,hashlib,tarfile
H=Path(__file__).resolve().parent;p=argparse.ArgumentParser();p.add_argument('--initial',type=Path,required=True);p.add_argument('--repair',type=Path,required=True);a=p.parse_args();sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();old=json.loads((a.initial/'evidence.json').read_text());new=json.loads((a.repair/'evidence.json').read_text());assert old['sourcePins']==new['sourcePins'] and old['originalReceiptPins']==new['originalReceiptPins'];selected=[]
for case in old['cases']:
 if case['label']=='suppressed-setter':assert case['status']=='FAIL_OR_LIMIT';case=new['cases'][0];assert case['label']=='suppressed-setter';root=a.repair
 else:root=a.initial
 assert case['status']=='DETECTED_COMPILING_RUNTIME_COUNTEREXAMPLE' and {x['backend'] for x in case['observations']}=={'js','native'};selected.append({'label':case['label'],'receipt':str(root/'evidence.json'),'receiptSHA256':sha(root/'evidence.json'),'case':case})
assert len(selected)==12 and len({x['label'] for x in selected})==12;entries={}
def add(p,n):assert p.is_file();entries[n]=p
for tag,d in [('initial',a.initial),('repair',a.repair)]:
 add(d/'evidence.json',tag+'/evidence.json')
 for case in json.loads((d/'evidence.json').read_text())['cases']:
  folder=d/case['label'];core=folder/'core'
  for f in folder.glob('*'):
   if f.is_file() and f.suffix in ['.json','.txt']:add(f,tag+'/'+case['label']+'/'+f.name)
  for n,h in case.get('generatedPins',{}).items():assert sha(folder/n)==h
  if 'mutantSourcePins' in case:
   for n,h in case['mutantSourcePins'].items():
    assert sha(core/Path(n).name)==h
    if h!=old['sourcePins'][n]:add(core/Path(n).name,tag+'/'+case['label']+'/source/'+Path(n).name)
  for n in ['host-motion-fixture.bend','host-motion-body.bend','host-health-fixture.bend','host-health-body.bend','host-fixture.bend','host-preflight.bend']:add(core/n,tag+'/'+case['label']+'/fixtures/'+n)
add(H/'mutants-v1.py','recipes/initial.py');add(H/'mutants.py','recipes/repair.py');out=H/'host12-mutants.tar.gz'
with tarfile.open(out,'w:gz') as t:
 for n,p in sorted(entries.items()):t.add(p,arcname=n,recursive=False)
pins={n:sha(p) for n,p in entries.items()}
with tarfile.open(out,'r:gz') as t:assert {m.name:hashlib.sha256(t.extractfile(m).read()).hexdigest() for m in t.getmembers()}==pins
(H/'host12-evidence.json').write_text(json.dumps({'status':'FRESH_ACTUAL_SLOT_HOST12_ORIGINALS_AND_12_MUTANTS_BOTH_BACKENDS_PASS','scope':'Finite original fourlane equality plus twelve reached compiling semantic mutants; no full22/adoption','generatedArtifactPolicy':'Mutant C/JS/native are locally SHA verified against executed receipts; portable archive retains exact generation inputs, commands, generated hashes and complete outputs; original C/JS retained separately','sourcePins':old['sourcePins'],'originalReceiptPins':old['originalReceiptPins'],'selectedMutants':selected,'retainedFailure':{'receipt':str(a.initial/'evidence.json'),'case':'suppressed-setter','classification':'Initial U32 quantity annotation rejection, not compiling runtime kill'},'initialRecipeSHA256':sha(H/'mutants-v1.py'),'repairRecipeSHA256':sha(H/'mutants.py')},indent=2)+'\n');(H/'host12-mutants-manifest.json').write_text(json.dumps({'archiveSHA256':sha(out),'decodedSHA256Verified':True,'members':pins},indent=2)+'\n');print(len(pins),out.stat().st_size)
