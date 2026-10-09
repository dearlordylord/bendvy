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
 out=Path(out).resolve();out.mkdir(exist_ok=False);stage=out/'stage';stage.mkdir()
 parent=HERE.parent
 capture(stage/'candidate.comp.ts',gzip.decompress((parent/'candidate.comp.ts.gz').read_bytes()))
 capture(stage/'emit-full.mts',(HERE/'emit-full.mts').read_bytes())
 oldplans=[Path('/tmp/bendvy56-recursive-'+kind+'-js-v1/plan.json')for kind in ['normal','mutant']]
 old=[json.loads(path.read_text())for path in oldplans]
 config=ROOT/'experiments/public-simulation/delivery-v1/installed-config.py'
 configuration=load('existing_configuration',config);runner=load('existing_runner',ROOT/'scripts/task_runner.py')
 tools={'python':str(Path(sys.executable).resolve()),'node':'/home/node/.local/share/mise/installs/node/24.20.0/bin/node','taskset':'/usr/bin/taskset','clangWrapper':'/tmp/bendvy-clang19-diagnostic/clang19','clangBinary':'/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang'}
 pins={};bindings={};cohorts=[]
 for kind,previous in zip(['normal','mutant'],old):
  inventory=Path(previous['constructorInventory']);identity=json.loads(inventory.read_text())
  for name,digest in identity['sourceSHA256'].items():
   if sha(name)!=digest:raise ValueError('full consuming source changed')
   pins[name]=digest
  for key in ['constructorInventory','oracle','join']:
   path=Path(previous[key]);pins[str(path)]=sha(path)
  if sha(previous['oracle'])!=previous['expectedSHA256']:raise ValueError('full oracle changed')
  c=out/(kind+'.c');binary=out/(kind+'.native');witness=out/(kind+'.witness.json')
  commands=[{'label':kind+'-emit','stage':'emit','argv':[tools['taskset'],'-c','5',tools['node'],str(stage/'emit-full.mts'),previous['entrypoint'],str(c),str(witness)],'capSeconds':30,'artifact':str(c),'witness':str(witness)},
   {'label':kind+'-build','stage':'build','argv':[tools['taskset'],'-c','5',tools['clangWrapper'],'-O3',str(c),'-o',str(binary),'-pthread','-lm'],'capSeconds':120,'artifact':str(binary)},
   {'label':kind+'-runtime','stage':'runtime','argv':[tools['taskset'],'-c','5',str(binary),'--threads','1','--gpu','off'],'capSeconds':5}]
  cohorts.append({'kind':kind,'entrypoint':previous['entrypoint'],'inventory':previous['constructorInventory'],'oracle':previous['oracle'],'join':previous['join'],'expectedSHA256':previous['expectedSHA256'],'sourceFiles':len(identity['sourceSHA256']),'commands':commands})
 # Retain historical baseline and copied-control joins as provenance, never replay them.
 ref=ROOT/'.references/bend2/bend2'
 adapters=json.loads((HERE/'PARSER-ADAPTERS.json').read_text())
 files=[*[Path(k)for prior in old for k in prior['pins']],*parent.rglob('*'),*stage.iterdir(),*oldplans,config,ROOT/'scripts/task_runner.py',ROOT/'scripts/evidence_boundary.py',ROOT/'scripts/owned-tool-pins.py',*map(Path,tools.values()),*map(Path,configuration.LINK_INPUTS),ref/'comp.ts',ref/'bend.ts',ref/'base.bend',*ref.joinpath('effs').rglob('*'),*[Path(r['original'])for r in adapters]]
 for path in files:
  if path.is_file()and '__pycache__'not in path.parts and path.suffix!='.pyc':
   resolved=path.resolve(strict=True);pins[str(resolved)]=sha(resolved)
   if path.is_symlink():bindings[str(path)]=str(resolved)
 p={'scope':'Copied candidate compiler full normal71 + reached handler omission whole controls only; no installed resolver/performance/task closure','pins':pins,'fileBindings':bindings,'resourceRoots':runner.Inputs(directories=configuration.RESOURCE_ROOTS).snapshot(),'environment':configuration.environment(),'tools':tools,'cwd':str(ROOT),'cohorts':cohorts,'compilerProvenance':str(parent/'SOURCE.json'),'successfulControls':str(parent/'controls-v1/evidence-v1/controls10/MANIFEST.json')}
 capture(out/'plan.json',(json.dumps(p,indent=2)+'\n').encode());print(sha(out/'plan.json'))

def run(planpath,admitted):
 planpath=Path(planpath).resolve(strict=True)
 if sha(planpath)!=admitted:raise ValueError('admitted plan digest mismatch')
 p=json.loads(planpath.read_text());pins=dict(p['pins']);pins[str(planpath)]=admitted
 if {n:sha(n) for n in pins}!=pins:raise ValueError('preimport pins drift')
 if any(str(Path(n).resolve(strict=True))!=target for n,target in p.get('fileBindings',{}).items()):raise ValueError('preimport link resolution drift')
 actual=str(Path(sys.executable).resolve(strict=True))
 if actual!=p['tools']['python'] or sha(actual)!=pins[actual]:raise ValueError('actual interpreter drift')
 runner=load('existing_runner',ROOT/'scripts/task_runner.py',pins);boundary=load('existing_boundary',ROOT/'scripts/evidence_boundary.py',pins);gate=load('existing_whole_control',HERE/'transport.py',pins)
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
     for target in [artifact,command.get('witness')]:
      if target is not None and (Path(target).exists()or Path(target).is_symlink()):raise ValueError('artifact must start absent')
     result=runner.execute_result(command['argv'],command['capSeconds'],p['environment'],p['cwd'],'split')
     row=record_returned(record,command,result,out)
     publish_streams(row,result,pins)
    finally:
     primary=sys.exc_info()[1]
     try:
      capture_error=None
      for target in [artifact,command.get('witness')]:
       try:capture_artifact(record,target,pins)
       except Exception as error:
        record.setdefault('secondaryCaptureErrors',[]).append(str(error))
        if capture_error is None:capture_error=error
      if primary is None and capture_error is not None:raise capture_error
     finally:fcntl.flock(lock,fcntl.LOCK_UN)
   if result['failure'] is not None or result['exit']!=0:raise ValueError('child failed: '+label)
   for target in [artifact,command.get('witness')]:
    if target is not None and str(target)not in pins:raise ValueError('successful child missing artifact')
   return row
 with boundary.ReceiptBoundary(record,out/'receipt.json',[('final boundary',lambda:guard('final'))]):
  for cohort in p['cohorts']:
   for command in cohort['commands']:
    row=step(command,command.get('artifact'))
    if command['stage']=='runtime':
     if Path(row['stderr']['path']).read_bytes():raise ValueError('runtime stderr')
     gate.check(p,cohort,Path(row['stdout']['path']).read_bytes(),pins)
     row['wholeOracleGate']=True
     if cohort['kind']=='mutant':row['wholePositiveRejected']=True
  record['status']='COPIED_FULL_CONSUMER_PASS';record['qualifiesNative56']=False
if __name__=='__main__':
 if sys.argv[1]=='prepare':prepare(sys.argv[2])
 else:run(sys.argv[2],sys.argv[3])
