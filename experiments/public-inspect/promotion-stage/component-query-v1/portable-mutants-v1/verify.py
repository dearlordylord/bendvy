"""No-child portable full-output normal/source/refusal/reached-control joins."""
import pathlib,json,hashlib,tarfile,tempfile,importlib.util
HERE=pathlib.Path(__file__).resolve().parent
PLANS=['7296b99f34d7f19cf80c62c36973a6bf994da283ee911e7c4f44354f8ac171aa','b194cdf1d2d8c2f0aaec2a5713534491c3a16275e91a6ffaf10ed3854250e737']
SOURCES=['5b1f4e1bb8635a5c0d446e5d7e1518d458e0106fbcac4dcf9b71d6520d4c9bdc','a3c51648e089035d6da22be85ed856fb4c430beef8cb7dd01f1854ffd4dd066c']
NAMES=['bend','node','python','taskset','clang']
def sha(b):return hashlib.sha256(b).hexdigest()
def verify():
 index=json.loads((HERE/'index.json').read_text());records=index['records'];objects={};archive=HERE/'objects.tar.gz';assert sha(archive.read_bytes())==index['archiveSHA256']
 with tarfile.open(archive,'r:gz') as t:
  ms=t.getmembers();expected={r['object'] for r in records.values()};assert len(ms)==len(expected) and {m.name for m in ms}==expected
  for m in ms:
   assert m.isfile();b=t.extractfile(m).read();assert sha(b)==m.name.split('/')[1];objects[m.name]=b
 for n,r in records.items():assert sha(objects[r['object']])==r['sha256'] and len(objects[r['object']])==r['bytes']
 def data(n):return objects[records[str(n)]['object']]
 def js(n):return json.loads(data(n))
 # Re-run already reviewed finite byte verifiers inside materialized archive views,
 # in this Python process. No subprocess, backend or current-root inference.
 with tempfile.TemporaryDirectory() as temp:
  root=pathlib.Path(temp)
  for kind in ['normal','static']:
   folder=root/kind/'portable';folder.mkdir(parents=True);embedded=index[kind+'Index'];(folder/'index.json').write_text(json.dumps(embedded));(folder/'objects.tar.gz').write_bytes(data(index['supportRecords'][kind+'-archive']));(folder/'verify.py').write_bytes(data(index['supportRecords'][kind+'-verifier']))
   if kind=='normal':
    for relative,key in index['normalLiveRecords'].items():
     target=folder.parent/relative;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data(key));assert sha(data(key))==embedded['liveSelected'][relative]['sha256']
    # The normal helper resolves these exact artifact sidecars beside itself.
    for name in ['ARCHIVED-PATH-JOINS.json','pinned-reference-sources.json']:
     candidates=[n for n in records if n.endswith('/portable-component-v1/'+name)];assert len(candidates)==1;(folder/name).write_bytes(data(candidates[0]))
   spec=importlib.util.spec_from_file_location('finite_'+kind,folder/'verify.py');module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module);module.verify()
 normal=index['normalIndex'];normal_bytes=data(normal['runtimeRoot']+'/complete-run-js.stdout.raw');assert sha(normal_bytes)=='810259f78227f2b3d158c02644978b6c7ecf58b40a4b2fb398a816005b2867e2'
 baseline_candidates=[n for n,r in records.items() if r['sha256']=='cf3c702fa04ed5064f816b3570155db69f9198aa128a7d3304b8f2e5045513a3'];assert len(baseline_candidates)==1;baseline=js(baseline_candidates[0])
 for idx,origin in enumerate(index['origins']):
  o=pathlib.Path(origin);p=js(o/'plan.json');r=js(o/'receipt.json');assert sha(data(o/'plan.json'))==PLANS[idx] and r['planSHA256']==PLANS[idx]
  assert r['status']=='COMPLETE_REACHED_FULL_COMPONENT_JS_MUTANT' and r.get('guardFailures',[])==[]
  for n,d in p['inputs'].items():
   for path,digest in ({str(pathlib.Path(n)/rel):v for rel,v in d.items()} if isinstance(d,dict) else {n:d}).items():
    if path in index['hashOnlyExclusions']:assert index['hashOnlyExclusions'][path]['sha256']==digest
    else:assert sha(data(path))==digest
  assert set(p['stageInventory'])==set(baseline['stageInventory']);changed='query.bend' if idx==0 else 'selection.bend'
  assert {n for n in p['stageInventory'] if p['stageInventory'][n]!=baseline['stageInventory'][n]}=={changed}
  for n,d in p['stageInventory'].items():assert sha(data(pathlib.Path(p['stage'])/n))==d
  assert {n for n in records if n.startswith(p['stage']+'/')}=={str(pathlib.Path(p['stage'])/n) for n in p['stageInventory']}
  q=p['mutationQualification'];sp=js(q['plan']);sr=js(q['receipt']);assert sha(data(q['plan']))==q['planSHA256']==SOURCES[idx] and sha(data(q['receipt']))==q['receiptSHA256']
  assert sr['planSHA256']==SOURCES[idx] and sr['status']=='SOURCE_MUTANT_FEASIBILITY_PASS' and sr['exit']==0 and sr['failure'] is None and sr.get('guardFailures',[])==[]
  for n,d in sr['logs'].items():assert sha(data(pathlib.Path(q['plan']).parent/n))==d
  for n,d in sp['sourceArchive'].items():assert sha(data(pathlib.Path(q['plan']).parent/'source'/n))==d
  for n,d in q['pins'].items():assert sha(data(n))==d
  prep_path=pathlib.Path(p['preparationPlan']);prep_root=prep_path.parent;prep_plan=js(prep_path);prep_receipt=js(prep_root/'prepare-receipt.json')
  assert sha(data(prep_path))==p['preparationPlanSHA256']=='01ee702524f7891b3059e4702fc03719ba8f82f5ff0f50fe9fb6d262bdf136f7'
  assert sha(data(prep_root/'prepare-receipt.json'))==p['preparationReceiptSHA256'] and data(o/'prepare-receipt.json')==data(prep_root/'prepare-receipt.json')
  assert prep_receipt['status']=='COMPLETE_ORDINARY_OWNED_JS_PREPARATION' and prep_receipt['preparationPlanSHA256']==p['preparationPlanSHA256'] and prep_receipt.get('guardFailures',[])==[] and prep_receipt['probeCount']==5
  assert prep_receipt['configurationBefore']==prep_receipt['configurationAfter']
  assert prep_receipt['gitOrigin']['exit']==0 and prep_receipt['gitOrigin']['failure'] is None and prep_receipt['gitOrigin']['seconds']==5
  assert prep_plan['gitOriginCommand']==['/usr/bin/taskset','-c','5','/usr/bin/git','ls-files'] and prep_plan['gitOriginSeconds']==5
  qualification=js(p['nativePreparationQualification']);assert sha(data(p['nativePreparationQualification']))==p['nativePreparationQualificationSHA256'] and qualification['status']=='COMPLETE_NATIVE_ORDINARY_PREPARATION_QUALIFICATION' and qualification['preparationPlanSHA256']==p['preparationPlanSHA256'] and qualification.get('guardFailures',[])==[]
  prep_labels=['prepare-ldd-'+name for name in NAMES];assert prep_plan['ordinaryProbeLabels']==prep_labels
  prep_files={str(prep_root/'prepare-probes'/(label+suffix)) for label in prep_labels for suffix in ['.json','.stdout.raw','.stderr.raw']};assert set(prep_receipt['probePins'])==prep_files
  assert {n for n in records if n.startswith(str(prep_root/'prepare-probes')+'/')}==prep_files
  for n,d in prep_receipt['probePins'].items():assert sha(data(n))==d
  name='order' if idx==0 else 'conjunction';tc=p['frozenToolConfiguration'];snapshot=js(p['toolSnapshot']);commands=p['commands'];assert len(commands)==2
  assert sha(data(p['toolSnapshot']))==p['toolSnapshotSHA256']
  assert index['hashOnlyExclusions'][p['privateEnvironment']]['sha256']==p['environmentSHA256']==index['privateEnvironmentBindings'][p['privateEnvironment']]['privateFileSHA256']
  assert snapshot['environment_sha256']==index['privateEnvironmentBindings'][p['privateEnvironment']]['canonicalEnvironmentSHA256']
  for label in prep_labels:
   m=js(prep_root/'prepare-probes'/(label+'.json'));tool=label.split('-ldd-')[1];assert m['argv']==[tc['taskset'],'-c','5',tc['ldd'],snapshot['tools'][tool]] and m['seconds']==5 and m['exit']==0 and m['failure'] is None and m.get('exception') is None and m['runnerSHA256']=='f6e3e815ede2d24dc80825f156ace534956d2f61ef559a09253bf97504e746b7'
  for n,d in prep_receipt['logs'].items():assert sha(data(prep_root/n))==d
  assert set(prep_receipt['logs'])=={'source-origin.stdout.raw','source-origin.stderr.raw'} and data(prep_root/'source-origin.stderr.raw')==b''

  assert commands[0]=={'label':name+'-emit-js','argv':[tc['taskset'],'-c','5',tc['tools']['bend'],str(o/'stage/output-io-main.bend'),'-o',str(o/'component-mutant.js')],'seconds':30,'generated':str(o/'component-mutant.js')}
  assert commands[1]=={'label':name+'-run-js','argv':[tc['taskset'],'-c','5',tc['tools']['node'],str(o/'component-mutant.js')],'seconds':5,'oracle':q['oracle']}
  assert r['commands']==[{'label':c['label'],'exit':0,'failure':None,'seconds':c['seconds']} for c in commands]
  expected_labels=['verify-'+str(i)+'-ldd-'+n for i in range(5) for n in NAMES];assert p['executionProbeLabels']==expected_labels and r['probeCount']==25
  expected_probe_files={str(o/'execution-probes'/(label+suffix)) for label in expected_labels for suffix in ['.json','.stdout.raw','.stderr.raw']};assert set(r['probePins'])==expected_probe_files and {n for n in records if n.startswith(str(o/'execution-probes')+'/')}==expected_probe_files
  for n,d in r['probePins'].items():assert sha(data(n))==d
  for label in expected_labels:
   m=js(o/'execution-probes'/(label+'.json'));tool=label.split('-ldd-')[1];assert m['argv']==[tc['taskset'],'-c','5',tc['ldd'],snapshot['tools'][tool]] and m['seconds']==5 and m['exit']==0 and m['failure'] is None and m.get('exception') is None
   assert m['runnerSHA256']=='f6e3e815ede2d24dc80825f156ace534956d2f61ef559a09253bf97504e746b7'
  subject_raws={c['label']+'.'+k+'.raw' for c in commands for k in ['stdout','stderr']};assert set(r['logs'])==subject_raws
  prep=js(o/'prepare-receipt.json');assert {n for n in records if pathlib.Path(n).parent==o and n.endswith('.raw')}=={str(o/n) for n in subject_raws|set(prep['logs'])}
  for n,d in {**prep['logs'],**r['logs']}.items():assert sha(data(o/n))==d
  assert data(o/(name+'-emit-js.stdout.raw'))==b'' and data(o/(name+'-emit-js.stderr.raw')) in [b'',b'bend 2.0.36 is available: run bend update\n'] and data(o/(name+'-run-js.stderr.raw'))==b''
  actual=data(o/(name+'-run-js.stdout.raw'));expected=data(q['oracle']);assert actual==expected and sha(expected)==q['oracleSHA256'] and actual!=normal_bytes
  assert r['generated']=={str(o/'component-mutant.js'):sha(data(o/'component-mutant.js'))}
  assert r['schemaOracles'][name+'-run-js']['actualSHA256']==r['schemaOracles'][name+'-run-js']['expectedSHA256']==sha(actual) and r['schemaOracles'][name+'-run-js']['bytes']==len(actual)
 return {'status':'FINITE_NORMAL_STATIC_AND_TWO_REACHED_COMPONENT_JS_CONTROLS_VERIFIED','records':len(records),'objects':len(objects),'mutants':2,'scope':index['scope']}
if __name__=='__main__':print(json.dumps(verify(),indent=2))
