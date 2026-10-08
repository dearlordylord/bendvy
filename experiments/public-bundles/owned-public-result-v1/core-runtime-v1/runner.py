"""Independent core-only runnable bundle example; six bounded subjects."""
from pathlib import Path
import fcntl,hashlib,json,os,re,runpy,shutil,sys,tempfile,zipfile
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'scripts'));import task_runner as R
T=runpy.run_path(str(ROOT/'scripts/owned-tool-pins.py'))
PLAN=HERE/'execution-plan.json';ENV=HERE/'private-environment.json';OUT=HERE/'execution';CANDIDATE=HERE.parent/'production-rewire-v1';PROPOSAL=HERE/'PLAN.json'
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def encoded(value):
 if isinstance(value,bytes):return {'rawHex':value.hex()}
 raise TypeError(type(value).__name__)
def decoded(value):
 if set(value)=={'rawHex'}:return bytes.fromhex(value['rawHex'])
 return value
def ancestors(roots):
 return {parent for root in roots for parent in [root,*root.parents]}
def configs(roots):
 return {str(root/name):(sha(root/name) if (root/name).is_file() else None) for root in ancestors(roots) for name in ['bend.json','bend.config.json','check.json','bunfig.toml','package.json','.clang','clang.cfg']}
def loaders():
 paths=[Path('/etc/ld.so.cache'),Path('/etc/ld.so.conf'),Path('/etc/ld.so.preload')]
 return {'files':{str(p):(sha(p) if p.is_file() else None) for p in paths},'confDirectory':inventory(Path('/etc/ld.so.conf.d'))}
PROBES=[]
def owned_probe(argv,seconds,**kwargs):
 result=R.execute_result(argv,seconds,capture='split',**kwargs)
 PROBES.append(dict(argv=argv,seconds=seconds,result=result))
 return result


