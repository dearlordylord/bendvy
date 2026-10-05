#!/usr/bin/env python3
"""Specialize only previously-unvisited actual control closures, exact Type map."""
import argparse,hashlib,json,re,shutil,subprocess
from pathlib import Path
KINDS={'Position':('PositionView','position'),'Vitals':('VitalsView','vitals'),'MotionLedger':('LedgerView','motion_ledger'),'HealthLedger':('LedgerView','health_ledger')}
def specialize(text):
 saved=[]
 while (match:=re.search(r'T\.(Position|Vitals|MotionLedger|HealthLedger)\{',text)):
  start=match.start();end=match.end();depth=1
  while depth:depth+=(text[end]=='{')-(text[end]=='}');end+=1
  raw=text[start:end];tag='__RAW_'+str(len(saved))+'__';saved.append('CP.'+KINDS[match[1]][1]+'_new('+raw+')');text=text[:start]+tag+text[end:]
 for kind,(view,_) in KINDS.items():text=re.sub(r'T\.'+kind+r'\b','CC.Cache<T.'+kind+',T.'+view+'>',text)
 for i,raw in enumerate(saved):text=text.replace('__RAW_'+str(i)+'__',raw)
 return text

def reachable_fixture(text,entry):
 headers=list(re.finditer(r'^(def|type) ([\w.]+)',text,re.M));blocks={};constructors={}
 for i,head in enumerate(headers):
  block=text[head.start():headers[i+1].start() if i+1<len(headers) else len(text)];name=head[2];blocks[name]=block
  if head[1]=='type':
   for constructor in re.findall(r'^  ([\w]+)\{',block,re.M):constructors[constructor]=name
 pending=[entry];seen=set()
 while pending:
  name=pending.pop()
  if name in seen:continue
  assert name in blocks,'Fixture dependency absent: '+name
  seen.add(name)
  for token in re.findall(r'(?<![\w.])([A-Za-z_][\w]*)(?![\w.])',blocks[name]):
   dependency=constructors.get(token,token)
   if dependency in blocks and dependency not in seen:pending.append(dependency)
 return text[:headers[0].start()]+''.join(blocks[head[2]] for head in headers if head[2] in seen),sorted(seen),sorted(set(blocks)-seen)

def slice_control_imports(core,entry,protected):
 modules={};pending=[(entry.resolve(),'main')];seen=set();used={}
 def module(path):
  if path in modules:return modules[path]
  text=path.read_text();headers=list(re.finditer(r'^(def|type) ([\w.]+)',text,re.M));blocks={};constructors={};aliases={alias:(path.parent/name).resolve() for name,alias in re.findall(r'^import (\./\S+\.bend) as (\w+)',text,re.M)}
  for i,head in enumerate(headers):
   block=text[head.start():headers[i+1].start() if i+1<len(headers) else len(text)];blocks[head[2]]=block
   if head[1]=='type':
    for ctor in re.findall(r'^  ([\w]+)\{',block,re.M):constructors[ctor]=head[2]
  modules[path]=(text,headers,blocks,constructors,aliases);return modules[path]
 while pending:
  path,name=pending.pop();assert path.is_relative_to(core.resolve())
  if str(path.relative_to(core.parent.parent)) in protected:continue
  text,headers,blocks,constructors,aliases=module(path);name=constructors.get(name,name)
  if (path,name) in seen:continue
  assert name in blocks,'Unknown control dependency '+str(path)+':'+name
  seen.add((path,name));used.setdefault(path,set()).add(name);block=blocks[name]
  for token in re.findall(r'(?<![\w.])([A-Za-z_][\w]*)(?![\w.])',block):
   target=constructors.get(token,token)
   if target in blocks:pending.append((path,target))
  for alias,target in aliases.items():
   for exported in re.findall(r'(?<![\w.])'+re.escape(alias)+r'\.([\w.]+)',block):pending.append((target,exported))
 changes={};prefix=entry.stem+'-slice-';targets={path:(path if path==entry.resolve() else core/(prefix+path.name)) for path in used}
 for path,names in used.items():
  text,headers,blocks,_,aliases=module(path);header=text[:headers[0].start()]
  for alias,target in aliases.items():
   relative='./'+target.name
   if target in targets:header=header.replace('import '+relative+' as '+alias,'import ./'+targets[target].name+' as '+alias)
   elif str(target.relative_to(core.parent.parent)) not in protected:header=re.sub(r'^import '+re.escape(relative)+' as '+re.escape(alias)+r'\n','',header,flags=re.M)
  sliced=header+''.join(blocks[head[2]] for head in headers if head[2] in names);destination=targets[path];destination.write_text(sliced)
  changes[str(destination.relative_to(core.parent.parent))]={'originalSource':str(path.relative_to(core.parent.parent)),'before':hashlib.sha256(text.encode()).hexdigest(),'after':hashlib.sha256(sliced.encode()).hexdigest(),'retainedDefinitions':sorted(names),'removedUnreachableControlDefinitions':sorted(set(blocks)-names)}
 return changes

