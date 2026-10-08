"""Portable archived-only cleanup JS qualification; no child processes."""
import hashlib, importlib.util, json, tarfile, tempfile
from pathlib import Path
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
PLANS={'failed-quantity':'6523063fdbba8ee9542e6ee5e7a46d1d15e6b5410f653b555067ed17b3c7db14','effect-boundary':'c8617c946654c495cca8d632e259dcbabf650a3c8d78f61ba110358484e9407e','JS':'f12eb6ba15cec9cfcb529bb5a9dc6431ab7497f2725f707a113fcc5779c74cb8'}
RECEIPTS={'effect-boundary':'0f4fa082740968eb06a47cb4c6b27a20741f0c49d856f8f31e1866bb20511199','JS':'5f7d341400316b5358582067042596dab207b86724996644e5d6fe231cac64fa'}
def verify():
 o=H/'delivery-js-v1';m=json.loads((o/'manifest.json').read_text());assert sha(Path(__file__).read_bytes())==m['verifierSHA256'] and sha((o/'REPORT.md').read_bytes())==m['reportSHA256']
 for n,digest in m['sources'].items():assert sha((H/n).read_bytes())==digest
 assert sha((o/'cohort.tar.gz').read_bytes())==m['archive']['sha256']
 with tarfile.open(o/'cohort.tar.gz') as t:
  members=t.getmembers();assert len(members)==len({v.name for v in members}) and all(v.isfile() and not Path(v.name).is_absolute() and '..' not in Path(v.name).parts for v in members)
  data={v.name:t.extractfile(v).read() for v in members}
 assert set(data)==set(m['archive']['members'])
 for n,b in data.items():assert sha(b)==m['archive']['members'][n]['sha256'] and len(b)==m['archive']['members'][n]['bytes']
 for n,digest in m['sources'].items():assert sha(data['source/'+n])==digest
 obj=lambda n:json.loads(data[n]);assert set(m['runs'])==set(PLANS)
 for label,digest in PLANS.items():
  p=obj(label+'/plan.json');r=obj(label+'/receipt.json');assert sha(data[label+'/plan.json'])==digest==r['planSHA256']==m['runs'][label]['planSHA256']
  assert sha(data[label+'/receipt.json'])==m['runs'][label]['receiptSHA256'] and not r.get('guardFailures',[])
  if label in RECEIPTS:assert sha(data[label+'/receipt.json'])==RECEIPTS[label]
  assert {n.removeprefix(label+'/stage/'):sha(b) for n,b in data.items() if n.startswith(label+'/stage/')}==p['inventory'] and len(p['inventory'])==90
  dispositions=m['pinDispositions'][label];assert set(dispositions)==set(p['pins'])
  for path,digest in p['pins'].items():
   e=dispositions[path];assert e['sha256']==digest
   if e['kind']=='archive':assert sha(data[e['member']])==digest
   elif e['kind']=='installedIdentityExcluded':assert p['tools']['pins'][path]==digest
   else:assert e['kind']=='privateEnvironmentIdentityExcluded' and Path(path).name.endswith('.private.json') and digest==p['environmentSHA256']
  commands=p['commands'] if label=='JS' else [p['command']];assert len(commands)==len(r['commands'])==(2 if label=='JS' else 1)
  for c,x in zip(commands,r['commands']):
   assert x['label']==c['label'] and x['argv']==c['argv'] and x['seconds']==c['seconds'] and x['failure'] is None and x['status']=='TERMINAL'
   assert x['argv'][:3]==['/usr/bin/taskset','-c','8'] and x['runnerSHA256']==p['pins'][str(Path(m['runs'][label]['originalDirectory']).parents[5]/'scripts/task_runner.py')]
   assert x['exit']==(0 if label=='JS' else 1)
  names={c['label']+suffix for c in commands for suffix in ['.stdout','.stderr']};assert set(r['logs'])==names
  assert {n.removeprefix(label+'/') for n in data if n.startswith(label+'/') and '/' not in n.removeprefix(label+'/') and n.endswith(('.stdout','.stderr'))}==names
  for n,digest in r['logs'].items():assert sha(data[label+'/'+n])==digest
  if label!='JS':
   assert r['status']=='INCOMPLETE' and commands[0]['seconds']==5 and commands[0]['argv'][-1]=='--check-only' and data[label+'/cleanup-source.stdout']==b''
  else:
   assert r['status']=='COMPLETE_TWO_SCHEMA_FOREIGN_DISPOSAL_RETRY_SURVIVOR_JS_PASS_NO_ISSUE_CLOSURE' and r['completeWorldRows']==36 and r['completeInstanceRecords']==22
   target=Path(p['stage'])/'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/caller.bend';artifact=Path(m['runs'][label]['originalDirectory'])/'application.js';prefix=[p['tools']['taskset'],'-c','8']
   assert commands==[{'label':'emit-js','argv':prefix+[p['tools']['tools']['bend'],str(target),'-o',str(artifact)],'seconds':30,'generated':str(artifact)},{'label':'consumer','argv':prefix+[p['tools']['tools']['node'],str(artifact)],'seconds':5}]
   assert r['generated']=={str(artifact):sha(data['JS/generated/application.js'])}
   assert data['JS/emit-js.stdout']==data['JS/consumer.stderr']==b'' and data['JS/emit-js.stderr'] in [b'',data['source/known-notice.txt']]
   tools=[n for n in p['tools']['tools'] if n not in p['tools']['skip_ldd']];labels=['guard-'+str(i)+'-ldd-'+n for i in range(5) for n in tools]
   assert len(tools)==7 and p['executionProbeLabels']==labels and p['expectedProbeCount']==r['probeCommandsExecuted']==35
   probeNames={n+suffix for n in labels for suffix in ['.json','.stdout','.stderr']};assert {n.removeprefix('JS/execution-probes/') for n in data if n.startswith('JS/execution-probes/')}==probeNames
   assert set(r['probePins'])=={str(artifact.parent/'execution-probes'/n) for n in probeNames}
   for path,digest in r['probePins'].items():assert sha(data['JS/execution-probes/'+Path(path).name])==digest
   for n in labels:
    x=obj('JS/execution-probes/'+n+'.json');tool=n.split('-ldd-',1)[1]
    assert x['argv']==prefix+[p['tools']['ldd'],p['tools']['tools'][tool]] and x['seconds']==5 and x['exit']==0 and x['failure'] is None and x['exception'] is None and x['runnerSHA256']==r['commands'][0]['runnerSHA256']
   for name in ['caller.bend','caller-core.bend']:assert data['JS/stage/experiments/public-machines/followup/stream-opt/cleanup-controls-v1/'+name]==data['source/'+name]
 assert sha(data['failed-quantity/cleanup-source.stderr'])=='5864315c949b03ad0961a32be88604003b467cfab618203e4f6e609ff60de75e'
 assert sha(data['effect-boundary/cleanup-source.stderr'])=='868d786993c068cbabfbf08a6e010acd658835fed5352da8f5617803b19c72a9'
 classification=obj('source/source-classification.json');assert classification['stderrSHA256']==sha(data['effect-boundary/cleanup-source.stderr']) and classification['receiptSHA256']==RECEIPTS['effect-boundary']
 js=obj('JS/plan.json')
 originalH=Path(m['runs']['JS']['originalDirectory']).parent
 for n,digest in m['sources'].items():assert digest==js['pins'][str(originalH/n)]==sha(data['source/'+n])
 assert sha(data['source/known-notice.txt'])=='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
 modelNames=['experiments/public-machines/followup/foreign-model.py','experiments/public-machines/followup/skip-model.py','experiments/public-machines/full-model.py','experiments/public-machines/expected.json','experiments/public-machines/followup/evidence/primary-ts-v1/expected.json.gz']
 assert {n.removeprefix('model-root/') for n in data if n.startswith('model-root/')}==set(modelNames)
 for n in modelNames:assert sha(data['model-root/'+n])==js['pins']['/workspace/formal-proofs/bendvy/'+n]
 with tempfile.TemporaryDirectory(prefix='cleanup-archived-model-') as directory:
  root=Path(directory)
  for n,b in data.items():
   if n.startswith('model-root/'):
    p=root/n.removeprefix('model-root/');p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(b)
  caller=root/'caller';caller.mkdir();text=data['source/model.py'].decode();literal="ROOT = Path('/workspace/formal-proofs/bendvy')";assert text.count(literal)==1
  (caller/'model.py').write_text(text.replace(literal,'ROOT = Path('+repr(str(root))+')'))
  for n in ['expected.json','validate.py']:(caller/n).write_bytes(data['source/'+n])
  spec=importlib.util.spec_from_file_location('portable_cleanup_complete',caller/'validate.py');model=importlib.util.module_from_spec(spec);spec.loader.exec_module(model);model.validate(data['JS/consumer.stdout'])
 print('PORTABLE_COMPLETE_CLEANUP_JS36_WORLD22_INSTANCE_ORACLE_AND_HISTORY_PASS_NO_ISSUE_CLOSURE')
if __name__=='__main__':verify()
