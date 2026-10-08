"""Portable archive/source/raw/model joins for finite bundle Native48; no child execution."""
import hashlib,importlib.util,json,sys,tarfile
from pathlib import Path
H=Path(__file__).resolve().parent;D=H/'delivery-native-v1';sha=lambda b:hashlib.sha256(b).hexdigest();sys.dont_write_bytecode=True
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
 'bundle-native-A-diagnostic-1791436391764146836':('cc31981d50715e36e362dabcff291808cab33b1bf9e0a834fc77bc7e759d3037','BUNDLE_SCHEMA_A_NATIVE_SOURCE_AND_C_EMISSION_DIAGNOSTIC_PASS',[5,30]),
 'bundle-native-A-1791436662137826392':('41fe6f40f4f4ab07d64ae1995abf0b959dfa6a8ac8546fbba86665c482fc7216','BUNDLE_SCHEMA_A_TWENTY_FOUR_NATIVE_OBSERVATIONS_PASS',[120,5]),
 'bundle-native-B-1791436663174091849':('119d47e3465b233d5eb1f26ab0b1a8accd3c804db730401a99f7a77c4b2f840e','BUNDLE_SCHEMA_B_SOURCE_C_EMISSION_DIAGNOSTIC_PASS',[5,30]),
 'bundle-native-B-1791436965507308248':('b3e720ab47fcf6967c5454b637966622192c1b2a8d50218934310290ac937312','BUNDLE_SCHEMA_B_TWENTY_FOUR_NATIVE_OBSERVATIONS_PASS',[120,5])}
expected=json.loads((H/'expected.json').read_text())['rows'];observed={}
for run,(planSHA,status,caps) in roles.items():
 p=j(run+'/plan.json');r=j(run+'/receipt.json');assert sha(data[run+'/plan.json'])==planSHA==r['planSHA256'];assert r['status']==status
 assert [c['seconds'] for c in p['commands']]==caps and len(r['commands'])==2;assert all(c['exit']==0 and c['failure'] is None for c in r['commands'])
 assert len(p['executionProbeLabels'])==r['probeCommandsExecuted']==25
 stageInventory={n[len(run+'/stage/'):]:sha(raw) for n,raw in data.items() if n.startswith(run+'/stage/')};assert stageInventory==p['inventory']
 fixture='experiments/public-machine-handlers/candidate-v1/bundle-v1/'
 for n,d in json.loads((H/'source-review-manifest.json').read_text())['source'].items():assert stageInventory[fixture+n]==d==sha((H/n).read_bytes())
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
union='bundle-native48-reconciliation-1791437158552482846';receipt=j(union+'/receipt.json');assert receipt['status']=='FULL_FORTY_EIGHT_ACTUAL_NATIVE_OBSERVATIONS_RECONCILED'
assert receipt['unionSHA256']==sha(data[union+'/full48.json']);assert equal(j(union+'/full48.json'),observed) and equal(observed,expected)
for schema,run in [('A','bundle-native-A-1791436662137826392'),('B','bundle-native-B-1791436965507308248')]:
 q=receipt['qualifications'][schema];assert q['planSHA256']==roles[run][0] and q['receiptSHA256']==sha(data[run+'/receipt.json']) and q['stdoutSHA256']==sha(data[run+'/bundle-'+schema+'-run.stdout'])
spec=importlib.util.spec_from_file_location('bundle_native_independent_model',H/'oracle.py');model=importlib.util.module_from_spec(spec);spec.loader.exec_module(model)
assert equal(observed,{s:model.scenarios(ns) for s,ns in [('A',1),('B',2)]})
print('PORTABLE_FINITE_BUNDLE_NATIVE48_PASS')
