"""Portable normal multi-owner correctness capsule; no executions or full56 grant."""
from pathlib import Path
import argparse,hashlib,io,json,tarfile
HERE=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
def strict(a,b):
 if type(a) is not type(b):return False
 if isinstance(a,dict):return a.keys()==b.keys() and all(strict(a[k],b[k]) for k in a)
 if isinstance(a,list):return len(a)==len(b) and all(strict(x,y) for x,y in zip(a,b))
 return a==b
parser=argparse.ArgumentParser();parser.add_argument('--root',default='/workspace/formal-proofs/bendvy');args=parser.parse_args();ROOT=Path(args.root)
selection=json.loads((HERE/'REACHED-FILES.json').read_text());liveRoot=HERE.parents[4]
for name,info in selection['files'].items():assert sha((liveRoot/name).read_bytes())==info['sha256']
prerequisites=json.loads((HERE/'REACHED-TRACKED-PREREQUISITES.json').read_text());assert len(prerequisites['files'])==35
for name,digest in prerequisites['files'].items():assert sha((ROOT/name).read_bytes())==digest
I=json.loads((HERE/'reached-evidence-v1/index.json').read_text());archive=(HERE/'reached-evidence-v1/objects.tar.gz').read_bytes();assert sha(archive)==I['archiveSHA256']
objects={}
with tarfile.open(fileobj=io.BytesIO(archive),mode='r:gz') as t:
 for m in t.getmembers():
  assert m.isfile() and '/' not in m.name and len(m.name)==64 and m.name not in objects
  objects[m.name]=t.extractfile(m).read();assert sha(objects[m.name])==m.name
assert set(objects)==set(I['records'].values())
def data(path):return objects[I['records'][str(path)]]
def parsed(path):return json.loads(data(path))
C=I['cohorts'];AH=str(Path(C['reference']['planPath']).parent.parent.parent)
def authored(name):return data(AH+'/'+name)
EXPECTED=authored('EXPECTED.stdout');assert len(EXPECTED)==9205 and sha(EXPECTED)=='a940e1b778f2749507e642dab274c98cb7ed0d77aed4b9de195be0a77a183f6f'
NOTICE=authored('pinned-notice.stderr');assert sha(NOTICE)=='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
POSITIVE=authored('pinned-source-positive.stdout');assert POSITIVE==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n'
LITERALS={
 'reference':('4978ee5066a5813c09ae86924dfdadeb8f99421a3b782f3532b69cba6977b579','a8245620dd681d40dc0647b9077c3c2f6aa3472aa0beaec8cd35a94bfa804754','DEVELOPMENT_ACTUAL_TS_FULL_DTO2_PASS_NOT_BEND_NOT_DELIVERY_NOT_FULL56',[('reference',5)]),
 'io':('9af7bdda8c653abf080cc640292e65e95a98ff4012ab061fae825e1b95df988c','8e9d73bc7f853be56c81232c26d6de7d29009d4fd6d0761bdbcf93b4821f3c9a','DEVELOPMENT_ACTUAL_MULTI_OWNER_IO_FULL_ORACLE_PASS_NOT_DELIVERY_NOT_FULL56',[('candidate',5)]),
 'js':('33317edaeb1d44694b6bb7c027fe75e1fce74ebd54d47a15d82550d3bcf7ccae','4e812fab89865451ef7b31ab54a2b05bce9be5c234b0f63fe34db648325151a2','DEVELOPMENT_ACTUAL_MULTI_OWNER_JS_FULL_ORACLE_PASS_NOT_DELIVERY_NOT_FULL56',[('emit',30),('candidate',5)]),
 'native':('22baa99fe2e712437f195f4bde1741dfa701f14672d79f67c8e2e8714853e80f','e5d50de39eb1eb71dbefe86c99b954700afe82ff067b09ed1110ecad95c69b38','NATIVE_MULTI_OWNER_FULL_ORACLE_QUALIFIED_NOT_FULL56_NOT_PROOF_NOT_PERFORMANCE',[('emit',30),('compile',120),('candidate',5)]),
 'authority':('98939e310125b66f307fac816324113c8834c8162711d6d4853e0bbac54153ae','46fc96482d5861439408b8e7cf4591bf4f4c2b14ec14a89bce48e33e65e96c75','DEVELOPMENT_SOURCE_COLLECTION_RAW_UNCLASSIFIED_NOT_PROOF_NOT_DELIVERY',[(n,5) for n in ['positive','schema','component-resource','label-resource','read-write','affine-world']])}
