#!/usr/bin/env python3
"""Compare fresh source-pinned counters; no elapsed or product acceptance."""
import argparse,pathlib,json,hashlib,collections,re
p=argparse.ArgumentParser();p.add_argument('--baseline-motion',type=pathlib.Path,required=True);p.add_argument('--baseline-health',type=pathlib.Path,required=True);p.add_argument('--candidate-motion',type=pathlib.Path,required=True);p.add_argument('--candidate-health',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args()
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();closure=lambda m:hashlib.sha256(json.dumps(m,sort_keys=True,separators=(',',':')).encode()).hexdigest()
pins={'baseline':'409d87045a832f021c7d7a1aa880ebfd16ff8d2b9eb5035883d96f781a49daad','candidate':'118c55026da99accd64febac3a66bbcce58bec4b5419fdff8d2e03441dfd285a'}
r={'status':'INCOMPLETE','scope':'Fresh four Native diagnostic executions, clocks3–4, no timing/physicalallocation/universal/product acceptance','sourceClosures':pins,'cases':[]}
def operation_totals(path):
 c=collections.Counter()
 for s in json.loads((path/'sites.json').read_text()):c[s['operation']]+=s.get('entries',0)
 return c
def normalized_kinds(path):
 m=json.loads((path/'analysis.json').read_text());k=m['heapByStaticAllocationKind'];return {re.sub(r'CID_.*?_EXPERIMENTS_S_INTEGRATE_','CID_',name):v for name,v in k.items()}
for schema in ['motion','health']:
 paths={role:getattr(a,role+'_'+schema) for role in ['baseline','candidate']};e={role:json.loads((path/'evidence.json').read_text()) for role,path in paths.items()}
 for role,m in e.items():
  assert m['status']=='CALLSITE_COUNTS_FULL65_FIELDS_PASS' and m['allFullFieldsEqual'];assert closure(m['runtimeSources'])==pins[role];assert m['sourceSHA256']==m['sourceAfterSHA256']
 for key in ['referenceSHA256','compilerWrapperSHA256','compilerELFSHA256','recipeSHA256','updates','fullWorlds']:assert e['baseline'][key]==e['candidate'][key]
 metrics={key:{'baseline':e['baseline'][key],'candidate':e['candidate'][key],'delta':e['candidate'][key]-e['baseline'][key]} for key in ['heapEntries','requestedWords','rfcCreated']}
 operations={role:operation_totals(path) for role,path in paths.items()};kinds={role:normalized_kinds(path) for role,path in paths.items()}
 case={'schema':schema.capitalize(),'status':'PASS','sourceC':{role:m['sourceSHA256'] for role,m in e.items()},'fullWorldsEach':65,'updates':1048576,'metrics':metrics,'physicalCalls':{role:{key:operations[role][key] for key in ['malloc','mmap','mprotect','heap_alloc_miss','bank_pop','corpus_grow']} for role in paths},'changedConstructorKinds':{key:{role:kinds[role].get(key,0) for role in paths} for key in set(kinds['baseline'])|set(kinds['candidate']) if kinds['baseline'].get(key)!=kinds['candidate'].get(key)},'evidenceHashes':{role:sha(path/'evidence.json') for role,path in paths.items()}}
 r['cases'].append(case)
r['status']='FRESH_SOURCE_PINNED_CLOSED_METADATA_NATIVE_COUNTS_BOTH_PASS';a.output.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps([{'schema':c['schema'],'metrics':c['metrics']} for c in r['cases']]))
