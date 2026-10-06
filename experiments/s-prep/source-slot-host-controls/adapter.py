#!/usr/bin/env python3
"""Task-local original Host fixture type/provider transport; no shared gate edits."""
from pathlib import Path
import argparse,hashlib,json,re,shutil,importlib.util,sys
H=Path(__file__).resolve().parent;ROOT=Path('/workspace/formal-proofs/bendvy');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
p=argparse.ArgumentParser();p.add_argument('--source',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--host-prefix',required=True);p.add_argument('--schema',choices=['motion','health'],required=True);a=p.parse_args();assert re.fullmatch('[A-Za-z_][A-Za-z0-9_]*',a.host_prefix)
m=json.loads((a.source/'overlay.json').read_text());pins=m['sources'];assert len(pins)==29;assert all(sha(a.source/n)==h for n,h in pins.items());cache=json.loads((a.source/'cache-specialization.json').read_text());digest=hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest();assert cache==m['cacheSpecialization'] and cache['runtimeClosure']==pins and cache['specializedClosure']==pins and cache['runtimeClosureSHA256']==digest and cache['specializedClosureSHA256']==digest
# Exact original fixture bytes are independently pinned before changing only its typed transport.
base=ROOT/'experiments/s-integrate';gate=ROOT/'experiments/s-prep/fivehour-connected-gates';sys.path.insert(0,str(gate));spec=importlib.util.spec_from_file_location('M',gate/'materialize-controls.py');M=importlib.util.module_from_spec(spec);spec.loader.exec_module(M)
a.output.mkdir(exist_ok=False);core=a.output/'core';shutil.copytree(a.source/'experiments/s-integrate',core)
originals={};changes={};host=(core/'host.bend').read_text();names=set(re.findall(r'^def ([\w.]+)\(',host,re.M));mapping={}
for lane,cap in [('motion','Motion'),('health','Health')]:
 for name in names:
  if name.startswith(lane+'_') and a.host_prefix+name in names:mapping[name]=a.host_prefix+name
 assert a.host_prefix+cap+'Host' in names,'Candidate private Host alias absent'
 mapping[cap+'Host']=a.host_prefix+cap+'Host'
 assert lane+'_dispatch' in mapping,'Candidate private dispatch absent'
def adapt(text):
 saved=[]
 kinds={'Position':('prototype_slot_position_new','CP.PrototypeMotionMainSlot'),'Vitals':('prototype_slot_vitals_new','CP.PrototypeHealthMainSlot'),'MotionLedger':('motion_ledger_new','CC.Cache<T.MotionLedger,T.LedgerView>'),'HealthLedger':('health_ledger_new','CC.Cache<T.HealthLedger,T.LedgerView>')}
 while (match:=re.search(r'T\.(Position|Vitals|MotionLedger|HealthLedger)\{',text)):
  start=match.start();end=match.end();depth=1
  while depth:assert end<len(text);depth+=(text[end]=='{')-(text[end]=='}');end+=1
  raw=text[start:end];tag='__CONTROL_RAW_'+str(len(saved))+'__';saved.append('CP.'+kinds[match[1]][0]+'('+raw+')');text=text[:start]+tag+text[end:]
 for kind,(_,typ) in kinds.items():text=re.sub(r'T\.'+kind+r'\b',typ,text)
 for i,raw in enumerate(saved):text=text.replace('__CONTROL_RAW_'+str(i)+'__',raw)
 for old,new in mapping.items():text=re.sub(r'\bH\.'+re.escape(old)+r'\b','H.'+new,text)
 assert 'import ./cache.bend as CC' not in text and 'import ./cached-payload.bend as CP' not in text
 return text.replace('import Base\n','import Base\nimport ./cache.bend as CC\nimport ./cached-payload.bend as CP\n',1)
for n in ['host-fixture.bend','host-preflight.bend']:
 old=(base/n).read_text();assert (base/n).read_bytes()==__import__('subprocess').check_output(['git','-C',str(ROOT),'show','8250177:experiments/s-integrate/'+n]);new=adapt(old);originals[n]=sha(base/n);(core/n).write_text(new);changes[n]={'originalSHA256':originals[n],'adaptedSHA256':sha(core/n)}
text=(core/'host-fixture.bend').read_text();sliced,retained,removed=M.reachable_fixture(text,'main_'+a.schema);fixture=core/('host-'+a.schema+'-body.bend');fixture.write_text(sliced);entry=core/('host-'+a.schema+'-fixture.bend');entry.write_text('import Base\nimport ./'+fixture.name+' as F\ndef main() -> IO(Unit):\n  F.main_'+a.schema+'()\n')
assert all(sha(core/Path(n).name)==h for n,h in pins.items()),'Candidate bytes changed'
r={'scope':'Original Host fixture transport only; no semantic pass','sourceClosureSHA256':digest,'sourcePins':pins,'originalFixturePins':originals,'changes':changes,'hostMapping':mapping,'retainedOriginalDefinitions':retained,'removedUnreachableOtherSchemaDefinitions':removed,'fixturePins':{p.name:sha(p) for p in core.glob('*.bend') if p.name not in {Path(n).name for n in pins}},'entry':str(entry),'schema':a.schema,'adapterSHA256':sha(Path(__file__)),'slicerSHA256':sha(gate/'materialize-controls.py')};(a.output/'adaptation.json').write_text(json.dumps(r,indent=2)+'\n')
