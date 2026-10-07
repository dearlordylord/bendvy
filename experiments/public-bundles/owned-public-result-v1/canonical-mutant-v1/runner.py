"""Source and five backend subjects for reached canonical omitted-value control."""
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
def config(env):return dict(execute=owned_probe,tools={'node':Path(shutil.which('node')).resolve(),'bend':Path(shutil.which('bend')).resolve(),'python':Path(sys.executable).resolve(),'clang-wrapper':Path('/tmp/bendvy-clang19-diagnostic/clang19'),'clang-native':Path('/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang')},resource_roots=[Path('/home/node/.bend/bend2'),Path('/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/lib/clang/19')],skip_ldd=('clang-wrapper',),ldd=Path(shutil.which('ldd')).resolve(),taskset=Path(shutil.which('taskset')).resolve(),cpu=min(os.sched_getaffinity(0)),env=env,capture_mode='split')
def expected_environment():
 return dict(os.environ,BEND_NO_TELEMETRY='1',BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root',LD_LIBRARY_PATH='/tmp/bendvy-clang19-diagnostic/root/usr/lib/aarch64-linux-gnu:/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/lib:/home/node/.local/opt/dnd-clang14/usr/lib/aarch64-linux-gnu')

def preflight():
 delivery=json.loads((CANDIDATE/'DELIVERY.json').read_text())
 assert all(sha(CANDIDATE/name)==want for name,want in delivery['selectedFiles'].items()),'selected candidate drift'
 binding=json.loads((CANDIDATE/'stage-binding.json').read_text())
 with zipfile.ZipFile(CANDIDATE/'source-stage.zip') as archive:
  assert set(archive.namelist())==set(binding['stage']),'archive membership drift'
  assert all(hashlib.sha256(archive.read(name)).hexdigest()==want for name,want in binding['stage'].items()),'archive source drift'
 classification=json.loads((CANDIDATE/'source-controls/classification.json').read_text())
 assert classification['status']=='CANONICAL_EIGHT_STATIC_NEGATIVES_AND_TWO_IO_BOUNDARIES_MATCH_NOT_PROOF_NOT_RUNTIME'
 with zipfile.ZipFile(CANDIDATE/'source-stage.zip') as archive:
  for name in archive.namelist():
   for imported in re.findall(r'^\s*import "([^"]+)"', archive.read(name).decode(), re.M):
    resolved=str(Path(os.path.normpath(str(Path(name).parent/imported))))
    assert resolved in binding['stage'],'missing quoted foreign import before tool discovery'
 normal_receipts={}
 for kind,folder,status in [('JS',HERE.parent/'canonical-js-v1','CANONICAL_CORE_OWNED_REQUEST_COMPLETE22_AND20_JS_FINITE_PASS'),('Native',HERE.parent/'canonical-native-v1','CANONICAL_CORE_OWNED_REQUEST_COMPLETE22_AND20_NATIVE_FINITE_PASS')]:
  receipt=json.loads((folder/'execution/receipt.json').read_text())
  plan=json.loads((folder/'execution-plan.json').read_text())
  assert receipt['status']==status and receipt['planSHA256']==sha(folder/'execution-plan.json')
  assert plan['stageFiles']==binding['stage'] and receipt['stagedInputs']==binding['stage']
  command=[row for row in receipt['commands'] if row['label']=='full22-'+kind+'-consumer'][0]
  assert command['exit']==0 and command['failure'] is None
  assert bytes.fromhex(command['result']['stdout']['rawHex'])==(HERE.parent/'expected.stdout').read_bytes()
  normal_receipts[kind]=sha(folder/'execution/receipt.json')
 proposal=json.loads(PROPOSAL.read_text())
 assert proposal['normalSourceFiles']==binding['stage']
 expected_mutant=dict(binding['stage'])
 with zipfile.ZipFile(CANDIDATE/'source-stage.zip') as archive:
  for name,change in proposal['changes'].items():
   raw=archive.read(name);assert hashlib.sha256(raw).hexdigest()==change['baseSha256']
   text=raw.decode();assert text.count(change['replace'])==1
   mutated=text.replace(change['replace'],change['withText']).encode()
   assert hashlib.sha256(mutated).hexdigest()==change['mutantSha256']
   expected_mutant[name]=change['mutantSha256']
 assert proposal['mutantSourceFiles']==expected_mutant,'unexpected extra mutation'
 return binding

def configuration_roots():
 return {ROOT,HERE,OUT,Path.cwd(),Path('/home/node/.bend'),Path(shutil.which('bend')).resolve().parent,Path(shutil.which('node')).resolve().parent,Path('/tmp/bendvy-clang19-diagnostic'),Path('/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin'),Path('/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/lib/clang/19')}

def prepare():
 assert not PLAN.exists() and not ENV.exists();binding=preflight()
 proposal=json.loads(PROPOSAL.read_text())
 files=dict(proposal['inputs'])
 for folder in [HERE.parent/'canonical-js-v1',HERE.parent/'canonical-native-v1']:
  for name in ['execution-plan.json','execution/receipt.json']:
   files[str(folder/name)]=sha(folder/name)
 for name in json.loads((CANDIDATE/'DELIVERY.json').read_text())['selectedFiles']:
  files[str(CANDIDATE/name)]=sha(CANDIDATE/name)
 for path in [Path(__file__),PROPOSAL,ROOT/'scripts/task_runner.py',ROOT/'scripts/owned-tool-pins.py']:
  files[str(path)]=sha(path)
 assert all(sha(name)==want for name,want in files.items())
 env=expected_environment()
 ENV.write_text(json.dumps(env,sort_keys=True,indent=2)+'\n');ENV.chmod(0o600)
 snapshot=T['snapshot'](**config(env))
 plan=dict(status='UNEXECUTED',files=files,normalSourceFiles=binding['stage'],stageFiles=proposal['mutantSourceFiles'],changes=proposal['changes'],environmentSHA256=sha(ENV),toolSnapshot=snapshot,commands=proposal['commands'],completeIndependentMutantOracleSha256=proposal['completeIndependentMutantOracleSha256'],rootConfigurations=configs(configuration_roots()),loaderConfigurations=loaders(),preparationProbeResults=list(PROBES),scope=proposal['scope'])
 PLAN.write_text(json.dumps(plan,indent=2,default=encoded)+'\n');print(sha(PLAN))

def execute():
 plan=json.loads(PLAN.read_text(),object_hook=decoded)
 assert sha(ENV)==plan['environmentSHA256'];env=json.loads(ENV.read_text())
 assert env==expected_environment(),'ambient environment drift'
 preflight();assert not OUT.exists();OUT.mkdir()
 receipt=dict(status='INCOMPLETE',planSHA256=sha(PLAN),commands=[],generated={},toolGuardSnapshots=[],rawLogs={},probeCommands=PROBES)
 def save():(OUT/'receipt.json').write_text(json.dumps(receipt,indent=2,default=encoded)+'\n')
 save()
 try:
  with tempfile.TemporaryDirectory(prefix='bundles41-owned-adoption-') as temp:
   stage=Path(temp)
   with zipfile.ZipFile(CANDIDATE/'source-stage.zip') as archive:
    assert set(archive.namelist())==set(plan['normalSourceFiles'])
    for name in archive.namelist():
     path=stage/name;assert path.is_relative_to(stage) and '..' not in Path(name).parts
     path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(archive.read(name))
   for name,change in plan['changes'].items():
    path=stage/name;assert sha(path)==change['baseSha256']
    text=path.read_text();assert text.count(change['replace'])==1
    path.write_text(text.replace(change['replace'],change['withText']))
    assert sha(path)==change['mutantSha256']
   for name in plan['stageFiles']:
    if name.endswith('.bend'):
     for imported in re.findall(r'^\s*import "([^"]+)"', (stage/name).read_text(), re.M):
      resolved=((stage/name).parent/imported).resolve()
      assert resolved.is_relative_to(stage) and str(resolved.relative_to(stage)) in plan['stageFiles'],'missing quoted foreign import'
   roots={stage,*[(stage/name).parent for name in plan['stageFiles']]}
   stageConfigs=configs(roots);receipt['stagedInputs']=plan['stageFiles'];receipt['stageConfigurations']=stageConfigs
   def guard():
    assert sha(PLAN)==receipt['planSHA256'],'frozen plan drift'
    assert sha(ENV)==plan['environmentSHA256'],'frozen environment drift'
    assert all(sha(name)==want for name,want in plan['files'].items()),'source/helper/oracle drift'
    assert inventory(stage)==plan['stageFiles'],'full stage membership/hash drift'
    assert configs(roots)==stageConfigs,'all stage ancestor configuration drift'
    assert configs(configuration_roots())==plan['rootConfigurations'],'root/tool ancestor configuration drift'
    assert loaders()==plan['loaderConfigurations'],'loader configuration drift'
    receipt['toolGuardSnapshots'].append(T['verify'](plan['toolSnapshot'],**config(env)))
    assert all(sha(OUT/name)==want for name,want in receipt['rawLogs'].items()),'raw log drift'
    assert all(sha(OUT/name)==want for name,want in receipt['generated'].items()),'generated artifact drift'
    save()
   for command in plan['commands']:
    guard()
    argv=[str(stage)+arg[6:] if arg.startswith('MUTANT/') else str(OUT)+arg[3:] if arg.startswith('OUT/') else arg for arg in command['argv']]
    result=R.execute_result(argv,command['seconds'],cwd=stage,env=env,capture='split');label=command['label']
    for stream in ('stdout','stderr'):
     path=OUT/(label+'.'+stream);assert not path.exists();path.write_bytes(result[stream]);receipt['rawLogs'][path.name]=sha(path)
    receipt['commands'].append(dict(label=label,argv=argv,seconds=command['seconds'],exit=result['exit'],failure=result['failure'],result=result));save()
    guard()
    assert result['failure'] is None,label
    if command['kind']=='IO-effect-boundary':
     expected=(HERE.parent/'expected-check-only.stderr').read_bytes()
     assert result['exit']==1 and not result['stdout']
     assert result['stderr'] in (expected,expected+b'bend 2.0.36 is available: run bend update\n'),'exact canonical IO diagnostic mismatch'
     receipt['sourceQualification']='Expected IO effect boundary only; not mathematical proof'
    elif command['kind']=='emit':
     assert result['exit']==0,label
     assert not result['stdout']
     receipt['generated'][command['generated']]=sha(OUT/command['generated'])
     # Current CLI may append its explicit update notice; raw stderr is retained.
     assert result['stderr'] in (b'',b'bend 2.0.36 is available: run bend update\n'),label
    else:
     assert result['exit']==0 and not result['stderr'],label
     oracle=HERE.parent/'expected-omitted-value.stdout'
     assert sha(oracle)==plan['completeIndependentMutantOracleSha256'] and result['stdout']==oracle.read_bytes(),'complete independent mutant oracle mismatch'
     assert result['stdout']!=(HERE.parent/'expected.stdout').read_bytes(),'mutant not reached'
     assert len(result['stdout'].splitlines())==command['rows']
     receipt.setdefault('fullPhysicalRows',{})[label]=command['rows']
   assert receipt['fullPhysicalRows']=={'mutant-JS-full22':22,'mutant-Native-full22':22}
   assert (OUT/'mutant-JS-full22.stdout').read_bytes()==(OUT/'mutant-Native-full22.stdout').read_bytes()
   receipt['status']='CANONICAL_OMITTED_VALUE_REACHED_COMPLETE22_JS_NATIVE_FINITE_CONTROL_PASS'
   guard()
 finally:save();print(OUT/'receipt.json')

if __name__=='__main__':
 with open('/tmp/bendvy-parity-heavy.lock','a') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  if sys.argv[1:]==['--prepare-only']:prepare()
  elif sys.argv[1:]==['--execute']:execute()
  else:raise SystemExit('use --prepare-only or --execute')
