"""Portable full-count Native mutation evidence; reads bytes/models, no children."""
import hashlib,importlib.util,json,gzip,tarfile
from pathlib import Path
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
LABELS=['queue-capacity','cached-size','oldest-newest-order','dropped-through','successful-cursor']
ADMITTED={'queue-capacity':('5c706c039d9d138a53f3731ae4c82d911c1ad69e27a1d8c3885324c3ee2604e5','4049aab3308b476ca76a8e9a96cdb12437e3bc647d7ffbdce5958b08c2c98e6d'),'cached-size':('5407940d3799ec308a04a40088d700c868d8dc36d11c92165e2d2fec1d2ba864','95d62f242c20b5b373ca4cceacaad6a5e9fe9991331bcc36b4f22b778133fd9a'),'oldest-newest-order':('1094ed6a3748db44613e4a109036b042be2ff6f4e9ed719701bc10cab8e36704','cac8963628168b4634f5538c11e079e3598225d3597bb88a360c2faae9e2d22f'),'dropped-through':('a7eb976cc01a3cc73140f1b5c6624af72f5024874c4b9edc5d4de02ea1315fa0','c13663ac5fbe585ff29cdf324883e498cfe03d3d5b4c7919d84ab1916aad8f08'),'successful-cursor':('b1415d002ee45751013398acc7bd9a051aad7f4810f343e411d6ea7a642e2585','cede7c3e07c219cbd80ab5357814f1928fb8856ada710a2efe04e32b5c8b36e8')}
def load(path,name):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
def strict(body):
 def pairs(items):
  result={}
  for k,v in items:
   assert k not in result;result[k]=v
  return result
 return json.loads(body,object_pairs_hook=pairs,parse_constant=lambda x:(_ for _ in ()).throw(ValueError(x)))
def read_archive(path):
 with tarfile.open(path) as t:
  members=t.getmembers();assert len(members)==len({m.name for m in members}) and all(m.isfile() for m in members)
  assert all(not Path(m.name).is_absolute() and '..' not in Path(m.name).parts for m in members)
  return {m.name:t.extractfile(m).read() for m in members}