LITERALS.update({
 'mutant-source':('461a3624213a49916c5903e2b1d302d859a0f5454d27e7dc32a8286568ebf738','5164645a1c4efade23e85f1d15cb9c1d92983f597565f379de2cf91e68bc9d3e','DEVELOPMENT_MUTANT_SOURCE_TYPING_PASS_NOT_REACHED_NOT_PROOF_NOT_DELIVERY',[(n,5) for n in ['omitted-needs','cursor-mutated']]),
 'mutant-js':('c294f03d69758119767272a46db611ad57e26e283b39362bf2483304ea916df8','fb53cc6196cb4bc647497f89d7286392ed42e8b9daa82a476effebd41dd32e95','DEVELOPMENT_REACHED_MUTANT_JS_FULL_ORACLES_PASS_NOT_NATIVE_PROOF_FULL56',[(n+s,t) for n in ['omitted-needs','cursor-mutated'] for s,t in [('-emit',30),('-candidate',5)]]),
 'mutant-native':('ab3794f88b6396c4ab5b93b21a63f6e2388c2e2a6fd39b3d967c1449f9152a92','0a18c4cb641cdc41a0c98fd202d588878ed0187723ae542b96fa28194cde368c','NATIVE_REACHED_MULTI_OWNER_FULL_ORACLES_PASS_NOT_FULL56_PROOF_PERFORMANCE',[(n+s,t) for n in ['omitted-needs','cursor-mutated'] for s,t in [('-emit',30),('-compile',120),('-candidate',5)]])})
plans={};receipts={}
# Roles derive only from the literal admitted owner plans, never from exclusion reason strings.
ownerPlans={label:parsed(C[label]['planPath']) for label in LITERALS}
privateEnvironments={p['environment']:p['environmentSHA256'] for p in ownerPlans.values()}
configsByPath={};executablePaths=set();snapshotIdentities={}
for p in ownerPlans.values():
 for c in p['commands']:
  executablePaths.update([c['argv'][0],c['argv'][3]])
 for name,state in p['configs'].items():
  if state['kind']=='file':configsByPath[name]=state['sha256']
  elif state['kind']=='symlink' and state['resolvedKind']=='file':configsByPath[state['resolvedPath']]=state['resolvedSHA256']
 snapshot=p.get('toolSnapshot',{});snapshotIdentities.update(snapshot.get('pins',{}));executablePaths.update(snapshot.get('tools',{}).values())
 for name in ['ldd','taskset']:
  if name in snapshot:executablePaths.add(snapshot[name])
executableIdentities={name:digest for p in ownerPlans.values() for name,digest in p['pins'].items() if name in executablePaths}
executableIdentities.update({name:digest for name,digest in snapshotIdentities.items() if name in executablePaths})
def scalar_disposition(name,digest,owner):
 if I['records'].get(name)==digest:return 'archived'
 assert I['excluded'].get(name,{}).get('sha256')==digest
 if privateEnvironments.get(name)==digest:return 'private environment of literal admitted owner plan'
 if configsByPath.get(name)==digest:return 'exact participating host/config identity'
 if name in executablePaths:
  assert not any(name in parsed(C[label]['receiptPath']).get('generated',{}) for label in LITERALS)
  return 'installed executable named by exact admitted argv or owned tool snapshot'
 raise AssertionError(('unjustified omitted scalar pin',owner,name))
