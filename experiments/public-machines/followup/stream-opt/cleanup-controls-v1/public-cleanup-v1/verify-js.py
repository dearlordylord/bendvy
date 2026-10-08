"""Portable archived source/JS joins; no compiler, runtime, or current resolver check."""
import hashlib,importlib.util,json,tarfile,tempfile
from pathlib import Path
H=Path(__file__).resolve().parent;D=H/'delivery-js-v1'
sha=lambda b:hashlib.sha256(b).hexdigest()
def canonical(v):return json.dumps(v,sort_keys=True,separators=(',',':'))
m=json.loads((D/'manifest.json').read_text());assert sha((D/'cohort.tar.gz').read_bytes())==m['archive']['sha256'];assert sha((D/'REPORT.md').read_bytes())==m['reportSHA256']
with tarfile.open(D/'cohort.tar.gz') as t:
 entries=t.getmembers();names=[x.name for x in entries]
 assert len(names)==len(set(names)) and set(names)==set(m['archive']['members'])
 assert all(x.isfile() and not Path(x.name).is_absolute() and '..' not in Path(x.name).parts for x in entries)
 data={x.name:t.extractfile(x).read() for x in entries}
for n,v in m['archive']['members'].items():assert sha(data[n])==v['sha256'] and len(data[n])==v['bytes']
for n,v in m['sources'].items():assert sha((H/n).read_bytes())==sha(data['source/'+n])==v
admitted={
 'source-eight':('8c0a68c369d5b1a8cfbb61c8471f32c07466a38812a1fbf4f850b145cbfc227e','73aca2007556b170afafcc547f3cce21359384507bb5e3b17063b6da2ab7f9e1',8,108),
 'import-failure':('b51e3e7f01d2242e332d8da89086fe88ec60a97caf1b9d572bc4defe750ba760','110d10a057afc5373b0a8ea45b32ada96b0a297807922fcb56d323c768e8de4a',2,110),
 'source-pair':('50eee7588f1600b46edbb434a49ecf486cfbc1d5d2da47eb6796976a8d24aae9','eccba059ff79e9fa13fe5f4d3924dff2fb3f1e1636ced39c2e72b93a26b16f9b',2,110),
 'post-JS':('7d6eebac780568eeebb7ea15b6b5fa935331c901b0c24d1440d49f11b2419098','ea1fc2211d06e201f5e3e5cfae0c9d969c5bb2aa28f526e3cc93c8f2540eb4e6',2,108),
 'failed-JS':('940b52905c4097ea9ca93884756e84d3109e385eea9dadc13a8c2ee0d006f403','88566fb9e998d63e1307c3c114e72034c4615ec571f9b464bb31cbbbd8d77d8f',2,108)}
