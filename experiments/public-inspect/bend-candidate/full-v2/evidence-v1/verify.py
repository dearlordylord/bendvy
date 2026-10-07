"""No-child strict closed-capsule and full-output reconciliation."""
from pathlib import Path
import hashlib,json,tarfile
here=Path(__file__).resolve().parent;i=json.loads((here/'index.json').read_text());archive=here/'objects.tar.gz';sha=lambda b:hashlib.sha256(b).hexdigest();assert sha(archive.read_bytes())==i['archiveSHA256'];objects={}
with tarfile.open(archive) as t:
 for m in t.getmembers():
  assert m.isfile() and m.name.startswith('objects/') and m.name not in objects
  b=t.extractfile(m).read();assert m.name=='objects/'+sha(b);objects[m.name]=b
assert set(objects)=={'objects/'+r['sha256'] for r in i['records'].values()}
def raw(path):
 r=i['records'][path];b=objects['objects/'+r['sha256']];assert len(b)==r['bytes'];return b
def json_at(path):return json.loads(raw(path))
for path in i['records']:raw(path)
p=json_at(i['positivePlan']);r=json_at(i['positiveReceipt']);assert r['planSHA256']==sha(raw(i['positivePlan']));assert r['status']=='RETAINED_LOOKUP_DESPAWN_FULL_JS_NATIVE_ORACLE_PASS';out=str(Path(i['positiveReceipt']).parent)
assert [x['label'] for x in r['commands']]==[x['label'] for x in p['commands']];assert all(x['exit']==0 and x['failure'] is None for x in r['commands'])
for f,digest in p['pins'].items():
 assert (sha(raw(f)) if f in i['records'] else i['excludedHashOnly'][f])==digest
for name,digest in p['inventory'].items():assert sha(raw(str(Path(p['stage'])/name)))==digest
for name,digest in r['logs'].items():assert sha(raw(out+'/'+name))==digest
for f,digest in r['probePins'].items():assert sha(raw(f))==digest
assert r['probeCommandsExecuted']==len(p['executionProbeLabels'])==55
for label in p['executionProbeLabels']:
 receipt=json_at(out+'/execution-probes/'+label+'.json');assert receipt['exit']==0 and receipt['failure'] is None and receipt['seconds']==5
 assert len(raw(out+'/execution-probes/'+label+'.stdout'))>0
for label in ['prepare-ldd-'+n for n in ['bend','node','python','taskset','clang']]:
 receipt=json_at(out+'/prepare-probes/'+label+'.json');assert receipt['exit']==0 and receipt['failure'] is None and receipt['seconds']==5
oracle=json_at(i['oracle']);expected=oracle['retained-bend'];assert len(expected.splitlines())==10
assert json.loads(raw(out+'/run-js.stdout'))==expected
assert json.loads(raw(out+'/run-native.stdout'))==expected
ts=json_at(i['tsReceipt']);assert ts['commands'][0]=={'label':'retained-ts','exit':0,'failure':None};assert json_at(i['tsRaw'])==oracle['retained-ts']
assert len(oracle['retained-ts']['observations'])==8
neg=json_at(i['negativeReceipt']);negout=str(Path(i['negativeReceipt']).parent);assert len(neg['commands'])==4 and all(x['exit']==1 and x['failure'] is None for x in neg['commands'])
for n,digest in neg['logs'].items():assert sha(raw(negout+'/'+n))==digest
candidate='/workspace/formal-proofs/bendvy/experiments/public-inspect/bend-candidate/full-v2'
for name,digest in neg['inputs'][candidate].items():
 path=candidate+'/'+name
 if path in i['records']:assert sha(raw(path))==digest
for case in ['write-read','cross-schema','duplicate-owner','undeclared-read']:
 diag=raw(negout+'/'+case+'.stderr').decode();assert 'Location: bad' in diag and '- expected :' in diag and '- observed :' in diag and '^' in diag
assert raw(negout+'/write-read.stderr').find(b'Cap.ValueWrite<')>=0
assert raw(negout+'/duplicate-owner.stderr').find(b'consumed more than once')>=0
assert i['acceptance'] is False and i['completeIssue54'] is False and i['privateEnvironmentExcluded'] is True
print('PASS:321 exact source/raw/receipt records; complete8 TS/JS/Native snapshots;60 owned installed probes; four intended static negatives; bounded development only')
