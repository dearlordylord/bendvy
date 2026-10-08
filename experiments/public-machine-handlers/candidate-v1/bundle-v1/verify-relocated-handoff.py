"""Portable archive/source/raw/model joins for finite bundle Native48; no child execution."""
import hashlib,importlib.util,json,sys,tarfile
from pathlib import Path
H=Path(__file__).resolve().parent;D=H/'delivery-relocated-v1';sha=lambda b:hashlib.sha256(b).hexdigest();sys.dont_write_bytecode=True
m=json.loads((D/'manifest.json').read_text());assert sha((H/'delivery-v1/manifest.json').read_bytes())==m['baselineManifestSHA256']
baseline=json.loads((H/'delivery-v1/manifest.json').read_text())
for n,d in baseline['source'].items():assert sha((H/n).read_bytes())==d,n
for n,d in m['source'].items():assert sha((H/n).read_bytes())==d,n
assert sha((D/'REPORT.md').read_bytes())==m['reportSHA256'];assert sha((D/m['archive']['name']).read_bytes())==m['archive']['sha256']
with tarfile.open(D/m['archive']['name'],'r:gz') as t:
 members=t.getmembers();assert all(f.isfile() for f in members);assert len(members)==len({f.name for f in members});data={f.name:t.extractfile(f).read() for f in members}
assert set(data)==set(m['archive']['members'])
for n,v in m['archive']['members'].items():assert sha(data[n])==v['sha256'] and len(data[n])==v['bytes']
j=lambda n:json.loads(data[n]);equal=lambda a,b:json.dumps(a,sort_keys=True,separators=(',',':'))==json.dumps(b,sort_keys=True,separators=(',',':'))
roles={
 'bundle-relocated-native-A-diagnostic-1791439480075463796':('ca3fae205507d2bd0298101333f92f8fd72b436f7f9390db64f456613793a285','BUNDLE_SCHEMA_A_NATIVE_SOURCE_AND_C_EMISSION_DIAGNOSTIC_PASS',[5,30]),
 'bundle-relocated-native-B-diagnostic-1791439481041560085':('c3fdd3fb80e856a4aee8a0e4970cee8eccc5ad7a8fe6c75947e5658a9aee37ae','BUNDLE_SCHEMA_B_NATIVE_SOURCE_AND_C_EMISSION_DIAGNOSTIC_PASS',[5,30]),
 'bundle-relocated-native-A-1791439666073142944':('f967adcff109ed3b324d59690955c2e1c46148baaa2cd454d59887c1b4cd84fd','BUNDLE_SCHEMA_A_TWENTY_FOUR_NATIVE_OBSERVATIONS_PASS',[120,5]),
 'bundle-relocated-native-B-1791439667093325179':('ce80a2d83523005757ee83dc4b7f5d2ad3e322a4f8bbc9b1209173db8c08ac0d','BUNDLE_SCHEMA_B_TWENTY_FOUR_NATIVE_OBSERVATIONS_PASS',[120,5])}
expected=json.loads((H/'expected.json').read_text())['rows'];observed={}
for run,(planSHA,status,caps) in roles.items():
 p=j(run+'/plan.json');r=j(run+'/receipt.json');assert sha(data[run+'/plan.json'])==planSHA==r['planSHA256'];assert r['status']==status
 assert [c['seconds'] for c in p['commands']]==caps and len(r['commands'])==2;assert all(c['exit']==0 and c['failure'] is None for c in r['commands'])
 assert len(p['executionProbeLabels'])==r['probeCommandsExecuted']==25
 stageInventory={n[len(run+'/stage/'):]:sha(raw) for n,raw in data.items() if n.startswith(run+'/stage/')};assert stageInventory==p['inventory']
 fixture='experiments/public-machine-handlers/candidate-v1/bundle-v1/'
 stageJoin=json.loads((H/'adoption-stage-review-manifest.json').read_text())
 for n,d in stageJoin['closure'].items():assert stageInventory[n]==d
 assert 'src/ecs/machine-handler-bundle.bend' in stageInventory
 root=Path(p['stage']).parent;probeRoot=root/'execution-probes';pins={str(probeRoot/(label+suffix)) for label in p['executionProbeLabels'] for suffix in ['.json','.stdout','.stderr']};assert set(r['probePins'])==pins
 for absolute,d in r['probePins'].items():assert sha(data[run+'/'+str(Path(absolute).relative_to(root))])==d
 assert {n[len(run+'/execution-probes/'):] for n in data if n.startswith(run+'/execution-probes/')}=={Path(f).name for f in pins}
 assert set(r['logs'])=={c['label']+suffix for c in p['commands'] for suffix in ['.stdout','.stderr']}
 for n,d in r['logs'].items():assert sha(data[run+'/'+n])==d
 assert all(not data[run+'/'+c['label']+'.stderr'] for c in p['commands'])
 for absolute,d in r['generated'].items():
  name=Path(absolute).name
  if name.endswith('.c'):assert sha(data[run+'/'+name])==d
 for absolute,d in p['pins'].items():
  path=Path(absolute)
  if path.is_relative_to(Path(m['historicalRoot'])):
   relative=str(path.relative_to(Path(m['historicalRoot'])))
   if relative in data:assert sha(data[relative])==d
   elif relative in baseline['source'] or relative in m['source']:assert sha((H/relative).read_bytes())==d
 if caps==[5,30]:assert data[run+'/'+p['commands'][0]['label']+'.stdout']==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n'
 else:
  schema=p['schema'];values=json.loads(data[run+'/bundle-'+schema+'-run.stdout']);assert len(values)==24 and [v['name'] for v in values]==list(expected[schema]);rows={v['name']:v['value'] for v in values};assert equal(rows,expected[schema]) and equal(rows,r['observations']);observed[schema]=rows
