"""Six-subject canonical complete22/20 Native qualification."""
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
def config(env):return dict(execute=owned_probe,tools={'bend':Path(shutil.which('bend')).resolve(),'python':Path(sys.executable).resolve(),'clang-wrapper':Path('/tmp/bendvy-clang19-diagnostic/clang19'),'clang-native':Path('/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang')},resource_roots=[Path('/home/node/.bend/bend2'),Path('/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/lib/clang/19')],skip_ldd=('clang-wrapper',),ldd=Path(shutil.which('ldd')).resolve(),taskset=Path(shutil.which('taskset')).resolve(),cpu=min(os.sched_getaffinity(0)),env=env,capture_mode='split')
def expected_environment():
 return dict(os.environ,BEND_NO_TELEMETRY='1',BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root',LD_LIBRARY_PATH='/tmp/bendvy-clang19-diagnostic/root/usr/lib/aarch64-linux-gnu:/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/lib:/home/node/.local/opt/dnd-clang14/usr/lib/aarch64-linux-gnu')

def preflight():
 delivery=json.loads((CANDIDATE/'DELIVERY.json').read_text())
 assert all(sha(CANDIDATE/n)==v for n,v in delivery['files'].items())
 binding=json.loads((CANDIDATE/'BINDING.json').read_text())
 with zipfile.ZipFile(CANDIDATE/'source-stage.zip') as archive:
  assert set(archive.namelist())==set(binding['stage'])
  assert all(hashlib.sha256(archive.read(n)).hexdigest()==v for n,v in binding['stage'].items())
  for n in binding['stage']:
   if n.endswith('.bend'):
    for imported in re.findall(r'^\s*import "([^"]+)"',archive.read(n).decode(),re.M):
     resolved=str(Path(os.path.normpath(str(Path(n).parent/imported))))
     assert resolved in binding['stage'],'missing quoted foreign import before discovery'
 source=HERE.parent/'production-controls-v3'
 finite=json.loads((source/'FINITE-DELIVERY.json').read_text())
 assert all(sha(source/n)==v for n,v in finite['selectedLiveFiles'].items())
 assert sha(source/'evidence-v1.zip')==finite['archiveSha256']
 with zipfile.ZipFile(source/'evidence-v1.zip') as archive:
  assert set(archive.namelist())==set(finite['archiveEntries'])
  assert all(hashlib.sha256(archive.read(n)).hexdigest()==v for n,v in finite['archiveEntries'].items())
  raw=archive.read('production-controls-v3/execution/receipt.json')
  assert hashlib.sha256(raw).hexdigest()==finite['receiptSha256']
  receipt=json.loads(raw)
  assert receipt['status']=='PRODUCTION68_SUPPORT_EIGHT_NEGATIVES_TWO_IO_BOUNDARIES_MATCH_NOT_PROOF_NOT_RUNTIME'
  assert receipt['stagedInputs']==binding['stage'] and len(receipt['commands'])==11
  assert all(c['failure'] is None for c in receipt['commands'])
 for label in ['bounded','surface']:
  comparator=json.loads((HERE.parent/(label+'-delivery.json')).read_text())
  archivePath=HERE.parent/(label+'-evidence-v1.zip')
  assert sha(archivePath)==comparator['archiveSHA256'],'qualified comparator archive drift'
  with zipfile.ZipFile(archivePath) as archive:
   assert set(archive.namelist())==set(comparator['archiveEntries'])
   assert all(hashlib.sha256(archive.read(n)).hexdigest()==v for n,v in comparator['archiveEntries'].items())
 proposal=json.loads(PROPOSAL.read_text())
 assert all(sha(n)==v for n,v in proposal['rootProductionPins'].items()),'root production drift'
 currentJS=HERE.parent/'production-js-v1'
 jsFinite=json.loads((currentJS/'FINITE-DELIVERY.json').read_text())
 assert all(sha(currentJS/n)==v for n,v in jsFinite['selectedLiveFiles'].items())
 assert sha(currentJS/'evidence-v1.zip')==jsFinite['archiveSha256']
 with zipfile.ZipFile(currentJS/'evidence-v1.zip') as archive:
  assert set(archive.namelist())==set(jsFinite['archiveEntries'])
  assert all(hashlib.sha256(archive.read(n)).hexdigest()==v for n,v in jsFinite['archiveEntries'].items())
  raw=archive.read('production-js-v1/execution/receipt.json')
  assert hashlib.sha256(raw).hexdigest()==jsFinite['receiptSha256']
  receipt=json.loads(raw)
  assert receipt['status']=='PRODUCTION_BUNDLES_COMPLETE22_AND20_JS_FINITE_PASS'
  assert receipt['stagedInputs']==binding['stage'] and len(receipt['commands'])==4
  assert all(c['exit']==0 and c['failure'] is None for c in receipt['commands'])
  for label,oracle in [('full22','expected.stdout'),('full20','surface-expected.stdout')]:
   assert archive.read('production-js-v1/execution/'+label+'-JS-consumer.stdout')==(HERE.parent/oracle).read_bytes()
 return binding

def configuration_roots():
 return {ROOT,HERE,OUT,Path.cwd(),Path('/home/node/.bend'),Path(shutil.which('bend')).resolve().parent,Path('/tmp/bendvy-clang19-diagnostic'),Path('/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin'),Path('/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/lib/clang/19'),*[Path(n).parent for n in json.loads(PROPOSAL.read_text())['rootProductionPins']]}

def prepare():
 assert not PLAN.exists() and not ENV.exists();binding=preflight()
 proposal=json.loads(PROPOSAL.read_text())
 files=dict(proposal['inputs']);files.update(proposal['rootProductionPins'])
 for name in json.loads((CANDIDATE/'DELIVERY.json').read_text())['files']:
  files[str(CANDIDATE/name)]=sha(CANDIDATE/name)
 for path in [Path(__file__),PROPOSAL,HERE/'HANDOFF.md',HERE/'DELIVERY.json',ROOT/'scripts/task_runner.py',ROOT/'scripts/owned-tool-pins.py']:
  files[str(path)]=sha(path)
 assert all(sha(name)==want for name,want in files.items())
 env=expected_environment()
 ENV.write_text(json.dumps(env,sort_keys=True,indent=2)+'\n');ENV.chmod(0o600)
 beforeConfigs=configs(configuration_roots());beforeLoaders=loaders()
 snapshot=T['snapshot'](**config(env))
 assert all(sha(n)==v for n,v in files.items()) and env==expected_environment()
 assert configs(configuration_roots())==beforeConfigs and loaders()==beforeLoaders
 plan=dict(status='UNEXECUTED',files=files,stageFiles=binding['stage'],environmentSHA256=sha(ENV),toolSnapshot=snapshot,commands=proposal['commands'],rootConfigurations=configs(configuration_roots()),loaderConfigurations=loaders(),preparationProbeResults=list(PROBES),scope=proposal['qualification'])
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
    assert set(archive.namelist())==set(plan['stageFiles'])
    for name in archive.namelist():
     path=stage/name;assert path.is_relative_to(stage) and '..' not in Path(name).parts
     path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(archive.read(name))
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
    argv=[str(stage)+arg[5:] if arg.startswith('STAGE/') else str(OUT)+arg[3:] if arg.startswith('OUT/') else arg for arg in command['argv']]
    result=R.execute_result(argv,command['seconds'],cwd=stage,env=env,capture='split');label=command['label']
    for stream in ('stdout','stderr'):
     path=OUT/(label+'.'+stream);assert not path.exists();path.write_bytes(result[stream]);receipt['rawLogs'][path.name]=sha(path)
    receipt['commands'].append(dict(label=label,argv=argv,seconds=command['seconds'],exit=result['exit'],failure=result['failure'],result=result));save()
    guard()
    assert result['failure'] is None and result['exit']==0,label
    if command['kind']=='emit':
     assert not result['stdout']
     receipt['generated'][command['generated']]=sha(OUT/command['generated'])
     # Current CLI may append its explicit update notice; raw stderr is retained.
     assert result['stderr'] in (b'',b'bend 2.0.36 is available: run bend update\n'),label
    else:
     assert not result['stderr'],label
     oracle=ROOT/command['completeOracle']
     assert sha(oracle)==command['completeOracleSha256'] and result['stdout']==oracle.read_bytes(),'complete literal oracle mismatch'
     assert len(result['stdout'].splitlines())==command['rows']
     receipt.setdefault('fullPhysicalRows',{})[label]=command['rows']
   join=runpy.run_path(str(HERE.parent/'surface-public-join.py'))['compare']
   report=join((OUT/'full20-Native-consumer.stdout').read_text(),(HERE.parent/'surface-expected-reference.stdout').read_text())
   assert len(report['publicCheckpoints'])==20
   path=OUT/'declared-public-join.json';path.write_text(json.dumps(report,indent=2)+'\n');receipt['rawLogs'][path.name]=sha(path);guard()
   with zipfile.ZipFile(HERE.parent/'production-js-v1/evidence-v1.zip') as jsArchive:
    for label in ['full22','full20']:
     assert (OUT/(label+'-Native-consumer.stdout')).read_bytes()==jsArchive.read('production-js-v1/execution/'+label+'-JS-consumer.stdout')
   receipt['status']='PRODUCTION_BUNDLES_COMPLETE22_AND20_NATIVE_FINITE_PASS'
 finally:save();print(OUT/'receipt.json')

if __name__=='__main__':
 with open('/tmp/bendvy-parity-heavy.lock','a') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  if sys.argv[1:]==['--prepare-only']:prepare()
  elif sys.argv[1:]==['--execute']:execute()
  else:raise SystemExit('use --prepare-only or --execute')
