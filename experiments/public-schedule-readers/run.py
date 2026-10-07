#!/usr/bin/env python3
"""Bounded, source-current schedule-reader semantics; no performance claim."""
import gzip,hashlib,json,os,pathlib,re,shutil,subprocess,tempfile,time,signal,sys
ROOT=pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'scripts'))
from task_runner import execute_result, _raise_failure
LOCAL=pathlib.Path('experiments/public-schedule-readers')
OUT=ROOT/'.artifacts'/('public-schedule-readers-'+str(time.time_ns()));OUT.mkdir(parents=True)
FIXED={};STAGES={};INVENTORIES={}
receipt={'format':1,'limits':{'checker':5,'emit':30,'clang':120,'runtime':5},'commands':[],'cases':[],'source':{},'qualification':'Finite semantics only; no timing cohorts or performance acceptance.'}
env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def inventory(directory,suffixes=None):
 return {str(p):sha(p) for p in sorted(directory.rglob('*')) if p.is_file() and '.git' not in p.parts and '__pycache__' not in p.parts and (suffixes is None or p.suffix in suffixes)}
def guard():
 assert all(pathlib.Path(k).is_file() and sha(pathlib.Path(k))==v for k,v in FIXED.items()),'fixed input changed'
 for directory,(suffixes,expected) in INVENTORIES.items():assert inventory(pathlib.Path(directory),suffixes)==expected,('inventory drift',directory)
 for stage,expected in STAGES.items():
  actual={}
  for directory in [stage/'src',stage/LOCAL]:actual.update(inventory(directory,{'.bend','.json','.mjs','.py'}))
  assert actual==expected,('staged input drift',stage)
def run(args,cap,cwd=ROOT,expected=0):
 guard();args=list(map(str,args));inputs={}
 for i,arg in enumerate(args):
  file=pathlib.Path(arg)
  if i and args[i-1]=='-o':continue
  if file.is_file():inputs[str(file.resolve())]=sha(file)
 result=execute_result(args,cap,env,cwd,capture='split')
 p=subprocess.CompletedProcess(args,result['exit'],result['stdout'],result['stderr'])
 if result['failure']:
  receipt['commands'].append({'args':args,'cap':cap,'failure':result['failure'],'stdoutSHA':hashlib.sha256(p.stdout).hexdigest(),'stderr':p.stderr.decode(errors='replace')})
  _raise_failure(result)
 receipt['commands'].append({'args':args,'cap':cap,'exit':p.returncode,'inputs':inputs,'stdoutSHA':hashlib.sha256(p.stdout).hexdigest(),'stderr':p.stderr.decode()})
 guard();assert all(sha(pathlib.Path(k))==v for k,v in inputs.items()),'command input drift'
 if expected is not None:assert p.returncode==expected,(args,p.stdout.decode(),p.stderr.decode())
 return p