def verify():
 folder=H/'delivery-v1';m=strict((folder/'manifest.json').read_bytes());assert sha(Path(__file__).read_bytes())==m['verifierSHA256']
 assert sha((folder/'REPORT.md').read_bytes())==m['reportSHA256']
 for path,digest in m['prerequisite'].items():assert sha((H.parent/path).read_bytes())==digest
 load(H.parent/'validate-linear.py','qualified_machine_positive').main()
 load(H.parent/'validate-controls.py','qualified_machine_js_controls').main()
 data=read_archive(folder/'native-controls.tar.gz');assert sha((folder/'native-controls.tar.gz').read_bytes())==m['archive']['sha256']
 assert set(data)==set(m['archive']['members'])
 for n,b in data.items():assert sha(b)==m['archive']['members'][n]['sha256'] and len(b)==m['archive']['members'][n]['bytes']
 for n,digest in m['source'].items():
  relative=Path(n);assert not relative.is_absolute() and '..' not in relative.parts
  assert sha((H/relative).read_bytes())==digest==sha(data['source/'+n])
 obj=lambda n:strict(data[n])
 normalData=read_archive(H.parent.parent/'evidence/linear-native-v1/cohort.tar.gz');normalPrefix=next(iter({n.split('/')[0] for n in normalData}));normal=obj('prerequisite/normal-native-plan.json')
 assert data['prerequisite/normal-native-plan.json']==normalData[normalPrefix+'/plan.json']
 controlsData=read_archive(H.parent.parent/'evidence/linear-controls-v1/cohort.tar.gz');cp=next(iter({n.split('/')[0] for n in controlsData}));oldControls=strict(controlsData[cp+'/plan.json'])
 controls=load(H.parent/'controls.py','native_control_witness');oracles=load(H.parent/'mutant-oracles.py','native_mutant_expectations');model=load(H.parent.parent/'overflow-model.py','native_complete_model')
 assert set(m['pinDispositions'])==set(m['generatedDispositions'])==set(LABELS)
 originalRoot=Path(m['archivedRoot']);taskRunner=originalRoot.parents[4]/'scripts/task_runner.py'
 for label in LABELS:
  p=obj(label+'/plan.json');r=obj(label+'/receipt.json');planSHA,receiptSHA=ADMITTED[label]
  assert sha(data[label+'/plan.json'])==planSHA==r['planSHA256'] and sha(data[label+'/receipt.json'])==receiptSHA
  assert r['status']=='FULL65537_FOURTEEN_ROWS_BOTH_SCHEMA_'+label+'_NATIVE_MUTANT_REACHED_NO_ISSUE_ACCEPTANCE' and not r.get('guardFailures',[])
  assert p['mutant']==label and p['expectedProbeCount']==49 and len(p['commands'])==len(r['commands'])==3
  assert p['normalNativePlanSHA256']==sha(data['prerequisite/normal-native-plan.json']) and p['normalNativeReceiptSHA256']=='70152f7721b1a601bbfeee8521bf4ac982d02ed3db9dfd5fd42ea6ff2d8bdf2a'
  for field in ['pins','tools','resource_roots','skip_ldd','ldd','taskset','cpu','cap_seconds','environment_sha256','capture_mode']:assert p['tools'][field]==normal['installedTools'][field]
  assert p['resources']==normal['resources'] and p['environmentSHA256']==normal['privateEnvironmentMapSHA256']
  boundary=p['historicalConfigurationBoundary'];assert boundary['path']=='/home/node/.bend/check.json' and boundary['historicalSHA256']==sha(data['source/historical-check-cache.json'])=='2701f29532eebe9f6fc5ed50c50cbfcbc33925cfe033065a86fa7bc8f9f43e5d'
  assert boundary['currentSHA256']==sha(data['source/current-check-cache.json'])=='2323ddd47baf7dd03018bcf923b6c9b4bb306f04c80bce7e21c4e5e62bc3c564'
  before=obj('source/historical-check-cache.json');after=obj('source/current-check-cache.json');assert set(before)==set(after)=={'t','ver','notice'} and {k for k in before if before[k]!=after[k]}=={'t'}
  assert boundary['sourceSHA256']==p['pins'][boundary['sourcePath']]=='d1a3e026f5014f8daec3614df8e39cf261e3fbc47769eb0916fd891bc18703c9' and boundary['completeEnvironmentUnchanged'] is True and boundary['BEND_NO_TELEMETRY']=='1'
  prefix=[p['tools']['taskset'],'-c','7'];assert prefix==['/usr/bin/taskset','-c','7']
  out=Path(p['privateEnvironment']).parent;root=Path(p['stage'])/'experiments/public-machines/followup/overflow.bend';c=out/'application.c';binary=out/'application-native'
  assert p['commands']==[{'label':'emit-c','argv':prefix+[p['tools']['tools']['bend'],str(root),'-o',str(c)],'seconds':30,'expected':0,'generated':str(c)}, {'label':'clang','argv':prefix+[p['tools']['tools']['clang_wrapper'],'-O3',str(c),'-o',str(binary),'-pthread','-lm'],'seconds':120,'expected':0,'generated':str(binary)}, {'label':'native','argv':prefix+[str(binary),'--threads','1','--gpu','off','65537'],'seconds':5,'expected':0,'oracle':True}]
  assert all(set(x)=={'exit','failure','capture','runnerSHA256'} and x['exit']==0 and x['failure'] is None and x['capture']=='split' and x['runnerSHA256']==p['pins'][str(taskRunner)] for x in r['commands'])
  assert p['pins'][str(taskRunner)]=='f6e3e815ede2d24dc80825f156ace534956d2f61ef559a09253bf97504e746b7'
  assert {n.removeprefix(label+'/stage/'):sha(b) for n,b in data.items() if n.startswith(label+'/stage/')}==p['inventory']
  assert len(p['inventory'])==90
  stage=m['stageJoins'][label];assert stage['inventory']==p['inventory'] and stage['historicalRoot'] in oldControls['stageInventories'] and oldControls['stageInventories'][stage['historicalRoot']]==p['inventory']
  differences=[n for n in set(p['inventory'])|set(normal['stageInventory']) if p['inventory'].get(n)!=normal['stageInventory'].get(n)]
  assert differences==[stage['singleMutationJoin']['relativePath']]
  path=differences[0];baseline=data['normal-stage/'+path];mutant=data[label+'/stage/'+path]
  assert sha(baseline)==normal['stageInventory'][path] and controls.apply(label,baseline.decode()).encode()==mutant
  dispositions=m['pinDispositions'][label];assert set(dispositions)==set(p['pins'])
  for path,digest in p['pins'].items():
   entry=dispositions[path];assert entry['sha256']==digest
   if entry['kind']=='archive':assert sha(data[entry['member']])==digest
   elif entry['kind']=='qualifiedNativeToolIdentity':assert entry['path']==path and normal['installedTools']['pins'][path]==digest
   else:
    assert entry['kind']=='qualifiedNativePrivateEnvironmentIdentity' and Path(path).name=='environment.private.json' and digest==normal['privateEnvironmentMapSHA256']==p['environmentSHA256']
  generated=m['generatedDispositions'][label];assert set(generated)==set(r['generated'])=={str(c),str(binary)}
  assert generated[str(c)]=={'kind':'archive','member':label+'/application.c','sha256':sha(data[label+'/application.c'])} and r['generated'][str(c)]==sha(data[label+'/application.c'])
  assert generated[str(binary)]=={'kind':'generatedELFIdentityExcluded','sha256':r['generated'][str(binary)]}
  logs={name+suffix for name in ['emit-c','clang','native'] for suffix in ['.stdout','.stderr']};assert set(r['logs'])==logs
  assert {n.removeprefix(label+'/') for n in data if n.startswith(label+'/') and '/' not in n.removeprefix(label+'/') and n.endswith(('.stdout','.stderr'))}==logs
  for path,digest in r['logs'].items():assert sha(data[label+'/'+path])==digest
  assert all(data[label+'/'+name+'.stderr']==b'' for name in ['emit-c','clang','native']) and data[label+'/emit-c.stdout']==data[label+'/clang.stdout']==b''
  tools=[name for name in p['tools']['tools'] if name not in p['tools']['skip_ldd']];assert len(tools)==7 and p['tools']['cpu']==7
  probeLabels=['guard-'+str(i)+'-ldd-'+name for i in range(7) for name in tools]
  assert p['executionProbeLabels']==probeLabels and r['probeCommandsExecuted']==49
  names={name+suffix for name in probeLabels for suffix in ['.json','.stdout','.stderr']}
  assert {n.removeprefix(label+'/execution-probes/') for n in data if n.startswith(label+'/execution-probes/')}==names
  assert set(r['probePins'])=={str(out/'execution-probes'/n) for n in names}
  for path,digest in r['probePins'].items():assert sha(data[label+'/execution-probes/'+Path(path).name])==digest
  for name in probeLabels:
   tool=name.split('-ldd-',1)[1];meta=obj(label+'/execution-probes/'+name+'.json')
   assert meta['argv']==prefix+[p['tools']['ldd'],p['tools']['tools'][tool]] and meta['seconds']==5 and meta['exit']==0 and meta['failure'] is None and meta.get('exception') is None and meta['runnerSHA256']==p['pins'][str(taskRunner)]
  raw=data[label+'/native.stdout'];expected=obj(label+'/expected.json');oracles.validate(label,raw,model,expected)
  assert r['independentValidationStatus']=='FULL14_EXACT_MUTANT_ORACLE_BOTH_SCHEMA_WITNESS_PASS' and r['witnesses']==controls.witness(label,raw,model)
 print('PORTABLE_FIVE_NATIVE_FULL65537_BOTH_SCHEMA14ROW_EXACT_ORACLES_AND_WITNESSES_PASS_NO_ISSUE_CLOSURE')
if __name__=='__main__':verify()