assert set(m['runs'])==set(admitted)
plans={};receipts={};private={}
for label,(ps,rs,count,stagecount) in admitted.items():
 assert sha(data[label+'/plan.json'])==m['runs'][label]['planSHA256']==ps and sha(data[label+'/receipt.json'])==m['runs'][label]['receiptSHA256']==rs
 p=json.loads(data[label+'/plan.json']);r=json.loads(data[label+'/receipt.json']);plans[label]=p;receipts[label]=r
 assert r['planSHA256']==ps and not r.get('guardFailures',[]) and len(p['commands'])==len(r['commands'])==count
 private[p['environment']]=p['environmentSHA256']
 prefix=label+'/stage/';actual={n[len(prefix):]:sha(b) for n,b in data.items() if n.startswith(prefix)}
 assert actual==p['inventory'] and len(actual)==stagecount
 lognames={c['label']+suffix for c in p['commands'] for suffix in ['.stdout','.stderr']}
 assert set(r['logs'])==lognames and {n[len(label)+1:] for n in data if n.startswith(label+'/') and '/' not in n[len(label)+1:] and n not in [label+'/plan.json',label+'/receipt.json']}==lognames
 for n,v in r['logs'].items():assert sha(data[label+'/'+n])==v
 for c,a in zip(p['commands'],r['commands']):
  assert all(a[k]==c[k] for k in ['label','argv','seconds']) and a['failure'] is None and a['capture']=='split' and a['status']=='TERMINAL'
  assert c['argv'][:3]==[p['tools']['taskset'],'-c','8'] and p['tools']['cpu']==8
 if label.endswith('JS'):
  assert [c['label'] for c in p['commands']]==['emit-js','consumer'] and [c['seconds'] for c in p['commands']]==[30,5]
  assert p['commands'][0]['argv'][3]==p['tools']['tools']['bend'] and p['commands'][1]['argv']==[p['tools']['taskset'],'-c','8',p['tools']['tools']['node'],p['commands'][0]['generated']]
  assert p['commands'][0]['argv'][5:]==['-o',p['commands'][0]['generated']]
  assert all(a['exit']==0 for a in r['commands'])
  assert set(r['generated'])=={p['commands'][0]['generated']} and set(m['generatedDispositions'][label])==set(r['generated'])
  assert {n for n in data if n.startswith(label+'/generated/')}=={e['member'] for e in m['generatedDispositions'][label].values()}
  active=[k for k in p['tools']['tools'] if k not in p['tools']['skip_ldd']]
  labels=['guard-'+str(i)+'-ldd-'+k for i in range(5) for k in active];assert p['executionProbeLabels']==labels and p['expectedProbeCount']==r['probeCommandsExecuted']==len(labels)==35
  names={n+s for n in labels for s in ['.json','.stdout','.stderr']};prefix=label+'/execution-probes/'
  assert {n[len(prefix):] for n in data if n.startswith(prefix)}==names and set(r['probePins'])=={m['runs'][label]['originalDirectory']+'/execution-probes/'+n for n in names}
  runner=next(v for n,v in p['pins'].items() if n.endswith('/scripts/task_runner.py'))
  assert all(a['runnerSHA256']==runner for a in r['commands'])
  for n in names:assert sha(data[prefix+n])==r['probePins'][m['runs'][label]['originalDirectory']+'/execution-probes/'+n]
  for n in labels:
   q=json.loads(data[prefix+n+'.json']);tool=n.split('-ldd-',1)[1]
   assert q['argv']==[p['tools']['taskset'],'-c','8',p['tools']['ldd'],p['tools']['tools'][tool]] and q['seconds']==5 and q['exit']==0 and q['failure'] is None and q['exception'] is None and q['runnerSHA256']==runner
 else:
  assert [c['label'] for c in p['commands']]==['source-'+str(i) for i in range(count)] and all(c['seconds']==5 and c['argv'][3]==p['tools']['tools']['bend'] and c['argv'][5:]==['--check-only'] for c in p['commands'])
  assert not r.get('generated',{}) and not r.get('probePins',{}) and not m['generatedDispositions'][label]
  runner=next(v for n,v in p['pins'].items() if n.endswith('/scripts/task_runner.py'));assert all(a['runnerSHA256']==runner for a in r['commands'])
  assert not any(n.startswith((label+'/generated/',label+'/execution-probes/')) for n in data)
  expectedstatus='GENERIC_CLEANUP_SOURCE_EIGHT_RAW_COLLECTED_NO_TYPING_PROOF_RUNTIME_ACCEPTANCE' if label=='source-eight' else 'GENERIC_CLEANUP_READ_WRITE_PAIR_RAW_COLLECTED_NO_TYPING_PROOF_RUNTIME_ACCEPTANCE'
  assert r['status']==expectedstatus and r['diagnosticClassification']=='RAW_UNCLASSIFIED_PENDING_FULL_INDEPENDENT_REVIEW'
 for c in p['commands']:
  if c['label'].startswith('source-') or c['label']=='emit-js':
   relative=str(Path(c['argv'][4]).relative_to(Path(p['stage'])))
   assert relative in p['inventory'] and sha(data[label+'/stage/'+relative])==p['inventory'][relative]
   if 'source' in c:assert c['source']==relative
 for n,v in p['pins'].items():
  if n.endswith('/plan.json'):
   e=m['pinDispositions'][label][n]
   if e['kind']=='archive':
    q=json.loads(data[e['member']])
    for field in ['environment','privateEnvironment']:
     if field in q:private[q[field]]=q['environmentSHA256']
assert private==m['privateOwnerRoles']
for label,p in plans.items():
 assert set(m['pinDispositions'][label])==set(p['pins'])
 for n,v in p['pins'].items():
  e=m['pinDispositions'][label][n];assert e['sha256']==v
  if e['kind']=='archive':assert sha(data[e['member']])==v
  elif e['kind']=='installedIdentityExcluded':assert p['tools']['pins'][n]==v
  else:assert e['kind']=='privateEnvironmentIdentityExcluded' and private[n]==v
 for n,v in receipts[label].get('generated',{}).items():
  e=m['generatedDispositions'][label][n];assert e['kind']=='archive' and e['sha256']==sha(data[e['member']])==v
# Selected source bytes must be admitted inputs, not just equal presentation hashes.
for n,v in m['sources'].items():
 if n=='read-write-classification.json':continue
 original=m['originalSourceRoot']+'/'+n
 assert any(p['pins'].get(original)==v for p in plans.values()),n