def main():
 p=argparse.ArgumentParser();p.add_argument('--overlay',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--raw-snapshots',action='store_true');p.add_argument('--slice-host-fixtures',action='store_true');a=p.parse_args();h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
 manifest=json.loads((a.overlay/'overlay.json').read_text());assert all(h(a.overlay/n)==v for n,v in manifest['sources'].items());shutil.copytree(a.overlay,a.output);core=a.output/'experiments/s-integrate';runtime=set();
 def runtime_visit(path):
  relative=str(path.relative_to(a.output))
  if relative in runtime:return
  runtime.add(relative)
  for name in re.findall(r'^import (\./\S+\.bend)',path.read_text(),re.M):runtime_visit((path.parent/name).resolve())
 runtime_visit(core/'measurement-bend.bend')
 already=set(manifest.get('cacheSpecialization',{}).get('specializedClosure',{}))|runtime;seen=set();changes={}
 root=Path(__file__).resolve().parents[3]
 for original in sorted((root/'experiments/s-integrate').glob('*.bend')):
  destination=core/original.name
  if destination.exists():continue
  candidate=root/'experiments/s-perf/candidate'/original.name;source=candidate if candidate.exists() else original
  pinned=subprocess.check_output(['git','-C',str(root),'show','HEAD:'+str(source.relative_to(root))],timeout=5);assert source.read_bytes()==pinned,'Untracked protected fixture source change'
  destination.write_bytes(pinned)
  manifest['sources'][str(destination.relative_to(a.output))]=h(destination)
 def visit(path):
  path=path.resolve();assert path.is_relative_to(core.resolve()) and not path.is_symlink()
  if path in seen:return
  seen.add(path)
  for name in re.findall(r'^import (\./\S+\.bend)',path.read_text(),re.M):visit(path.parent/name)
 for entry in ['host-motion-fixture.bend','host-health-fixture.bend','integrated-access-positive.bend','host-retention-controls.bend']:visit(core/entry)
 for path in sorted(seen):
  relative=str(path.relative_to(a.output));text=path.read_text()
  if relative in already or path.name in ['types.bend','payload.bend','uncached-payload.bend','cache.bend','cached-payload.bend','raw-boundaries.bend','held.bend','held-adapter.bend']:continue
  changed=specialize(text)
  for alias in re.findall(r'^import ./payload\.bend as (\w+)',text,re.M):
   for _,(_,stem) in KINDS.items():
    for op in ['get','swap']:changed=changed.replace(alias+'.'+stem+'_'+op,'CP.'+stem+'_'+op)
  changed=changed.replace('import Base\n','import Base\nimport ./cache.bend as CC\nimport ./cached-payload.bend as CP\n',1)
  if changed!=text:path.write_text(changed);changes[relative]={'before':hashlib.sha256(text.encode()).hexdigest(),'after':h(path)}
 if a.raw_snapshots:
  host=core/'host.bend';text=host.read_text();observer=Path(__file__).resolve().parent/'original-raw-observer.bend';original=Path(__file__).resolve().parents[3]/'experiments/s-integrate/payload.bend';assert h(core/'payload.bend')==h(original),'Original raw observer payload drift';native_optimized=h(core/'uncached-payload.bend')!=h(original)
  if native_optimized:(core/'original-raw-observer.bend').write_bytes(observer.read_bytes());text=text.replace('import Base\n','import Base\nimport ./original-raw-observer.bend as ORG\n',1)
  for schema,main,ledger in [('motion','position','motion_ledger'),('health','vitals','health_ledger')]:
   match=re.search(r'^def '+schema+r'_snapshot\(',text,re.M);end=text.find('\ndef ',match.start()+1);end=len(text) if end<0 else end;before=text[match.start():end];after=before.replace('CP.'+main+'_get',('ORG.'+main+'_get') if native_optimized else ('CP.'+main+'_uncached')).replace('CP.'+ledger+'_get',('ORG.'+ledger+'_get') if native_optimized else ('CP.'+ledger+'_uncached'));assert before!=after;text=text[:match.start()]+after+text[end:]
  relative=str(host.relative_to(a.output));changes[relative]={'before':h(host),'after':hashlib.sha256(text.encode()).hexdigest(),'scope':'Raw-owner snapshot observation only; actual callback providers unchanged; getters return affine owner'};host.write_text(text)
 if a.slice_host_fixtures:
  original=core/'host-fixture.bend';text=original.read_text()
  for schema in ['motion','health']:
   sliced,retained,removed=reachable_fixture(text,'main_'+schema);body=core/('host-'+schema+'-body.bend');body.write_text(sliced);entry=core/('host-'+schema+'-fixture.bend');entry.write_text(entry.read_text().replace('./host-fixture.bend','./host-'+schema+'-body.bend'));manifest['sources'][str(body.relative_to(a.output))]=h(body);changes.update(slice_control_imports(core,entry,runtime));changes[str(body.relative_to(a.output))]={'originalSHA256':h(original),'derivedSHA256':h(body),'entry':'main_'+schema,'retainedDefinitions':retained,'removedUnreachableFixtureDefinitions':removed,'scope':'Explicit conservative local reachable definition slice; imported runtime entire closure unchanged; all frames/phases/captures retained'}
 manifest['sources']={str(path.relative_to(a.output)):h(path) for path in a.output.rglob('*.bend')};manifest['controlSpecialization']={'scope':'Previously-unvisited actual Host/access fixture closure; exact full constructor wrap and raw->cached Type/provider map','changes':changes};(a.output/'overlay.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps(manifest['controlSpecialization'],indent=2))
if __name__=='__main__':main()
