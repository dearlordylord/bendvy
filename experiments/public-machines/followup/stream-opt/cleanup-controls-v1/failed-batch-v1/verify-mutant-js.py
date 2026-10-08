"""Portable archived-only reached cleanup mutant JS qualification; no child processes."""
import hashlib, importlib.util, json, tarfile, tempfile
from pathlib import Path
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
PLANS={'source':'839aa2dcbb54f8fb46780aaadf4722a358a24f4d4fc2c4daad4d54e345db95a9','JS':'01bac5b5a910d193f171d86521d57a069cd9802bb5d0fb644029eb2f488be8ff'}
RECEIPTS={'source':'52f79cf9483abf52e3587bce4558179835c5d1a0ec7ffa09229ffa4b77548684','JS':'1d171af4bc16e056b8b89d54086fc8ebab0edb3a3c8eaaf8902ba7d7fa45fa17'}
def verify():
 o=H/'delivery-mutant-js-v1';m=json.loads((o/'manifest.json').read_text());assert sha(Path(__file__).read_bytes())==m['verifierSHA256'] and sha((o/'REPORT.md').read_bytes())==m['reportSHA256']
 for n,digest in m['sources'].items():assert sha((H/n).read_bytes())==digest
 for n,digest in m['prerequisiteFiles'].items():assert sha((H.parents[5]/n).read_bytes())==digest
 spec=importlib.util.spec_from_file_location('normal_js_cleanup_prerequisite',H/'verify.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v);v.verify()
 assert sha((o/'cohort.tar.gz').read_bytes())==m['archive']['sha256']
 with tarfile.open(o/'cohort.tar.gz') as t:
  members=t.getmembers();assert len(members)==len({v.name for v in members}) and all(v.isfile() and not Path(v.name).is_absolute() and '..' not in Path(v.name).parts for v in members)
  data={v.name:t.extractfile(v).read() for v in members}
 assert set(data)==set(m['archive']['members'])
 for n,b in data.items():assert sha(b)==m['archive']['members'][n]['sha256'] and len(b)==m['archive']['members'][n]['bytes']
 for n,digest in m['sources'].items():assert sha(data['source/'+n])==digest
 obj=lambda n:json.loads(data[n]);assert set(m['runs'])==set(PLANS)
 originalH=Path(m['runs']['JS']['originalDirectory']).parent;noticePath=str(originalH.parent/'known-notice.txt');entry=m['pinDispositions']['JS'][noticePath];assert entry['kind']=='archive';notice=data[entry['member']];assert sha(notice)=='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
 privateRoles={};elfRoles={}
 for label in PLANS:
  ownerPlans=[(PLANS[label],obj(label+'/plan.json'))]
  for n,digest in obj(label+'/plan.json')['pins'].items():
   if Path(n).name=='plan.json':
    x=m['pinDispositions'][label][n];assert x['kind']=='archive' and sha(data[x['member']])==digest;ownerPlans.append((digest,obj(x['member'])))
   if Path(n).name=='receipt.json':
    x=m['pinDispositions'][label][n];assert x['kind']=='archive' and sha(data[x['member']])==digest
    for path,h in obj(x['member']).get('generated',{}).items():
     if Path(path).name=='application-native':assert digest=='e9cf9cb37dd7fe181854e9909545458011ecb78c6cfb657dc4c4a758c8a13603';elfRoles[path]=h
  for ownerSHA,owner in ownerPlans:
   if 'environmentSHA256' not in owner:continue
   keys=[k for k in ['environment','privateEnvironment'] if k in owner];assert len(keys)==1;path=owner[keys[0]];h=owner['environmentSHA256']
   if path in owner['pins']:assert owner['pins'][path]==h
   else:assert ownerSHA=='5c706c039d9d138a53f3731ae4c82d911c1ad69e27a1d8c3885324c3ee2604e5' and keys==['privateEnvironment'] and h=='52d8344e4e309c2e668a904372ca8a610287c50b8fe0305d7a6ba2dc7758080e'
   if path in privateRoles:assert privateRoles[path]==h
   privateRoles[path]=h
 for label,digest in PLANS.items():
  p=obj(label+'/plan.json');r=obj(label+'/receipt.json');assert sha(data[label+'/plan.json'])==digest==r['planSHA256']==m['runs'][label]['planSHA256']
  assert sha(data[label+'/receipt.json'])==m['runs'][label]['receiptSHA256'] and not r.get('guardFailures',[])
  if label in RECEIPTS:assert sha(data[label+'/receipt.json'])==RECEIPTS[label]
  assert {n.removeprefix(label+'/stage/'):sha(b) for n,b in data.items() if n.startswith(label+'/stage/')}==p['inventory'] and len(p['inventory'])==92
  dispositions=m['pinDispositions'][label];assert set(dispositions)==set(p['pins'])
  for path,digest in p['pins'].items():
   e=dispositions[path];assert e['sha256']==digest
   if e['kind']=='archive':assert sha(data[e['member']])==digest
   elif e['kind']=='installedIdentityExcluded':assert p['tools']['pins'][path]==digest
   elif e['kind']=='generatedELFIdentityExcluded':assert elfRoles[path]==digest and e['bytes']>0
   else:assert e['kind']=='privateEnvironmentIdentityExcluded' and privateRoles[path]==digest
  commands=p['commands'] if label=='JS' else [p['command']];assert len(commands)==len(r['commands'])==(2 if label=='JS' else 1)
  for c,x in zip(commands,r['commands']):
   assert x['label']==c['label'] and x['argv']==c['argv'] and x['seconds']==c['seconds'] and x['failure'] is None and x['status']=='TERMINAL'
   assert x['argv'][:3]==['/usr/bin/taskset','-c','8'] and x['runnerSHA256']==p['pins'][str(Path(m['runs'][label]['originalDirectory']).parents[6]/'scripts/task_runner.py')]
   assert x['exit']==(0 if label=='JS' else 1)
  names={c['label']+suffix for c in commands for suffix in ['.stdout','.stderr']};assert set(r['logs'])==names
  assert {n.removeprefix(label+'/') for n in data if n.startswith(label+'/') and '/' not in n.removeprefix(label+'/') and n.endswith(('.stdout','.stderr'))}==names
  for n,digest in r['logs'].items():assert sha(data[label+'/'+n])==digest
  if label!='JS':
   assert r['status']=='FAILED_BATCH_ERASURE_MUTANT_SOURCE_RAW_COLLECTED_NO_TYPING_OR_RUNTIME_CREDIT' and commands[0]['seconds']==5 and commands[0]['argv'][-1]=='--check-only' and data[label+'/cleanup-source.stdout']==b''
  else:
   assert r['status']=='COMPLETE_TWO_SCHEMA_ACCEPTED_CLEANUP_BATCH_ERASURE_MUTANT_JS_FULL_ORACLE_AND_WITNESSES_PASS' and r['completeWorldRows']==32 and r['completeInstanceRecords']==16
   target=Path(p['stage'])/'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/failed-batch-v1/caller.bend';artifact=Path(m['runs'][label]['originalDirectory'])/'application.js';prefix=[p['tools']['taskset'],'-c','8']
   assert commands==[{'label':'emit-js','argv':prefix+[p['tools']['tools']['bend'],str(target),'-o',str(artifact)],'seconds':30,'generated':str(artifact)},{'label':'consumer','argv':prefix+[p['tools']['tools']['node'],str(artifact)],'seconds':5}]
   assert r['generated']=={str(artifact):sha(data['JS/generated/application.js'])}
   assert data['JS/emit-js.stdout']==data['JS/consumer.stderr']==b'' and data['JS/emit-js.stderr'] in [b'',notice]
   tools=[n for n in p['tools']['tools'] if n not in p['tools']['skip_ldd']];labels=['guard-'+str(i)+'-ldd-'+n for i in range(5) for n in tools]
   assert len(tools)==7 and p['executionProbeLabels']==labels and p['expectedProbeCount']==r['probeCommandsExecuted']==35
   probeNames={n+suffix for n in labels for suffix in ['.json','.stdout','.stderr']};assert {n.removeprefix('JS/execution-probes/') for n in data if n.startswith('JS/execution-probes/')}==probeNames
   assert set(r['probePins'])=={str(artifact.parent/'execution-probes'/n) for n in probeNames}
   for path,digest in r['probePins'].items():assert sha(data['JS/execution-probes/'+Path(path).name])==digest
   for n in labels:
    x=obj('JS/execution-probes/'+n+'.json');tool=n.split('-ldd-',1)[1]
    assert x['argv']==prefix+[p['tools']['ldd'],p['tools']['tools'][tool]] and x['seconds']==5 and x['exit']==0 and x['failure'] is None and x['exception'] is None and x['runnerSHA256']==r['commands'][0]['runnerSHA256']
   assert data['JS/stage/experiments/public-machines/followup/stream-opt/cleanup-controls-v1/failed-batch-v1/caller.bend']==(H/'caller.bend').read_bytes()
   assert data['JS/stage/experiments/public-machines/followup/stream-opt/cleanup-controls-v1/failed-batch-v1/caller-core.bend']==data['source/mutant-caller-core.bend']
 assert sha(data['source/cleanup-source.stderr'])=='607556a2b69ba1750877198242ed267c204cc7fc3e97b4419f3e68f6f6c8b67e'
 classification=obj('source/mutant-source-classification.json');assert classification['planSHA256']==PLANS['source'] and classification['receiptSHA256']==RECEIPTS['source'] and classification['stderrSHA256']==sha(data['source/cleanup-source.stderr']) and classification['classification']=='EXPLICIT_FIVE_FOREIGN_PROMISE_DEPENDENCY_BOUNDARY_ONLY'
 js=obj('JS/plan.json');originalH=Path(m['runs']['JS']['originalDirectory']).parent
 for n,digest in m['sources'].items():
  assert digest==js['pins'][str(originalH/n)]==sha(data['source/'+n])
 assert sha(notice)=='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
 with tarfile.open(H/'delivery-v1/cohort.tar.gz') as t:normalData={v.name:t.extractfile(v).read() for v in t.getmembers()}
 proposal=obj('source/mutant-proposal.json');base=normalData['source/caller-core.bend'];mutant=data['source/mutant-caller-core.bend'];assert sha(base)==proposal['baseSourceSHA256'] and sha(mutant)==proposal['mutantSHA256'] and base.decode().count(proposal['oldBody'])==1
 text=base.decode();assert text.count('def first_cleaned(')==1 and text.count('import ../../../../slots.bend as Slots')==1
 assert text.replace('import ../../../../slots.bend as Slots','import ../../../../slots.bend as Slots\n'+proposal['additionalImport']).replace('def first_cleaned(',proposal['helper']+'def first_cleaned(').replace(proposal['oldBody'],proposal['newBody']).encode()==mutant
 expectedInventory=json.loads(normalData['JS/plan.json'])['inventory'].copy();expectedInventory['experiments/public-machines/followup/stream-opt/cleanup-controls-v1/failed-batch-v1/caller-core.bend']=sha(mutant)
 assert obj('source/plan.json')['inventory']==js['inventory']==expectedInventory
 assert sha(data['source/mutant-expected.json'])==proposal['independentOracleSHA256']
 with tempfile.TemporaryDirectory(prefix='cleanup-archived-model-') as directory:
  root=Path(directory)
  for n,b in normalData.items():
   if n.startswith('model-root/'):
    p=root/n.removeprefix('model-root/');p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(b)
  caller=root/'caller';caller.mkdir();text=normalData['source/model.py'].decode();literal="ROOT=Path('/workspace/formal-proofs/bendvy')";assert text.count(literal)==1
  (caller/'model.py').write_text(text.replace(literal,'ROOT=Path('+repr(str(root))+')'))
  (caller/'expected.json').write_bytes(normalData['source/expected.json'])
  for n in ['mutant-model.py','mutant-expected.json','validate-mutant.py']:(caller/n).write_bytes(data['source/'+n])
  spec=importlib.util.spec_from_file_location('portable_cleanup_complete',caller/'validate-mutant.py');model=importlib.util.module_from_spec(spec);spec.loader.exec_module(model);observed=model.validate(data['JS/consumer.stdout']);normal=json.loads(normalData['source/expected.json']);assert json.dumps(observed,sort_keys=True)!=json.dumps(normal,sort_keys=True)
  assert obj('JS/receipt.json')['reachedWitnessSchemas']==['A','B']
  for schema in ['A','B']:
   cleaned=next(v for v in observed[schema]['worlds']['A'] if v['label']=='first-owned-cleanup');assert 'batches=[]' in cleaned['fields']['flowStream']
   assert observed[schema]['instances'][5]=='survivor-delivery=[actual:flow=[]:level=[]:lagged=false,false]'
   assert normal[schema]['instances'][5]=='survivor-delivery=[actual:flow=[Boot>Play]:level=[]:lagged=false,false]'
 print('PORTABLE_REACHED_FAILED_BATCH_ERASURE_JS32_WORLD16_INSTANCE_FULL_ORACLE_BOTH_WITNESSES_PASS')
if __name__=='__main__':verify()
