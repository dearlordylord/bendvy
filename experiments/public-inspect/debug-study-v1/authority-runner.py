"""Source authority preparation and separately admitted raw controls; no proof/runtime claim."""
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
   for n in ['check.json','bend.json','bend.jsonc','bender.json','package.json','.bend.json','bend.config.json','tsconfig.json','.node-version','.nvmrc','.npmrc','.clang','clang.cfg','bunfig.toml']:paths.add(p/n)
 return {str(p):sha(p) if p.is_file() else None for p in paths}
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
 return dict(execute=execute,tools={'bend':Path(shutil.which('bend')).resolve(),'python':Path(sys.executable).resolve()},resource_roots=[Path('/home/node/.bend/bend2')],skip_ldd=(),ldd=Path(shutil.which('ldd')).resolve(),taskset=Path(shutil.which('taskset')).resolve(),cpu=5,env=env,capture_mode='split')
def prepare():
 prior=HERE/'preflight/1791437041909327885';old=json.loads((prior/'plan.json').read_text());receipt=json.loads((prior/'receipt.json').read_text())
 assert receipt['planSHA256']==sha(prior/'plan.json') and receipt['status']=='DEVELOPMENT_PREFLIGHT_FULL16_PASS_NOT_DELIVERY'
 assert len(receipt['commands'])==2 and all(c['exit']==0 and c['failure'] is None for c in receipt['commands'])
 assert (prior/'candidate.stdout').read_bytes()==(HERE/'EXPECTED.stdout').read_bytes() and (prior/'candidate.stderr').read_bytes()==b''
 archived=Path(old['stage']);assert inv(archived)==old['inventory']
 out=HERE/'authority-v1/cohort'/str(time.time_ns());out.mkdir(parents=True);stage=out/'stage';shutil.copytree(archived,stage)
 pins={}
 for n,h in old['pins'].items():
  assert sha(n)==h;pins[n]=h
 for file in [prior/'plan.json',prior/'receipt.json',prior/'candidate.stdout',prior/'candidate.stderr',prior/'emit.stdout',prior/'emit.stderr',Path(__file__),ROOT/'scripts/owned-tool-pins.py']:
  pins[str(file)]=sha(file)
 for file in archived.rglob('*'):
  if file.is_file():pins[str(file)]=sha(file)
 for source in (HERE/'authority-v1').glob('*.bend'):
  target=stage/'study/authority-v1'/source.name;target.parent.mkdir(exist_ok=True);pins[str(source)]=sha(source)
  target.write_text(source.read_text().replace(str(ROOT/'src/ecs')+'/', '../../src/ecs/'))
 pins[str(HERE/'authority-v1/SOURCE-PLAN.json')]=sha(HERE/'authority-v1/SOURCE-PLAN.json')
 rootjoins={}
 for file in (stage/'src/ecs').rglob('*'):
  if file.is_file():
   actual=ROOT/'src/ecs'/file.relative_to(stage/'src/ecs');assert sha(actual)==sha(file);rootjoins[str(actual)]=sha(actual)
 env=json.loads(Path(old['environment']).read_text());env.update(BEND_NO_TELEMETRY='1',BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root',BENDVY_NATIVE_THREADS='1',BENDVY_NATIVE_GPU='off',OMP_NUM_THREADS='1',LD_LIBRARY_PATH='/tmp/bendvy-clang19-diagnostic/root/usr/lib/aarch64-linux-gnu:/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/lib:/home/node/.local/opt/dnd-clang14/usr/lib/aarch64-linux-gnu')
 private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True));private.chmod(0o600);pins[str(private)]=sha(private)
 roots=[ROOT,HERE,out,stage,Path('/home/node/.bend/bend2'),Path('/tmp/bendvy-clang19-diagnostic'),Path('/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin'),Path('/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/lib/clang/19'),*[Path(n).parent for n in pins],*[f.parent for f in stage.rglob('*') if f.is_file()]]
 before=configs(roots);beforeloader=loaders();beforestage=inv(stage);probes=[]
 expectedprobes=[[str(Path(shutil.which('taskset')).resolve()),'-c','5',str(Path(shutil.which('ldd')).resolve()),str(binary)] for binary in [Path(shutil.which('bend')).resolve(),Path(sys.executable).resolve()]]
 def probe(argv,seconds,**kwargs):
  assert len(probes)<len(expectedprobes) and list(argv)==expectedprobes[len(probes)] and seconds==5
  result=T.execute_result(argv,seconds,capture='split',**kwargs);probes.append(dict(argv=argv,seconds=seconds,result=result));return result
 prep={'status':'INCOMPLETE','scope':'ordinary Native preparation only','probes':probes}
 try:
  snapshot=O.snapshot(**toolconfig(env,probe));assert len(probes)==2 and inv(stage)==beforestage and all(sha(n)==h for n,h in rootjoins.items());assert configs(roots)==before and loaders()==beforeloader and all(sha(n)==h for n,h in pins.items())
  config=toolconfig(env,probe);taskset=str(config['taskset']);bend=str(config['tools']['bend'])
  commands=[{'label':name,'argv':[taskset,'-c','5',bend,str(stage/'study/authority-v1'/(name+'.bend')),'--check-only'],'seconds':5,'expectedExit':0 if name=='positive' else 1,'diagnosticClassification':'RAW_UNCLASSIFIED_UNTIL_INDEPENDENT_REVIEW'} for name in ['positive','negative-schema','negative-token','negative-write','negative-owner','negative-undeclared']]
  plan={**old,'scope':'Source authority raw controls; no proof/runtime/delivery credit until intended diagnosis review','pins':pins,'rootJoins':rootjoins,'stage':str(stage),'inventory':inv(stage),'environment':str(private),'environmentSHA256':sha(private),'configRoots':list(map(str,roots)),'configs':before,'loaders':beforeloader,'toolSnapshot':snapshot,'preparationProbeCommands':expectedprobes,'commands':commands,'normalJSReuse':{'plan':str(prior/'plan.json'),'receipt':str(prior/'receipt.json'),'scope':'actual development full16 JS success; TS reuse remains separate inside old INCOMPLETE'}}
  path=out/'plan.json';path.write_text(json.dumps(plan,indent=2,default=encoded)+'\n');prep['status']='ORDINARY_PREPARATION_PASS_NO_BACKEND';print(path);print(sha(path))
 finally:(out/'prepare-receipt.json').write_text(json.dumps(prep,indent=2,default=encoded)+'\n')