for name,item in I['excluded'].items():
 digest=item['sha256']
 assert privateEnvironments.get(name)==digest or configsByPath.get(name)==digest or executableIdentities.get(name)==digest or snapshotIdentities.get(name)==digest

for label,(ps,rs,status,commands) in LITERALS.items():
 c=C[label];assert c['planSHA256']==ps and c['receiptSHA256']==rs;assert sha(data(c['planPath']))==ps and sha(data(c['receiptPath']))==rs
 p=parsed(c['planPath']);r=parsed(c['receiptPath']);plans[label]=p;receipts[label]=r;assert r['planSHA256']==ps and r['status']==status and r.get('guardFailures',[])==[]
 assert [(x['label'],x['seconds']) for x in p['commands']]==commands and len(r['commands'])==len(commands)
 for j,x in enumerate(r['commands']):
  assert all(x[k]==p['commands'][j][k] for k in p['commands'][j]) and x['failure'] is None
  assert x['argv'][:3][-2:]==['-c','5']
  assert x['exit']==(1 if label=='authority' and x['label']!='positive' else 0)
 assert set(r['logs'])=={name+'.'+stream for name,_ in commands for stream in ['stdout','stderr']}
 base=str(Path(c['planPath']).parent)
 for n,h in r['logs'].items():assert sha(data(base+'/'+n))==h
 assert set(r.get('generated',{}))=={c['artifact'] for c in p['commands'] if 'artifact' in c}
 for n,h in r.get('generated',{}).items():assert sha(data(n))==h
 stage=p['stage'];actual={n[len(stage)+1:]:h for n,h in I['records'].items() if n.startswith(stage+'/')};assert actual==p['inventory']
 for n,h in p['pins'].items():
  scalar_disposition(n,h,label)
 for n,h in p.get('toolSnapshot',{}).get('pins',{}).items():assert I['records'].get(n)==h or I['excluded'].get(n,{}).get('sha256')==h
 ej=I['environmentJoins'][p['environment']];assert ej['fileSHA256']==p['environmentSHA256']
 if 'toolSnapshot' in p:assert p['toolSnapshot']['environment_sha256']==ej['ownedCanonicalSHA256']
 for n,h in p.get('rootJoins',{}).items():
  assert sha(data(n))==h
  file=ROOT/Path(n).relative_to('/workspace/formal-proofs/bendvy');assert sha(file.read_bytes())==h
  staged=stage+('/omitted-needs/src/ecs/' if label.startswith('mutant-') else '/src/ecs/')+str(Path(n).relative_to('/workspace/formal-proofs/bendvy/src/ecs'))
  import re
  norm=lambda b:re.sub(rb'(^\s*import\s+)\./',rb'\1',b,flags=re.M)
  assert norm(data(staged))==norm(data(n))
 if label in ['io','js','native']:
  assert data(base+'/candidate.stdout')==EXPECTED and data(base+'/candidate.stderr')==(NOTICE if label=='io' else b'')
  if label!='io':assert data(base+'/emit.stdout')==b'' and data(base+'/emit.stderr') in [b'',NOTICE]
  if label in ['native','mutant-native']:assert data(base+'/compile.stdout')==data(base+'/compile.stderr')==b''
 if label=='reference':
  rows=[json.loads(x) for x in data(base+'/reference.stdout').splitlines()];oracle=json.loads(authored('ORACLE.json'))['cases'];assert len(rows)==len(oracle)==2
  for row,expected in zip(rows,oracle):
   assert row['name']==expected['name'] and strict(row['dto'],expected['description']) and strict(row['beforeDTO'],row['afterDTO']) and row['distinctSystems'] is True and row['distinctSchedules'] is True and strict(row['dto'],row['observed']) and strict(row['beforeDTO'],row['before']) and strict(row['afterDTO'],row['after'])
  assert data(base+'/reference.stderr')==b''
 if label=='authority':
  assert data(base+'/positive.stdout')==POSITIVE and data(base+'/positive.stderr') in [b'',NOTICE]
  classification=json.loads(authored('AUTHORITY-CLASSIFICATION.json'));assert classification['receiptSHA256']==rs and classification['planSHA256']==ps
  assert set(classification['items'])=={n for n,_ in commands if n!='positive'}
  for name,item in {'positive':classification['matchedPositive'],**classification['items']}.items():
   assert sha(data(next(c['argv'][4] for c in p['commands'] if c['label']==name)))==item['sourceSHA256']
   for stream in ['stdout','stderr']:assert sha(data(base+'/'+name+'.'+stream))==item[stream+'SHA256']
   if name!='positive':assert data(base+'/'+name+'.stdout')==b'' and item['classification']=='INTENDED_REFUSAL_INDEPENDENT_REVIEW'
 if label in ['native','mutant-native']:
  prep=parsed(base+'/prepare-receipt.json');assert prep['status']=='ORDINARY_PREPARATION_PASS_NO_BACKEND' and prep.get('guardFailures',[])==[]
  for probes,repeats in [(prep['probes'],1),(r['ordinaryGuardProbes'],14 if label=='mutant-native' else 8)]:
   assert len(probes)==3*repeats
   for j,probe in enumerate(probes):
    assert probe['argv']==p['preparationProbeCommands'][j%3] and probe['seconds']==5 and probe.get('failure') is None and probe.get('exception') is None
    assert probe['result']['exit']==0 and probe['result']['failure'] is None and probe['result']['capture']=='split' and probe['result']['runnerSHA256']==p['pins']['/workspace/formal-proofs/bendvy/scripts/task_runner.py']
    for stream in ['stdout','stderr']:assert set(probe['result'][stream])=={'rawHex'};bytes.fromhex(probe['result'][stream]['rawHex'])
