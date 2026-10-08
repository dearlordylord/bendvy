"""Portable connected declaration evidence audit; no child processes."""
from pathlib import Path
import hashlib,json,tarfile,re,os,argparse
H=Path(__file__).resolve().parent;E=H/'declaration-evidence-v1';I=json.loads((E/'index.json').read_text());sha=lambda b:hashlib.sha256(b).hexdigest()
assert sha((E/'objects.tar.gz').read_bytes())==I['archiveSHA256']
with tarfile.open(E/'objects.tar.gz') as tar:
 members=tar.getmembers();assert all(m.isfile() and len(m.name)==64 and all(c in '0123456789abcdef' for c in m.name) for m in members);assert len({m.name for m in members})==len(members)
 objects={m.name:tar.extractfile(m).read() for m in members}
assert set(objects)==set(I['records'].values()) and all(sha(b)==digest for digest,b in objects.items())
def data(path):return objects[I['records'][str(path)]]
def identity(path):return I['records'].get(path) or I['excluded'].get(path,{}).get('sha256')
AP=json.loads(data(I['cohorts']['js']['planPath']));AH=Path(next(n for n in AP['pins'] if n.endswith('/description-v1/full-dto-v1/main-v2.bend'))).parent
assert len([n for n in AP['pins'] if n.endswith('/description-v1/full-dto-v1/main-v2.bend')])==1
def strict(a,b):
 if type(a) is not type(b):return False
 if isinstance(a,dict):return a.keys()==b.keys() and all(strict(a[k],b[k]) for k in a)
 if isinstance(a,list):return len(a)==len(b) and all(strict(x,y) for x,y in zip(a,b))
 return a==b
LITERALS={
 'io':('d2036f262c4de1462729b41320a929dc0c1e21916daf9f4896179150223fef71','36fa439a795b31b46810ad7f0ffa518d219450a43ae89d586b797dc87bc6d9b5',1,'DEVELOPMENT_ACTUAL_DECLARATION_IO_FULL_DTO2_PASS_NOT_JS_NATIVE_DELIVERY_FULL56'),
 'js':('4e9987d1d36ec92de0f84b8737eb4c90217bfcb0bb9b0bf45297394e0c968be2','4f653e876a0940c85aaf12a6c590bbcfaa1c6627ac32a6faf65a932a598cb4dc',2,'DEVELOPMENT_ACTUAL_DECLARATION_JS_FULL_DTO2_PASS_NOT_NATIVE_DELIVERY_FULL56'),
 'native':('27ab529d6e5861a4ad3dc609406912bb6e062ddc7014bc86ff8caf0b66431b27','ba68e6569547be823a6ed0df4659cdac9d22fc419a181d5d9f84c2e5582f8b99',3,'NATIVE_DECLARATION_FULL_DTO2_QUALIFIED_NOT_FULL56_NOT_PROOF_NOT_PERFORMANCE'),
 'authority-original':('64256e4e061dee05ee22a6cbb8aee0d9084e7dd835908e21edcf03f3775cfdbc','e4149ea5d8f07e8978a77f943c4d9d2f5ed86afe9da7b7e7afb306a03e857376',7,'DECLARATION_AUTHORITY_RAW_COLLECTED_UNCLASSIFIED_NOT_PROOF_FULL56'),
 'authority-repair':('8f3de82ded3e662d840226c94aba8058c21ba799b901882318919b0f8fe62686','f1c89a715ffd184fc1b285b9d1fbc9f6b8ba5b2a8aae192e66e8774506cb6fee',2,'DECLARATION_AUTHORITY_RAW_COLLECTED_UNCLASSIFIED_NOT_PROOF_FULL56'),
 'mutant-source':('c342cbfd574a2ec63491ab6a01ee9c5a04b6a52ed0b9872f1fd7b0dfcff29ea9','e875ec6501fbc503cf06fe3db4b9b1ee352c841e0a742e12a9187b4943e756a9',3,'DECLARATION_COUNTERFACTUAL_SOURCE_FEASIBLE_NOT_REACHED_NOT_PROOF_FULL56'),
 'mutant-native':('c5b55a31e5c42c4ddb17e36724353427a42e4bc54f4ff1a3e566a7945f3e0594','e85b77fa5dee40f1b531a44147c0d5358743d82320a34e5dba095ff4379d8fba',9,'NATIVE_DECLARATION_FULL_DTO2_COUNTERFACTUALS_REACHED_NOT_FULL56_NOT_PROOF_NOT_PERFORMANCE'),
 'mutant-js':('12c1bab8b9bd323f6131bf7fab0469b9e8da4785b9dfb7065ce45e7cdac928c0','c1193f91b0b1bc2b9474d0913a1baf94d87975515c2811421bacb7ab1646816c',6,'DECLARATION_JS_FULL_DTO2_COUNTERFACTUALS_REACHED_NOT_NATIVE_PROOF_FULL56')}