def inventory(p):return {str(f.relative_to(p)):sha(f) for f in sorted(p.rglob('*')) if f.is_file()}
def config(env):return dict(execute=owned_probe,tools={'node':Path(shutil.which('node')).resolve(),'bend':Path(shutil.which('bend')).resolve(),'python':Path(sys.executable).resolve(),'clang-wrapper':Path('/tmp/bendvy-clang19-diagnostic/clang19'),'clang-native':Path('/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang')},resource_roots=[Path('/home/node/.bend/bend2'),Path('/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/lib/clang/19')],skip_ldd=('clang-wrapper',),ldd=Path(shutil.which('ldd')).resolve(),taskset=Path(shutil.which('taskset')).resolve(),cpu=min(os.sched_getaffinity(0)),env=env,capture_mode='split')
def expected_environment():
 return dict(os.environ,BEND_NO_TELEMETRY='1',BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root',LD_LIBRARY_PATH='/tmp/bendvy-clang19-diagnostic/root/usr/lib/aarch64-linux-gnu:/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/lib:/home/node/.local/opt/dnd-clang14/usr/lib/aarch64-linux-gnu')

def preflight():
 proposal=json.loads(PROPOSAL.read_text());delivery=json.loads((HERE/'DELIVERY.json').read_text())
 assert all(sha(HERE/n)==v for n,v in delivery['files'].items())
 assert all(sha(ROOT/n)==v for n,v in proposal['inputs'].items())
 assert all(sha(p)==v for p,v in proposal['rootProductionPins'].items())
 with zipfile.ZipFile(HERE/'source-stage.zip') as z:
  assert set(z.namelist())==set(proposal['stageFiles']) and len(z.namelist())==len(proposal['stageFiles'])
  assert all(hashlib.sha256(z.read(n)).hexdigest()==v for n,v in proposal['stageFiles'].items())
  for n in proposal['stageFiles']:
   if n.endswith('.bend'):
    for imported in re.findall(r'^\s*import "([^"]+)"',z.read(n).decode(),re.M):
     assert os.path.normpath(str(Path(n).parent/imported)) in proposal['stageFiles']
 return proposal

def configuration_roots(proposal):
 return {ROOT,HERE,OUT,Path.cwd(),Path('/home/node/.bend'),Path(shutil.which('bend')).resolve().parent,*[Path(n).parent for n in proposal['rootProductionPins']]}
def prepare():
 assert not PLAN.exists() and not ENV.exists();proposal=preflight();env=expected_environment()
 files={str(ROOT/n):v for n,v in proposal['inputs'].items()};files.update(proposal['rootProductionPins'])
 for p in [Path(__file__),PROPOSAL,HERE/'DELIVERY.json',ROOT/'scripts/task_runner.py',ROOT/'scripts/owned-tool-pins.py']:files[str(p)]=sha(p)
 configsBefore=configs(configuration_roots(proposal));loadersBefore=loaders();snapshot=T['snapshot'](**config(env))
 assert all(sha(n)==v for n,v in files.items()) and env==expected_environment()
 assert configs(configuration_roots(proposal))==configsBefore and loaders()==loadersBefore
 ENV.write_text(json.dumps(env,sort_keys=True,indent=2)+'\n');ENV.chmod(0o600)
 plan=dict(status='UNEXECUTED',files=files,stageFiles=proposal['stageFiles'],environmentSHA256=sha(ENV),toolSnapshot=snapshot,commands=proposal['commands'],rootConfigurations=configsBefore,loaderConfigurations=loadersBefore,preparationProbeResults=list(PROBES),scope=proposal['scope'])
 PLAN.write_text(json.dumps(plan,indent=2,default=encoded)+'\n');print(sha(PLAN))
def execute():
 assert not OUT.exists();OUT.mkdir();plan=json.loads(PLAN.read_text(),object_hook=decoded);env=json.loads(ENV.read_text());assert env==expected_environment()
 receipt=dict(status='INCOMPLETE',planSHA256=sha(PLAN),commands=[],rawLogs={},generated={},toolGuardSnapshots=[],probeCommands=PROBES)
 def save():(OUT/'receipt.json').write_text(json.dumps(receipt,indent=2,default=encoded)+'\n')
 save()
 try:
  with tempfile.TemporaryDirectory(prefix='bendvy-core-runtime-') as tmp:
   stage=Path(tmp)
   with zipfile.ZipFile(HERE/'source-stage.zip') as z:
    assert set(z.namelist())==set(plan['stageFiles']) and len(z.namelist())==len(plan['stageFiles'])
    for n,want in plan['stageFiles'].items():
     assert hashlib.sha256(z.read(n)).hexdigest()==want
     p=stage/n;assert p.is_relative_to(stage) and '..' not in Path(n).parts;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(z.read(n))
   roots={stage,*[(stage/n).parent for n in plan['stageFiles']]};stageConfigs=configs(roots);receipt['stagedInputs']=plan['stageFiles'];receipt['stageConfigurations']=stageConfigs
   def guard():
    assert sha(PLAN)==receipt['planSHA256'] and sha(ENV)==plan['environmentSHA256'] and env==expected_environment()
    assert all(sha(n)==v for n,v in plan['files'].items())
    assert inventory(stage)==plan['stageFiles'] and configs(roots)==stageConfigs
    assert configs(configuration_roots(json.loads(PROPOSAL.read_text())))==plan['rootConfigurations'] and loaders()==plan['loaderConfigurations']
    receipt['toolGuardSnapshots'].append(T['verify'](plan['toolSnapshot'],**config(env)))
    assert all(sha(OUT/n)==v for n,v in receipt['rawLogs'].items()) and all(sha(OUT/n)==v for n,v in receipt['generated'].items());save()
   for c in plan['commands']:
    guard();argv=[str(stage)+a[5:] if a.startswith('STAGE/') else str(OUT)+a[3:] if a.startswith('OUT/') else a for a in c['argv']]
    if c['kind']=='emit':assert not (OUT/c['generated']).exists(),'generated output must be absent before each emit/compile'
    result=R.execute_result(argv,c['seconds'],cwd=stage,env=env,capture='split')
    for stream in ['stdout','stderr']:
     p=OUT/(c['label']+'.'+stream);assert not p.exists();p.write_bytes(result[stream]);receipt['rawLogs'][p.name]=sha(p)
    receipt['commands'].append(dict(label=c['label'],argv=argv,seconds=c['seconds'],exit=result['exit'],failure=result['failure'],result=result));save();guard()
    assert result['failure'] is None and result['exit']==c['expectedExit'],c['label']
    if c['kind']=='source':
     assert result['stdout']==(HERE/'expected-source.stdout').read_bytes()
     notice=b'bend 2.0.36 is available: run bend update\n';base=(HERE/'expected-source.stderr').read_bytes();assert result['stderr'] in [base,base+notice]
    elif c['kind']=='emit':
     assert not result['stdout'] and result['stderr'] in [b'',b'bend 2.0.36 is available: run bend update\n']
     receipt['generated'][c['generated']]=sha(OUT/c['generated']);save()
    else:
     assert not result['stderr'] and result['stdout']==(HERE/'expected.stdout').read_bytes()
   receipt['status']='CORE_ONLY_BOOTSTRAP_SPAWN_INSERT_RESTORE_RETURN_JS_NATIVE_PASS_NOT_PROOF_NOT_PERFORMANCE';guard()
 finally:save();print(OUT/'receipt.json')
if __name__=='__main__':
 with open('/tmp/bendvy-parity-heavy.lock','a') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  if sys.argv[1:]==['--prepare-only']:prepare()
  elif sys.argv[1:]==['--execute']:execute()
  else:raise SystemExit('use --prepare-only or --execute')
