#!/usr/bin/env python3
"""Immutable diagnostic subject/import map; incomplete cohorts cannot be accepted."""
import argparse,pathlib,json,hashlib,re
p=argparse.ArgumentParser();p.add_argument('--source',type=pathlib.Path,required=True);p.add_argument('--config',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();m=json.loads((a.source/'overlay.json').read_text());base=m['sources'];assert len(base)==29 and all(sha(a.source/n)==h for n,h in base.items());cfg=json.loads(a.config.read_text());rows=[]
def commands(x):
 if isinstance(x,dict):
  for key in ['command','argv']:
   v=x.get(key)
   if isinstance(v,list) and 'bend' in v and '--check-only' in v:
    for s in v:
     if isinstance(s,str) and s.endswith('.bend'):yield pathlib.Path(s)
  for v in x.values():yield from commands(v)
 elif isinstance(x,list):
  for v in x:yield from commands(v)
def imports(entry,root):
 seen={};pending=[entry.resolve()]
 while pending:
  f=pending.pop();assert (f.is_relative_to(root.resolve()) or str(f) in {str((a.source/n).resolve()) for n in base}) and f.is_file() and not f.is_symlink(),('unconfined/missing source',f)
  if str(f) in seen:continue
  seen[str(f)]=sha(f)
  for imp in re.findall(r'^import (\S+)',f.read_text(),re.M):
   if imp=='Base':continue
   assert imp.endswith('.bend') and (imp.startswith(('./','../')) or str(pathlib.Path(imp).resolve()) in {str((a.source/n).resolve()) for n in base}),('unsupported import',f,imp);pending.append((f.parent/imp).resolve())
 return seen
for c in cfg['cohorts']:
 rp=pathlib.Path(c['receipt']);x=json.loads(rp.read_text());assert x.get('status')==c['expectedStatus'],c['name'];entries=set(commands(x));entries.update(map(pathlib.Path,c.get('extraEntries',[])));assert entries,('no consumed checker subject',c['name']);subjects=[]
 for entry in sorted(entries):
  if str(entry) in c.get('entryPins',{}):assert sha(entry)==c['entryPins'][str(entry)],('fixture receipt mismatch',entry)
  root=entry.parent if entry.parent.name=='core' else pathlib.Path(c.get('subjectRoot',entry.parent.parent));sourceMap=imports(entry,root);core=pathlib.Path(c.get('runtimeRoot',entry.parent));runtime={n:sha(core/pathlib.Path(n).name) for n in base};delta=[n for n in base if runtime[n]!=base[n]];allowed=c.get('permittedRuntimeModules',[])
  if 'suppressed' in str(entry) and c['name']=='tx-baseline':allowed=['held-adapter.bend']
  assert all(pathlib.Path(n).name in allowed for n in delta),('conflicting runtime',c['name'],entry,delta)
  for n in base:sourceMap[str((core/pathlib.Path(n).name).resolve())]=runtime[n]
  for token in c.get('requiredControlTokens',[]):
   controlText='\n'.join(pathlib.Path(f).read_text() for f in sourceMap if pathlib.Path(f).name not in {pathlib.Path(n).name for n in base})
   assert token in controlText,('missing reached control token',c['name'],entry,token)
  anchorPins={}
  for file,name in c.get('requiredDefinitions',[]):
   body=(core/file).read_text();hits=list(re.finditer(r'^def '+re.escape(name)+r'\(.*?(?=\ndef |\ntype |\Z)',body,re.M|re.S));assert len(hits)==1,('missing/ambiguous anchor',c['name'],file,name);anchorPins[file+':'+name]=hashlib.sha256(hits[0][0].encode()).hexdigest()
  subjects.append({'liveAnchorDefinitions':anchorPins,'entry':str(entry),'entrySHA256':sha(entry),'sourceMap':sourceMap,'actualRuntime29':runtime,'runtimeDelta':delta,'entryKind':'scoped positive/negative type subject' if c.get('negativeCohort') else 'source-bound executable/type subject','route':c['route']})
 oracles={}
 for op in c['oracles']:
  f=pathlib.Path(op);assert f.is_file();oracles[str(f)]=sha(f)
 assert oracles,('missing oracle',c['name']);rows.append({'name':c['name'],'gateIDs':c['gateIDs'],'route':c['route'],'receipt':str(rp),'receiptSHA256':sha(rp),'expectedStatus':c['expectedStatus'],'subjects':subjects,'oraclePins':oracles})
r={'status':'INCOMPLETE_DIAGNOSTIC_SOURCE_COHORT_MAP' if cfg['missingRequiredCohorts'] else 'FROZEN_DIAGNOSTIC_SOURCE_COHORT_MAP_PENDING_VERIFICATION','scope':'Static consumed subject/import/runtime/oracle pins; not branch execution/canonical acceptance','baseSourceRoot':str(a.source.resolve()),'baseSource29':base,'baseManifestSHA256':sha(a.source/'overlay.json'),'configSHA256':sha(a.config),'cohorts':rows,'missingRequiredCohorts':cfg['missingRequiredCohorts']};a.output.write_text(json.dumps(r,indent=2)+'\n')