def copy_join(p,stageRoot,variant=None):
 root=Path('/workspace/formal-proofs/bendvy/src/ecs');study=AH.parent
 for name in p['inventory']:
  absolute=Path(p['stage'])/name
  if not absolute.is_relative_to(stageRoot):continue
  relative=absolute.relative_to(stageRoot)
  if str(relative).startswith('variants/'):continue
  if str(relative).startswith('src/ecs/'):source=root/relative.relative_to('src/ecs')
  elif str(relative).startswith('study/'):source=study/relative.relative_to('study')
  else:continue
  if source.suffix!='.bend':
   if source.is_relative_to(root):assert data(str(absolute))==data(str(source))
   continue
  text=data(str(source)).decode()
  if variant and str(relative)=='study/full-dto-v1/'+variant['source']:
   assert sha(text.encode())==variant['normalSHA256'] and text.count(variant['old'])==1;text=text.replace(variant['old'],variant['new']);assert sha(text.encode())==variant['mutantSHA256']
  for imported in re.findall(r'^\s*import\s+(\S+)',text,re.M):
   if imported=='Base':continue
   foreign=imported.startswith('"');child=(source.parent/imported.strip('"')).resolve() if not imported.startswith('/') else Path(imported)
   target=Path(stageRoot)/'src/ecs'/child.relative_to(root) if child.is_relative_to(root) else Path(stageRoot)/'study'/child.relative_to(study)
   # Each reached import target is an exact archive member, not a guessed resolver path.
   assert str(target) in I['records']
   if foreign:assert data(str(target))==data(str(child))
   relocated=os.path.relpath(target,absolute.parent);relocated=relocated if relocated.startswith('.') else './'+relocated
   text=re.sub(r'(^\s*import\s+)'+re.escape(imported)+r'(?=\s|$)',lambda m:m.group(1)+('"'+relocated+'"' if foreign else relocated),text,flags=re.M)
  assert data(str(absolute))==text.encode()
