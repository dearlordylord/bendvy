"""Validate portable membership, raw receipts and full named observations; no children."""
import hashlib,json,tarfile
from pathlib import Path
D=Path(__file__).resolve().parent;index=json.loads((D/'index.json').read_text());archive=D/'objects.tar.gz'
def sha(b):return hashlib.sha256(b).hexdigest()
assert sha(archive.read_bytes())==index['archiveSHA256']
with tarfile.open(archive,'r:gz') as t:
 members=t.getmembers();assert len(members)==len(set(m.name for m in members));assert set(m.name for m in members)==set(index['files']);objects={}
 for m in members:
  assert m.isfile() and not m.name.startswith('/') and '..' not in Path(m.name).parts
  data=t.extractfile(m).read();record=index['files'][m.name];assert len(data)==record['bytes'] and sha(data)==record['sha256'];assert not data.startswith(b'\x7fELF');assert Path(m.name).name!='environment.json';objects[m.name]=data
prefix='experiments/public-relation-readers/keyed-candidate/wider/'
def obj(name):return json.loads(objects[prefix+name])
def relative(name):return name.split('/bendvy/',1)[1]
r=obj('mixed-v16-controls-001/receipt.json');assert sha(objects[prefix+'mixed-v16-controls-001/receipt.json'])==index['terminalSHA256'];assert r['status']=='MIXED_DEVELOPMENT_PASS';assert r['developmentOnly'] and not r['acceptance'] and not r['completeIssue43']
plan=obj('freeze-mixed-v16-controls-001/execution-plan.json');assert sha(objects[prefix+'freeze-mixed-v16-controls-001/execution-plan.json'])==r['planSHA256'];assert len(plan['commands'])==14
for command in plan['commands']:
 receipt=obj('mixed-v16-controls-001/'+command['label']+'.json');assert receipt['exit']==0 and receipt['failure'] is None;assert receipt['command']==command['argv'] and receipt['timeout']==command['limit'];assert receipt['planSHA256']==r['planSHA256']
for field in ['receiptPins','toolProbeReceiptPins']:
 for name,h in r[field].items():assert sha(objects[relative(name)])==h
for folder,field in [('mixed-v16-controls-001/','rawPins'),('mixed-v16-controls-001/tool-probes/','toolProbeRawPins')]:
 for name,h in r[field].items():assert sha(objects[prefix+folder+name])==h
for name,h in r['generatedPins'].items():
 key=relative(name)
 if key in objects:assert sha(objects[key])==h
 else:assert key.endswith('/mixed-native'),key
js=obj('mixed-v16-cheap-001/consume.stdout')['observed'];native=obj('mixed-v16-controls-001/consume-native.stdout')['observed'];assert native==js and len(js)==2
comparison=obj('mixed-v16-controls-001/public-compare.stdout');assert comparison['matchedRoots']==2 and comparison['matchedRegisteredReads']==8 and comparison['clockNormalization'] is False
for kind in ['clock','cursor','queue']:
 data=obj('mixed-v16-controls-001/'+kind+'-consume.stdout');assert data['killed'] and data['mutant']==kind;expected=json.loads(json.dumps(js))
 for root in expected:
  if kind=='clock':next(m for m in root['marks'] if m['stage']=='inserted')['relationTick']=2
  elif kind=='cursor':
   root['relationRegistry']['cursor']=0
   for m in root['marks']:
    if m['stage']=='registered':m['cursor']=0;m['added']=m['stamp']['added']>0;m['changed']=m['stamp']['changed']>0
  else:root['beforePartition']=[root['beforePartition'][2],*root['beforePartition'][:2]]
 assert data['observed']==expected and data['observed']!=js
for root in js:
 reads=[m for m in root['marks'] if m['stage']=='registered'];assert len(reads)==4
 assert reads[1]['component']['value']==reads[2]['component']['value']==[11,12,13,14]
 assert reads[1]['added'] and reads[1]['changed'] and not reads[2]['added'] and not reads[2]['changed']
print(json.dumps({'status':'PORTABLE_MIXED_V16_DEVELOPMENT_EVIDENCE_VALID','files':len(objects),'completePublicCallbacks':8,'compilingMutants':3,'nativeMatchesFullJS':True,'acceptance':False,'completeIssue43':False}))