mutants={'event-skip-keeps-backlog': ('experiments/public-schedule-readers/driver.bend',
                              'Ev.skip(~S.Schema,~S.Store,~Unit,~S.Notice,D.attach(~S.Schema,~S.Store,~Unit,~S.Notice,events,world),reader)',
                              '(D.attach(~S.Schema,~S.Store,~Unit,~S.Notice,events,world),reader)'),
 'own-write-replays': ('src/ecs/system.bend',
                       'def run_tracked(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: '
                       'Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> '
                       'Outcome<W.World<S,C,R,E>,Error,Output>,registry: '
                       'Registry<S,C,R,E,Args,Error,Output,runner>,world: W.World<S,C,R,E>,args: '
                       'Args) -> RunResult<S,C,R,E,Args,Error,Output,runner>:\n'
                       '  '
                       'tracked_result(~S,~C,~R,~E,~Args,~Error,~Output,~runner,run(~S,~C,~R,~E,~Args,~Error,~Output,~runner,registry,world,args))',
                       'def pre_clock_run(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: '
                       'Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> '
                       'Outcome<W.World<S,C,R,E>,Error,Output>,registry: '
                       'Registry<S,C,R,E,Args,Error,Output,runner>,world: W.World<S,C,R,E> & '
                       'U32,args: Args) -> RunResult<S,C,R,E,Args,Error,Output,runner>:\n'
                       '  match world:\n'
                       '    case (world,clock): '
                       'run_to_cursor(~S,~C,~R,~E,~Args,~Error,~Output,~runner,registry,world,args,clock)\n'
                       '\n'
                       'def run_tracked(~S: Data,~C: Type,~R: Type,~E: Data,~Args: Type,~Error: '
                       'Data,~Output: Type,~runner: W.World<S,C,R,E> -> Args -> '
                       'Outcome<W.World<S,C,R,E>,Error,Output>,registry: '
                       'Registry<S,C,R,E,Args,Error,Output,runner>,world: W.World<S,C,R,E>,args: '
                       'Args) -> RunResult<S,C,R,E,Args,Error,Output,runner>:\n'
                       '  '
                       'pre_clock_run(~S,~C,~R,~E,~Args,~Error,~Output,~runner,registry,W.clock(~S,~C,~R,~E,world),args)'),
 'event-failure-advances': ('src/ecs/event-runtime.bend',
                            'case Sy.Failed{world,error}: '
                            'Ran{Runtime{world,namespace,batches,activate(positions,readerId,Nat.sub(tick,1n)),',
                            'case Sy.Failed{world,error}: '
                            'Ran{Runtime{world,namespace,batches,update(activate(positions,readerId,Nat.sub(tick,1n)),readerId,tick,False{}),'),
 'removal-failure-advances': ('src/ecs/removals.bend',
                              'case reader Sys.Failed{world,error}: '
                              'Completed{reader,Sys.Failed{world,error}}',
                              'case Reader{namespace,id,name,_} Sys.Failed{world,error}: '
                              'Completed{Reader{namespace,id,name,next},Sys.Failed{world,error}}'),
 'publisher-failure-commits': ('experiments/public-schedule-readers/operations.bend',
                               'case True{}: T.Failure{C.Failed{"publisher"}}',
                               'case True{}: T.Success{}'),
 'removal-domain-lost': ('src/ecs/reader-domains.bend',
                         'world,removals),Events{namespace',
                         'world,[]),Events{namespace'),
 'event-recovery-keeps-notices': ('src/ecs/reader-domains.bend',
                                  'def recover(~S: Data,~C: Type,~R: Type,~E: Data,~is_event: E -> '
                                  'Bool,runtime: Ev.Runtime<S,C,R,E>,+old_removals: List<&2,E>) -> '
                                  'Detached<S,C,R,E>:\n'
                                  '  match runtime:\n'
                                  '    case '
                                  'Ev.Runtime{world,+namespace,+batches,+positions,+nextReader,+tick,+frameStart,+boundary,+capacity,+dropped}: '
                                  'recovery_view(~S,~C,~R,~E,~is_event,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped,old_removals,W.events_view(~S,~C,~R,~E,world))',
                                  'def recover(~S: Data,~C: Type,~R: Type,~E: Data,~is_event: E -> '
                                  'Bool,runtime: Ev.Runtime<S,C,R,E>,+old_removals: List<&2,E>) -> '
                                  'Detached<S,C,R,E>:\n'
                                  '  detach(~S,~C,~R,~E,runtime,old_removals)')}
