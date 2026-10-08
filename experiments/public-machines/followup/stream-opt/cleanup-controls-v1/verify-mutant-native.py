"""Portable finite reached Native cleanup mutation evidence, archived model only; no children."""
import hashlib, importlib.util, json, tarfile, tempfile
from pathlib import Path
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
def verify():
 o=H/'delivery-mutant-native-v1';m=json.loads((o/'manifest.json').read_text());assert sha(Path(__file__).read_bytes())==m['verifierSHA256']
 root=H.parents[4]
 for n,h in m['prerequisiteFiles'].items():assert sha((root/n).read_bytes())==h,n
 spec=importlib.util.spec_from_file_location('cleanup_js_prerequisite',H/'verify-mutant-js.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v);v.verify()
 spec=importlib.util.spec_from_file_location('normal_native_cleanup_prerequisite',H/'verify-native.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v);v.verify()
 assert sha((H/'run-mutant-native.py').read_bytes())==m['runnerSHA256'] and sha((o/'REPORT.md').read_bytes())==m['reportSHA256'] and sha((o/'cohort.tar.gz').read_bytes())==m['archive']['sha256']
 with tarfile.open(o/'cohort.tar.gz') as t:
  entries=t.getmembers();assert len(entries)==len({x.name for x in entries}) and all(x.isfile() and not Path(x.name).is_absolute() and '..' not in Path(x.name).parts for x in entries);data={x.name:t.extractfile(x).read() for x in entries}
 assert set(data)==set(m['archive']['members'])
 for n,b in data.items():assert sha(b)==m['archive']['members'][n]['sha256'] and len(b)==m['archive']['members'][n]['bytes']
 p=json.loads(data['plan.json']);r=json.loads(data['receipt.json']);d=Path(m['originalDirectory']);originalH=d.parent
 assert p['pins'][str(originalH/'run-mutant-native.py')]==m['runnerSHA256']
 assert sha(data['plan.json'])==m['planSHA256']==r['planSHA256']=='4e84a27391c44c0138dc55fb0c53955034661b2a30bcbd1bff91d398ce96b4fe'
 assert sha(data['receipt.json'])==m['receiptSHA256']=='8e30e24a6af7e1fcedfd615159382a17bd3877a0a2c9abd1ac25533592395d0d' and not r.get('guardFailures',[])
 assert r['status']=='COMPLETE_TWO_SCHEMA_REJECTED_DISPOSAL_DELETION_MUTANT_NATIVE_FULL_ORACLE_AND_WITNESSES_PASS' and r['completeWorldRows']==36 and r['completeInstanceRecords']==22
 assert {n.removeprefix('stage/'):sha(b) for n,b in data.items() if n.startswith('stage/')}==p['inventory'] and len(p['inventory'])==90
 assert set(m['pinDispositions'])==set(p['pins'])
 for n,h in p['pins'].items():
  x=m['pinDispositions'][n];assert x['sha256']==h
  if x['kind']=='archive':assert sha(data[x['member']])==h
  elif x['kind']=='installedIdentityExcluded':assert p['tools']['pins'][n]==h
  else:assert x['kind']=='privateEnvironmentIdentityExcluded' and n==p['environment'] and h==p['environmentSHA256']
 prefix=[p['tools']['taskset'],'-c','8'];target=Path(p['stage'])/'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/caller.bend';c=d/'application.c';elf=d/'application-native'
 expected=[{'label':'emit-c','argv':prefix+[p['tools']['tools']['bend'],str(target),'-o',str(c)],'seconds':30,'generated':str(c)},{'label':'clang','argv':prefix+['/tmp/bendvy-clang19-diagnostic/clang19','-O3',str(c),'-o',str(elf),'-pthread','-lm'],'seconds':120,'generated':str(elf)},{'label':'consumer','argv':prefix+[str(elf),'--threads','1','--gpu','off'],'seconds':5}]
 assert p['commands']==expected and len(r['commands'])==3
 runner=p['pins'][str(originalH.parents[4]/'scripts/task_runner.py')]
 for x,y in zip(expected,r['commands']):assert all(y[k]==x[k] for k in ['label','argv','seconds']) and y['exit']==0 and y['failure'] is None and y['status']=='TERMINAL' and y['runnerSHA256']==runner
 names={x['label']+s for x in expected for s in ['.stdout','.stderr']};assert set(r['logs'])==names and {n for n in data if '/' not in n and n.endswith(('.stdout','.stderr'))}==names
 for n,h in r['logs'].items():assert sha(data[n])==h
 notice=(H/'known-notice.txt').read_bytes();assert sha(notice)=='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
 assert data['emit-c.stdout']==data['clang.stdout']==data['clang.stderr']==data['consumer.stderr']==b'' and data['emit-c.stderr'] in [b'',notice]
 assert set(r['generated'])==set(m['generatedDispositions'])=={str(c),str(elf)}
 for n,h in r['generated'].items():
  x=m['generatedDispositions'][n];assert x['sha256']==h
  if n==str(c):assert x['kind']=='archive' and sha(data[x['member']])==h
  else:assert x['kind']=='generatedELFIdentityExcluded' and x['bytes']>0
 tools=[n for n in p['tools']['tools'] if n not in p['tools']['skip_ldd']];labels=['guard-'+str(i)+'-ldd-'+n for i in range(7) for n in tools]
 assert len(tools)==7 and p['executionProbeLabels']==labels and p['expectedProbeCount']==r['probeCommandsExecuted']==49
 names={n+s for n in labels for s in ['.json','.stdout','.stderr']};assert {n.removeprefix('execution-probes/') for n in data if n.startswith('execution-probes/')}==names and set(r['probePins'])=={str(d/'execution-probes'/n) for n in names}
 for n,h in r['probePins'].items():assert sha(data['execution-probes/'+Path(n).name])==h
 for n in labels:
  x=json.loads(data['execution-probes/'+n+'.json']);tool=n.split('-ldd-',1)[1];assert x['argv']==prefix+[p['tools']['ldd'],p['tools']['tools'][tool]] and x['seconds']==5 and x['exit']==0 and x['failure'] is None and x['exception'] is None and x['runnerSHA256']==runner
 jm=json.loads((H/'delivery-mutant-js-v1/manifest.json').read_text())
 for n,h in jm['sources'].items():
  if n!='metadata-deadlock-observation.json':assert p['pins'][str(originalH/n)]==h
 with tarfile.open(H/'delivery-js-v1/cohort.tar.gz') as t:jd={x.name:t.extractfile(x).read() for x in t.getmembers()}
 with tarfile.open(H/'delivery-mutant-js-v1/cohort.tar.gz') as t:mutantData={x.name:t.extractfile(x).read() for x in t.getmembers()}
 assert p['inventory']==json.loads(mutantData['JS/plan.json'])['inventory']
 assert data['stage/experiments/public-machines/followup/stream-opt/cleanup-controls-v1/caller.bend']==jd['source/caller.bend']
 assert data['stage/experiments/public-machines/followup/stream-opt/cleanup-controls-v1/caller-core.bend']==mutantData['source/mutant-caller-core.bend']
 with tempfile.TemporaryDirectory(prefix='cleanup-native-archived-model-') as directory:
  root=Path(directory)
  for n,b in jd.items():
   if n.startswith('model-root/'):
    q=root/n.removeprefix('model-root/');q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(b)
  caller=root/'caller';caller.mkdir();s=jd['source/model.py'].decode();literal="ROOT = Path('/workspace/formal-proofs/bendvy')";assert s.count(literal)==1;(caller/'model.py').write_text(s.replace(literal,'ROOT = Path('+repr(str(root))+')'))
  (caller/'expected.json').write_bytes(jd['source/expected.json'])
  for n in ['mutant-model.py','mutant-expected.json','validate-mutant.py']:(caller/n).write_bytes(mutantData['source/'+n])
  spec=importlib.util.spec_from_file_location('native_archived_cleanup',caller/'validate-mutant.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v);observed=v.validate(data['consumer.stdout']);normal=json.loads(jd['source/expected.json']);assert json.dumps(observed,sort_keys=True)!=json.dumps(normal,sort_keys=True)
  assert r['reachedWitnessSchemas']==['A','B']
  for schema in ['A','B']:
   rejected=next(v for v in observed[schema]['worlds']['B'] if v['label']=='foreign-disposal-rejected');assert 'positions=[]' in rejected['fields']['flowStream'] and 'positions=[]' in rejected['fields']['levelStream']
   assert observed[schema]['instances'][-2]=='B-survivor-delivery=[actual:flow=[Boot>Play]:level=[]:lagged=false,false]'
 print('PORTABLE_REACHED_CLEANUP_MUTANT_NATIVE36_WORLD22_INSTANCE_FULL_ORACLE_BOTH_WITNESSES_PASS')
if __name__=='__main__':verify()
