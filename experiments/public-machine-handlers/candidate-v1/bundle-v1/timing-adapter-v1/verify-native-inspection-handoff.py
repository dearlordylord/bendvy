"""Portable read/hash-only thin Native C dependency inspection; no binary runs."""
from pathlib import Path
import hashlib,json,tarfile,importlib.util
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
def verify():
 m=json.loads((H/'delivery-native-inspection-v1/manifest.json').read_text());assert sha(Path(__file__).read_bytes())==m['verifierSHA256'];assert sha((H/'delivery-native-inspection-v1/REPORT.md').read_bytes())==m['reportSHA256']
 for file,key in [('delivery-v1/manifest.json','manifestSHA256'),('verify-handoff.py','verifierSHA256'),('delivery-v1/inspection.tar.gz','archiveSHA256')]:assert sha((H/file).read_bytes())==m['prerequisite'][key]
 spec=importlib.util.spec_from_file_location('qualified_same_owner_js_inspection',H/'verify-handoff.py');previous=importlib.util.module_from_spec(spec);spec.loader.exec_module(previous);previous.verify()
 a=m['archive'];assert sha((H/'delivery-native-inspection-v1'/a['name']).read_bytes())==a['sha256']
 with tarfile.open(H/'delivery-native-inspection-v1'/a['name']) as archive:
  entries=archive.getmembers();assert len(entries)==len({x.name for x in entries});assert all(x.isfile() for x in entries);assert {x.name for x in entries}==set(a['members']);data={x.name:archive.extractfile(x).read() for x in entries}
 for name,b in data.items():assert sha(b)==a['members'][name]['sha256'] and len(b)==a['members'][name]['bytes']
 obj=lambda n:json.loads(data[n]);p=obj('native/plan.json');r=obj('native/receipt.json')
 assert sha(data['native/plan.json'])==r['planSHA256']==m['planSHA256']=='6de1c0f4da84987a2ff7f5240858858003b107f33daa44dc9404efc4c1186cfa'
 assert sha(data['native/receipt.json'])==m['receiptSHA256'];assert r['status']=='NATIVE_SOURCE_AND_C_DEPENDENCY_EMISSION_PASS_NO_RUNTIME_TIMING_CREDIT' and not r.get('guardFailures',[])
 main=str(Path(p['stage'])/'experiments/public-machine-handlers/candidate-v1/bundle-v1/native-clock-inspection.bend');prefix=[p['tools']['taskset'],'-c','8']
 assert p['commands']==[{'label':'native-source-check','argv':prefix+[p['tools']['tools']['bend'],main,'--check-only'],'seconds':5,'expected':0},{'label':'native-clock-emit','argv':prefix+[p['tools']['tools']['bend'],main,'-o',str(Path(p['stage']).parent/'clock-inspection.c')],'seconds':30,'generated':str(Path(p['stage']).parent/'clock-inspection.c'),'expected':0}]
 assert {name.split('/')[1] for name in data if name.startswith('native/')}=={'plan.json','receipt.json','clock-inspection.c','stage','execution-probes','native-source-check.stdout','native-source-check.stderr','native-clock-emit.stdout','native-clock-emit.stderr'}
 assert len(p['commands'])==len(r['commands'])==2 and [c['seconds'] for c in p['commands']]==[5,30] and [c['label'] for c in p['commands']]==['native-source-check','native-clock-emit']
 assert [c['exit'] for c in r['commands']]==[0,0] and all(c['failure'] is None for c in r['commands']) and len(p['pins'])==1512
 labels=[c['label'] for c in p['commands']];raw={label+suffix for label in labels for suffix in ['.stdout','.stderr']};assert set(r['logs'])==raw
 assert {n.removeprefix('native/') for n in data if n.startswith('native/') and n.endswith(('.stdout','.stderr')) and '/execution-probes/' not in n}==raw
 for name,h in r['logs'].items():assert sha(data['native/'+name])==h
 assert data['native/native-source-check.stdout']==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n'
 assert all(data['native/'+label+'.stderr']==b'' for label in labels) and data['native/native-clock-emit.stdout']==b''
 expected=['guard-'+str(i)+'-ldd-'+tool for i in range(5) for tool in ['bend','node','python','taskset','clang']];assert p['executionProbeLabels']==expected and r['probeCommandsExecuted']==25
 probes={label+suffix for label in expected for suffix in ['.json','.stdout','.stderr']};assert {n.removeprefix('native/execution-probes/') for n in data if n.startswith('native/execution-probes/')}==probes
 assert set(r['probePins'])=={str(Path(p['stage']).parent/'execution-probes'/n) for n in probes}
 for name,h in r['probePins'].items():assert sha(data['native/execution-probes/'+Path(name).name])==h
 for label in expected:
  proof=obj('native/execution-probes/'+label+'.json');tool=label.rsplit('-ldd-',1)[1];assert proof['seconds']==5 and proof['exit']==0 and proof['failure'] is None and proof.get('exception') is None
  assert proof['argv']==[p['tools']['taskset'],'-c','8',p['tools']['ldd'],p['tools']['tools'][tool]]
 assert {name.removeprefix('native/stage/'):sha(b) for name,b in data.items() if name.startswith('native/stage/')}==p['inventory']
 generated='native/clock-inspection.c';assert sha(data[generated])==m['generatedSHA256']==r['generated'][str(Path(p['stage']).parent/'clock-inspection.c')]
 manifest=obj('source/proposal/source-joins.json');assert sha(data['source/proposal/source-joins.json'])==p['sourceReviewManifestSHA256']==m['sourceProposalSHA256']
 original=[Path(n) for n,h in p['pins'].items() if n.endswith('/native-inspection-proposal-v1/main.bend') and h==manifest['mainSHA256']];assert len(original)==1
 originalStage=original[0].parent.parent/'stage';assert original[0].parent.name=='native-inspection-proposal-v1'
 for name,h in manifest['closure'].items():
  source=Path(name)
  if source==original[0]:assert sha(data['source/proposal/main.bend'])==h==p['pins'][name]
  else:
   relative=source.relative_to(originalStage);assert not relative.is_absolute() and '..' not in relative.parts
   assert sha(data['native/stage/'+str(relative)])==h==p['pins'][name]
 expectedRoot=data['source/proposal/main.bend'].decode().replace('../stage/experiments/public-machine-handlers/candidate-v1/bundle-v1/','')
 assert data['native/stage/experiments/public-machine-handlers/candidate-v1/bundle-v1/native-clock-inspection.bend'].decode()==expectedRoot
 text=data[generated].decode();assert '#define BANGS   0' in text and 'Term req = corpus_eval(e.mem, term_tsk(FID_CLO_APPLY, ap));' in text
 assert 'WL_CASE(FID_CLOCK_STEP_STEP_0_C1068)' in text and 'WL_CONT = term_tsk(FID_CLOCK_STEP_STEP_0_K1069, _t_0);' in text and 'WL_JMP(FID_BATCH_STEP_0);' in text
 assert 'WL_CASE(FID_CLOCK_STEP_COMPLETED_0_C1070)' in text and 'term_clo(FID_IO_NOW, 0)' in text and 'WL_CASE(FID_BATCH_STEPPED_0_K1034)' in text
 assert sha((H/'NATIVE-GENERATED-INSPECTION.md').read_bytes())==sha(data['source/NATIVE-GENERATED-INSPECTION.md'])
 assert sha((H/'run-native-inspection.py').read_bytes())==sha(data['source/run-native-inspection.py'])
 print('PORTABLE_THIN_NATIVE_SOURCE_C_DEPENDENCY_INSPECTION_PASS_NO_RUNTIME_TIMING_CREDIT')
if __name__=='__main__':verify()
