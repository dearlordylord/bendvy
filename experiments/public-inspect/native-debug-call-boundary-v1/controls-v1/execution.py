"""Focused derivative of existing native-development Runner/Inputs/receipt recipe."""
import fcntl,gzip,hashlib,json,os,stat,sys,types
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path('/workspace/formal-proofs/bendvy')
HERE=Path(__file__).resolve().parent

def sha(path):
 p=Path(path)
 if p.is_symlink() or not p.is_file():raise ValueError('regular nonsymlink file required')
 with p.open('rb') as f:
  if not stat.S_ISREG(os.fstat(f.fileno()).st_mode):raise ValueError('regular descriptor required')
  return hashlib.sha256(f.read()).hexdigest()
def load(name,path,pins=None):
 path=Path(path)
 if path.is_symlink() or not path.is_file():raise ValueError('regular source required')
 with path.open('rb') as stream:
  if not stat.S_ISREG(os.fstat(stream.fileno()).st_mode):raise ValueError('regular source descriptor required')
  raw=stream.read()
 if pins is not None and hashlib.sha256(raw).hexdigest()!=pins[str(path)]:raise ValueError('loaded source drift')
 m=types.ModuleType(name);m.__file__=str(path);m.__dict__['PINNED_FILES']=pins
 exec(compile(raw,str(path),'exec'),m.__dict__);return m
def capture(path,raw):
 p=Path(path)
 if p.exists() or p.is_symlink():raise ValueError('output must start absent')
 with p.open('xb') as f:f.write(raw)
def record_returned(record,command,result,out):
 row=dict(command)
 for key,value in result.items():
  if isinstance(value,bytes):row[key]={'path':str(Path(out)/(command['label']+'.'+key)),'bytes':len(value),'sha256':hashlib.sha256(value).hexdigest(),'publication':'pending'}
  else:row[key]=value
 record['commands'].append(row)
 return row
def publish_streams(row,result,pins):
 for key,value in result.items():
  if isinstance(value,bytes):
   target=Path(row[key]['path'])
   try:
    capture(target,value);pins[str(target)]=sha(target);row[key]['publication']='complete'
   except Exception as error:
    row[key]['publication']='failed';row[key]['publicationError']=str(error)
    if target.is_file() and not target.is_symlink():
     actual=target.read_bytes();row[key]['retainedPartialBytes']=len(actual);row[key]['retainedPartialSHA256']=hashlib.sha256(actual).hexdigest();pins[str(target)]=row[key]['retainedPartialSHA256']
    raise
def capture_artifact(record,artifact,pins):
 if artifact is not None and (Path(artifact).exists() or Path(artifact).is_symlink()):
  ledger={'path':str(artifact)};record.setdefault('artifactLedger',[]).append(ledger)
  try:
   pins[str(artifact)]=sha(artifact);ledger['sha256']=pins[str(artifact)]
  except Exception as error:
   ledger['captureError']=str(error);raise
def prepare(out):
 out=Path(out).resolve();out.mkdir(exist_ok=False)
 root=HERE.parent;stage=out/'stage';stage.mkdir()
 for name in ['baseline','candidate']:capture(stage/(name+'.comp.ts'),gzip.decompress((root/(name+'.comp.ts.gz')).read_bytes()))
 for p in HERE.glob('*.bend'):capture(stage/p.name,p.read_bytes())
 capture(stage/'emit-controls.mts',(HERE/'emit-controls.mts').read_bytes())
 capture(stage/'witness-gate.mjs',(HERE/'witness-gate.mjs').read_bytes())
 config=ROOT/'experiments/public-simulation/delivery-v1/installed-config.py'
 configuration=load('existing_configuration',config);runner=load('existing_runner',ROOT/'scripts/task_runner.py')
 tools={'python':str(Path(sys.executable).resolve()),'node':'/home/node/.local/share/mise/installs/node/24.20.0/bin/node','taskset':'/usr/bin/taskset','clangWrapper':'/tmp/bendvy-clang19-diagnostic/clang19','clangBinary':'/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang'}
 pins={};bindings={}
 ref=Path('/workspace/formal-proofs/bendvy/.references/bend2/bend2')
 for p in [*root.rglob('*'),*stage.iterdir(),config,ROOT/'scripts/task_runner.py',ROOT/'scripts/evidence_boundary.py',*map(Path,tools.values()),*map(Path,configuration.LINK_INPUTS),ref/'comp.ts',ref/'bend.ts',ref/'base.bend',*ref.joinpath('effs').rglob('*')]:
  if p.is_file() and '__pycache__' not in p.parts and p.suffix!='.pyc':
   resolved=p.resolve(strict=True);pins[str(resolved)]=sha(resolved)
   if p.is_symlink():bindings[str(p)]=str(resolved)
 transport=Path('/workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/declaration-adoption-v1/transport-v1/transport.py')
 parser=Path('/workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/parse-scenario.py')
 for p in [transport,parser]:pins[str(p)]=sha(p)
 commands=[{'label':'emit-controls','argv':[tools['taskset'],'-c','5',tools['node'],str(stage/'emit-controls.mts'),str(out/'controls.json')],'capSeconds':30}]
 subjects=[]
 for name in ['physical-owners','erased-specialization','parallel-return','recursive-tail','layout-cut']:
  for subject in ['baseline','candidate']:
   label=name+'-'+subject;c=out/(label+'.c');binary=out/(label+'.native')
   subjects.append({'name':name,'subject':subject,'c':str(c),'binary':str(binary),'entry':str(HERE/(name+'.bend')),'expected':str(HERE/(name+'.expected.json'))})
   commands += [{'label':label+'-build','argv':[tools['taskset'],'-c','5',tools['clangWrapper'],'-O3',str(c),'-o',str(binary),'-pthread','-lm'],'capSeconds':120},{'label':label+'-consumer','argv':[tools['taskset'],'-c','5',str(binary),'--threads','1','--gpu','off'],'capSeconds':5}]
 plan={'scope':'Five complete branch-reaching copied compiler controls only; no installed compiler/Native56/full71/performance acceptance','fileBindings':bindings,'pins':pins,'resourceRoots':runner.Inputs(directories=configuration.RESOURCE_ROOTS).expected,'environment':configuration.environment(),'tools':tools,'cwd':str(HERE),'report':str(out/'controls.json'),'subjects':subjects,'commands':commands,'postConsumer':'Existing exact source-derived Data transport validates whole Report vs independent source-authored expected model; both baseline and candidate; empty stderr'}
 capture(out/'plan.json',(json.dumps(plan,indent=2)+'\n').encode());print(sha(out/'plan.json'))