relativeH='experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1'
assert str(Path(m['originalSourceRoot']).relative_to(Path(m['originalSourceRoot']).parents[5]))==relativeH
joins=json.loads(data['source/current-core-joins.json']);assert len(joins['files'])==8
for label,p in plans.items():
 for n in ['adapter.bend','ports.bend','caller.bend']:
  relative=relativeH+'/'+n;assert p['inventory'][relative]==m['sources'][n]==sha(data[label+'/stage/'+relative])==sha(data['source/'+n])
 for original,entry in joins['files'].items():
  copy=entry['copy'];digest=entry['sha256'];assert p['pins'][original]==p['pins'][copy]==digest==p['inventory'][copy]==sha(data[label+'/stage/'+copy])
notice=next(data[e['member']] for e in m['pinDispositions']['post-JS'].values() if e['kind']=='archive' and e['sha256']=='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494')
assert sha(notice)=='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
banner=b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n'
assert data['source-eight/source-0.stdout']==data['source-pair/source-0.stdout']==banner and data['source-eight/source-0.stderr']==data['source-pair/source-0.stderr']==b''
assert [c['exit'] for c in receipts['source-eight']['commands']]==[0,1,1,1,1,1,1,1] and [c['exit'] for c in receipts['import-failure']['commands']]==[1,1] and [c['exit'] for c in receipts['source-pair']['commands']]==[0,1]
assert sha(data['source-pair/source-1.stderr'])=='cc93394653a260fc6037a38ae1b24a7fcc4ac2f3861147b3518450136d6cbafe' and data['source-pair/source-1.stdout']==b''
assert sha(data['import-failure/source-0.stderr'])==sha(data['import-failure/source-1.stderr'])=='cfbddb831a356a0aa11024c49da8f40cf5ef08001cdaf90db3abfeaeb4801c25'
classification=json.loads(data['source/source-classification.json']);assert classification['receiptSHA256']==admitted['source-eight'][1]
assert len(classification['classifications'])==8
for i,c in enumerate(classification['classifications']):
 assert c['label']=='source-'+str(i) and c['stdoutSHA256']==receipts['source-eight']['logs'][c['label']+'.stdout'] and c['stderrSHA256']==receipts['source-eight']['logs'][c['label']+'.stderr']
assert classification['classifications'][7]['classification']=='PARSER_FAILURE_NO_READ_WRITE_REFUSAL_CREDIT'
pair=json.loads(data['source/read-write-classification.json']);assert pair['receiptSHA256']==admitted['source-pair'][1] and pair['planSHA256']==admitted['source-pair'][0] and pair['originalRAWPreserved'] and pair['earlierParserAndImportFailuresReceiveNoRefusalCredit']
assert pair['negative']['stderrSHA256']==receipts['source-pair']['logs']['source-1.stderr'] and pair['positive']['stdoutSHA256']==receipts['source-pair']['logs']['source-0.stdout']
with tempfile.TemporaryDirectory(prefix='generic-cleanup-nochild-') as tmp:
 root=Path(tmp)
 for n in m['sources']:
  if n.startswith(('models/','model-root/')):
   p=root/n;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(data['source/'+n])
 for label,scenario,worlds,instances in [('post-JS','post-consumption',36,22),('failed-JS','failed-batch',32,16)]:
  p=plans[label];r=receipts[label];assert p['scenario']==scenario and r['status']=='COMPLETE_GENERIC_CLEANUP_'+scenario.upper().replace('-','_')+'_FULL_JS_ORACLE_PASS_NO_ISSUE_CLOSURE'
  assert r['completeWorldRows']==worlds and r['completeInstanceRecords']==instances
  assert data[label+'/emit-js.stdout']==data[label+'/consumer.stderr']==b'' and data[label+'/emit-js.stderr'] in [b'',notice]
  spec=importlib.util.spec_from_file_location('generic_cleanup_validator_'+scenario.replace('-','_'),root/'models'/scenario/'validate.py');module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
  observed=module.validate(data[label+'/consumer.stdout']);assert canonical(observed)==canonical(json.loads(data['source/models/'+scenario+'/expected.json']))
print('CURRENT_GENERIC_CLEANUP_SOURCE_HISTORY_AND_MATCHED_READ_WRITE_REFUSAL_PASS')
print('CURRENT_GENERIC_CLEANUP_JS_COMPLETE36_WORLD22_INSTANCE_PASS')
print('CURRENT_GENERIC_CLEANUP_JS_COMPLETE32_WORLD16_INSTANCE_PASS_NO_NATIVE_ADOPTION_TIMING')
