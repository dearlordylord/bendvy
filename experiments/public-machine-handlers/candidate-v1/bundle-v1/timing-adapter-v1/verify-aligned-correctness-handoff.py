"""Portable retained aligned source/JS/TS correctness; no children or clocks."""
import hashlib,importlib.util,json,tarfile
from pathlib import Path
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
def strict(raw):
 def pairs(items):
  out={}
  for key,value in items:assert key not in out;out[key]=value
  return out
 return json.loads(raw,object_pairs_hook=pairs,parse_constant=lambda x:(_ for _ in ()).throw(ValueError(x)))
def load(path,name):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
def canonical(value):return json.dumps(value,sort_keys=True,separators=(',',':'),ensure_ascii=False)
def verify():
 d=H/'delivery-aligned-correctness-v1';m=strict((d/'manifest.json').read_bytes());a=m['archive']
 assert sha(Path(__file__).read_bytes())==m['verifierSHA256'] and sha((d/'REPORT.md').read_bytes())==m['reportSHA256']
 assert sha((H/'delivery-ledger-correctness-v1/manifest.json').read_bytes())==m['prerequisite']['manifestSHA256']
 assert sha((H/'verify-ledger-correctness-handoff.py').read_bytes())==m['prerequisite']['verifierSHA256']
 load(H/'verify-ledger-correctness-handoff.py','preceding_full_io_js').verify()
 assert sha((d/a['name']).read_bytes())==a['sha256']
 with tarfile.open(d/a['name']) as t:
  entries=t.getmembers();assert len(entries)==len({e.name for e in entries}) and all(e.isfile() for e in entries)
  assert {e.name for e in entries}==set(a['members']);data={e.name:t.extractfile(e).read() for e in entries}
 for name,b in data.items():assert sha(b)==a['members'][name]['sha256'] and len(b)==a['members'][name]['bytes']
 for name,digest in m['source'].items():
  rel=Path(name);assert not rel.is_absolute() and '..' not in rel.parts
  assert sha((H/rel).read_bytes())==digest==sha(data['source/'+name])
 assert sha((H.parent.parent/'readiness-v1/README.md').read_bytes())==m['readinessSHA256']==sha(data['source/readiness-current.md'])
 priorManifest=strict((H/'delivery-ledger-correctness-v1/manifest.json').read_bytes())
 with tarfile.open(H/'delivery-ledger-correctness-v1'/priorManifest['archive']['name']) as t:prior={e.name:t.extractfile(e).read() for e in t.getmembers()}
 priorPlan=strict(prior['run/plan.json']);obj=lambda n:strict(data[n]);receipts={}
 accepted={'source':('778c15578a8271c66793514d05d4516c1aca5b86c3ff62fbb285712238884186','ad0ef6b4d10b63febcf308266892b07cf7f2dd6c0529b489409d9ba9265ec4f4','ALIGNED_SOURCE_DEVELOPMENT_TYPING_PASS_NO_RUNTIME_CREDIT',[5]),'js':('6f62e3ed0d3a031f20166ba6be5591c810a277c2fb1fcaa8b3ff6bf4d34f901a','50a142643239cfd09d5bbad9de7b1d7127705e42067c4180dd85fd7b897074ff','FULL116_ALIGNED_CAPTURES_AND_UNCHANGED42_JS_CORRECTNESS_PASS_NO_TIMING_CREDIT',[30,5]),'ts':('d662bf1a853bb3bd6b1cf1ab90aec4fb3790a1f7f859562bf49929b668a66575','b11dc46acd3328b3b5658b570d147c6f58e25e5e8d6e8a2068940b914d872cba','ACTUAL_PINNED_TS_ALIGNED116_COMMON_AND_UNCHANGED42_WITH_FULL_RAW_PASS',[5])}
 assert set(m['pinDispositions'])==set(accepted)
 for key,(planSHA,receiptSHA,status,caps) in accepted.items():
  p=obj(key+'/plan.json');r=obj(key+'/receipt.json');receipts[key]=r
  assert sha(data[key+'/plan.json'])==planSHA==r['planSHA256'] and sha(data[key+'/receipt.json'])==receiptSHA
  assert r['status']==status and not r.get('guardFailures',[]) and len(r['commands'])==len(caps)
  commands=[p['command']] if key=='source' else p['commands'];assert [c['seconds'] for c in commands]==caps and len(commands)==len(caps)
  prefix=[p['tools']['taskset'],'-c','8'];taskPath=str(Path(m['archivedRoot']).parents[4]/'scripts/task_runner.py');taskSHA=p['pins'][taskPath]
  assert taskSHA=='f6e3e815ede2d24dc80825f156ace534956d2f61ef559a09253bf97504e746b7'
  assert all(c['runnerSHA256']==taskSHA for c in r['commands'])
  if key=='source':
   assert commands==[{'argv':prefix+[p['tools']['tools']['bend'],str(Path(m['archivedRoot'])/'capture-alignment-source-v1/correctness-main.bend'),'--check-only'],'seconds':5}]
   assert not r.get('generated',{})
  elif key=='js':
   artifact=str(Path(p['stage']).parent/'aligned-ledger.js')
   assert commands==[{'label':'aligned-emit','argv':prefix+[p['tools']['tools']['bend'],str(Path(p['stage'])/'capture-alignment-source-v1/correctness-main.bend'),'-o',artifact],'seconds':30,'expected':0,'generated':artifact},{'label':'aligned-io-run','argv':prefix+[p['tools']['tools']['node'],artifact],'seconds':5,'expected':0}]
   assert r['generated']=={artifact:sha(data['js/aligned-ledger.js'])}
  else:
   assert commands==[{'label':'aligned-TS-consume','argv':prefix+[p['tools']['tools']['node'],str(Path(p['stage'])/'capture-alignment-source-v1/consumer-ts.mjs')],'seconds':5,'expected':0}]
   assert r['generated']=={}
  assert all(c['exit']==0 and c['failure'] is None for c in r['commands'])
  assert set(m['pinDispositions'][key])==set(p['pins'])
  for path,digest in p['pins'].items():
   entry=m['pinDispositions'][key][path];assert entry['sha256']==digest
   if entry['kind']=='archive':assert sha(data[entry['member']])==digest
   elif entry['kind']=='qualifiedJSArchive':assert sha(prior[entry['member']])==digest
   elif entry['kind']=='qualifiedJSScalarIdentity':assert entry['path']==path and priorPlan['pins'][path]==digest
   else:
    assert entry['kind']=='privateEnvironmentIdentityExcluded' and Path(path).name=='private-environment.json'
    owners=[priorPlan]+[obj(k+'/plan.json') for k in accepted]
    assert any(owner.get('privateEnvironment',owner.get('environment'))==path and owner['environmentSHA256']==digest for owner in owners)
  if key=='source':
   assert set(r['logs'])=={'aligned-source.stdout','aligned-source.stderr'}
   sourceKeys=sorted(p['source']);assert {n.removeprefix('source/source/') for n in data if n.startswith('source/source/')}=={str(i)+'.bend' for i in range(len(sourceKeys))}
   for i,path in enumerate(sourceKeys):assert sha(data['source/source/'+str(i)+'.bend'])==p['source'][path]
  else:
   assert {n.removeprefix(key+'/stage/'):sha(b) for n,b in data.items() if n.startswith(key+'/stage/')}==p['inventory']
   labels=['guard-'+str(i)+'-ldd-'+tool for i in range(5 if key=='js' else 3) for tool in ['bend','node','python','taskset','clang']]
   assert p['executionProbeLabels']==labels and r['probeCommandsExecuted']==len(labels)
   members={label+suffix for label in labels for suffix in ['.json','.stdout','.stderr']}
   assert {n.removeprefix(key+'/execution-probes/') for n in data if n.startswith(key+'/execution-probes/')}==members
   assert set(r['probePins'])=={str(Path(p['stage']).parent/'execution-probes'/n) for n in members}
   for path,digest in r['probePins'].items():assert sha(data[key+'/execution-probes/'+Path(path).name])==digest
   for label in labels:
    record=obj(key+'/execution-probes/'+label+'.json');tool=label.split('-ldd-',1)[1]
    assert record['argv']==[p['tools']['taskset'],'-c','8',p['tools']['ldd'],p['tools']['tools'][tool]] and record['seconds']==5
    assert record['exit']==0 and record['failure'] is None and record.get('exception') is None
    assert record['runnerSHA256']==taskSHA and all(record['runnerSHA256']==c['runnerSHA256'] for c in r['commands'])
   assert set(r['logs'])=={c['label']+suffix for c in commands for suffix in ['.stdout','.stderr']}
   for path,digest in r['generated'].items():assert sha(data[key+'/'+Path(path).name])==digest
  for name,digest in r['logs'].items():assert sha(data[key+'/'+name])==digest
  assert all(data[key+'/'+name]==b'' for name in r['logs'] if name.endswith('.stderr'))
 assert data['source/aligned-source.stdout']==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n' and data['js/aligned-emit.stdout']==b''
 aligned=H/'capture-alignment-source-v1';jsResult=load(aligned/'validate-correctness.py','complete_aligned_model').validate(data['js/aligned-io-run.stdout'])
 assert jsResult['status']==receipts['js']['independentValidationStatus']
 ts=obj('ts/aligned-TS-consume.stdout');assert ts['status']=='UNQUALIFIED_ALIGNED_CAPTURE_SOURCE_NO_CLOCK' and list(ts['schemas'])==['A','B']
 model=load(aligned/'model.py','capture_model');expected=model.expected();assert canonical(expected)==canonical(strict((aligned/'expected-before-output.json').read_bytes()))
 ledger=strict((H/'operations.json').read_bytes());checkpoint=strict((H/'common-expected.json').read_bytes())['comparable']
 for schema in ['A','B']:
  result=ts['schemas'][schema];assert set(result)=={'rows','samples','captures'} and len(result['captures'])==13 and len(result['samples'])==58
  assert [s['kind'] for s in result['samples']]==[kind for descriptor in ledger['scenarios'] for kind in ['setup',*['steady:'+step['kind'] for step in descriptor['steps']]]]
  assert all(s['nanoseconds']=='0' for s in result['samples']);rows={};count=0
  for descriptor,scenario,wanted in zip(ledger['scenarios'],result['captures'],expected['captures'][schema],strict=True):
   assert scenario['scenario']==descriptor['scenario']==wanted['scenario'] and len(scenario['captures'])==len(wanted['captures'])
   for ordinal,(record,modeled) in enumerate(zip(scenario['captures'],wanted['captures'],strict=True)):
    assert set(record)=={'kind','checkpoint','raw','common'} and record['kind']==modeled['kind'] and record['checkpoint']==modeled['checkpoint']
    assert canonical(record['common'])==canonical(model.common(modeled['values'][0]))
    raw=record['raw'];assert set(raw)=={'label','result','world','streams','hostLocal','attempts','prefix','deliveries'} and raw['label']==('seed' if ordinal==0 else record['kind'])
    for source,field in [('hostLocal','locals'),('attempts','attempts'),('prefix','prefix'),('deliveries','deliveries')]:assert canonical(raw[source])==canonical(record['common'][field])
    if record['checkpoint'] is not None:
     name=record['checkpoint'];assert name not in rows;rows[name]=record['common'];point=result['rows'][name]
     assert canonical(point['common'])==canonical(record['common']) and canonical(point['raw']['world'])==canonical(raw['world']) and canonical(point['raw']['streams'])==canonical(raw['streams'])
     assert canonical(point['raw']['history'])==canonical([item['raw'] for item in scenario['captures'][:ordinal+1]])
    count+=1
  assert count==58 and canonical(rows)==canonical(checkpoint[schema]) and list(result['rows'])==list(checkpoint[schema])
 p=obj('ts/plan.json');tm=obj('reference/qualified-ts-source-review-manifest.json')
 assert tm['pinnedTSSource']['commit']=='3040a3b2a3f28fa8554d856f9ccb6bf5433fa334'
 assert sha(data['reference/sources.json'])==tm['pinnedTSSource']['sourceManifestSHA256']
 assert {n.removeprefix('reference/core/'):sha(b) for n,b in data.items() if n.startswith('reference/core/')}==p['tsCoreInventory']
 print('PORTABLE_ALIGNED_JS_PHYSICAL116_TS_COMMON116_UNCHANGED42_PASS_NO_TIMING_NATIVE_CREDIT')
if __name__=='__main__':verify()
