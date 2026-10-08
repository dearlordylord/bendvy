"""One source-only independent two-family consumer; no proof/runtime claim."""
from pathlib import Path
import fcntl,hashlib,json,os,re,runpy,shutil,sys,tempfile,zipfile
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'scripts'));import task_runner as R
T=runpy.run_path(str(ROOT/'scripts/owned-tool-pins.py'))
PLAN=HERE/'execution-plan.json';ENV=HERE/'private-environment.json';OUT=HERE/'execution';CANDIDATE=HERE.parent/'canonical-source-v2';PROPOSAL=HERE/'PLAN.json'
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
def config(env):
 return dict(execute=owned_probe,tools={'bend':Path(shutil.which('bend')).resolve(),'python':Path(sys.executable).resolve()},resource_roots=[Path('/home/node/.bend/bend2')],ldd=Path(shutil.which('ldd')).resolve(),taskset=Path(shutil.which('taskset')).resolve(),cpu=min(os.sched_getaffinity(0)),env=env,capture_mode='split')
def expected_environment():return dict(os.environ,BEND_NO_TELEMETRY='1')

def preflight():
 delivery=json.loads((HERE/'DELIVERY.json').read_text())
 assert all(sha(HERE/n)==v for n,v in delivery['files'].items()),'reviewed source preparation drift'
 proposal=json.loads(PROPOSAL.read_text())
 assert all(sha(ROOT/name)==want for name,want in proposal['inputs'].items()),'source proposal/diagnostic drift'
 assert all(sha(name)==want for name,want in proposal['rootProductionPins'].items()),'root production source drift'
 archivePath=HERE/'source-stage.zip'
 with zipfile.ZipFile(archivePath) as archive:
  assert set(archive.namelist())==set(proposal['stageFiles'])
  assert all(hashlib.sha256(archive.read(n)).hexdigest()==v for n,v in proposal['stageFiles'].items())
  import posixpath
  for n in proposal['stageFiles']:
   if n.endswith('.bend'):
    for imported in re.findall(r'^\s*import \"([^\"]+)\"',archive.read(n).decode(),re.M):
     target=posixpath.normpath(posixpath.join(posixpath.dirname(n),imported))
     assert target in proposal['stageFiles'],'missing quoted foreign source'
 return proposal

def configuration_roots():
 proposal=json.loads(PROPOSAL.read_text())
 return {ROOT,HERE,OUT,Path.cwd(),Path('/home/node/.bend'),Path(shutil.which('bend')).resolve().parent,*[Path(n).parent for n in proposal['rootProductionPins']]}

def prepare():
 assert not PLAN.exists() and not ENV.exists();proposal=preflight()
 files={str(ROOT/n):v for n,v in proposal['inputs'].items()}
 files.update(proposal['rootProductionPins'])
 for p in [Path(__file__),PROPOSAL,HERE/'ERGONOMICS.md',HERE/'DELIVERY.json',ROOT/'scripts/task_runner.py',ROOT/'scripts/owned-tool-pins.py']:files[str(p)]=sha(p)
 env=expected_environment();ENV.write_text(json.dumps(env,sort_keys=True,indent=2)+'\n');ENV.chmod(0o600)
 beforeConfigs=configs(configuration_roots());beforeLoaders=loaders()
 snapshot=T['snapshot'](**config(env))
 assert all(sha(n)==v for n,v in files.items()) and env==expected_environment()
 assert configs(configuration_roots())==beforeConfigs and loaders()==beforeLoaders
 plan=dict(status='UNEXECUTED',files=files,stageFiles=proposal['stageFiles'],environmentSHA256=sha(ENV),toolSnapshot=snapshot,commands=proposal['commands'],rootConfigurations=configs(configuration_roots()),loaderConfigurations=loaders(),preparationProbeResults=list(PROBES),scope=proposal['scope'])
 PLAN.write_text(json.dumps(plan,indent=2,default=encoded)+'\n');print(sha(PLAN))