notice=b'bend 2.0.36 is available: run bend update\n';assert sha(notice)=='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494';banner=b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n'
assert set(I['cohorts'])==set(LITERALS)
for label,(ps,rs,count,status) in LITERALS.items():
 entry=I['cohorts'][label];pb=data(entry['planPath']);rb=data(entry['receiptPath']);assert sha(pb)==ps==entry['planSHA256'] and sha(rb)==rs==entry['receiptSHA256'];p=json.loads(pb);r=json.loads(rb);base=str(Path(entry['planPath']).parent)
 assert r['planSHA256']==ps and r['status']==status and not r.get('guardFailures',[]) and not r.get('failure') and not r.get('primaryFailure')
 assert len(p['commands'])==len(r['commands'])==count and len({c['label'] for c in p['commands']})==count
 assert set(r['logs'])=={c['label']+'.'+stream for c in p['commands'] for stream in ['stdout','stderr']}
 assert all(sha(data(base+'/'+name))==digest for name,digest in r['logs'].items())
 assert all(identity(name)==digest for name,digest in p['pins'].items());assert all(identity(n)==v['sha256'] for n,v in p.get('configs',{}).items() if v['kind']=='file');assert identity(p['environment'])==p['environmentSHA256']
 staged={name[len(p['stage'])+1:]:digest for name,digest in I['records'].items() if name.startswith(p['stage']+'/')};assert staged==p['inventory']
 for name,digest in r.get('generated',{}).items():assert sha(data(name))==digest
 if label in ('io','js','native','mutant-js','mutant-native'):
  copy_join(p,Path(p['stage']))
  if label.startswith('mutant-'):
   proposal=json.loads(data(str(AH/'counterfactual-v2/PROPOSAL.json')))
   for variant in proposal['variants']:copy_join(p,Path(p['stage'])/'variants'/variant['name'],variant)
 expectedGenerated={c['artifact'] for c in p['commands'] if 'artifact' in c};assert set(r.get('generated',{}))==expectedGenerated
 for c,a in zip(p['commands'],r['commands']):
  assert all(a[k]==v for k,v in c.items()) and a['failure'] is None and c['argv'][:3]==['/usr/bin/taskset','-c','5']
  name=c['label'];out=data(base+'/'+name+'.stdout');err=data(base+'/'+name+'.stderr')
  if label.startswith('authority'):
   assert c['seconds']==5 and c['argv'][-1]=='--check-only'
   if name=='positive':assert a['exit']==0 and out==banner and err in (b'',notice)
   else:assert a['exit']==1 and out==b'' and err.count(b'Error:')==err.count(b'Location:')==1
  elif label=='mutant-source':assert a['exit']==0 and c['seconds']==5 and c['argv'][-1]=='--check-only' and out==banner and err in (b'',notice)
  elif name.startswith('emit'):
   assert a['exit']==0 and c['seconds']==30 and c['argv'][-2]=='-o' and c['argv'][-1]==c['artifact'] and out==b'' and err in (b'',notice)
  elif name.startswith('compile'):
   assert a['exit']==0 and c['seconds']==120 and c['argv'][4]=='-O3' and c['argv'][-2:]==['-o',c['artifact']] and out==err==b''
  else:
   assert a['exit']==0 and c['seconds']==5 and err in ((b'',notice) if label=='io' else (b'',))
   root=p['variants'][c['variant']]['oracleRoot'] if label in ('mutant-js','mutant-native') else p['stage']+'/study/full-dto-v1'
   assert out==data(root+'/EXPECTED-V2.stdout');lines=out.splitlines();assert len(lines)==6
   assert strict([json.loads(v) for v in lines[:2]],json.loads(data(root+'/ORACLE.json'))['cases'])
   owner=json.loads(data(root+'/OWNER-V2-ORACLE.json'));assert lines[2:]==[('ownerBefore='+owner['before']).encode(),('ownerAfter='+owner['after']).encode(),('registration='+owner['registration']).encode(),('requirements='+owner['requirements']).encode()]
 if label in ('native','mutant-native'):
  snapshot=p['toolSnapshot'];assert all(identity(n)==v for n,v in snapshot['pins'].items());assert snapshot['cpu']==5 and snapshot['cap_seconds']==5 and snapshot['capture_mode']=='split' and snapshot['environment_sha256']==I['environmentJoins'][p['environment']]['ownedCanonicalSHA256'] and I['environmentJoins'][p['environment']]['fileSHA256']==p['environmentSHA256']
  assert p['preparationProbeCommands']==[[snapshot['taskset'],'-c','5',snapshot['ldd'],snapshot['tools'][name]] for name in ['bend','python','clang-native']]
  assert p['pins']['/workspace/formal-proofs/bendvy/scripts/task_runner.py']==identity('/workspace/formal-proofs/bendvy/scripts/task_runner.py') and p['pins']['/workspace/formal-proofs/bendvy/scripts/owned-tool-pins.py']==identity('/workspace/formal-proofs/bendvy/scripts/owned-tool-pins.py')
  probes=r['ordinaryGuardProbes'];assert len(probes)==(24 if label=='native' else 60) and [v['argv'] for v in probes]==p['preparationProbeCommands']*(8 if label=='native' else 20)
  prep=json.loads(data(base+'/prepare-receipt.json'));assert prep['status']=='ORDINARY_PREPARATION_PASS_NO_BACKEND' and not prep.get('guardFailures',[]);assert len(prep['probes'])==3 and [v['argv'] for v in prep['probes']]==p['preparationProbeCommands']
  assert all(v['seconds']==5 and v.get('failure') is None and v.get('exception') is None and v['result']['exit']==0 and v['result']['failure'] is None for v in [*probes,*prep['probes']])
