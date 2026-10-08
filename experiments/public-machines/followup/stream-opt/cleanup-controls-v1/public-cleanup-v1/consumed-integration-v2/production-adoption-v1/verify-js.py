"""Portable finite actual-callsite evidence; no backend or current resolver execution."""
import hashlib,importlib.util,json,tarfile,tempfile
from pathlib import Path
P=Path(__file__).resolve().parent;H=P.parent.parent;D=P/'delivery-js-v1'
sha=lambda b:hashlib.sha256(b).hexdigest()
# Exact reviewed selection convention: all delivered files except selection itself;
# the selection is the independently reviewed additive manifest, not self-hashed.
R=H.parents[5]
selection=json.loads((D/'selection.json').read_text())
SELECTED={'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/system-instance.bend', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/api-controls-v1/stage/experiments/public-machines/positive-owner.bend', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/delivery-js-v1/cohort.tar.gz', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/stage-v3-inventory.json', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/api-controls-v1/stage/experiments/public-machines/negative-owner-duplicate.bend', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/run-js.py', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/api-controls-v1/stage/experiments/public-machines/negative-cross-schema.bend', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/caller-source-joins.json', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/PROPOSAL.md', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/FACTORY-IMPLEMENTATION.md', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/source-joins.json', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/verify-js.py', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/system-cleanup.bend', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/delivery-js-v1/manifest.json', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/reader-cleanup-ports.bend', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/full-scene-source-proposal.json', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/system-instance-before-computed-scrutinee-repair.bend', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/run-source-before-computed-scrutinee-repair.py', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/delivery-js-v1/REPORT.md', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/api-controls-v1/proposal.json', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/run-mutant-js.py', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/FACTORY-BINDING.md', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/factory-caller.bend', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/stage-inventory-before-computed-scrutinee-repair.json', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/reader-factory.bend', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/mutation-clock-v1/proposal.json'}
PREREQUISITES={'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/model-root/experiments/public-machines/followup/evidence/primary-ts-v1/expected.json.gz', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/model-root/experiments/public-machines/followup/foreign-model.py', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/mutation-clock-v2/models/failed-batch/validate.py', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/models/failed-batch/validate.py', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/models/post-consumption/expected.json', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/mutation-clock-v2/models/post-consumption/expected.json', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/mutation-clock-v2/models/post-consumption/validate.py', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/models/failed-batch/model.py', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/models/failed-batch/expected.json', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/models/post-consumption/model.py', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/model-root/experiments/public-machines/full-model.py', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/model-root/experiments/public-machines/expected.json', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/mutation-clock-v2/models/post-consumption/model.py', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/model-root/experiments/public-machines/followup/skip-model.py', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/models/post-consumption/validate.py', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/mutation-clock-v2/models/failed-batch/expected.json', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/mutation-clock-v2/models/failed-batch/model.py', 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/mutation-clock-v2/model.py'}
assert set(selection['files'])==SELECTED and set(selection['prerequisites'])==PREREQUISITES
assert str((D/'selection.json').relative_to(R)) not in SELECTED
for group in ['files','prerequisites']:
 for n,digest in selection[group].items():
  assert not Path(n).is_absolute() and '..' not in Path(n).parts
  assert sha((R/n).read_bytes())==digest,n
canonical=lambda x:json.dumps(x,sort_keys=True,separators=(',',':'))
m=json.loads((D/'manifest.json').read_text());assert sha((D/'cohort.tar.gz').read_bytes())==m['archive']['sha256'];assert sha((D/'REPORT.md').read_bytes())==m['reportSHA256']
with tarfile.open(D/'cohort.tar.gz') as t:
 es=t.getmembers();ns=[e.name for e in es];assert len(ns)==len(set(ns)) and set(ns)==set(m['archive']['members'])
 assert all(e.isfile() and not Path(e.name).is_absolute() and '..' not in Path(e.name).parts for e in es)
 data={e.name:t.extractfile(e).read() for e in es}
for n,e in m['archive']['members'].items():assert len(data[n])==e['bytes'] and sha(data[n])==e['sha256']
normalized='consumed-integration-v2/production-adoption-v1/reader-cleanup-ports.bend'
assert m['sourceNormalizations']=={normalized:{'executedSHA256':'06a6c7bd5dc2ca8789fdc29c9364531f245c2eb0df3ede64547fca2c8e5db27d','selectedSHA256':'0d0fe43f328e1a8650cddef5c0c8fe52652c6e4abce9875399908a0187b11052','removedFinalLFCount':1}}
for n,s in m['sources'].items():
 b=(H/n).read_bytes();assert sha(data['source/'+n])==s
 if n==normalized:assert sha(b)==m['sourceNormalizations'][n]['selectedSHA256'] and data['source/'+n]==b+b'\n'
 else:assert sha(b)==s
ADMITTED={'initial-source': ('e475ff21995438795092df44b7533c111cdc53947290c36434d6b38082dbe69b', 'fd0ba585f74678ae68801990b30510a29d1c4d433ed2157e89fbec0870a0f245'), 'post-JS': ('5deeab1afee75d5e051c4594d4569b35116421d2c7773ddf52b6ea273ef33007', '19930cb274868ee05b7c6baac9b6c86778bfcd9d31149f117568ade2618f3d6e'), 'failed-JS': ('7b15329369010764567c1cdb2738a235e8f709aae711df84544eacf923a87f1d', '3daee4a0c80d2b6eebe2fc480b0fb0af7bb6ffb783c1dce2031c0a0c2216317e'), 'post-mutant-JS': ('413b8e1749bb80bb4427eeae8ce07f7c3cb2b8e429e3366d7fa35d15fd646def', '1523b86838e14ef798eeb4e2d7d92873832e5bffb8dd45ff2cf256330988f09d'), 'failed-mutant-JS': ('f9da8e527c183e051437004c034019e5efc1e7f6dfa827f16794e27fad385af0', '50a998c1ddf6a53b232b66148b6d84ec22f8c83f7b0d2054567916465868aef9')}

assert set(m['runs'])==set(ADMITTED)
plans={};receipts={};private={};outputs={}
runner='f6e3e815ede2d24dc80825f156ace534956d2f61ef559a09253bf97504e746b7'
notice='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
for label,(ps,rs) in ADMITTED.items():
 assert sha(data[label+'/plan.json'])==m['runs'][label]['planSHA256']==ps and sha(data[label+'/receipt.json'])==m['runs'][label]['receiptSHA256']==rs
 p=json.loads(data[label+'/plan.json']);r=json.loads(data[label+'/receipt.json']);plans[label]=p;receipts[label]=r
 assert r['planSHA256']==ps and not r.get('guardFailures',[])
 private[p['environment']]=p['environmentSHA256']
 pref=label+'/stage/';stage={n[len(pref):]:sha(b) for n,b in data.items() if n.startswith(pref)};assert stage==p['inventory']
 assert len(stage)==(113 if label=='initial-source' else 114)
 assert set(m['pinDispositions'][label])==set(p['pins'])
 for n,s in p['pins'].items():
  e=m['pinDispositions'][label][n];assert e['sha256']==s
  if e['kind']=='archive':
   assert sha(data[e['member']])==s
   if n.endswith('/plan.json'):
    q=json.loads(data[e['member']])
    for f in ['environment','privateEnvironment']:
     if f in q:private[q[f]]=q['environmentSHA256']
  elif e['kind']=='installedIdentityExcluded':assert p['tools']['pins'][n]==s
  else:assert e['kind']=='privateEnvironmentIdentityExcluded'
 assert p['tools']['cpu']==8 and any(n.endswith('/scripts/task_runner.py') and s==runner for n,s in p['pins'].items())
 for c in p['commands']:
  assert c['argv'][:4]==[p['tools']['taskset'],'-c','8',p['tools']['tools']['bend']] if c['label']!='consumer' else c['argv'][:4]==[p['tools']['taskset'],'-c','8',p['tools']['tools']['node']]
  if c['label']!='consumer':
   rel=str(Path(c['argv'][4]).relative_to(Path(p['stage'])));assert rel in stage and sha(data[pref+rel])==stage[rel]
 for c,a in zip(p['commands'],r['commands']):
  assert all(a[k]==c[k] for k in ['label','argv','seconds']) and a['runnerSHA256']==runner and a['capture']=='split'
 lognames={a['label']+s for a in r['commands'] for s in ['.stdout','.stderr']};assert set(r['logs'])==lognames
 assert {n[len(label)+1:] for n in data if n.startswith(label+'/') and '/' not in n[len(label)+1:] and n not in [label+'/plan.json',label+'/receipt.json']}==lognames
 for n,s in r['logs'].items():assert sha(data[label+'/'+n])==s
 if label.endswith('JS'):
  assert len(p['commands'])==len(r['commands'])==2 and [c['label'] for c in p['commands']]==['emit-js','consumer'] and [c['seconds'] for c in p['commands']]==[30,5]
  assert all(a['exit']==0 and a['failure'] is None for a in r['commands'])
  scenario='POST_CONSUMPTION' if label.startswith('post') else 'FAILED_BATCH'
  assert r['status']==('REACHED_ORDINARY_FACTORY_KERNEL_CLOCK_CONTROL_'+scenario+'_FULL_JS_ORACLE_PASS_NO_ISSUE_CLOSURE' if 'mutant' in label else 'COMPLETE_ORDINARY_FACTORY_CLEANUP_'+scenario+'_FULL_JS_ORACLE_PASS_NO_ISSUE_CLOSURE')
  artifact=p['commands'][0]['generated'];assert p['commands'][0]['argv'][5:]==['-o',artifact] and p['commands'][1]['argv'][4:]==[artifact]
  assert set(r['generated'])==set(m['generatedDispositions'][label])=={artifact}
  assert {n for n in data if n.startswith(label+'/generated/')}=={e['member'] for e in m['generatedDispositions'][label].values()}
  for n,s in r['generated'].items():e=m['generatedDispositions'][label][n];assert e['sha256']==sha(data[e['member']])==s
  active=[k for k in p['tools']['tools'] if k not in p['tools']['skip_ldd']];labels=['guard-'+str(i)+'-ldd-'+k for i in range(5) for k in active]
  assert p['executionProbeLabels']==labels and p['expectedProbeCount']==r['probeCommandsExecuted']==len(labels)==35
  members={n+s for n in labels for s in ['.json','.stdout','.stderr']};pre=label+'/execution-probes/';orig=m['runs'][label]['originalDirectory']+'/execution-probes/'
  assert set(r['probePins'])=={orig+n for n in members} and {n[len(pre):] for n in data if n.startswith(pre)}==members
  for n in members:assert sha(data[pre+n])==r['probePins'][orig+n]
  for n in labels:
   q=json.loads(data[pre+n+'.json']);key=n.split('-ldd-',1)[1];assert q['argv']==[p['tools']['taskset'],'-c','8',p['tools']['ldd'],p['tools']['tools'][key]] and q['seconds']==5 and q['exit']==0 and q['failure'] is None and q['exception'] is None and q['runnerSHA256']==runner
  assert data[label+'/emit-js.stdout']==b'' and (data[label+'/emit-js.stderr']==b'' or sha(data[label+'/emit-js.stderr'])==notice) and data[label+'/consumer.stderr']==b''
  outputs[label]=data[label+'/consumer.stdout']
 else:
  assert all(c['seconds']==5 and c['argv'][5:]==['--check-only'] for c in p['commands']) and not r.get('generated',{}) and not r.get('probePins',{})
  assert label=='initial-source' and len(p['commands'])==len(r['commands'])==1 and r['commands'][0]['exit']==1 and r['commands'][0]['failure'] is None
  assert r['status']=='NAMED_ORDINARY_FACTORY_SOURCE_RAW_COLLECTED_NO_FULL_SCENE_RUNTIME_ACCEPTANCE' and data[label+'/'+r['commands'][0]['label']+'.stdout']==b''
  assert sha(data[label+'/'+r['commands'][0]['label']+'.stderr'])=='1c460ad895d9b19bccfe920c8c590fa1bfd3ad51ffef1c5f51ec11e2a23e3c1e'

assert private==m['privateOwnerRoles']
for label,p in plans.items():
 for n,e in m['pinDispositions'][label].items():
  if e['kind']=='privateEnvironmentIdentityExcluded':assert private[n]==e['sha256']
# Bind actually consumed public kernel/factory/managed sources to each delivered stage.
relative='consumed-integration-v2/production-adoption-v1/'
corebase='experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/'
sourcepaths={'system-cleanup.bend':corebase+'system-cleanup.bend','system-instance.bend':corebase+'system-instance.bend','reader-factory.bend':'experiments/public-machines/reader-factory.bend','reader-cleanup-ports.bend':'experiments/public-machines/reader-cleanup-ports.bend','factory-caller.bend':'experiments/public-machines/factory-caller.bend'}
for label,p in plans.items():
 if not label.endswith('JS'):continue
 for n,target in sourcepaths.items():
  if n=='system-cleanup.bend' and 'mutant' in label:
   assert sha(data[label+'/stage/'+target])=='28311a165b1004b11558af662da1ecc36de15f7a1c79e5d1e9d1abcd660057f4'
  else:assert data[label+'/stage/'+target]==data['source/'+relative+n]
 bridge=data[label+'/stage/experiments/public-machines/followup/stream-opt/cleanup-controls-v1/caller-core.bend'].decode()
 assert 'Factory.dispose_owned' in bridge and 'Factory.provision' in bridge and 'Factory.invoke_owned' in bridge
 factory=data[label+'/stage/'+sourcepaths['reader-factory.bend']].decode()
 assert 'Managed.dispose' in factory and 'Managed.register' in factory and 'Managed.run' in factory
 for a,b in [('post-JS','post-mutant-JS'),('failed-JS','failed-mutant-JS')]:
  assert set(plans[a]['inventory'])==set(plans[b]['inventory'])
  assert [n for n in plans[a]['inventory'] if plans[a]['inventory'][n]!=plans[b]['inventory'][n]]==[corebase+'system-cleanup.bend']
# Direct API development remains inconclusive, never classified by exit alone.
if 'api-development/results.json' in data:
 q=json.loads(data['api-development/results.json']);assert len(q)==3
 assert [Path(x['source']).stem for x in q]==['positive-owner','negative-owner-duplicate','negative-cross-schema']
 for x in q:
  n=Path(x['source']).stem;assert x['exit']==-9
  assert data['api-development/'+n+'.stdout']==data['api-development/'+n+'.stderr']==b''
  assert sha(data['api-source/'+n+'.bend'])==x['sourceSHA256']
  assert data['api-source/'+n+'.bend']==(P/'api-controls-v1/stage/experiments/public-machines'/(n+'.bend')).read_bytes()
# Rebuild only independently authored model files; all output fields are compared.
with tempfile.TemporaryDirectory() as tmp:
 h=Path(tmp)/'public-cleanup-v1'
 for n,b in data.items():
  if n.startswith('source/'):
   f=h/n[7:];f.parent.mkdir(parents=True,exist_ok=True);f.write_bytes(b)
 for scenario,normal,mutant in [('post-consumption','post-JS','post-mutant-JS'),('failed-batch','failed-JS','failed-mutant-JS')]:
  results=[]
  for path,label in [(h/'models'/scenario/'validate.py',normal),(h/'consumed-integration-v2/mutation-clock-v2/models'/scenario/'validate.py',mutant)]:
   spec=importlib.util.spec_from_file_location('v_'+label.replace('-','_'),path);mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod);results.append(mod.validate(outputs[label]))
  assert canonical(results[0])!=canonical(results[1])
  def diffs(a,b,path=()):
   if isinstance(a,dict):
    assert set(a)==set(b);return sum((diffs(a[k],b[k],path+(k,)) for k in a),[])
   if isinstance(a,list):
    assert len(a)==len(b);return sum((diffs(x,y,path+(i,)) for i,(x,y) in enumerate(zip(a,b))),[])
   return [] if canonical(a)==canonical(b) else [(path,a,b)]
  ds=diffs(*results);assert len(ds)==6 and all(p[-1]=='componentClock' and int(b)-int(a) in [1,2] for p,a,b in ds)
print('PORTABLE_ORDINARY_FACTORY_NORMAL_AND_REACHED_JS_FULL_ORACLES_PASS_NO_NATIVE_ADOPTION')