def run(planpath,admitted):
 planpath=Path(planpath).resolve(strict=True)
 if sha(planpath)!=admitted:raise ValueError('admitted plan digest mismatch')
 p=json.loads(planpath.read_text());pins=dict(p['pins']);pins[str(planpath)]=admitted
 if {n:sha(n) for n in pins}!=pins:raise ValueError('preimport pins drift')
 if any(str(Path(n).resolve(strict=True))!=target for n,target in p.get('fileBindings',{}).items()):raise ValueError('preimport link resolution drift')
 actual=str(Path(sys.executable).resolve(strict=True))
 if actual!=p['tools']['python'] or sha(actual)!=pins[actual]:raise ValueError('actual interpreter drift')
 runner=load('existing_runner',ROOT/'scripts/task_runner.py',pins);boundary=load('existing_boundary',ROOT/'scripts/evidence_boundary.py',pins);gate=load('existing_whole_control',HERE/'check-whole.py',pins)
 out=planpath.parent;record={'scope':p['scope'],'planSHA256':admitted,'commands':[],'guards':[]}
 def guard(label):
  actual={n:sha(n)for n in pins};unchanged=actual==pins
  if any(str(Path(n).resolve(strict=True))!=target for n,target in p.get('fileBindings',{}).items()):raise ValueError('link resolution drift')
  if runner.Inputs(directories=p['resourceRoots']).snapshot()!=p['resourceRoots']:raise ValueError('resource membership drift')
  target=out/(label+'.guard.json');capture(target,(json.dumps({'label':label,'actualPins':actual,'unchanged':unchanged},indent=2)+'\n').encode());record['guards'].append({'path':str(target),'sha256':sha(target)})
  if not unchanged:raise ValueError('guard drift')
 def step(command,artifact=None):
  label=command['label'];guard(label+'-pre')
  with boundary.GuardBoundary([('named post',lambda:guard(label+'-post'))]):
   with open('/tmp/bendvy-parity-heavy.lock','a') as lock:
    fcntl.flock(lock,fcntl.LOCK_EX)
    try:
     guard(label+'-acquired')
     if artifact is not None and (Path(artifact).exists() or Path(artifact).is_symlink()):raise ValueError('artifact must start absent')
     result=runner.execute_result(command['argv'],command['capSeconds'],p['environment'],p['cwd'],'split')
     row=record_returned(record,command,result,out)
     publish_streams(row,result,pins)
    finally:
     primary=sys.exc_info()[1]
     try:
      try:capture_artifact(record,artifact,pins)
      except Exception as error:
       if primary is None:raise
       record.setdefault('secondaryCaptureErrors',[]).append(str(error))
     finally:fcntl.flock(lock,fcntl.LOCK_UN)
   if result['failure'] is not None or result['exit']!=0:raise ValueError('child failed: '+label)
   return row
 with boundary.ReceiptBoundary(record,out/'receipt.json',[('final boundary',lambda:guard('final'))]):
  step(p['commands'][0],p['report']);report=json.loads(Path(p['report']).read_text())
  if report['status']!='EMISSION_CONTROLS_PASS' or len(report['cases'])!=5 or report['active'] is not None:raise ValueError('incomplete emission controls')
  byname={r['name']:r for r in report['cases']}
  for index,subject in enumerate(p['subjects']):
   row=byname[subject['name']];capture(subject['c'],row[subject['subject']+'C'].encode());pins[subject['c']]=sha(subject['c'])
   step(p['commands'][1+2*index],subject['binary'])
   observed=step(p['commands'][2+2*index]);raw=Path(observed['stdout']['path'])
   if Path(observed['stderr']['path']).read_bytes():raise ValueError('runtime stderr')
   gate.check(subject['entry'],raw,subject['expected']);observed['wholeReportGate']=True
  record['status']='COPIED_COMPILER_CONTROL_PASS';record['qualifiesNative56']=False
if __name__=='__main__':
 if sys.argv[1]=='prepare':prepare(sys.argv[2])
 else:run(sys.argv[2],sys.argv[3])