try:
 def imports(path,seen):
  if path in seen:return
  seen.add(path)
  for name in re.findall(r'^import\s+([^\s]+)',path.read_text(),re.M):
   if name!='Base' and name.endswith('.bend'):imports((path.parent/name).resolve(),seen)
 dependencies=set()
 for entry in (ROOT/LOCAL).glob('*.bend'):imports(entry,dependencies)
 for p in dependencies|{p for p in (ROOT/LOCAL).glob('*') if p.suffix in {'.bend','.json','.mjs','.py'}}:
  if p.is_file():receipt['source'][str(p.relative_to(ROOT))]=sha(p)
 FIXED.update({str(ROOT/k):v for k,v in receipt['source'].items()})
 for directory,suffixes in [(ROOT/'.references/bevy-ts/packages/core/src',{'.ts'}),(pathlib.Path('/home/node/.bend/bend2'),None)]:
  bound=inventory(directory,suffixes);INVENTORIES[str(directory)]=(suffixes,bound)
  receipt.setdefault('externalInventories',{})[str(directory)]=bound
 for file in [pathlib.Path(shutil.which('bend')).resolve(),pathlib.Path(shutil.which('node')).resolve(),pathlib.Path(sys.executable).resolve(),pathlib.Path('/tmp/bendvy-clang19-diagnostic/clang19'),pathlib.Path('/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang')]:
  FIXED[str(file)]=sha(file)
 for file in [ROOT/'.references/bevy-ts/package.json',ROOT/'.references/bevy-ts/packages/core/package.json',pathlib.Path('/home/node/.bend/check.json')]:
  FIXED[str(file)]=sha(file)
 receipt['fixedInputs']=dict(FIXED)
 receipt['affinity']=sorted(os.sched_getaffinity(0))
 receipt['referenceManifestSHA']=sha(ROOT/'.references/sources.json')
 manifest=json.loads((ROOT/'.references/sources.json').read_text())
 receipt['references']={}
 for name,entry in manifest['sources'].items():
  actual=run(['git','-C',ROOT/'.references'/name,'rev-parse','HEAD'],5).stdout.decode().strip()
  assert actual==entry['commit'];receipt['references'][name]=actual
 receipt['compilerSHA']=sha(pathlib.Path(shutil.which('bend')).resolve())
 receipt['versions']={k:run(cmd,5).stdout.decode().strip() for k,cmd in [('Bend',['bend','version']),('Node',['node','--version']),('Clang',['/tmp/bendvy-clang19-diagnostic/clang19','--version'])]}
 run(['node',ROOT/LOCAL/'reference.mjs','--verify'],5)
 run(['node',ROOT/LOCAL/'added-reference.mjs','--verify'],5)
 expected=json.loads((ROOT/LOCAL/'expected.json').read_text())
 for name,fragment in [('affine','consumed more than once'),('schema','D.Events<Other'),('read-write','Cap.Write'),('undeclared','access~H')]:
  q=run(['bend',ROOT/LOCAL/('negative-'+name+'.bend'),'--check-only'],5,expected=1)
  assert fragment in (q.stdout+q.stderr).decode();(OUT/('negative-'+name+'.log')).write_bytes(q.stdout+q.stderr)
 for subject in ['domain-controls','lifecycle-controls','mixed-controls','added-controls','event-mixed-controls']:
  entry=ROOT/LOCAL/(subject+'.bend');run(['bend',entry,'--check-only'],5)
  for backend,ext in [('JS','js'),('Native','c')]:
   generated=OUT/(subject+'.'+ext);run(['bend',entry,'-o',generated],30)
   if backend=='Native':
    executable=OUT/(subject+'.native');run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',generated,'-pthread','-lm','-o',executable],120);cmd=[executable,'--threads','1','--gpu','off']
   else:cmd=['node',generated]
   observed=run(cmd,5).stdout
   if subject=='domain-controls':assert observed.strip()==b'[ping:10, ping:11, ping:12]|[removed:1, removed:2, removed:3, removed:4]|resource:[77, 77, 77, 77]'
   else:assert json.loads(observed)==json.loads((ROOT/LOCAL/(subject.replace('-controls','-expected')+'.json')).read_text())
   (OUT/(subject+'-'+backend+'.json')).write_bytes(observed)
   receipt['cases'].append({'case':subject,'backend':backend,'controlPassed':True,'outputSHA':hashlib.sha256(observed).hexdigest()})
 for case in ['current','foreign-world',*mutants]:
  stage=OUT/case
  expectedStage={}
  for key,value in receipt['source'].items():
   target=stage/key;target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(ROOT/key,target);assert sha(target)==value
   expectedStage[str(target)]=value
  if case=='foreign-world':
   file=LOCAL/'driver.bend';target=stage/file;old='~Owners,namespace,"reader-tick",steps';new='~Owners,(namespace+1 : U32),"reader-tick",steps';text=target.read_text();assert text.count(old)==1;target.write_text(text.replace(old,new));expectedStage[str(target)]=sha(target)
   receipt['foreignInput']={'file':str(file),'before':old,'after':new,'SHA':sha(target)}
  elif case!='current':
   file,old,new=mutants[case];p=stage/file;t=p.read_text();assert old in t,(case,old);p.write_text(t.replace(old,new));receipt.setdefault('mutations',{})[case]={'file':str(file),'before':old,'after':new,'occurrences':t.count(old),'beforeSHA':expectedStage[str(p)],'afterSHA':sha(p)};expectedStage[str(p)]=sha(p)
  STAGES[stage]=expectedStage;guard()
  receipt.setdefault('stages',{})[case]=expectedStage
  subject='event-mixed-controls' if case=='event-recovery-keeps-notices' else 'driver'
  caseExpected=json.loads((ROOT/LOCAL/'event-mixed-expected.json').read_text()) if subject!='driver' else expected
  entry=stage/LOCAL/(subject+'.bend');run(['bend',entry,'--check-only'],5,stage)
  for backend,ext in [('JS','js'),('Native','c')]:
   generated=stage/('driver.'+ext);run(['bend',entry,'-o',generated],30,stage)
   if backend=='Native':
    executable=stage/'driver.native';run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',generated,'-pthread','-lm','-o',executable],120,stage);cmd=[executable,'--threads','1','--gpu','off']
   else:cmd=['node',generated]
   p=run(cmd,5,stage);observed=json.loads(p.stdout);equal=observed==caseExpected
   assert equal==(case=='current'),(case,backend)
   if case=='foreign-world':assert all(not point['ok'] and not point['reads'] and not point['entities'] and not point['events'] for point in observed['checkpoints'])
   diffs=[{'checkpoint':a.get('label'),'fields':[k for k in a if a[k]!=b.get(k)]} for a,b in zip(caseExpected['checkpoints'],observed['checkpoints']) if a!=b]
   with gzip.open(stage/(backend+'.json.gz'),'wb') as f:f.write(p.stdout)
   receipt['cases'].append({'case':case,'backend':backend,'exact':equal,'differences':diffs,'outputSHA':hashlib.sha256(p.stdout).hexdigest(),'generatedSHA':sha(generated)})
 guard()
 receipt['sourceUnchanged']=all(sha(ROOT/k)==v for k,v in receipt['source'].items());assert receipt['sourceUnchanged']
 receipt['status']='PASS'
finally:
 (OUT/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(OUT)