# Full reached witness sets use complete checkpoint objects, never reduced counts.
normalBase=str(Path(I['cohorts']['js']['planPath']).parent);normalLines=data(normalBase+'/candidate.stdout').splitlines();proposalBytes=data(str(AH/'counterfactual-v2/PROPOSAL.json'));assert sha(proposalBytes)=='4c1ae571741d4ac2929d2fad11dc89e1efe4797d61bdd5d3093521c25cae386b';proposal=json.loads(proposalBytes)
for backend in ['mutant-js','mutant-native']:
 entry=I['cohorts'][backend];mp=json.loads(data(entry['planPath']));mb=str(Path(entry['planPath']).parent)
 for variant in proposal['variants']:
  name=variant['name'];actual=data(mb+'/candidate-'+name+'.stdout').splitlines();assert len(actual)==len(normalLines)==6 and [j for j,(a,b) in enumerate(zip(normalLines,actual)) if a!=b]==variant['exactChangedCheckpointIndices'];assert mp['variants'][name]['exactChangedCheckpointIndices']==variant['exactChangedCheckpointIndices']
  mutated=data(str(AH/'counterfactual-v2'/name/variant['source']));original=data(str(AH/variant['source']));assert sha(original)==variant['normalSHA256'] and sha(mutated)==variant['mutantSHA256'] and original.count(variant['old'].encode())==1 and mutated==original.replace(variant['old'].encode(),variant['new'].encode())
# Actual TS2 prerequisite remains a separate reference subject, not a fresh call.
jp=json.loads(data(I['cohorts']['js']['planPath']));ts=jp['referenceReuse'];tpb=data(ts['plan']);trb=data(ts['receipt']);assert sha(tpb)=='7281cc169cc84647fd8aace1e618971a7518dcaf5adbec09d39a05dd479aac8c' and sha(trb)=='9efcb8e84369351f423814c9715607973a6ce3d0c0932cdc0dc334082481126f'
tp=json.loads(tpb);tr=json.loads(trb);assert tr['status']=='DEVELOPMENT_ACTUAL_TS_FULL_DTO2_PASS_NOT_BEND_NOT_DELIVERY_NOT_FULL56' and tr['planSHA256']==sha(tpb) and not tr.get('guardFailures',[]) and not tr.get('failure') and not tr.get('primaryFailure')
assert len(tp['commands'])==len(tr['commands'])==1;tc=tp['commands'][0];assert tc['label']=='reference' and tc['seconds']==5 and tc['argv']==['/usr/bin/taskset','-c','5','/home/node/.local/share/mise/installs/node/24.20.0/bin/node',tp['stage']+'/study/reference.ts'];assert tr['commands']==[{**tc,'exit':0,'failure':None}]
tbase=str(Path(ts['plan']).parent);assert set(tr['logs'])=={'reference.stdout','reference.stderr'} and all(sha(data(tbase+'/'+n))==v for n,v in tr['logs'].items()) and data(tbase+'/reference.stderr')==b''
assert all(identity(n)==v for n,v in tp['pins'].items());assert {n[len(tp['stage'])+1:]:v for n,v in I['records'].items() if n.startswith(tp['stage']+'/')}==tp['inventory']
rows=[json.loads(line) for line in data(tbase+'/reference.stdout').splitlines()];assert len(rows)==2 and strict([{'name':v['name'],'description':v['dto']} for v in rows],json.loads(data(tp['stage']+'/study/ORACLE.json'))['cases']) and all(strict(v['beforeDTO'],v['afterDTO']) and strict(v['dto'],v['afterDTO']) for v in rows)
assert (H/'ORACLE.json').read_bytes()==data(tp['stage']+'/study/ORACLE.json') and (H/'reference.ts').read_bytes()==data(next(n for n in tp['pins'] if n.endswith('/full-dto-v1/reference.ts')))
for name in ['AUTHORITY-V2-CLASSIFICATION.json','AUTHORITY-V3-CLASSIFICATION.json']:assert (H/name).read_bytes()==data(str(AH/name))
# Old failed/trusted preflights retain their own statuses and exact raw ledgers.
for key,ps,rs,status in [('failedIO','99164c03d65a474dd3078c7d949eda6ea3dca09dd0fcb5cbe4fce001f087d3b9','2f32ed1920e2ef06dba27e3d084919bb090f4c37e5378805a5221ea6b0469351','INCOMPLETE'),('trustedPreflight','d5ba21da2bf90418da9a8d1163ef64d002835ac009069e3786dfd4986cc37880','f2e70e5380b8f41ba9801cdf94753080614ecd5b805a36155ad167442ccc0a18','DEVELOPMENT_ACTUAL_BEND_IO_FULL_DTO2_PASS_NOT_JS_NATIVE_DELIVERY_FULL56')]:
 history=jp[key];hpb=data(history['plan']);hrb=data(history['receipt']);assert sha(hpb)==ps and sha(hrb)==rs;hp=json.loads(hpb);hr=json.loads(hrb);hb=str(Path(history['plan']).parent);assert hr['planSHA256']==ps and hr['status']==status and not hr.get('guardFailures',[])
 assert hr['commands']==[{**hp['commands'][0],'exit':0,'failure':None}] and set(hr['logs'])=={'candidate-io.stdout','candidate-io.stderr'} and all(sha(data(hb+'/'+n))==v for n,v in hr['logs'].items());assert {n[len(hp['stage'])+1:]:v for n,v in I['records'].items() if n.startswith(hp['stage']+'/')}==hp['inventory']
 if key=='failedIO':
  for name in ['render.bend','io-runner.py']:
   assert sha(data(str(AH/'source-history/io99164-render-order'/name)))==hp['pins'][str(AH/name)]
