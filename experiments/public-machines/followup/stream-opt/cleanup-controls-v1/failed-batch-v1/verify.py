"""Portable finite full failed-batch cleanup JS/Native evidence; no children."""
import hashlib,importlib.util,json,tarfile,tempfile
from pathlib import Path
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
PLANS={'failed-syntax':'e9b708dae3ea91ab0b460a036484bfd19927497e112e1ac7c6de33a01d0194ba','effect-boundary':'21282080652192e0b6791d17e58bd6d3aaca012c291dee14c970d922bcc82fd4','JS':'eee8cef0f84245021dd76dbaba2230059fabecd5900032cb2db6e1c6408ccab0','Native':'b57074e075c9cf7f06c260824062d9e3a9b4e8410111a9658fe9a190981c0ec0','unexecuted-repair':'3665a1f2e8c55e2fa91bc7c9fc53927e7654484398cd58576e40529ebdcbf88d'}
RECEIPTS={'failed-syntax':'9e50c77b8f0c9f233580bbc7d58e7c89bec1e8e2594a74f029871b35799c0aff','effect-boundary':'88f02251717923e01a8075dbb8f3052079a83e3943849b22bc50a35f066c76c4','JS':'2a8a9ab241f37acc9a7857b4f75ebc1bda5e632f8e3bc14b0d5d1617b6cd0ba5','Native':'e9cf9cb37dd7fe181854e9909545458011ecb78c6cfb657dc4c4a758c8a13603'}
def verify():
 o=H/'delivery-v1';m=json.loads((o/'manifest.json').read_text());assert sha(Path(__file__).read_bytes())==m['verifierSHA256'] and sha((o/'REPORT.md').read_bytes())==m['reportSHA256'] and sha((o/'cohort.tar.gz').read_bytes())==m['archive']['sha256']
 for n,h in m['sources'].items():assert sha((H/n).read_bytes())==h
 with tarfile.open(o/'cohort.tar.gz') as t:
  entries=t.getmembers();assert len(entries)==len({v.name for v in entries}) and all(v.isfile() and not Path(v.name).is_absolute() and '..' not in Path(v.name).parts for v in entries);data={v.name:t.extractfile(v).read() for v in entries}
 assert set(data)==set(m['archive']['members'])
 for n,b in data.items():assert sha(b)==m['archive']['members'][n]['sha256'] and len(b)==m['archive']['members'][n]['bytes']
 for n,h in m['sources'].items():assert sha(data['source/'+n])==h
 obj=lambda n:json.loads(data[n]);assert set(m['runs'])==set(m['pinDispositions'])==set(PLANS)
 privateRoles={}
 ownerPlans=[(sha(data[label+'/plan.json']),json.loads(data[label+'/plan.json'])) for label in PLANS]
 for label in PLANS:
  for path,digest in json.loads(data[label+'/plan.json'])['pins'].items():
   if Path(path).name=='plan.json':
    disposition=m['pinDispositions'][label][path]
    assert disposition['kind']=='archive' and sha(data[disposition['member']])==digest
    ownerPlans.append((digest,json.loads(data[disposition['member']])))
 for ownerSHA,owner in ownerPlans:
  if 'environmentSHA256' in owner:
   fields=[key for key in ['environment','privateEnvironment'] if key in owner]
   assert len(fields)==1
   path=owner[fields[0]];digest=owner['environmentSHA256']
   if path in owner['pins']:assert owner['pins'][path]==digest
   else:
    # This admitted historical owner declares its private identity separately from pins.
    assert ownerSHA=='5c706c039d9d138a53f3731ae4c82d911c1ad69e27a1d8c3885324c3ee2604e5'
    assert fields==['privateEnvironment'] and Path(path).name=='private-environment.json'
    assert digest=='52d8344e4e309c2e668a904372ca8a610287c50b8fe0305d7a6ba2dc7758080e'
   if path in privateRoles:assert privateRoles[path]==digest
   privateRoles[path]=digest

 # Exact notice bytes are retrieved from their immutable archived input, never guessed.
 native=obj('Native/plan.json');originalH=Path(m['runs']['Native']['originalDirectory']).parent;noticePath=str(originalH.parent/'known-notice.txt');noticeEntry=m['pinDispositions']['Native'][noticePath];notice=data[noticeEntry['member']];assert sha(notice)=='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
 for label,planSHA in PLANS.items():
  p=obj(label+'/plan.json');d=Path(m['runs'][label]['originalDirectory']);assert sha(data[label+'/plan.json'])==planSHA==m['runs'][label]['planSHA256']
  assert {n.removeprefix(label+'/stage/'):sha(b) for n,b in data.items() if n.startswith(label+'/stage/')}==p['inventory'] and len(p['inventory'])==92
  assert set(m['pinDispositions'][label])==set(p['pins'])
  for n,h in p['pins'].items():
   x=m['pinDispositions'][label][n];assert x['sha256']==h
   if x['kind']=='archive':assert sha(data[x['member']])==h
   elif x['kind']=='installedIdentityExcluded':assert p['tools']['pins'][n]==h
   else:assert x['kind']=='privateEnvironmentIdentityExcluded' and privateRoles[n]==h
  if label=='unexecuted-repair':assert m['runs'][label]['executionCredit'] is False and label+'/receipt.json' not in data;continue
  r=obj(label+'/receipt.json');assert sha(data[label+'/receipt.json'])==RECEIPTS[label]==m['runs'][label]['receiptSHA256'] and r['planSHA256']==planSHA and not r.get('guardFailures',[])
  commands=p['commands'] if label in ['JS','Native'] else [p['command']];prefix=[p['tools']['taskset'],'-c','8'];target=Path(p['stage'])/'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/failed-batch-v1/caller.bend'
  if label=='JS':
   artifact=d/'application.js';expected=[{'label':'emit-js','argv':prefix+[p['tools']['tools']['bend'],str(target),'-o',str(artifact)],'seconds':30,'generated':str(artifact)},{'label':'consumer','argv':prefix+[p['tools']['tools']['node'],str(artifact)],'seconds':5}]
  elif label=='Native':
   c=d/'application.c';elf=d/'application-native';expected=[{'label':'emit-c','argv':prefix+[p['tools']['tools']['bend'],str(target),'-o',str(c)],'seconds':30,'generated':str(c)},{'label':'clang','argv':prefix+[p['tools']['tools']['clang_wrapper'],'-O3',str(c),'-o',str(elf),'-pthread','-lm'],'seconds':120,'generated':str(elf)},{'label':'consumer','argv':prefix+[str(elf),'--threads','1','--gpu','off'],'seconds':5}]
  else:expected=[{'label':'cleanup-source','argv':prefix+[p['tools']['tools']['bend'],str(target),'--check-only'],'seconds':5}]
  assert commands==expected and len(r['commands'])==len(expected)
  runner=p['pins'][str(d.parents[6]/'scripts/task_runner.py')]
  for c,x in zip(expected,r['commands']):assert all(x[k]==c[k] for k in ['label','argv','seconds']) and x['exit']==(0 if label in ['JS','Native'] else 1) and x['failure'] is None and x['status']=='TERMINAL' and x['runnerSHA256']==runner
  names={c['label']+suffix for c in expected for suffix in ['.stdout','.stderr']};assert set(r['logs'])==names and {n.removeprefix(label+'/') for n in data if n.startswith(label+'/') and '/' not in n.removeprefix(label+'/') and n.endswith(('.stdout','.stderr'))}==names
  for n,h in r['logs'].items():assert sha(data[label+'/'+n])==h
  if label not in ['JS','Native']:
   assert r['status']=='FAILED_BATCH_CLEANUP_SOURCE_RAW_COLLECTED_NO_TYPING_OR_RUNTIME_CREDIT' and data[label+'/cleanup-source.stdout']==b'' and r['diagnosticClassification']=='RAW_UNCLASSIFIED_PENDING_FULL_INDEPENDENT_REVIEW';continue
  assert r['status']=='COMPLETE_FAILED_BATCH_CLEANUP_'+label.upper()+'32_WORLD16_INSTANCE_PASS_NO_ISSUE_CLOSURE' and r['completeWorldRows']==32 and r['completeInstanceRecords']==16
  generated={c['generated'] for c in expected if 'generated' in c};assert set(r['generated'])==set(m['generatedDispositions'][label])==generated
  for n,h in r['generated'].items():
   x=m['generatedDispositions'][label][n];assert x['sha256']==h
   if Path(n).name=='application-native':assert x['kind']=='generatedELFIdentityExcluded' and x['bytes']>0
   else:assert x['kind']=='archive' and sha(data[x['member']])==h
  emission='emit-js' if label=='JS' else 'emit-c';assert data[label+'/'+emission+'.stdout']==data[label+'/consumer.stderr']==b'' and data[label+'/'+emission+'.stderr'] in [b'',notice]
  if label=='Native':assert data[label+'/clang.stdout']==data[label+'/clang.stderr']==b''
  tools=[n for n in p['tools']['tools'] if n not in p['tools']['skip_ldd']];labels=['guard-'+str(i)+'-ldd-'+n for i in range(5 if label=='JS' else 7) for n in tools];assert len(tools)==7 and p['executionProbeLabels']==labels and p['expectedProbeCount']==r['probeCommandsExecuted']==len(labels)
  names={n+suffix for n in labels for suffix in ['.json','.stdout','.stderr']};assert {n.removeprefix(label+'/execution-probes/') for n in data if n.startswith(label+'/execution-probes/')}==names and set(r['probePins'])=={str(d/'execution-probes'/n) for n in names}
  for n,h in r['probePins'].items():assert sha(data[label+'/execution-probes/'+Path(n).name])==h
  for n in labels:
   x=obj(label+'/execution-probes/'+n+'.json');tool=n.split('-ldd-',1)[1];assert x['argv']==prefix+[p['tools']['ldd'],p['tools']['tools'][tool]] and x['seconds']==5 and x['exit']==0 and x['failure'] is None and x['exception'] is None and x['runnerSHA256']==runner
 for n,h in m['sources'].items():
  assert native['pins'][str(originalH/n)]==h
  if n!='run-native.py':assert obj('JS/plan.json')['pins'][str(originalH/n)]==h
 for label in ['JS','Native','effect-boundary','unexecuted-repair']:
  for n in ['caller.bend','caller-core.bend']:assert data[label+'/stage/experiments/public-machines/followup/stream-opt/cleanup-controls-v1/failed-batch-v1/'+n]==data['source/'+n]
 classification=obj('source/source-classification.json');assert classification['planSHA256']==PLANS['effect-boundary'] and classification['receiptSHA256']==RECEIPTS['effect-boundary'] and classification['stderrSHA256']==sha(data['effect-boundary/cleanup-source.stderr'])=='607556a2b69ba1750877198242ed267c204cc7fc3e97b4419f3e68f6f6c8b67e'
 repair=obj('source/source-proposal.json')['developmentRepair'];old=data['failed-syntax/stage/experiments/public-machines/followup/stream-opt/cleanup-controls-v1/failed-batch-v1/caller-core.bend'];assert sha(old)==repair['oldSHA256'] and old.decode().count('case F.Observed{ao,aw,ar} (survivor,view):')==2 and old.decode().replace('case F.Observed{ao,aw,ar} (survivor,view):','case F.Observed{ao,aw,ar}, (survivor,view):').encode()==data['source/caller-core.bend']
 names=['experiments/public-machines/followup/foreign-model.py','experiments/public-machines/followup/skip-model.py','experiments/public-machines/full-model.py','experiments/public-machines/expected.json','experiments/public-machines/followup/evidence/primary-ts-v1/expected.json.gz'];assert {n.removeprefix('model-root/') for n in data if n.startswith('model-root/')}==set(names)
 for n in names:assert sha(data['model-root/'+n])==native['pins']['/workspace/formal-proofs/bendvy/'+n]
 with tempfile.TemporaryDirectory(prefix='failed-batch-archived-model-') as directory:
  root=Path(directory)
  for n in names:p=root/n;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(data['model-root/'+n])
  caller=root/'caller';caller.mkdir();s=data['source/model.py'].decode();literal="ROOT=Path('/workspace/formal-proofs/bendvy')";assert s.count(literal)==1;(caller/'model.py').write_text(s.replace(literal,'ROOT=Path('+repr(str(root))+')'))
  for n in ['expected.json','validate.py']:(caller/n).write_bytes(data['source/'+n])
  spec=importlib.util.spec_from_file_location('failed_batch_archived_complete',caller/'validate.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
  for label in ['JS','Native']:v.validate(data[label+'/consumer.stdout'])
 print('PORTABLE_FAILED_BATCH_CLEANUP_FULL32_WORLD16_INSTANCE_JS_NATIVE_AND_HISTORY_PASS_NO_ISSUE_CLOSURE')
if __name__=='__main__':verify()
