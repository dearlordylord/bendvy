"""Portable no-child reconciliation of the frozen ordinary resource JS slice."""
import hashlib,json,tarfile
from pathlib import Path
HERE=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
INDEX=json.loads((HERE/'index.json').read_text())
assert sha((HERE/'objects.tar.gz').read_bytes())==INDEX['archiveSHA256']
OBJECTS={}
with tarfile.open(HERE/'objects.tar.gz','r:gz') as archive:
 for member in archive:
  assert member.isfile() and member.name.startswith('objects/')
  body=archive.extractfile(member).read();digest=sha(body)
  assert member.name=='objects/'+digest and digest not in OBJECTS
  OBJECTS[digest]=body
assert set(OBJECTS)==set(INDEX['records'].values())
# FILES.json excludes its own digest; every listed regular selected file is checked.
SELECTION=json.loads((HERE/'FILES.json').read_text())
DREL=Path('experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1')
for name,digest in SELECTION['files'].items():
 relative=Path(name).relative_to(DREL);live=HERE.parent/relative
 assert live.is_file() and sha(live.read_bytes())==digest
 if relative.parts[0]!='ordinary-consumed-resource-evidence-v1':
  archivedPath=str(Path(INDEX['archivedHere'])/relative)
  eligible=[key for key,value in INDEX['records'].items() if key.split(':',1)[1]==archivedPath and value==digest]
  assert eligible,(name,'no exact archived owner source join')

def data(owner,path):return OBJECTS[INDEX['records'][owner+':'+str(path)]]
def model(owner,path):return json.loads(data(owner,path))
def strict(left,right):
 assert type(left) is type(right)
 if isinstance(left,dict):
  assert set(left)==set(right)
  for key in left:strict(left[key],right[key])
 elif isinstance(left,list):
  assert len(left)==len(right)
  for a,b in zip(left,right):strict(a,b)
 else:assert left==right
BINDINGS={
 'normal':('49c39e885190d33f5dbfd7c92705a6effbb70b4e35c5b2c3e1cbe0bfaf74cbe9','e105c7eb98b74c45169aa837f998f33d3899d333e32ceaa36717e7a4fcba6758'),
 'failedIO':('c154aee956544e4cb3d853e0cdfc4bc3151d6074972d5836e724b18dc272973e','d8e8d1de81a9ebe32ef19d81865a661a7f598f399ec93c540f15037b77dbb210'),
 'registered':('1d5b789350b6f4f06e2c05ab8b033d213a8da4fe5a8d150b2647e3fc6521a7e2','d81aee04c945ea5ec75ffb5e601921a495e88e7d3b4aff94803a55745bea1459'),
 'authority':('6e0bdf373cf7b1e1109553ad09b5ab67cacb92623bea3006b6faf652709f8883','0fec2d90d9f296d5a2b3aa226be89a07c5917e5bdcdda1c9a25b903acddfac1e')}
assert set(INDEX['cohorts'])==set(BINDINGS)
PLANS={};RECEIPTS={};roles={};environments={}
for owner,(ps,rs) in BINDINGS.items():
 c=INDEX['cohorts'][owner];directory=Path(c['directory'])
 assert (c['planSHA256'],c['receiptSHA256'])==(ps,rs)
 assert sha(data(owner,directory/'plan.json'))==ps and sha(data(owner,directory/'receipt.json'))==rs
 p=model(owner,directory/'plan.json');r=model(owner,directory/'receipt.json');PLANS[owner]=p;RECEIPTS[owner]=r
 assert r['planSHA256']==ps and r.get('guardFailures',[])==[]
 environments[p['environment']]=p['environmentSHA256']
 for cmd in p['commands']:
  for index in [0,3]:roles.setdefault(cmd['argv'][index],[]).append((owner,cmd['label'],index,ps))
