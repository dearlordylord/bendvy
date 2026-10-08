"""Portable source/raw/independent variant/witness joins; no Bend/JS children."""
import hashlib,importlib.util,json,sys,tarfile
from pathlib import Path
H=Path(__file__).resolve().parent;D=H/'delivery-mutants-js-v1';sha=lambda b:hashlib.sha256(b).hexdigest();sys.dont_write_bytecode=True
m=json.loads((D/'manifest.json').read_text());assert sha((H/'delivery-v1/manifest.json').read_bytes())==m['baselineManifestSHA256']
for n,d in m['source'].items():assert sha((H/n).read_bytes())==d,n
assert sha((D/'REPORT.md').read_bytes())==m['reportSHA256'] and sha((D/m['archive']['name']).read_bytes())==m['archive']['sha256']
with tarfile.open(D/m['archive']['name'],'r:gz') as t:
 members=t.getmembers();assert all(f.isfile() for f in members);assert len(members)==len({f.name for f in members});data={f.name:t.extractfile(f).read() for f in members}
assert set(data)==set(m['archive']['members'])
for n,v in m['archive']['members'].items():assert sha(data[n])==v['sha256'] and len(data[n])==v['bytes']
j=lambda n:json.loads(data[n]);equal=lambda a,b:json.dumps(a,sort_keys=True,separators=(',',':'))==json.dumps(b,sort_keys=True,separators=(',',':'))
source='bundle-mutant-source-1791437789551147879';js='bundle-mutant-JS-1791438058480149128';models=json.loads((H/'mutations-v1/manifest.json').read_text());normal=json.loads((H/'expected.json').read_text())['rows']
for run,admitted,status,count in [(source,'553e5d064c38afa4aca149e6f7979cce87e0e8279551e8dbcabb4813ce2471f3','THREE_BUNDLE_COMPOSITION_MUTANTS_SOURCE_FEASIBLE_NO_RUNTIME_KILL',35),(js,'4503c5eb202851aeb8852ef830ffec0fe55278bb19ba1435bfc3d8bfbe76aae4','THREE_ACTUAL_BUNDLE_VARIANTS_COMPLETE48_WITH_REACHED_WITNESSES_PASS',65)]:
 p=j(run+'/plan.json');r=j(run+'/receipt.json');assert sha(data[run+'/plan.json'])==admitted==r['planSHA256'];assert r['status']==status
 assert len(r['commands'])==len(p['commands'])==(3 if run==source else 6);assert all(c['exit']==0 and c['failure'] is None for c in r['commands'])
 assert len(p['executionProbeLabels'])==r['probeCommandsExecuted']==count
 stage={n[len(run+'/stage/'):]:sha(raw) for n,raw in data.items() if n.startswith(run+'/stage/')};assert stage==p['inventory']
 root=Path(p['stage']).parent;probe=root/'execution-probes';pins={str(probe/(label+suffix)) for label in p['executionProbeLabels'] for suffix in ['.json','.stdout','.stderr']};assert set(r['probePins'])==pins
 for absolute,d in r['probePins'].items():assert sha(data[run+'/'+str(Path(absolute).relative_to(root))])==d
 assert {n[len(run+'/execution-probes/'):] for n in data if n.startswith(run+'/execution-probes/')}=={Path(n).name for n in pins}
 assert set(r['logs'])=={c['label']+suffix for c in p['commands'] for suffix in ['.stdout','.stderr']}
 for n,d in r['logs'].items():assert sha(data[run+'/'+n])==d
 assert all(not data[run+'/'+c['label']+'.stderr'] for c in p['commands'])
 for absolute,d in r.get('generated',{}).items():assert sha(data[run+'/'+Path(absolute).name])==d
 for variant,record in models['variants'].items():
  prefix=variant+'/experiments/public-machine-handlers/candidate-v1/bundle-v1/'
  assert stage[prefix+record['changedFile']]==record['variantSHA256'];assert stage[prefix+'expected.json']==record['expectedSHA256']
  if run==source:assert data[run+'/'+variant+'.stdout']==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n'
for variant,record in models['variants'].items():
 directory=H/'mutations-v1'/variant;expected=json.loads((directory/'expected.json').read_text())
 for name,key in [(record['changedFile'],'variantSHA256'),('source.patch','patchSHA256'),('oracle.py','modelSHA256'),('expected.json','expectedSHA256')]:assert sha((directory/name).read_bytes())==record[key]
 spec=importlib.util.spec_from_file_location('independent_'+variant.replace('-','_'),directory/'oracle.py');model=importlib.util.module_from_spec(spec);spec.loader.exec_module(model)
 predicted={s:model.scenarios(ns) for s,ns in [('A',1),('B',2)]};assert equal(predicted,expected['rows'])
 observed=j(js+'/'+variant+'-consume.stdout');assert equal(observed,predicted)
 for s in ['A','B']:
  assert len(observed[s])==24 and list(observed[s])==list(normal[s]);assert not equal(observed[s][record['witness']],normal[s][record['witness']])
print('PORTABLE_THREE_BUNDLE_JS_VARIANTS_FULL48_REACHED_PASS')
