#!/usr/bin/env python3
from pathlib import Path
import argparse,json,hashlib,tarfile,re
H=Path(__file__).resolve().parent;p=argparse.ArgumentParser();p.add_argument('--static',type=Path,required=True);p.add_argument('--world',type=Path,required=True);a=p.parse_args();sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();x=json.loads((a.static/'evidence.json').read_text());w=json.loads((a.world/'evidence.json').read_text());assert x['status']=='FRESH_RETAINED_PUBLIC_STATIC_EIGHT_CONTRACTS_PASS' and w['status']=='FRESH_ACTUAL_SLOT_FACTORY_WORLD16_FULL_FIELDS_PASS';assert x['sourcePins']==w['sourcePins'];entries={'static/evidence.json':a.static/'evidence.json','static/route-provider-controls.py':a.static/'route-provider-controls.py','world/evidence.json':a.world/'evidence.json'};base=Path('/tmp/bendvy-slot-host-v1');bindings=[]
for n,h in x['sourcePins'].items():assert sha(base/n)==h;entries['source29/'+Path(n).name]=base/n
for n in ['overlay.json','cache-specialization.json']:entries['source29/'+n]=base/n
for c in x['boundary']['cases']:
 d=a.static/c['name'];f=d/'subject.bend';assert sha(f)==c['sourceSHA256'];imports=re.findall(r'^import (\S+)',f.read_text(),re.M);targets={str(Path(n)):sha(Path(n)) for n in imports if n!='Base'};assert all(Path(n).parent==base/'experiments/s-integrate' for n in targets);bindings.append({'case':c['name'],'entrySHA256':sha(f),'imports':targets,'checkerOutputSHA256':sha(d/'checker.txt'),'execution':'Original run checked its temporary rebound subject; archived subject bytes identical. Temporary pathname was not separately recorded; no synthetic command receipt.'});entries['static/'+c['name']+'/subject.bend']=f;entries['static/'+c['name']+'/checker.txt']=d/'checker.txt'
for c in w['cases']:
 label=c['observer']+'-'+c['client']+'-'+c['schema'];d=a.world/label;assert c['status']=='BOTH_BACKENDS_EIGHT_FULL_RECORDS_PASS'
 for n,h in w['sourcePins'].items():assert sha(d/'core'/Path(n).name)==h
 for n,h in c['fixturePins'].items():assert sha(d/'core'/n)==h;entries['world/'+label+'/core/'+n]=d/'core'/n
 for n,h in c['generatedPins'].items():assert sha(d/n)==h
 for f in d.glob('*.txt'):entries['world/'+label+'/'+f.name]=f
 for n in ['subject.js','subject.c']:entries['world/'+label+'/'+n]=d/n
out=H/'static-provider-world.tar.gz'
with tarfile.open(out,'w:gz') as t:
 for n,f in sorted(entries.items()):t.add(f,arcname=n,recursive=False)
pins={n:sha(f) for n,f in entries.items()}
with tarfile.open(out,'r:gz') as t:assert {m.name:hashlib.sha256(t.extractfile(m).read()).hexdigest() for m in t.getmembers()}==pins
(H/'static-provider-world-manifest.json').write_text(json.dumps({'scope':'Unchanged retained-public static8 and fresh actualSlot factory world16, finite separate routes','archiveSHA256':sha(out),'decodedSHA256Verified':True,'staticEntryBindings':bindings,'members':pins},indent=2)+'\n');print(len(pins),out.stat().st_size)
