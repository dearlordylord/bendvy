#!/usr/bin/env python3
from pathlib import Path
import json,hashlib,tarfile,argparse
H=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--input',type=Path,required=True);a=p.parse_args()
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
e=json.loads((a.input/'evidence.json').read_text());assert e['status']=='FRESH_ACTUAL_SLOT_E11_TEN_MUTANTS_BOTH_BACKENDS_PASS' and len(e['cases'])==10
entries={'evidence.json':a.input/'evidence.json'}
for c in e['cases']:
 d=a.input/c['name'];assert c['status']=='DETECTED_COMPILING_RUNTIME_COUNTEREXAMPLE'
 for n,h in c['generatedPins'].items():assert sha(d/n)==h
 for n,h in {**c['mutantSourcePins'],**c['fixturePins']}.items():
  f=d/'core'/Path(n).name;assert sha(f)==h;entries[c['name']+'/core/'+f.name]=f
 for f in d.glob('*.txt'):entries[c['name']+'/'+f.name]=f
out=H/'e11-mutants.tar.gz'
with tarfile.open(out,'w:gz') as t:
 for n,f in sorted(entries.items()):t.add(f,arcname=n,recursive=False)
pins={n:sha(f) for n,f in entries.items()}
with tarfile.open(out,'r:gz') as t:assert {m.name:hashlib.sha256(t.extractfile(m).read()).hexdigest() for m in t.getmembers()}==pins
(H/'e11-mutants-manifest.json').write_text(json.dumps({'scope':e['scope'],'status':e['status'],'sourcePins':e['sourcePins'],'archiveSHA256':sha(out),'decodedSHA256Verified':True,'generatedArtifacts':'Locally verified against evidence generatedPins; source and complete command/output receipts archived, binaries not duplicated','members':pins},indent=2)+'\n')
print(len(pins),out.stat().st_size)
