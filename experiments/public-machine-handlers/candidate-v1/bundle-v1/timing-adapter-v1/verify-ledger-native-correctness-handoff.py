"""Portable retained full IO Native42 evidence; read/hash/model only, no children."""
import hashlib,importlib.util,json,tarfile
from pathlib import Path
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
def strict(raw):
 def pairs(items):
  out={}
  for key,value in items:
   assert key not in out;out[key]=value
  return out
 return json.loads(raw,object_pairs_hook=pairs,parse_constant=lambda x:(_ for _ in ()).throw(ValueError(x)))
def load(path,name):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
def verify():
 d=H/'delivery-ledger-native-correctness-v1';m=strict((d/'manifest.json').read_bytes())
 assert sha(Path(__file__).read_bytes())==m['verifierSHA256'] and sha((d/'REPORT.md').read_bytes())==m['reportSHA256']
 assert sha((H/'delivery-ledger-correctness-v1/manifest.json').read_bytes())==m['prerequisite']['manifestSHA256']
 assert sha((H/'verify-ledger-correctness-handoff.py').read_bytes())==m['prerequisite']['verifierSHA256']
 load(H/'verify-ledger-correctness-handoff.py','retained_ledger_js').verify()
 a=m['archive'];assert sha((d/a['name']).read_bytes())==a['sha256']
 with tarfile.open(d/a['name']) as t:
  entries=t.getmembers();assert len(entries)==len({e.name for e in entries}) and all(e.isfile() for e in entries)
  assert {e.name for e in entries}==set(a['members']);data={e.name:t.extractfile(e).read() for e in entries}
 for name,b in data.items():assert sha(b)==a['members'][name]['sha256'] and len(b)==a['members'][name]['bytes']
 for name,digest in m['source'].items():
  rel=Path(name);assert not rel.is_absolute() and '..' not in rel.parts
  assert sha((H/rel).read_bytes())==digest==sha(data['source/'+name])
 obj=lambda n:strict(data[n]);actual={};joins={}
 priorManifest=strict((H/'delivery-ledger-correctness-v1/manifest.json').read_bytes())
 with tarfile.open(H/'delivery-ledger-correctness-v1'/priorManifest['archive']['name']) as t:
  priorData={e.name:t.extractfile(e).read() for e in t.getmembers()}
 priorPlan=strict(priorData['run/plan.json'])
 assert set(m['pinDispositions'])==set(m['generatedDispositions'])=={'A-diagnostic','B-diagnostic','A-runtime','B-runtime'}
 admitted={'A-diagnostic':('65608393ecadcd62c043e0f8e7550469b7a327df9e4a0e4763a0b729d51a8b12','55329b6303e1d3ccdd4034a002f2120df7a11f83137d89edfe89c2e51db3610e'),'A-runtime':('998eaf022d43aaa8d01ddbc0637e5fa076d7a5913b07bfde5b504089a17cb5a9','dffdc05044bd971b0930a98070ec4dde28ed16a0406096a4aa95d76408c08187'),'B-diagnostic':('742c3c3a21c17f7916d81263c0d2cac5a87482be941957e238cc6a043493ef1b','faa5bc0f04948234368f52e37d391ab3f99083b72d8987b1f6900c901880545b'),'B-runtime':('b969a2e3fd6f1e252c67b46136326151249d18101647a7ae3b97dab3d5092190','a20173b92edc1b8643970b566c445358374025845b6aefa45b741f17147500f0')}
 for key,(planSHA,receiptSHA) in admitted.items():
  p=obj(key+'/plan.json');r=obj(key+'/receipt.json');schema=key[0];runtime=key.endswith('runtime')
  assert sha(data[key+'/plan.json'])==planSHA==r['planSHA256'] and sha(data[key+'/receipt.json'])==receiptSHA
  expectedStatus=('SCHEMA_'+schema+'_COMPLETE21_IO_LEDGER_NATIVE_CORRECTNESS_PASS_NO_FULL42_TIMING_CREDIT' if runtime else 'SCHEMA_'+schema+'_COMPLETE_IO_LEDGER_SOURCE_C_EMISSION_PASS_NO_RUNTIME_TIMING_CREDIT')
  assert r['status']==expectedStatus and not r.get('guardFailures',[])
  dispositions=m['pinDispositions'][key];assert set(dispositions)==set(p['pins'])
  for name,digest in p['pins'].items():
   entry=dispositions[name];assert entry['sha256']==digest
   if entry['kind']=='archive':assert sha(data[entry['member']])==digest
   elif entry['kind']=='qualifiedJSArchive':assert sha(priorData[entry['member']])==digest
   elif entry['kind']=='qualifiedJSScalarPin':assert entry['path']==name and priorPlan['pins'][name]==digest
   else:
    assert entry['kind']=='privateEnvironmentIdentityExcluded' and Path(name).name=='private-environment.json'
    owner=priorPlan if entry['plan']=='JS' else obj(entry['plan']+'/plan.json')
    assert owner['privateEnvironment']==name and owner['environmentSHA256']==digest
  generated=m['generatedDispositions'][key];assert set(generated)==set(r['generated'])
  for name,digest in r['generated'].items():
   entry=generated[name];assert entry['sha256']==digest
   if runtime:
    assert entry['kind']=='generatedELFIdentityExcluded' and name==p['commands'][0]['generated']==p['commands'][1]['argv'][3]
    assert Path(name).name=='ledger-'+schema
   else:assert entry['kind']=='archive' and sha(data[entry['member']])==digest
  assert len(p['commands'])==len(r['commands'])==2 and [c['seconds'] for c in p['commands']]==([120,5] if runtime else [5,30])
  assert all(c['exit']==0 and c['failure'] is None for c in r['commands'])
  logs={c['label']+suffix for c in p['commands'] for suffix in ['.stdout','.stderr']};assert set(r['logs'])==logs
  assert {n.removeprefix(key+'/') for n in data if n.startswith(key+'/') and '/' not in n.removeprefix(key+'/') and n.endswith(('.stdout','.stderr'))}==logs
  for name,digest in r['logs'].items():assert sha(data[key+'/'+name])==digest
  assert all(data[key+'/'+c['label']+'.stderr']==b'' for c in p['commands'])
  assert data[key+'/'+p['commands'][0]['label']+'.stdout']==(b'' if runtime else b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n')
  if not runtime:assert data[key+'/'+p['commands'][1]['label']+'.stdout']==b''
  assert {n.removeprefix(key+'/stage/'):sha(b) for n,b in data.items() if n.startswith(key+'/stage/')}==p['inventory']
  labels=['guard-'+str(i)+'-ldd-'+tool for i in range(5) for tool in ['bend','node','python','taskset','clang']]
  assert p['executionProbeLabels']==labels and r['probeCommandsExecuted']==25
  members={label+suffix for label in labels for suffix in ['.json','.stdout','.stderr']}
  assert {n.removeprefix(key+'/execution-probes/') for n in data if n.startswith(key+'/execution-probes/')}==members
  original=Path(p['stage']).parent/'execution-probes';assert set(r['probePins'])=={str(original/n) for n in members}
  for name,digest in r['probePins'].items():assert sha(data[key+'/execution-probes/'+Path(name).name])==digest
  for label in labels:
   meta=obj(key+'/execution-probes/'+label+'.json');tool=label.split('-ldd-',1)[1]
   assert meta['argv']==['/usr/bin/taskset','-c','8','/usr/bin/ldd',p['tools']['tools'][tool]]
   assert meta['seconds']==5 and meta['exit']==0 and meta['failure'] is None and meta.get('exception') is None
   assert meta['runnerSHA256']==r['commands'][0]['runnerSHA256']==r['commands'][1]['runnerSHA256']
  if runtime:
   assert p['sourceDiagnosticPlanSHA256']==admitted[schema+'-diagnostic'][0] and p['sourceDiagnosticReceiptSHA256']==admitted[schema+'-diagnostic'][1]
   c=Path(p['commands'][0]['argv'][5]);assert sha(data[schema+'-diagnostic/'+c.name])==p['pins'][str(c)]
   assert p['commands'][1]['argv'][-4:]==['--threads','1','--gpu','off']
   raw=data[key+'/'+p['commands'][1]['label']+'.stdout'];strict(raw)
   result=load(H/'ledger-native-source-v1/validate-schema.py','schema_'+schema).validate(schema,raw)
   assert result['status']==r['independentValidationStatus'];actual[schema]=result['physical'][schema]
   joins[schema]={'planSHA256':planSHA,'receiptSHA256':receiptSHA,'stdoutSHA256':sha(raw)}
  else:
   for name,digest in r['generated'].items():assert sha(data[key+'/'+Path(name).name])==digest
 union=obj('union/receipt.json');assert sha(data['union/receipt.json'])=='a683bc9030d18919b48ed4b9f27231472af25225901d3ced714d1c086186b877'
 assert union['qualifications']==joins and union['backendSubjectsExecuted']==0 and union['unionSHA256']==sha(data['union/full42.json'])
 canonical=lambda v:json.dumps(v,sort_keys=True,separators=(',',':'),ensure_ascii=False)
 assert canonical(strict(data['union/full42.json']))==canonical(actual)
 result=load(H/'ledger-driver-source-v1/validate-correctness.py','full_native_ledger').validate(json.dumps(actual))
 assert canonical(result)==canonical(union['validation'])
 assert union['status']=='FULL42_SAME_OWNER_IO_LEDGER_NATIVE_CORRECTNESS_RECONCILED_NO_TIMING_CREDIT'
 print('PORTABLE_FULL42_SAME_OWNER_IO_LEDGER_NATIVE_CORRECTNESS_PASS_NO_TIMING_CREDIT')
if __name__=='__main__':verify()
