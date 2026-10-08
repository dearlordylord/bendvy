"""Portable finite actual-callsite evidence; no backend or current resolver execution."""
import hashlib,importlib.util,json,tarfile,tempfile
from pathlib import Path
V=Path(__file__).resolve().parent;H=V.parent;D=V/'delivery-js-v1'
sha=lambda b:hashlib.sha256(b).hexdigest()
canonical=lambda x:json.dumps(x,sort_keys=True,separators=(',',':'))
m=json.loads((D/'manifest.json').read_text());assert sha((D/'cohort.tar.gz').read_bytes())==m['archive']['sha256'];assert sha((D/'REPORT.md').read_bytes())==m['reportSHA256']
with tarfile.open(D/'cohort.tar.gz') as t:
 es=t.getmembers();ns=[e.name for e in es];assert len(ns)==len(set(ns)) and set(ns)==set(m['archive']['members'])
 assert all(e.isfile() and not Path(e.name).is_absolute() and '..' not in Path(e.name).parts for e in es)
 data={e.name:t.extractfile(e).read() for e in es}
for n,e in m['archive']['members'].items():assert len(data[n])==e['bytes'] and sha(data[n])==e['sha256']
for n,s in m['sources'].items():assert sha((H/n).read_bytes())==sha(data['source/'+n])==s
ADMITTED={'full-source': ('ad5ccd1e38f56824b66112f80a9d5f2f4eb5e663043ad43a84895ab9f43a5265', 'df89c932ddc0ffa3a6708d78017eb123cef8a3198225db92fcd5eee1579cb021'), 'named-source': ('3d4dcdc27dd8b7100c07632fe47d3b8b92c5c0475015fe75a07c43a1f5552b64', '4354d217e1b718c8afdcdba1e96464fcaa2d057aa6a6c2717e099091a40c32bb'), 'old-mutant-source': ('d4b72575513fa0412e0fdee30459dc00c42d5b51b1d693f97384898a38adb486', 'fe56431d04fc4fd552411121c7855ba7279a30de303a607cc53826c56678d81c'), 'mutant-source': ('a63315f310c1588c54dddf0dd4daab65015ce8b9891e64eab5a1fc66498b2a5d', 'be2e4a741439e8dbae4006d0e22897fe3be89412939afe04365f20d149d93541'), 'post-JS': ('9275c0a7806305441bf164f2c9182202d63de46fc512a30e1c84c4d8fd6cd542', '21626d9e62314f31e27707dcc69dbb9cef4c8f550ffa0123f08364f2aaa8a1b3'), 'failed-JS': ('5163c40ea803a9d8e642e40b4ca62ff9cbbcc408e1decf0c1de83eb9cef6f201', '8590c4c2c73e3ffb18166b8efe19ffa3804a66f4917b73255ce81dd8d406d8c9'), 'post-mutant-JS': ('d2bdebe2ed13891e430b4bb260e9832ab156428be9f642969ccbaa30ec53fcc8', '557985ee02e1e1635e186378fe6b8766500fe9c225d0f56535c4d0531018e512'), 'failed-mutant-JS': ('e813e1ba12bdfe0355d52fa721f183912d1724cdcdd77599993009050e8b9182', 'f789c0cbbd061f148e4d92f1a2ead1ee345428787a7fbfdd1afe3d58a4686ec3')}

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
 assert len(stage)==(108 if label=='full-source' else 109)
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
  assert r['status']==('ACTUAL_ADAPTER_ACCEPTED_CLOCK_MUTANT_'+scenario+'_FULL_JS_VARIANT_ORACLE_AND_BOTH_SCHEMA_WITNESSES_PASS_NO_NATIVE_ADOPTION' if 'mutant' in label else 'COMPLETE_GENERIC_CLEANUP_'+scenario+'_FULL_JS_ORACLE_PASS_NO_ISSUE_CLOSURE')
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
  if label=='full-source':assert len(p['commands'])==2 and len(r['commands'])==1 and r['status']=='INCOMPLETE' and r['commands'][0]['exit'] is None and r['commands'][0]['failure']=='child deadline' and data[label+'/source-0.stdout']==data[label+'/source-0.stderr']==b''
  else:
   assert len(p['commands'])==len(r['commands'])==1 and r['commands'][0]['failure'] is None
   assert r['status']==('ISOLATED_EXACT_NAMED_BRIDGE_SOURCE_RAW_COLLECTED_NO_FULL_SOURCE_RUNTIME_PROOF_ACCEPTANCE' if label=='named-source' else 'MATCHED_ACTUAL_ADAPTER_CLOCK_MUTANT_NAMED_BRIDGE_RAW_COLLECTED_NO_FULL_SOURCE_RUNTIME_PROOF_ACCEPTANCE')
   if label=='old-mutant-source':assert r['commands'][0]['exit']==1 and sha(data[label+'/source-0.stderr'])=='03868dc704f17f39230909a3c65086c1f46e5ca707591c54b7bb99809d8715dc'
   else:assert r['commands'][0]['exit']==0 and data[label+'/source-0.stdout']==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n' and data[label+'/source-0.stderr']==b''
assert private==m['privateOwnerRoles']
for label,p in plans.items():
 for n,e in m['pinDispositions'][label].items():
  if e['kind']=='privateEnvironmentIdentityExcluded':assert private[n]==e['sha256']
# Bind public dependencies and the actual called bridge, not an unused staged module.
rootrel='experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/'
core='experiments/public-machines/followup/stream-opt/cleanup-controls-v1/caller-core.bend'
joins=json.loads(data['source/current-core-joins.json']);assert len(joins['files'])==8
for label,p in plans.items():
 for original,e in joins['files'].items():
  assert p['pins'][original]==p['pins'][e['copy']]==e['sha256']==p['inventory'][e['copy']]==sha(data[label+'/stage/'+e['copy']])
for label,p in plans.items():
 if not label.endswith('JS'):continue
 bridge=data[label+'/stage/'+core].decode();assert 'GC.cleanup' in bridge and 'Ports.Two' in bridge
 for n in ['adapter.bend','ports.bend']:
  rel=rootrel+n;expected='source/consumed-integration-v2/mutation-clock-v2/adapter.bend' if n=='adapter.bend' and 'mutant' in label else 'source/'+n
  assert data[label+'/stage/'+rel]==data[expected]
for n,s in m['sources'].items():
 if n.endswith('source-classification.json'):continue
 assert any(p['pins'].get(m['originalSourceRoot']+'/'+n)==s for p in plans.values()),n
for a,b in [('post-JS','post-mutant-JS'),('failed-JS','failed-mutant-JS')]:
 assert set(plans[a]['inventory'])==set(plans[b]['inventory'])
 assert [n for n in plans[a]['inventory'] if plans[a]['inventory'][n]!=plans[b]['inventory'][n]]==[rootrel+'adapter.bend']
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
print('PORTABLE_ACTUAL_CLEANUP_NORMAL_AND_REACHED_JS_FULL_ORACLES_PASS')
