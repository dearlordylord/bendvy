"""Isolated current public Batch constructor gate; reviewed raw/tool/log helpers."""
from pathlib import Path
import argparse,functools,hashlib,json,os,re,runpy,shutil,sys,tempfile,time
ROOT=Path(__file__).resolve().parents[5];LOCAL=Path('experiments/public-bundles/production-candidate/transactions/invalid-constructor-v1');HERE=ROOT/LOCAL
parser=argparse.ArgumentParser();parser.add_argument('--prepare-only',action='store_true');parser.add_argument('--preflight-only',action='store_true');args=parser.parse_args()
os.sched_setaffinity(0,{5})
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def inventory(p):return {str(f.relative_to(p)):sha(f) for f in sorted(p.rglob('*')) if f.is_file()}
def core_inventory():return {str(f.relative_to(ROOT)):sha(f) for f in sorted((ROOT/'src/ecs').iterdir()) if f.is_file() and f.suffix in ('.bend','.c','.js')}
core=core_inventory();assert sum(n.endswith('.bend') for n in core)==46
files=set()
def closure(p):
 p=p.resolve()
 if p in files:return
 files.add(p)
 if p.suffix!='.bend':return
 for name in re.findall(r'^\s*import\s+(\S+)',p.read_text(),re.M):
  if name!='Base':closure(p.parent/name.strip('"'))
