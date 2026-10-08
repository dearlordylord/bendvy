"""Native connected declaration full2 preparation and separately admitted execution; no full56 claim."""
import argparse,hashlib,importlib.util,json,os,re,shutil,sys,time
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy');HERE=Path(__file__).resolve().parent
sys.dont_write_bytecode=True
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(p,n):
 spec=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
T=load(ROOT/'scripts/task_runner.py','task_runner');L=load(ROOT/'scripts/receipt-logs.py','logs');B=load(ROOT/'scripts/evidence_boundary.py','boundary')
def inv(p):return {str(f.relative_to(p)):sha(f) for f in p.rglob('*') if f.is_file()}
def configs(roots):
 paths=set()
 for root in roots:
  for p in [root,*root.parents]:
   for n in ['bend.toml','check.json','check.jsonc','bender.jsonc','.bend','bend.json','bend.jsonc','bender.json','package.json','.bend.json','bend.config.json','tsconfig.json','.node-version','.nvmrc','.npmrc','.clang','clang.cfg','bunfig.toml']:paths.add(p/n)
 def state(p):
  if p.is_symlink():
   resolved=p.resolve();kind='file' if resolved.is_file() else 'directory' if resolved.is_dir() else 'absent' if not resolved.exists() else 'other'
   return {'kind':'symlink','target':os.readlink(p),'resolvedPath':str(resolved),'resolvedKind':kind,'resolvedSHA256':sha(resolved) if kind=='file' else None,'resolvedInventory':inv(resolved) if kind=='directory' else None}
  if p.is_file():return {'kind':'file','sha256':sha(p)}
  if p.is_dir():return {'kind':'directory','inventory':inv(p)}
  return {'kind':'absent'}
 return {str(p):state(p) for p in paths}
def encoded(value):
 if isinstance(value,bytes):return {'rawHex':value.hex()}
 raise TypeError(type(value).__name__)
def decoded(value):
 if set(value)=={'rawHex'}:return bytes.fromhex(value['rawHex'])
 return value
O=load(ROOT/'scripts/owned-tool-pins.py','owned_tools')
def loaders():
 return {'files':{str(p):sha(p) if p.is_file() else None for p in map(Path,['/etc/ld.so.cache','/etc/ld.so.conf','/etc/ld.so.preload'])},'directory':inv(Path('/etc/ld.so.conf.d'))}
def toolconfig(env,execute):
 return dict(execute=execute,tools={'bend':Path(shutil.which('bend')).resolve(),'python':Path(sys.executable).resolve(),'clang-wrapper':Path('/tmp/bendvy-clang19-diagnostic/clang19'),'clang-native':Path('/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang')},resource_roots=[Path('/home/node/.bend/bend2'),Path('/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/lib/clang/19')],skip_ldd=('clang-wrapper',),ldd=Path(shutil.which('ldd')).resolve(),taskset=Path(shutil.which('taskset')).resolve(),cpu=5,env=env,capture_mode='split')