proposal=json.loads(authored('reached-v1/PROPOSAL.json'));assert sha(authored('reached-v1/PROPOSAL.json'))=='d24cae8d0bf0e2ed698ae8d5fd8d3009510e2dca5214006b9cc8af99e6534dfc'
assert sha(authored('registered.bend'))==proposal['originalSourceSHA256'] and sha(EXPECTED)==proposal['originalExpectedSHA256']
for variant in proposal['variants']:
 name=variant['name'];assert sha(authored('reached-v1/'+name+'.bend'))==variant['sourceSHA256'];expected=authored('reached-v1/'+name+'.stdout');assert sha(expected)==variant['expectedSHA256']
 changed=[j for j,(a,b) in enumerate(zip(EXPECTED.splitlines(),expected.splitlines())) if a!=b];assert len(expected.splitlines())==len(EXPECTED.splitlines())==15 and changed==variant['changedRows']
 original=data(plans['js']['stage']+'/study/production-adoption-v1/authoring-v1/registered.bend');assert original.count(variant['old'].encode())==1;edited=original.replace(variant['old'].encode(),variant['new'].encode())
 for label in ['mutant-source','mutant-js','mutant-native']:
  p=plans[label];r=receipts[label];base=str(Path(C[label]['planPath']).parent);stage=p['stage']
  for rel,digest in plans['js']['inventory'].items():
   copy=data(stage+'/'+name+'/'+rel)
   assert copy==(edited if rel=='study/production-adoption-v1/authoring-v1/registered.bend' else data(plans['js']['stage']+'/'+rel))
  if label=='mutant-source':assert data(base+'/'+name+'.stdout')==POSITIVE and data(base+'/'+name+'.stderr') in [b'',NOTICE]
  else:
   assert data(base+'/'+name+'-candidate.stdout')==expected and data(base+'/'+name+'-candidate.stderr')==b''
   assert data(base+'/'+name+'-emit.stdout')==b'' and data(base+'/'+name+'-emit.stderr') in [b'',NOTICE]
   if label=='mutant-native':assert data(base+'/'+name+'-compile.stdout')==data(base+'/'+name+'-compile.stderr')==b''
print('PASS current normal prerequisites + two reached full15-line JS/Native counterfactuals; no proof/full56/public adoption')