for owner,p in PLANS.items():
 for path,digest in p['pins'].items():
  key=owner+':'+path
  if key in INDEX['records']:assert INDEX['records'][key]==digest
  else:
   e=INDEX['excluded'][key];assert e['sha256']==digest
   if path in environments:assert e['kind']=='private-environment' and digest==environments[path]
   else:
    assert path in roles and e['kind'] in ['installed-command','installed-command-or-exact-prerequisite']
    # Installed prerequisite identity is justified by an exact archived owner plan.
    assert any(PLANS[role[0]]['pins'].get(path)==digest for role in roles[path])
    if 'declaredRoles' in e:assert {(z['owner'],z['label'],z['argument'],z['planSHA256']) for z in e['declaredRoles']}==set(roles[path])
 stage=Path(p['stage']);actual={key[len(owner+':'+str(stage)+'/'):]:h for key,h in INDEX['records'].items() if key.startswith(owner+':'+str(stage)+'/')}
 assert actual==p['inventory']
 for name,v in p['sourceMap'].items():
  original=data(owner,v['original']);copied=data(owner,stage/name)
  assert sha(original)==v['originalSHA256'] and sha(copied)==v['copiedSHA256']==p['inventory'][name]
  if name.endswith('.bend'):
   root='/workspace/formal-proofs/bendvy/src/ecs/'
   prefix='../'*(len(Path(name).parts)-1)+'core/' if Path(name).parts[0]=='client' else './'
   assert original.decode().replace(root,prefix).encode()==copied
  else:assert original==copied
 for lib in p['libraries'].values():
  for name,h in lib['inventory'].items():assert sha(data(owner,Path(lib['root'])/name))==h
 r=RECEIPTS[owner];directory=Path(INDEX['cohorts'][owner]['directory'])
 assert len(r['commands'])==len(p['commands'])
 labels=[c['label'] for c in p['commands']];assert set(r['logs'])=={n+'.'+stream for n in labels for stream in ['stdout','stderr']}
 for c,a in zip(p['commands'],r['commands']):
  assert a['label']==c['label'] and a['argv']==c['argv'] and a['seconds']==c['seconds'] and a['capture']=='split'
  assert a['runnerSHA256']=='ad723a8f1989c7d7610a7f58fe3a4bb820b43ba5069084201d1a3b6931fa4c44'
  assert c['argv'][1:3]==['-c','5']
  for stream in ['stdout','stderr']:
   b=data(owner,directory/(c['label']+'.'+stream));assert sha(b)==r['logs'][c['label']+'.'+stream]==a[stream+'SHA256']
 for path,h in r.get('generated',{}).items():assert sha(data(owner,path))==h
 notice=data(owner,p['notice']);assert sha(notice)=='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
 if owner in ['normal','registered']:
  assert labels==['emit','candidate'] and [c['seconds'] for c in p['commands']]==[30,5]
  emit,candidate=p['commands']
  artifact=emit['artifact'];entry=emit['argv'][4]
  assert emit['argv'][5:]==['-o',artifact] and Path(entry).is_relative_to(stage)
  assert str(Path(entry).relative_to(stage)) in p['inventory'] and sha(data(owner,entry))==p['inventory'][str(Path(entry).relative_to(stage))]
  assert candidate['argv'][4:]==[artifact] and set(r['generated'])=={artifact}
  assert all(c['exit']==0 and c['failure'] is None for c in r['commands'])
  assert r['status']==('DEVELOPMENT_ORDINARY_DEBUG_NORMAL4_JS_FULL_ORACLE_PASS_NOT_IO_ADOPTION_FULL56_PROOF' if owner=='normal' else 'DEVELOPMENT_REGISTERED_DISPATCH_DUPLICATE_JS2_FULL_ORACLE_PASS_NOT_ADOPTION_FULL56_PROOF')
  assert not data(owner,directory/'emit.stdout') and data(owner,directory/'emit.stderr') in [b'',notice]
  observed=data(owner,directory/'candidate.stdout');expected=data(owner,p['expected']);assert observed==expected and not data(owner,directory/'candidate.stderr')
  assert len(observed.splitlines())==(4 if owner=='normal' else 2)
  if owner=='normal':
   assert sha(expected)=='fbd4479819d5c2ccaeba419ae796bdef9392e689f9d3c6833635446c056113af'
   for line in observed.splitlines():
    v=json.loads(line)['observation'];strict(v['beforeWorld'],v['afterWorld']);strict(v['beforeApp'],v['afterApp'])
  else:
   independent=model(owner,str(Path(INDEX['archivedHere'])/'NORMAL-REGISTERED-CONTROLS-ORACLE.json'))
   rows=list(map(json.loads,observed.splitlines()));strict(rows[0],independent['registered']);strict(rows[1],independent['duplicate'])
 elif owner=='failedIO':
  assert labels==['candidate'] and p['commands'][0]['seconds']==5 and r['status']=='INCOMPLETE'
  a=r['commands'][0];assert a['exit'] is None and a['failure']=='child deadline'
  assert not data(owner,directory/'candidate.stdout') and not data(owner,directory/'candidate.stderr') and r['generated']=={}
 else:
  assert labels==['positive','cross-schema','wrong-layout','label-path','write-through-read','affine-owner'] and all(c['seconds']==5 and c['argv'][-1]=='--check-only' for c in p['commands'])
  assert r['status']=='DEVELOPMENT_ORDINARY_AUTHORITY_RAW_UNCLASSIFIED_NOT_PROOF' and all(c['failure'] is None for c in r['commands'])
  assert [c['exit'] for c in r['commands']]==[0,1,1,1,1,1]
  assert data(owner,directory/'positive.stdout')==data(owner,p['positive']) and sha(data(owner,p['positive']))=='931f1e664a679af1355a9ca547ac1daef9f7b14137bc7cc21b110b0cc504b5b1'
  assert data(owner,directory/'positive.stderr') in [b'',notice]
  classification=model('classification',str(Path(INDEX['archivedHere'])/'NORMAL-AUTHORITY-CLASSIFICATION.json'))
  assert classification['planSHA256']==BINDINGS[owner][0] and classification['receiptSHA256']==BINDINGS[owner][1]
  assert set(classification['classification'])==set(labels[1:])
  for label in labels[1:]:
   b=data(owner,directory/(label+'.stderr'));c=classification['classification'][label]
   assert not data(owner,directory/(label+'.stdout')) and sha(b)==c['stderrSHA256']
   assert b.count(b'Error:')==1 and b.count(b'Location:')==1
   assert sha(data(owner,Path(p['stage'])/('client/authority/'+label+'.bend')))==c['sourceSHA256']
print('PASS: historical JS normal4 + registered/duplicate2 + classified authority; failed IO retained; no current-root/Native/full56/proof claim')