failedNative=str(AH/'native-v1/1791449700635179249/FAILURE.json');failure=json.loads(data(failedNative));assert failure['status']=='PREPARATION_FAILED_BEFORE_PROBES_NO_RECEIPT_NO_BACKEND' and failure['probes']==[] and failure['helperSHA256']==sha(data(str(AH/'source-history/native-ab4e-preprobe-failure.py')))
# Separate independent classifications do not relabel original raw receipts.
original=json.loads((H/'AUTHORITY-V2-CLASSIFICATION.json').read_text());repair=json.loads((H/'AUTHORITY-V3-CLASSIFICATION.json').read_text())
for entry in original['cases']:
 assert entry['stderrSHA256']==sha(data(str(Path(I['cohorts']['authority-original']['planPath']).parent/(entry['label']+'.stderr'))))
assert sum(v['classification'].startswith('INTENDED_') for v in original['cases'])==5 and next(v for v in original['cases'] if v['label']=='read-write')['classification']=='REJECTED_NOT_AUTHORITY_EVIDENCE'
assert repair['classification']=='INTENDED_READ_TO_WRITE_REFUSAL' and repair['stderrSHA256']==sha(data(str(Path(I['cohorts']['authority-repair']['planPath']).parent)+'/read-write.stderr'))
dependencies=json.loads((H/'ROOT-DEPENDENCIES.json').read_text());assert len(dependencies['joins'])==25 and set(dependencies['dispositions'])==set(I['cohorts'])
for name,v in dependencies['joins'].items():assert v['tracked'] is True and v['currentMatches'] is True and I['records'][name]==v['sha256'] and name.startswith(('/workspace/formal-proofs/bendvy/src/ecs/','/workspace/formal-proofs/bendvy/scripts/'))
for label,entry in I['cohorts'].items():
 p=json.loads(data(entry['planPath']));expected={'pins':p['pins'],'ordinarySnapshotPins':p.get('toolSnapshot',{}).get('pins',{}),'participatingFileConfigs':{n:v['sha256'] for n,v in p.get('configs',{}).items() if v['kind']=='file'}}
 for group,rows in expected.items():
  declared=dependencies['dispositions'][label][group];assert set(declared)==set(rows)
  for name,digest in rows.items():assert declared[name]=={'sha256':digest,'disposition':'archive' if I['records'].get(name)==digest else 'identity-only-exclusion'} and identity(name)==digest
assert (H/'EXPECTED-V2.stdout').read_bytes()==data(json.loads(data(I['cohorts']['js']['planPath']))['stage']+'/study/full-dto-v1/EXPECTED-V2.stdout')

parser=argparse.ArgumentParser();parser.add_argument('--root',type=Path);parser.add_argument('--selected-only',action='store_true');args=parser.parse_args();liveRepo=H.parents[4];liveRoot=(args.root or liveRepo).resolve()
selection=json.loads((H/'DECLARATION-FILES.json').read_text());assert len(selection['files'])==62
for name,digest in selection['files'].items():assert sha((liveRepo/name).read_bytes())==digest
for name,v in dependencies['joins'].items():assert sha((liveRoot/Path(name).relative_to(dependencies['root'])).read_bytes())==v['sha256']
if args.selected_only:
 assert liveRoot==liveRepo
 expected=set(selection['files'])|{str(Path(name).relative_to(dependencies['root'])) for name in dependencies['joins']}|{str((H/'DECLARATION-FILES.json').relative_to(liveRepo))}
 assert {str(f.relative_to(liveRepo)) for f in liveRepo.rglob('*') if f.is_file()}==expected
print('PASS: connected declaration full DTO2/owners/actual requirements IO+JS+Native, classified static boundaries and reached JS+Native controls; no full56/proof/performance claim')