def run(path):
 path=Path(path).resolve();p=json.loads(path.read_text(),object_hook=decoded);out=path.parent;stage=Path(p['stage']);env=json.loads(Path(p['environment']).read_text());r={'status':'INCOMPLETE','planSHA256':sha(path),'scope':p['scope'],'commands':[]};generated=dict(p.get('preexistingGenerated',{}));logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);inputs=T.Inputs(files=[path,*p['pins']],directories=[stage]);runner=T.Runner(logs,inputs=inputs,env=env,cwd=stage,capture='split')
 def owned_guard_probe(argv,seconds,**kwargs):
  result=T.execute_result(argv,seconds,capture='split',**kwargs)
  r.setdefault('ordinaryGuardProbes',[]).append(json.loads(json.dumps(dict(argv=argv,seconds=seconds,result=result),default=encoded)))
  return result
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
    assert result['exit']==c['expectedExit'] and result['failure'] is None
    item['diagnosticClassification']='RAW_UNCLASSIFIED_UNTIL_INDEPENDENT_REVIEW'
   r['logs']=dict(logs.hashes);r['generated']=dict(generated)
  r['status']='SOURCE_CONTROLS_RAW_UNCLASSIFIED_NOT_PROOF_NOT_RUNTIME_NOT_DELIVERY'
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');a=parser.parse_args();prepare() if a.prepare else run(a.run)
