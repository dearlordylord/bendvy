"""Portable retained full IO Native116 and unchanged42 evidence; read/hash/model only, no children."""
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
 d=H/'delivery-aligned-native-correctness-v1';m=strict((d/'manifest.json').read_bytes())
 assert sha(Path(__file__).read_bytes())==m['verifierSHA256'] and sha((d/'REPORT.md').read_bytes())==m['reportSHA256']
 assert sha((H/'delivery-aligned-correctness-v1/manifest.json').read_bytes())==m['prerequisite']['manifestSHA256']
 assert sha((H/'verify-aligned-correctness-handoff.py').read_bytes())==m['prerequisite']['verifierSHA256']
 load(H/'verify-aligned-correctness-handoff.py','retained_ledger_js').verify()
 a=m['archive'];assert sha((d/a['name']).read_bytes())==a['sha256']
 with tarfile.open(d/a['name']) as t:
  entries=t.getmembers();assert len(entries)==len({e.name for e in entries}) and all(e.isfile() for e in entries)
  assert {e.name for e in entries}==set(a['members']);data={e.name:t.extractfile(e).read() for e in entries}
 for name,b in data.items():assert sha(b)==a['members'][name]['sha256'] and len(b)==a['members'][name]['bytes']
 for name,digest in m['source'].items():
  rel=Path(name);assert not rel.is_absolute() and '..' not in rel.parts
  assert sha((H/rel).read_bytes())==digest==sha(data['source/'+name])
 obj=lambda n:strict(data[n]);actual={};joins={}
 priorManifest=strict((H/'delivery-aligned-correctness-v1/manifest.json').read_bytes())
 with tarfile.open(H/'delivery-aligned-correctness-v1'/priorManifest['archive']['name']) as t:
  priorData={e.name:t.extractfile(e).read() for e in t.getmembers()}
 priorPlan=strict(priorData['js/plan.json'])
 assert set(m['pinDispositions'])==set(m['generatedDispositions'])=={'A-diagnostic','B-diagnostic','A-runtime','B-runtime'}
 admitted={'A-diagnostic':('16ab4a26364c798a058003eec52893e68c6479a2752a7da9fe4ffdcbc2a51058','39e776ca3b4603d0b0f28983d494cc89bb28f5cb8580d1c48a98a7894d6b4a8a'),'B-diagnostic':('abb8528948e21351c65081b4f2c21a72c74a4ed781c6934d50553b868ed40291','ef3ac042502e3bb55ba2a3255fc26250b14d297fd39568c931e01e341739b443'),'A-runtime':('3e709322c39d5b7cc664ae5ac2919ecaef7edb0113fd63c5e70cbd1365e98a76','49c934ac96a957cac57c01d08fae7afe5c5820fe4e86a81b7548e75ab1402d94'),'B-runtime':('519cda2f27deb848f4968d4ba4c65a3ca6d54aa6573bb845226386db5e900739','a02c0fd8e91097f3d90a551b4973fbea966eabcd49a8c1ac27e58bce72ceccc0')}
 for key,(planSHA,receiptSHA) in admitted.items():
  p=obj(key+'/plan.json');r=obj(key+'/receipt.json');schema=key[0];runtime=key.endswith('runtime')
  assert sha(data[key+'/plan.json'])==planSHA==r['planSHA256'] and sha(data[key+'/receipt.json'])==receiptSHA
  expectedStatus=('SCHEMA_'+schema+'_COMPLETE58_AND21_ALIGNED_IO_NATIVE_CORRECTNESS_PASS_NO_FULL116_TIMING_CREDIT' if runtime else 'SCHEMA_'+schema+'_ALIGNED_WHOLE_IO_SOURCE_C_EMISSION_PASS_NO_RUNTIME_TIMING_CREDIT')
  assert r['status']==expectedStatus and not r.get('guardFailures',[])
  dispositions=m['pinDispositions'][key];assert set(dispositions)==set(p['pins'])
  for name,digest in p['pins'].items():
   entry=dispositions[name];assert entry['sha256']==digest
   if entry['kind']=='archive':assert sha(data[entry['member']])==digest
   elif entry['kind']=='qualifiedAlignedArchive':assert sha(priorData[entry['member']])==digest
   elif entry['kind']=='qualifiedAlignedScalarPin':assert entry['path']==name and priorPlan['pins'][name]==digest
   else:
    assert entry['kind']=='privateEnvironmentIdentityExcluded' and Path(name).name=='private-environment.json'
    owner=obj(entry['ownerMember']);assert owner['privateEnvironment']==name and owner['environmentSHA256']==digest
  generated=m['generatedDispositions'][key];assert set(generated)==set(r['generated'])
  for name,digest in r['generated'].items():
   entry=generated[name];assert entry['sha256']==digest
   if runtime:
    assert entry['kind']=='generatedELFIdentityExcluded' and name==p['commands'][0]['generated']==p['commands'][1]['argv'][3]
    assert Path(name).name=='aligned-ledger-'+schema
   else:assert entry['kind']=='archive' and sha(data[entry['member']])==digest
  assert len(p['commands'])==len(r['commands'])==2 and [c['seconds'] for c in p['commands']]==([120,5] if runtime else [5,30])
  assert all(c['exit']==0 and c['failure'] is None for c in r['commands'])
  prefix=[p['tools']['taskset'],'-c','8'];out=Path(p['stage']).parent
  assert prefix==['/usr/bin/taskset','-c','8']
  if runtime:
   cfile=p['commands'][0]['argv'][5];binary=out/('aligned-ledger-'+schema)
   assert p['commands']==[{'label':'aligned-native-clang','argv':prefix+[p['tools']['tools']['clang-wrapper'],'-O3',cfile,'-pthread','-lm','-o',str(binary)],'seconds':120,'expected':0,'generated':str(binary)}, {'label':'aligned-native-run','argv':prefix+[str(binary),'--threads','1','--gpu','off'],'seconds':5,'expected':0,'oracle':True}]
   assert set(r['generated'])=={str(binary)}
  else:
   root=Path(p['stage'])/'capture-alignment-source-v1'/('native-'+schema+'.bend');cfile=out/('aligned-ledger-'+schema+'.c')
   assert p['commands']==[{'label':'aligned-native-source','argv':prefix+[p['tools']['tools']['bend'],str(root),'--check-only'],'seconds':5,'expected':0}, {'label':'aligned-native-emit','argv':prefix+[p['tools']['tools']['bend'],str(root),'-o',str(cfile)],'seconds':30,'expected':0,'generated':str(cfile)}]
   assert set(r['generated'])=={str(cfile)}
  taskRunner=Path(m['archivedRoot']).parents[4]/'scripts/task_runner.py'
  assert p['pins'][str(taskRunner)]=='f6e3e815ede2d24dc80825f156ace534956d2f61ef559a09253bf97504e746b7'

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
   assert meta['runnerSHA256']==p['pins'][str(taskRunner)]==r['commands'][0]['runnerSHA256']==r['commands'][1]['runnerSHA256']
  if runtime:
   assert p['sourceDiagnosticPlanSHA256']==admitted[schema+'-diagnostic'][0] and p['sourceDiagnosticReceiptSHA256']==admitted[schema+'-diagnostic'][1]
   c=Path(p['commands'][0]['argv'][5]);assert sha(data[schema+'-diagnostic/'+c.name])==p['pins'][str(c)]
   assert p['commands'][1]['argv'][-4:]==['--threads','1','--gpu','off']
   raw=data[key+'/'+p['commands'][1]['label']+'.stdout'];strict(raw)
   result=load(H/'capture-alignment-source-v1/validate-schema.py','schema_'+schema).validate(schema,raw)
   assert result['status']==r['independentValidationStatus'];actual[schema]=strict(raw)[schema]
   joins[schema]={'planSHA256':planSHA,'receiptSHA256':receiptSHA,'stdoutSHA256':sha(raw)}
  else:
   for name,digest in r['generated'].items():assert sha(data[key+'/'+Path(name).name])==digest
 union=obj('union/receipt.json');assert sha(data['union/receipt.json'])=='7e52bfa7c2f5b6b1c871005d6e1dd0e1294d01f4c384f56d949b56a37ba64cd2'
 assert union['qualifications']==joins and union['backendSubjectsExecuted']==0 and union['unionSHA256']==sha(data['union/full116.json'])
 canonical=lambda v:json.dumps(v,sort_keys=True,separators=(',',':'),ensure_ascii=False)
 assert canonical(strict(data['union/full116.json']))==canonical(actual)
 result=load(H/'capture-alignment-source-v1/validate-correctness.py','full_native_ledger').validate(json.dumps(actual))
 assert canonical(result)==canonical(union['validation'])
 assert union['status']=='FULL116_ALIGNED_CAPTURES_AND_UNCHANGED42_NATIVE_CORRECTNESS_RECONCILED_NO_TIMING_CREDIT'
 print('PORTABLE_FULL116_ALIGNED_NATIVE_AND_UNCHANGED42_CORRECTNESS_PASS_NO_TIMING_CREDIT')
if __name__=='__main__':verify()