union='bundle-relocated-native48-reconciliation-1791439853884363158';receipt=j(union+'/receipt.json');assert receipt['status']=='FULL_FORTY_EIGHT_ACTUAL_NATIVE_OBSERVATIONS_RECONCILED'
assert receipt['unionSHA256']==sha(data[union+'/full48.json']);assert equal(j(union+'/full48.json'),observed) and equal(observed,expected)
for schema,run in [('A','bundle-relocated-native-A-1791439666073142944'),('B','bundle-relocated-native-B-1791439667093325179')]:
 q=receipt['qualifications'][schema];assert q['planSHA256']==roles[run][0] and q['receiptSHA256']==sha(data[run+'/receipt.json']) and q['stdoutSHA256']==sha(data[run+'/bundle-'+schema+'-run.stdout'])
spec=importlib.util.spec_from_file_location('bundle_native_independent_model',H/'oracle.py');model=importlib.util.module_from_spec(spec);spec.loader.exec_module(model)
assert equal(observed,{s:model.scenarios(ns) for s,ns in [('A',1),('B',2)]})
# Source/JS currentstage full membership and raw joins are separately required.
for run,planSHA,count in [('bundle-relocated-source-1791438766040767121','7d38740e8367237ed1d557576641eb833ac0a35cef2b8f3c1cc7d44f4ef2f303',75),('bundle-relocated-js-1791439163954053936','4d57b972050bdffdfde3f4cb46334a32892f660d29228146df9f93ac872af972',25)]:
 p=j(run+'/plan.json');r=j(run+'/receipt.json');assert sha(data[run+'/plan.json'])==planSHA==r['planSHA256'];assert r['probeCommandsExecuted']==count
 expectedCount=7 if count==75 else 2
 assert len(p['commands'])==len(r['commands'])==expectedCount
 assert r['status']==('CURRENT_ROOT_RELOCATED_BUNDLE_SOURCE_AND_FIVE_RAW_REFUSALS_COLLECTED_UNCLASSIFIED' if count==75 else 'INDEPENDENT_BUNDLE_FORTY_EIGHT_COMPLETE_JS_OBSERVATIONS_PASS')
 assert set(r['logs'])=={c['label']+suffix for c in p['commands'] for suffix in ['.stdout','.stderr']}
 assert {n[len(run+'/execution-probes/'):] for n in data if n.startswith(run+'/execution-probes/')}=={label+suffix for label in p['executionProbeLabels'] for suffix in ['.json','.stdout','.stderr']}
 stageInventory={n[len(run+'/stage/'):]:sha(raw) for n,raw in data.items() if n.startswith(run+'/stage/')};assert stageInventory==p['inventory']
 for n,digest in stageJoin['closure'].items():assert stageInventory[n]==digest
 root=Path(p['stage']).parent;probe=root/'execution-probes';assert set(r['probePins'])=={str(probe/(label+suffix)) for label in p['executionProbeLabels'] for suffix in ['.json','.stdout','.stderr']}
 for absolute,digest in r['probePins'].items():assert sha(data[run+'/'+str(Path(absolute).relative_to(root))])==digest
 for n,digest in r['logs'].items():assert sha(data[run+'/'+n])==digest
 assert all(c['failure'] is None for c in r['commands'])
 if count==75:
  assert [c['exit'] for c in r['commands']]==[0,0,1,1,1,1,1]
  for c in p['commands'][:2]:assert data[run+'/'+c['label']+'.stdout']==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n' and not data[run+'/'+c['label']+'.stderr']
  classification=json.loads((H/'relocated-authority-classification.json').read_text());assert classification['rawReceiptSHA256']==sha(data[run+'/receipt.json'])
  for name,c in classification['classifications'].items():assert c['stderrSHA256']==sha(data[run+'/'+name+'.stderr']) and c['sourceSHA256']==stageInventory[fixture+name+'.bend'] and not data[run+'/'+name+'.stdout']
 else:
  assert all(c['exit']==0 for c in r['commands']) and all(not data[run+'/'+c['label']+'.stderr'] for c in p['commands'])
  full=j(run+'/bundle-consume.stdout');assert equal(full,expected)
  for absolute,digest in r['generated'].items():assert sha(data[run+'/'+Path(absolute).name])==digest
print('PORTABLE_CURRENT_ROOT_RELOCATED_BUNDLE_SOURCE_JS_NATIVE48_PASS')
