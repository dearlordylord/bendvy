from pathlib import Path
import json,hashlib,zipfile,gzip
E=Path(__file__).resolve().parent
h=lambda b:hashlib.sha256(b).hexdigest()
x=json.loads((E/'DELIVERY.json').read_text())
for n,digest in x['files'].items():assert h((E/n).read_bytes())==digest,n
def validate_execution(p,r,guard_objects,root):
 labels=['emit','build','consumer']
 assert [c['label'] for c in p['commands']]==labels
 assert [c['label'] for c in r['commands']]==labels
 assert p['generated']==root+'/seeded.c' and p['native']==root+'/owner.native'
 assert p['commands'][0]['argv'][-2]==p['generated']
 assert p['commands'][1]['argv'][-2:]==['-o',p['native']]
 assert p['commands'][1]['argv'][5]==p['generated']
 assert p['commands'][2]['argv'][3]==p['native']
 assert [c['capSeconds'] for c in p['commands']]==[5,120,5]
 for planned,actual in zip(p['commands'],r['commands']):
  assert actual['argv']==planned['argv'] and actual['capSeconds']==planned['capSeconds']
  assert actual['exit']==0 and actual['failure'] is None and actual['capture']=='split'
  for stream in ['stdout','stderr']:
   row=actual[stream]
   assert row['path']==root+'/'+actual['label']+'.'+stream and row['published'] is True
 guard_labels=[label+'-'+phase for label in labels for phase in ['pre','acquired','post']]+['final']
 assert [g['path'] for g in r['guards']]==[root+'/'+label+'.guard.json' for label in guard_labels]
 assert len(guard_objects)==10
 pins=dict(p['pins']);pins[root+'/plan.json']=r['planSHA256']
 for label,obj in zip(guard_labels,guard_objects):
  if label.endswith('-post'):
   cmd=next(c for c in r['commands'] if c['label']==label[:-5])
   pins.update({cmd[stream]['path']:cmd[stream]['sha256'] for stream in ['stdout','stderr']})
   if cmd['label']=='emit':pins[p['generated']]=r['emitArtifactSHA256']
   if cmd['label']=='build':pins[p['native']]=r['buildArtifactSHA256']
  assert obj['label']==label and obj['unchanged'] is True and obj['actualPins']==pins

m=json.loads((E/'MANIFEST.json').read_text())
with zipfile.ZipFile(E/'EVIDENCE.zip') as z:
 assert set(z.namelist())==set(m['members']) and len(z.namelist())==len(set(z.namelist()))
 data={}
 for name,row in m['members'].items():
  b=z.read(name);assert len(b)==row['bytes'] and h(b)==row['sha256'];data[(row['path'],row['sha256'])]=b
 def get(path,digest=None):
  keys=m['pathHashToMember'][path]
  if digest is None:assert len(keys)==1;digest=next(iter(keys))
  return data[path,digest]
 root=x['producerLeaf'];raw=get(root+'/plan.json');p=json.loads(raw);r=json.loads(get(root+'/receipt.json'))
 assert r['planSHA256']==h(raw) and r['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS'
 for name,digest in p['pins'].items():
  if name.startswith('/workspace/'):assert h(get(name,digest))==digest
 guard_objects=[json.loads(get(g['path'],g['sha256'])) for g in r['guards']]
 validate_execution(p,r,guard_objects,root)
 expected=gzip.decompress(get(p['oracle'],p['pins'][p['oracle']]))
 assert len(expected)==158 and h(expected)==p['oracleSHA256']
 for c in r['commands']:
  assert c['exit']==0 and c['failure'] is None
  for stream in ('stdout','stderr'):assert h(get(c[stream]['path'],c[stream]['sha256']))==c[stream]['sha256']
  if c['label']=='consumer':assert get(c['stdout']['path'],c['stdout']['sha256'])==expected and c['stderr']['bytes']==0
 before=get(p['provenance']['normalC'],p['provenance']['normalCSHA256']);after=get(p['generated'],r['emitArtifactSHA256'])
 a=b'static _Atomic uint32_t bendvy_namespace_next = 1;';b=b'static _Atomic uint32_t bendvy_namespace_next = UINT32_MAX - 2;'
 assert before.count(a)==1 and after==before.replace(a,b) and after.replace(b,a)==before
 assert h(get(p['native'],r['buildArtifactSHA256']))==r['buildArtifactSHA256']
print(json.dumps({'status':'PASS_RETAINED_NATIVE_SATURATION','members':len(m['members']),'fullOwnerBytes':158,'scope':'sequential-single-executable'}))