def prepare():
 prior=HERE/'preflight/1791449185489792748';old=json.loads((prior/'plan.json').read_text());receipt=json.loads((prior/'receipt.json').read_text())
 assert sha(prior/'plan.json')=='4e9987d1d36ec92de0f84b8737eb4c90217bfcb0bb9b0bf45297394e0c968be2'
 assert sha(prior/'receipt.json')=='4f653e876a0940c85aaf12a6c590bbcfaa1c6627ac32a6faf65a932a598cb4dc'
 assert receipt.get('guardFailures',[])==[]
 assert receipt['planSHA256']==sha(prior/'plan.json') and receipt['status']=='DEVELOPMENT_ACTUAL_DECLARATION_JS_FULL_DTO2_PASS_NOT_NATIVE_DELIVERY_FULL56'
 assert set(receipt['logs'])=={'emit.stdout','emit.stderr','candidate.stdout','candidate.stderr'}
 assert all(sha(prior/n)==h for n,h in receipt['logs'].items())
 assert len(receipt['commands'])==2 and all(c['exit']==0 and c['failure'] is None for c in receipt['commands'])
 assert receipt['generated']=={str(prior/'main.js'):'d61e5c59524ff3930dcae3a7f6dcb96f9233d854a0d04d186faa56befbdb72e7'}
 assert all(sha(n)==digest for n,digest in receipt['generated'].items())
 assert (prior/'candidate.stdout').read_bytes()==(HERE/'EXPECTED-V2.stdout').read_bytes() and (prior/'candidate.stderr').read_bytes()==b''
 assert all(all(c[k]==old['commands'][j][k] for k in old['commands'][j]) for j,c in enumerate(receipt['commands']))
 archived=Path(old['stage']);assert inv(archived)==old['inventory']
 out=HERE/'native-v1'/str(time.time_ns());out.mkdir(parents=True);stage=out/'stage';shutil.copytree(archived,stage)
 pins={}
 for n,h in old['pins'].items():
  assert sha(n)==h;pins[n]=h
 for file in [prior/'plan.json',prior/'receipt.json',prior/'candidate.stdout',prior/'candidate.stderr',prior/'emit.stdout',prior/'emit.stderr',Path(__file__),ROOT/'scripts/owned-tool-pins.py',ROOT/'scripts/evidence_boundary.py']:
  pins[str(file)]=sha(file)
 for name,digest in receipt['generated'].items():pins[name]=digest
 pins[str(HERE/'source-history/native-ab4e-preprobe-failure.py')]=sha(HERE/'source-history/native-ab4e-preprobe-failure.py')
 pins[str(HERE/'source-history/native-b0d33-unexecuted.py')]=sha(HERE/'source-history/native-b0d33-unexecuted.py')
 for file in (HERE/'native-v1/1791449700635179249').rglob('*'):
  if file.is_file():pins[str(file)]=sha(file)
 for file in archived.rglob('*'):
  if file.is_file():pins[str(file)]=sha(file)
 rootjoins={}
 for file in (stage/'src/ecs').rglob('*'):
  if file.is_file():
   actual=ROOT/'src/ecs'/file.relative_to(stage/'src/ecs');assert sha(actual)==old['pins'][str(actual)]
   normalize=lambda text:re.sub(r'(^\s*import\s+)\./',r'\1',text,flags=re.M)
   assert normalize(actual.read_text())==normalize(file.read_text());rootjoins[str(actual)]=sha(actual)
 env=json.loads(Path(old['environment']).read_text());env.update(BEND_NO_TELEMETRY='1',BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root',BENDVY_NATIVE_THREADS='1',BENDVY_NATIVE_GPU='off',OMP_NUM_THREADS='1',LD_LIBRARY_PATH='/tmp/bendvy-clang19-diagnostic/root/usr/lib/aarch64-linux-gnu:/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/lib:/home/node/.local/opt/dnd-clang14/usr/lib/aarch64-linux-gnu')
 private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True));private.chmod(0o600);pins[str(private)]=sha(private)
 roots=[ROOT,HERE,out,stage,Path('/home/node/.bend'),Path('/home/node/.bend/bend2'),Path('/tmp/bendvy-clang19-diagnostic'),Path('/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin'),Path('/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/lib/clang/19'),*[binary.resolve().parent for binary in toolconfig(env,None)['tools'].values()],Path(shutil.which('taskset')).resolve().parent,*[Path(n).parent for n in pins],*[f.parent for f in stage.rglob('*') if f.is_file()]]
 before=configs(roots);beforeloader=loaders();beforestage=inv(stage);probes=[]
 expectedprobes=[[str(Path(shutil.which('taskset')).resolve()),'-c','5',str(Path(shutil.which('ldd')).resolve()),str(binary)] for binary in [Path(shutil.which('bend')).resolve(),Path(sys.executable).resolve(),Path('/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang').resolve()]]
 def probe(argv,seconds,**kwargs):
  assert len(probes)<len(expectedprobes) and list(argv)==expectedprobes[len(probes)] and seconds==5
  try:
   result=T.execute_result(argv,seconds,capture='split',**kwargs)
  except BaseException as error:
   probes.append(json.loads(json.dumps(dict(argv=list(argv),seconds=seconds,result=getattr(error,'result',None),failure=repr(error)),default=encoded)));raise
  probes.append(json.loads(json.dumps(dict(argv=argv,seconds=seconds,result=result),default=encoded)));return result
 prep={'status':'INCOMPLETE','scope':'ordinary Native preparation only','probes':probes}
 preparationTools={str(binary):sha(binary) for binary in toolconfig(env,probe)['tools'].values()}
 def preparation_source_guard():
  assert inv(stage)==beforestage and all(sha(n)==h for n,h in rootjoins.items())
  assert all(sha(n)==h for n,h in pins.items()) and sha(private)==pins[str(private)]
 def preparation_config_guard():assert configs(roots)==before
 def preparation_loader_guard():assert loaders()==beforeloader
 def preparation_tool_guard():assert all(sha(n)==h for n,h in preparationTools.items())
 preparationGuards=[('source-stage-env',preparation_source_guard),('config',preparation_config_guard),('loaders',preparation_loader_guard),('tool-identities',preparation_tool_guard)]
 with B.ReceiptBoundary(prep,out/'prepare-receipt.json',preparationGuards), B.GuardBoundary(preparationGuards):
  for _,guard in preparationGuards:guard()
  snapshot=O.snapshot(**toolconfig(env,probe));assert len(probes)==3 and inv(stage)==beforestage and all(sha(n)==h for n,h in rootjoins.items());assert configs(roots)==before and loaders()==beforeloader and all(sha(n)==h for n,h in pins.items())
  config=toolconfig(env,probe);taskset=str(config['taskset']);bend=str(config['tools']['bend']);clang=str(config['tools']['clang-wrapper'])
  commands=[{'label':'emit','argv':[taskset,'-c','5',bend,str(stage/'study/full-dto-v1/main-v2.bend'),'-o',str(out/'main.c')],'seconds':30,'artifact':str(out/'main.c')},{'label':'compile','argv':[taskset,'-c','5',clang,'-O3',str(out/'main.c'),'-lm','-o',str(out/'main.native')],'seconds':120,'artifact':str(out/'main.native')},{'label':'candidate','argv':[taskset,'-c','5',str(out/'main.native'),'--threads','1','--gpu','off'],'seconds':5}]
  plan={**old,'scope':'Native connected declaration full2 ordinary source-current qualification; no full56/proof/performance claim','pins':pins,'rootJoins':rootjoins,'stage':str(stage),'inventory':inv(stage),'environment':str(private),'environmentSHA256':sha(private),'configRoots':list(map(str,roots)),'configs':before,'loaders':beforeloader,'toolSnapshot':snapshot,'preparationProbeCommands':expectedprobes,'nativeRuntimeIntent':{'threads':1,'gpu':'off','authority':'explicit runtime argv; environment labels descriptive'},'commands':commands,'normalJSReuse':{'plan':str(prior/'plan.json'),'receipt':str(prior/'receipt.json'),'scope':'actual connected declaration JS six-line success; TS2 remains the separate successful reference-only subject'}}
  path=out/'plan.json';path.write_text(json.dumps(plan,indent=2,default=encoded)+'\n');prep['status']='ORDINARY_PREPARATION_PASS_NO_BACKEND';print(path);print(sha(path))

