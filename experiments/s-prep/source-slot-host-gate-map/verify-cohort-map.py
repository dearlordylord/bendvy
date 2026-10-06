#!/usr/bin/env python3
"""Fail closed on incomplete/conflicting consumed source cohorts; no canonical gate status."""
import argparse,pathlib,json,hashlib,re
p=argparse.ArgumentParser();p.add_argument('--map',type=pathlib.Path,required=True);p.add_argument('--config',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();m=json.loads(a.map.read_text());cfg=json.loads(a.config.read_text());assert sha(a.config)==m['configSHA256'];assert not m['missingRequiredCohorts'] and not cfg['missingRequiredCohorts'],'Incomplete required cohorts';names={'host-original-motion','host-original-health','host12-selected-live-mutants','e11-original','e11-mutants','access-nine','static-provider-eight','static-world-sixteen','owned-generic','staging','staging-live-mutants','tx-baseline','tx-mutants'};cs={c['name']:c for c in cfg['cohorts']};rows={c['name']:c for c in m['cohorts']};assert len(rows)==len(m['cohorts']) and set(rows)==set(cs)==names;wanted={'host-original-motion':1,'host-original-health':1,'e11-original':1,'e11-mutants':10,'access-nine':9,'tx-baseline':8,'tx-mutants':16,'owned-generic':1,'staging':14,'host12-selected-live-mutants':24,'static-provider-eight':8,'static-world-sixteen':8,'staging-live-mutants':8};total=0
def checker_entries(x):
 if isinstance(x,dict):
  for k in ['command','argv']:
   v=x.get(k)
   if isinstance(v,list) and 'bend' in v and '--check-only' in v:
    for f in v:
     if isinstance(f,str) and f.endswith('.bend'):yield f
  for v in x.values():yield from checker_entries(v)
 elif isinstance(x,list):
  for v in x:yield from checker_entries(v)
def source_closure(entry,root):
 basePaths={str((pathlib.Path(m['baseSourceRoot'])/n).resolve()) for n in m['baseSource29']};seen=set();pending=[entry.resolve()]
 while pending:
  f=pending.pop();assert f.is_relative_to(root.resolve()) or str(f) in basePaths,'Unconfined import'
  if str(f) in seen:continue
  seen.add(str(f));assert f.is_file() and not f.is_symlink()
  for imp in re.findall(r'^import (\S+)',f.read_text(),re.M):
   if imp=='Base':continue
   assert imp.endswith('.bend') and (imp.startswith(('./','../')) or str(pathlib.Path(imp).resolve()) in basePaths),'Unknown import';pending.append((f.parent/imp).resolve())
 return seen
for name,c in rows.items():
 spec=cs[name];receipt=pathlib.Path(c['receipt']);assert sha(receipt)==c['receiptSHA256'];data=json.loads(receipt.read_text());assert data['status']==c['expectedStatus']==spec['expectedStatus'];assert len(c['subjects'])==wanted[name];assert {s['entry'] for s in c['subjects']}==set(checker_entries(data))|set(spec.get('extraEntries',[])),'Unknown/missing consumed subject';assert c['route']==spec['route'] and c['gateIDs']==spec['gateIDs']
 for op,h in c['oraclePins'].items():assert sha(pathlib.Path(op))==h,('oracle changed',op)
 assert c['oraclePins'],'Missing oracle';seen=set()
 for s in c['subjects']:
  entry=pathlib.Path(s['entry']);assert str(entry) not in seen;seen.add(str(entry));assert sha(entry)==s['entrySHA256'];assert s['sourceMap'] and str(entry.resolve()) in s['sourceMap'];assert len(s['actualRuntime29'])==29 and set(s['actualRuntime29'])==set(m['baseSource29'])
  for path,h in s['sourceMap'].items():assert sha(pathlib.Path(path))==h,('source/import drift',path)
  core=pathlib.Path(spec.get('runtimeRoot',entry.parent));delta=[]
  bound=entry.parent if entry.parent.name=='core' else pathlib.Path(spec.get('subjectRoot',entry.parent.parent));required=source_closure(entry,bound)|{str((core/pathlib.Path(n).name).resolve()) for n in m['baseSource29']};assert set(s['sourceMap'])==required,'Missing or unknown imported source'
  for n,h in s['actualRuntime29'].items():
   path=(core/pathlib.Path(n).name).resolve();assert s['sourceMap'][str(path)]==h and sha(path)==h
   if h!=m['baseSource29'][n]:delta.append(n)
  assert delta==s['runtimeDelta'];allowed=spec.get('permittedRuntimeModules',[])
  if name=='tx-baseline' and 'suppressed' in str(entry):allowed=['held-adapter.bend']
  assert all(pathlib.Path(n).name in allowed for n in delta),('unknown mutation',name,delta)
  assert set(s['liveAnchorDefinitions'])=={f+':'+n for f,n in spec.get('requiredDefinitions',[])},'Missing required live anchors'
  for key,h in s['liveAnchorDefinitions'].items():
   file,definition=key.split(':');hits=list(re.finditer(r'^def '+re.escape(definition)+r'\(.*?(?=\ndef |\ntype |\Z)',(core/file).read_text(),re.M|re.S));assert len(hits)==1 and hashlib.sha256(hits[0][0].encode()).hexdigest()==h,('missing live anchor',key)
  total+=1
r={'status':'DIAGNOSTIC_IMMUTABLE_13_COHORTS_109_SUBJECT_SOURCE_IMPORT_ORACLE_MAP_PASS','mapSHA256':sha(a.map),'configSHA256':sha(a.config),'cohorts':len(rows),'subjects':total,'semanticIDs':['host12','access','e11','owned-storage','staging','tx-baseline','tx-stale-head','tx-torn-tail','tx-lost-mark','tx-inverse-order'],'materializeScope':'Diagnostic immutable route-aware cohort source map only; no canonical PASS_DERIVED_CONTROL_SOURCE_MAP or validate_gates/full22 approval','sourceClosureSHA256':hashlib.sha256(json.dumps(m['baseSource29'],sort_keys=True,separators=(',',':')).encode()).hexdigest()};a.output.write_text(json.dumps(r,indent=2)+'\n')