def execute():
 assert not OUT.exists();OUT.mkdir();plan=json.loads(PLAN.read_text(),object_hook=decoded);env=json.loads(ENV.read_text());assert env==expected_environment()
 receipt=dict(status='INCOMPLETE',planSHA256=sha(PLAN),commands=[],rawLogs={},toolGuardSnapshots=[],probeCommands=PROBES)
 def save():(OUT/'receipt.json').write_text(json.dumps(receipt,indent=2,default=encoded)+'\n')
 save()
 try:
  with tempfile.TemporaryDirectory(prefix='bendvy-production41-source-') as temporary:
   stage=Path(temporary)
   with zipfile.ZipFile(HERE/'source-stage.zip') as archive:
    assert set(archive.namelist())==set(plan['stageFiles'])
    for name,want in plan['stageFiles'].items():
     assert hashlib.sha256(archive.read(name)).hexdigest()==want
     path=stage/name;assert path.is_relative_to(stage) and '..' not in Path(name).parts
     path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(archive.read(name))
   for name in plan['stageFiles']:
    if name.endswith('.bend'):
     for imported in re.findall(r'^\s*import "([^"]+)"',(stage/name).read_text(),re.M):
      resolved=((stage/name).parent/imported).resolve()
      assert resolved.is_relative_to(stage) and str(resolved.relative_to(stage)) in plan['stageFiles']
   roots={stage,*[(stage/n).parent for n in plan['stageFiles']]};stageConfigs=configs(roots)
   receipt['stagedInputs']=plan['stageFiles'];receipt['stageConfigurations']=stageConfigs
   def guard():
    assert sha(PLAN)==receipt['planSHA256'] and sha(ENV)==plan['environmentSHA256']
    assert all(sha(n)==v for n,v in plan['files'].items()),'source/diagnostic/helper/root production drift'
    assert inventory(stage)==plan['stageFiles'],'full stage membership drift'
    assert configs(roots)==stageConfigs and configs(configuration_roots())==plan['rootConfigurations']
    assert loaders()==plan['loaderConfigurations']
    receipt['toolGuardSnapshots'].append(T['verify'](plan['toolSnapshot'],**config(env)))
    assert all(sha(OUT/n)==v for n,v in receipt['rawLogs'].items());save()
   for c in plan['commands']:
    guard();argv=['bend',str(stage/c['source']),'--check-only']
    result=R.execute_result(argv,c['seconds'],cwd=stage,env=env,capture='split')
    for stream in ('stdout','stderr'):
     path=OUT/(c['label']+'.'+stream);assert not path.exists();path.write_bytes(result[stream]);receipt['rawLogs'][path.name]=sha(path)
    receipt['commands'].append(dict(label=c['label'],argv=argv,seconds=c['seconds'],exit=result['exit'],failure=result['failure'],result=result));save();guard()
    assert result['failure'] is None and result['exit']==c['expectedExit'],c['label']
    assert result['stdout']==(ROOT/c['stdoutSource']).read_bytes(),'exact stdout delta: '+c['label']
    expected=(ROOT/c['diagnosticSource']).read_bytes();notice=b'bend 2.0.36 is available: run bend update\n'
    base=expected[:-len(notice)] if expected.endswith(notice) else expected
    assert result['stderr'] in (base,base+notice),'exact diagnostic delta: '+c['label']
   receipt['status']='CORE_ONLY_TWO_FAMILY_CONSUMER_SAFE_SOURCE_MATCH_NOT_PROOF_NOT_RUNTIME';guard()
 finally:save();print(OUT/'receipt.json')

if __name__=='__main__':
 with open('/tmp/bendvy-parity-heavy.lock','a') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  if sys.argv[1:]==['--prepare-only']:prepare()
  elif sys.argv[1:]==['--execute']:execute()
  else:raise SystemExit('use --prepare-only or --execute')
