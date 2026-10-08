"""Read/hash/model-check portable finite bundle evidence; never execute a backend."""
import hashlib,importlib.util,json,sys,tarfile
from pathlib import Path
H=Path(__file__).resolve().parent;D=H/'delivery-v1';sha=lambda b:hashlib.sha256(b).hexdigest()
sys.dont_write_bytecode=True
m=json.loads((D/'manifest.json').read_text())
for n,d in m['source'].items():assert sha((H/n).read_bytes())==d,n
assert sha((D/'REPORT.md').read_bytes())==m['reportSHA256']
assert sha((D/m['archive']['name']).read_bytes())==m['archive']['sha256']
with tarfile.open(D/m['archive']['name'],'r:gz') as t:
 members=t.getmembers();assert all(f.isfile() for f in members);assert len(members)==len({f.name for f in members})
 data={f.name:t.extractfile(f).read() for f in members}
assert set(data)==set(m['archive']['members'])
for n,v in m['archive']['members'].items():assert len(data[n])==v['bytes'] and sha(data[n])==v['sha256'],n
j=lambda n:json.loads(data[n])
source='bundle-source-1791435890088394562';js='bundle-js-1791435891914821638'
plans={source:'88ec0391a738dfc00c210c43f32b32629760b4db45fd3f2885ed5440b61939b8',js:'dfa69422d8376097ecc7f44bbe68e831e8f9200906e87fa22fc0eb141f5e1d4d'}
for run,planSHA in plans.items():
 p=j(run+'/plan.json');r=j(run+'/receipt.json');assert sha(data[run+'/plan.json'])==planSHA==r['planSHA256']
 assert len(r['commands'])==len(p['commands']);assert all(c['failure'] is None for c in r['commands'])
 assert r['probeCommandsExecuted']==len(p['executionProbeLabels'])
 for n,d in r['logs'].items():assert sha(data[run+'/'+n])==d
 actualStage={n[len(run+'/stage/'):]:sha(b) for n,b in data.items() if n.startswith(run+'/stage/')}
 assert actualStage==p['inventory']
 fixture='experiments/public-machine-handlers/candidate-v1/bundle-v1/'
 for name,digest in j(run+'/stage/'+fixture+'source-review-manifest.json')['source'].items() if run+'/stage/'+fixture+'source-review-manifest.json' in data else json.loads((H/'source-review-manifest.json').read_text())['source'].items():
  assert actualStage[fixture+name]==digest==sha((H/name).read_bytes())
 probeRoot=Path(p['stage']).parent/'execution-probes'
 expected={str(probeRoot/(label+suffix)) for label in p['executionProbeLabels'] for suffix in ['.json','.stdout','.stderr']}
 assert set(r['probePins'])==expected
 for absolute,digest in r['probePins'].items():assert sha(data[run+'/execution-probes/'+Path(absolute).name])==digest
 for absolute,digest in r.get('generated',{}).items():assert sha(data[run+'/'+Path(absolute).name])==digest
 for absolute,digest in p['pins'].items():
  path=Path(absolute)
  historical=Path(m['historicalRoot'])
  if path.is_relative_to(historical) and str(path.relative_to(historical)) in m['source']:assert sha((H/path.relative_to(historical)).read_bytes())==digest
assert [c['exit'] for c in j(source+'/receipt.json')['commands']]==[0,0,1,1,1,1,1]
for label in ['main','authority-positive']:
 assert data[source+'/'+label+'.stdout']==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n' and not data[source+'/'+label+'.stderr']
a=json.loads((H/'authority-classification.json').read_text());assert a['rawReceiptSHA256']==sha(data[source+'/receipt.json'])
for label,c in a['classifications'].items():
 assert sha(data[source+'/'+label+'.stderr'])==c['stderrSHA256'];assert not data[source+'/'+label+'.stdout'];assert sha((H/(label+'.bend')).read_bytes())==c['sourceSHA256']
 assert data[source+'/'+label+'.stderr'].count(b'Error:')==1 and data[source+'/'+label+'.stderr'].count(b'Location:')==1
assert [c['exit'] for c in j(js+'/receipt.json')['commands']]==[0,0]
assert all(not data[js+'/'+c['label']+'.stderr'] for c in j(js+'/plan.json')['commands'])
spec=importlib.util.spec_from_file_location('bundle_independent_model',H/'oracle.py');model=importlib.util.module_from_spec(spec);spec.loader.exec_module(model)
expected=json.loads((H/'expected.json').read_text())['rows'];assert expected=={s:model.scenarios(ns) for s,ns in [('A',1),('B',2)]}
observed=json.loads(data[js+'/bundle-consume.stdout']);assert observed==expected
assert {s:len(rows) for s,rows in observed.items()}=={'A':24,'B':24}
print('PORTABLE_FINITE_BUNDLE_SOURCE_JS_48_PASS')