closure(HERE/'main.bend')
RUNNER=Path('scripts/task_runner.py')
files.update(p for p in HERE.iterdir() if p.is_file())
files.update(ROOT/p for p in [RUNNER,Path('scripts/owned-tool-pins.py'),Path('scripts/receipt-logs.py'),Path('scripts/bend-check')])
sources={str(p.relative_to(ROOT)):sha(p) for p in files}
configNames=['bend.json','bend.config.json','bunfig.toml','package.json','.clang','clang.cfg']
def config_inventory(roots):return {str(root/name):(sha(root/name) if (root/name).is_file() else None) for root in roots for name in configNames}
configurationRoots={ROOT,Path.cwd(),HERE,Path('/tmp/bendvy-clang19-diagnostic'),Path('/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin')}
rootConfigs=config_inventory(configurationRoots)
external={str(p):inventory(p) for p in [ROOT/'.references/bevy-ts/packages/core/src',Path('/home/node/.bend/bend2')]}
fixed={str(p):sha(p) for p in [Path('/home/node/.bend/check.json'),ROOT/'.references/sources.json',ROOT/'.references/bevy-ts/package.json',ROOT/'.references/bevy-ts/packages/core/package.json']}
labels=['runner-raw','runner-escape','bend-version','bend-guide','reference-bevy-ts','reference-bevy','reference-bend2','constructor-proof-boundary','TS-current-constructors','constructor-live','constructor-JS-emit','constructor-JS-run','constructor-Native-emit','constructor-Native-clang','constructor-Native-run']
OUT=ROOT/'.artifacts'/('bundles41-invalid-constructors-'+str(time.time_ns()));OUT.mkdir();logs=runpy.run_path(str(ROOT/'scripts/receipt-logs.py'))['CommandLogs'](OUT,labels)
r={'status':'INCOMPLETE','sources':sources,'coreInventory':core,'coreBendModules':46,'coreEffectAssets':2,'externalInventories':external,'fixedInputs':fixed,'plannedLabels':labels,'rootConfigurations':rootConfigs,'commands':[],'generated':{},'immutableLogs':{},'cases':{},'caps':{'checker/interpreter':5,'emit':30,'clang':120,'runtime':5},'affinity':[5],'hostObservations':[],'scope':'Fourteen current public invalid-constructor owner/refusal/barrier/retry observations in two schemas plus eight actual TS applications; no repeated unchanged mutations/negatives, failed-activation policy/proofs/production/timing approval'}
env=dict(os.environ,BEND_NO_TELEMETRY='1',BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root')
CLANG_ROOT=Path('/tmp/bendvy-clang19-diagnostic/root');toolEnv=dict(env,LD_LIBRARY_PATH=':'.join(map(str,[CLANG_ROOT/'usr/lib/aarch64-linux-gnu',CLANG_ROOT/'usr/lib/llvm-19/lib',Path('/home/node/.local/opt/dnd-clang14/usr/lib/aarch64-linux-gnu')])))
def host(label):r['hostObservations'].append({'label':label,'monotonicNs':time.monotonic_ns(),'procStat':Path('/proc/stat').read_text(),'procLoadavg':Path('/proc/loadavg').read_text(),'procMeminfo':Path('/proc/meminfo').read_text(),'procVmstat':Path('/proc/vmstat').read_text()})
def encoded(value):
 if isinstance(value,bytes):return {'rawHex':value.hex()}
 raise TypeError(type(value).__name__)
try:
 with tempfile.TemporaryDirectory(prefix='bundles41-invalid-constructors-') as tmp:
  stage=Path(tmp)
  for name in sources:
   p=stage/name;p.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/name,p)
  staged=dict(sources);stageConfigs=config_inventory({stage,stage/LOCAL});r['stageConfigurations']=stageConfigs
  sys.dont_write_bytecode=True
  sys.path.insert(0,str(stage/'scripts'))
  import task_runner as runner
  assert Path(runner.__file__).resolve()==(stage/RUNNER).resolve()
  r['runnerSHA256']=runner.IMPLEMENTATION_SHA256
  tools=runpy.run_path(str(stage/'scripts/owned-tool-pins.py'))
  toolConfig=dict(execute=functools.partial(runner.execute_result,capture='split'),tools={'bend':Path(shutil.which('bend')).resolve(),'node':Path(shutil.which('node')).resolve(),'python':Path(sys.executable).resolve(),'taskset':Path(shutil.which('taskset')).resolve(),'git':Path(shutil.which('git')).resolve(),'clang-wrapper':Path('/tmp/bendvy-clang19-diagnostic/clang19'),'clang-native':CLANG_ROOT/'usr/lib/llvm-19/bin/clang'},resource_roots=[Path('/home/node/.bend/bend2'),CLANG_ROOT/'usr/lib/llvm-19/lib/clang/19'],ldd=Path(shutil.which('ldd')).resolve(),taskset=Path(shutil.which('taskset')).resolve(),cpu=5,env=toolEnv,skip_ldd=('clang-wrapper',),capture_mode='split')
  toolSnapshot=tools['snapshot'](**toolConfig);r['toolSnapshot']=toolSnapshot
  def guard():
   tools['verify'](toolSnapshot,**toolConfig);logs.guard()
   assert core_inventory()==core,'46-module/effect inventory drift'
   assert config_inventory(configurationRoots)==rootConfigs,'root/cwd config drift'
   assert config_inventory({stage,stage/LOCAL})==stageConfigs,'stage config drift'
   assert all(sha(ROOT/n)==h for n,h in sources.items()),'live source drift'
   assert inventory(stage)==staged,'exact stage drift'
   assert all(inventory(Path(n))==h for n,h in external.items()),'external/tool/Base inventory drift'
   assert all(sha(n)==h for n,h in fixed.items()),'fixed input drift'
   assert all(sha(OUT/n)==h for n,h in r['generated'].items()),'generated drift'
  def run(label,argv,cap,exit=0,emits=None):
   guard();assert label in labels
   if emits:assert not (OUT/emits).exists()
   argv=['taskset','-c','5']+list(map(str,argv));host('before-'+label)
   try:code,out,err=runner.execute_split(argv,cap,env=env)
   except (TimeoutError,RuntimeError) as error:
    r['immutableLogs']=logs.record(label,getattr(error,'stdout',b''),getattr(error,'stderr',b''));r['commands'].append({'label':label,'argv':argv,'cap':cap,'supervisionFailure':str(error)});raise
   r['immutableLogs']=logs.record(label,out,err);r['commands'].append({'label':label,'argv':argv,'cap':cap,'exit':code,'stdoutSHA256':sha(OUT/(label+'.stdout')),'stderrSHA256':sha(OUT/(label+'.stderr'))});assert code==exit,(label,err.decode())
   if emits:r['generated'][emits]=sha(OUT/emits)
   guard();host('after-'+label);return out.decode(),err.decode()
  guard();host('prepared')
  if args.prepare_only:r['status']='PREPARED_NOT_EXECUTED'
  else:
   out,err=run('runner-raw',[sys.executable,stage/LOCAL/'runner-control.py','raw'],5);assert out=='raw-out\n' and err=='raw-err\n'
   guard()
   try:runner.execute_split(['taskset','-c','5',sys.executable,str(stage/LOCAL/'runner-control.py'),'escape'],0.5,env=env)
   except TimeoutError as error:
    out=error.stdout;err=error.stderr;assert out.startswith(b'escaped:') and not err;pid=int(out.decode().strip().split(':')[1]);assert not Path('/proc',str(pid)).exists() and not runner.child_pids(os.getpid());r['immutableLogs']=logs.record('runner-escape',out,err);r['commands'].append({'label':'runner-escape','expectedTimeoutControl':True,'escapedPID':pid,'reaped':True})
   else:raise AssertionError('escaping child deadline absent')
   guard()
   out,err=run('bend-version',['bend','version'],5);assert out=='bend 2.0.35\n' and not err
   out,err=run('bend-guide',['bend','guide'],5);assert '# Bend' in out and 'Core Features' in out and not err
   manifest=json.loads((ROOT/'.references/sources.json').read_text())
   for name,entry in manifest['sources'].items():out,err=run('reference-'+name,['git','-C',ROOT/'.references'/name,'rev-parse','HEAD'],5);assert not err and out.strip()==entry['commit']
   fixture=stage/LOCAL/'main.bend'
   out,err=run('constructor-proof-boundary',['bend',fixture,'--check-only'],5,1);assert not out and err==(stage/LOCAL/'expected-check-only.stderr').read_text();r['foreignBoundaryIsProofPass']=False
   out,err=run('TS-current-constructors',['node',stage/LOCAL/'reference.mjs'],5);assert not err and out==(stage/LOCAL/'expected-reference.stdout').read_text();r['referenceApplications']=8
   expected=(stage/LOCAL/'expected.stdout').read_text();out,err=run('constructor-live',['bend',fixture],5);assert not err and out==expected,('full literal constructor mismatch',out);r['liveRows']=14
   if args.preflight_only:r['status']='CURRENT_CONSTRUCTOR_PREFLIGHT_PASS'
   else:
    for backend in ['JS','Native']:
     suffix='js' if backend=='JS' else 'c';label='constructor-'+backend;run(label+'-emit',['bend',fixture,'-o',OUT/(label+'.'+suffix)],30,emits=label+'.'+suffix)
     if backend=='Native':run(label+'-clang',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',OUT/(label+'.c'),'-pthread','-lm','-o',OUT/(label+'.native')],120,emits=label+'.native')
     seen,err=run(label+'-run',['node',OUT/(label+'.js')] if backend=='JS' else [OUT/(label+'.native'),'--threads','1','--gpu','off'],5);assert not err and seen==expected;r['cases'][backend]={'fullLiteralMatch':True,'rows':14,'stdoutSHA256':hashlib.sha256(seen.encode()).hexdigest()}
    r['status']='CURRENT_PUBLIC_BATCH_CONSTRUCTOR_FINITE_PASS';r['nativeExecuted']=True
  guard()
finally:
 host('terminal');(OUT/'receipt.json').write_text(json.dumps(r,indent=2,default=encoded)+'\n');print(OUT)