def run(path):
 path=Path(path).resolve();p=json.loads(path.read_text(),object_hook=decoded);out=path.parent;stage=Path(p['stage']);env=json.loads(Path(p['environment']).read_text());r={'status':'INCOMPLETE','planSHA256':sha(path),'scope':p['scope'],'commands':[]};generated=dict(p.get('preexistingGenerated',{}));logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);inputs=T.Inputs(files=[path,*p['pins']],directories=[stage]);runner=T.Runner(logs,inputs=inputs,env=env,cwd=stage,capture='split')
 def owned_guard_probe(argv,seconds,**kwargs):
  try:result=T.execute_result(argv,seconds,capture='split',**kwargs)
  except BaseException as error:
   r.setdefault('ordinaryGuardProbes',[]).append(json.loads(json.dumps(dict(argv=list(argv),seconds=seconds,result=getattr(error,'result',None),failure=repr(error)),default=encoded)));raise
  r.setdefault('ordinaryGuardProbes',[]).append(json.loads(json.dumps(dict(argv=list(argv),seconds=seconds,result=result),default=encoded)));return result
 def source_guard():
  assert sha(path)==r['planSHA256']
  assert loaders()==p['loaders']
  O.verify(p['toolSnapshot'],**toolconfig(env,owned_guard_probe))
  assert all(sha(n)==h for n,h in p['rootJoins'].items())
  assert all(sha(n)==s for n,s in p['pins'].items());assert inv(stage)==p['inventory'];assert inv(Path(p['resource']))==p['resourceInventory'];assert sha(p['environment'])==p['environmentSHA256'];assert configs(list(map(Path,p['configRoots'])))==p['configs']
 def generated_guard():
  assert all(sha(n)==s for n,s in generated.items());runner.inputs.guard()
 def generated_registration():
  assert sha(path)==r['planSHA256']
  for c in p['commands']:
   if 'artifact' in c and Path(c['artifact']).is_file() and c['artifact'] not in generated:generated[c['artifact']]=sha(c['artifact'])
  runner.inputs=T.Inputs(files=[path,*p['pins'],*generated],directories=[stage])
 def evidence_record():
  r['logs']=dict(logs.hashes);r['generated']=dict(generated)
 guards=[('generated-registration',generated_registration),('source-config-env',source_guard),('raw',logs.guard),('generated',generated_guard),('record-evidence',evidence_record)]
 with B.ReceiptBoundary(r,out/'receipt.json',guards):
  source_guard();logs.guard()
  for c in p['commands']:
   item={**c,'exit':None,'failure':None};r['commands'].append(item)
   with B.GuardBoundary(guards):
    source_guard();logs.guard();generated_guard()
    if 'artifact' in c:assert not Path(c['artifact']).exists()
    if c['label']=='emit':assert not (out/'main.native').exists()
    try:
     result=runner.run(c['label'],c['argv'],c['seconds'],expected=None);item.update(exit=result['exit'],failure=result['failure'])
    except BaseException as e:
     result=getattr(e,'result',None)
     if result is not None:item.update(exit=result['exit'],failure=result['failure'])
     raise
    assert result['exit']==0 and result['failure'] is None
    if c['label']=='emit':
     assert result['stderr'] in (b'',b'bend 2.0.36 is available: run bend update\n');item['stderrClassification']='EMPTY' if result['stderr']==b'' else 'EXACT_KNOWN_42B_UPDATE_NOTICE'
    else:assert result['stderr']==b''
    if c['label'] in ('emit','compile'):assert result['stdout']==b'';generated[c['artifact']]=sha(c['artifact'])
    elif c['label']=='candidate':assert result['stdout']==(stage/'study/full-dto-v1/EXPECTED-V2.stdout').read_bytes()
    else:
     raise AssertionError('unexpected subject')
   r['logs']=dict(logs.hashes);r['generated']=dict(generated)
  r['status']='NATIVE_DECLARATION_FULL_DTO2_QUALIFIED_NOT_FULL56_NOT_PROOF_NOT_PERFORMANCE'
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');a=parser.parse_args();prepare() if a.prepare else run(a.run)
