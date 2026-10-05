#!/usr/bin/env python3
"""Isolated, source-pinned cached Type specialization; no protected source edits."""
import pathlib,subprocess,hashlib,json,re,sys,importlib.util
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2]
KINDS={'Position':('PositionView','position'),'Vitals':('VitalsView','vitals'),'MotionLedger':('LedgerView','motion_ledger'),'HealthLedger':('LedgerView','health_ledger')}
def digest(b):return hashlib.sha256(b).hexdigest()
def specialize(text):
 # Constructors are raw inputs to complete original-getter initialization.
 saved=[]
 pattern=r'T\.(Position|Vitals|MotionLedger|HealthLedger)\{'
 while (m:=re.search(pattern,text)):
  start=m.start();end=m.end();depth=1
  while depth:
   depth+=(text[end]=='{')-(text[end]=='}');end+=1
  raw=text[start:end];tag='__RAWCONSTRUCTOR_'+str(len(saved))+'__';saved.append('CP.'+KINDS[m[1]][1]+'_new('+raw+')');text=text[:start]+tag+text[end:]
 for kind,(view,_) in KINDS.items():text=re.sub(r'T\.'+kind+r'\b','CC.Cache<T.'+kind+',T.'+view+'>',text)
 for i,raw in enumerate(saved):text=text.replace('__RAWCONSTRUCTOR_'+str(i)+'__',raw)
 return text

def materialize(destination):
 destination=pathlib.Path(destination);spec=importlib.util.spec_from_file_location('overlay',ROOT/'experiments/s-perf/overlay.py');overlay=importlib.util.module_from_spec(spec);spec.loader.exec_module(overlay);manifest=overlay.materialize(destination);pkg=destination/'experiments/s-integrate'
 # The protected workload and raw payload remain byte-for-byte pinned inputs.
 for name,pin,path in [('measurement-bend.bend','56b72f6',ROOT/'experiments/s-perf/candidate/measurement-bend.bend'),('payload.bend','56b72f6',ROOT/'experiments/s-integrate/payload.bend')]:
  frozen=subprocess.check_output(['git','-C',str(ROOT),'show',pin+':'+path.relative_to(ROOT).as_posix()]);assert path.read_bytes()==frozen;assert (pkg/name).read_bytes()==frozen
 before={};after={};seen=set()
 def visit(path):
  path=path.resolve()
  if path in seen:return
  seen.add(path);text=path.read_text()
  for imported in re.findall(r'^import\s+(\S+)',text,re.M):
   if imported.startswith('.'):visit(path.parent/imported)
 visit(pkg/'measurement-bend.bend')
 # Payload/types define the actual raw owners and must never be specialized.
 for path in sorted(seen):
  if path.name in ['types.bend','payload.bend']:continue
  text=path.read_text();before[str(path.relative_to(destination))]=digest(text.encode());changed=specialize(text)
  
  for _,(_,stem) in KINDS.items():
   for operation in ['get','swap']:
    for alias in re.findall(r'^import ./payload\.bend as (\w+)',text,re.M):changed=changed.replace(alias+'.'+stem+'_'+operation,'CP.'+stem+'_'+operation)
  changed=changed.replace('import Base\n','import Base\nimport ./cache.bend as CC\nimport ./cached-payload.bend as CP\n',1)
  path.write_text(changed);after[str(path.relative_to(destination))]=digest(changed.encode())
 source=ROOT/'experiments/s-prep/persistent-cache-world'
 (pkg/'cache.bend').write_bytes((source/'cache.bend').read_bytes());(pkg/'uncached-payload.bend').write_bytes((pkg/'payload.bend').read_bytes())
 cp=(source/'persistent-payload.bend').read_text()
 # Aux columns stay raw, observed through the actual original getter.
 cp+='\ndef velocity_get(owner:T.Velocity) -> T.Velocity & T.VelocityView:\n  P.velocity_get(owner)\ndef armor_get(owner:T.Armor) -> T.Armor & T.ArmorView:\n  P.armor_get(owner)\n'
 (pkg/'cached-payload.bend').write_text(cp)
 # Protected callbacks have no concrete owner occurrence, so specialization must preserve bytes.
 original=(ROOT/'experiments/s-perf/candidate/measurement-bend.bend').read_text();derived=(pkg/'measurement-bend.bend').read_text();pins={}
 for name in ['motion_body_ledger','motion_body_read','motion_body','health_body_ledger','health_body_read','health_body']:
  def extract(s):
   m=re.search(r'^def '+name+r'\(',s,re.M);end=min(x for x in [s.find('\ndef ',m.start()+1),s.find('\ntype ',m.start()+1),len(s)] if x>=0);return s[m.start():end].rstrip()+'\n'
  a=extract(original);assert a==extract(derived);pins[name]=digest(a.encode())
 receipt={'sourceCommit':subprocess.check_output(['git','-C',str(ROOT),'rev-parse','HEAD'],text=True).strip(),'recipeSHA256':digest(pathlib.Path(__file__).read_bytes()),'originalClosure':before,'specializedClosure':after,'callbackPins':pins,'cacheSourceSHA256':digest((pkg/'cache.bend').read_bytes()),'cachedPayloadSHA256':digest(cp.encode()),'rawPayloadSHA256':digest((pkg/'payload.bend').read_bytes()),'scope':'private wrapped Type World; original generic dispatcher/transaction/storage/commands; trusted original-getter initialization'}
 manifest['sources']={str(p.relative_to(destination)):digest(p.read_bytes()) for p in destination.rglob('*.bend')};manifest['cacheSpecialization']=receipt
 (destination/'overlay.json').write_text(json.dumps(manifest,indent=2)+'\n')
 (destination/'cache-specialization.json').write_text(json.dumps(receipt,indent=2)+'\n');return pkg
if __name__=='__main__':print(materialize(sys.argv[1]))
