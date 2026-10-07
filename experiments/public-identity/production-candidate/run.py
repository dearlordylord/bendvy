#!/usr/bin/env python3
"""Source-bound canonical creator candidate; finite semantics, no core adoption."""
import pathlib,hashlib,json,os,re,shutil,subprocess,signal,tempfile,time,sys,runpy
ROOT=pathlib.Path(__file__).resolve().parents[3];LOCAL=pathlib.Path('experiments/public-identity/production-candidate')
sys.path.insert(0,str(ROOT/'scripts'))
from task_runner import execute_result, _raise_failure
os.sched_setaffinity(0,{10})
OUT=ROOT/'.artifacts'/('identity-production-candidate-'+str(time.time_ns()));OUT.mkdir()
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def inventory(p):return {str(f.relative_to(p)):sha(f) for f in sorted(p.rglob('*')) if f.is_file()}
def imports(p,seen):
 p=p.resolve()
 if p in seen:return
 seen.add(p)
 for name in re.findall(r'^\s*import\s+(\S+)',p.read_text(),re.M):
  if name!='Base':imports(p.parent/name.strip('"'),seen)
files={ROOT/'scripts/task_runner.py'}
for p in (ROOT/LOCAL).glob('*.bend'):imports(p,files)
files.update(p for p in (ROOT/LOCAL).iterdir() if p.is_file() and p.suffix in {'.py','.json','.mjs','.stdout'})
sources={str(p.relative_to(ROOT)):sha(p) for p in files}
external={str(p):inventory(p) for p in [ROOT/'.references/bevy-ts/packages/core/src',pathlib.Path('/home/node/.bend/bend2')]}
fixed={str(p):sha(p) for p in [pathlib.Path(shutil.which('bend')).resolve(),pathlib.Path(shutil.which('node')).resolve(),pathlib.Path(sys.executable).resolve(),pathlib.Path('/tmp/bendvy-clang19-diagnostic/clang19'),pathlib.Path('/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang'),pathlib.Path('/home/node/.bend/check.json'),ROOT/'.references/sources.json',ROOT/'.references/bevy-ts/package.json',ROOT/'.references/bevy-ts/packages/core/package.json']}
tool=runpy.run_path(str(ROOT/LOCAL/'tool-pins.py'));toolSnapshot=tool['snapshot']()
r={'status':'INCOMPLETE','scope':'Finite same-emitted-program canonical IO creator/foreign owner/refusal controls; no global constructor confinement or cross-program uniqueness','sources':sources,'externalInventories':external,'fixedInputs':fixed,'toolSnapshot':toolSnapshot,'commands':[],'generated':{}}
env=dict(os.environ,BEND_NO_TELEMETRY='1',BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root')
with tempfile.TemporaryDirectory(prefix='bendvy-world-io-') as tmp:
 stage=pathlib.Path(tmp)
 for rel in sources:
  dest=stage/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/rel,dest)
 staged=dict(sources)
 def guard():
  tool['verify'](toolSnapshot)
  assert all(sha(ROOT/p)==h for p,h in sources.items()),'live source drift'
  assert inventory(stage)==staged,'stage inventory drift'
  assert all(inventory(pathlib.Path(p))==h for p,h in external.items()),'reference/Base inventory drift'
  assert all(sha(pathlib.Path(p))==h for p,h in fixed.items()),'fixed input drift'
  assert all(sha(OUT/p)==h for p,h in r['generated'].items()),'generated runtime drift'
 def run(label,args,cap,expected=0,emits=None):
  guard()
  if emits:assert not (OUT/emits).exists(),'prospective output exists'
  argv=['taskset','-c','10']+list(map(str,args))
  result=execute_result(argv,cap,env,capture='split')
  out,err=result['stdout'],result['stderr']
  p=subprocess.CompletedProcess(argv,result['exit'],out,err)
  (OUT/(label+'.stdout')).write_bytes(out);(OUT/(label+'.stderr')).write_bytes(err)
  r['commands'].append({'label':label,'argv':argv,'cap':cap,'exit':p.returncode,'stdoutSHA256':sha(OUT/(label+'.stdout')),'stderrSHA256':sha(OUT/(label+'.stderr'))})
  if result['failure']:
   r['commands'][-1]['failure']=result['failure'];_raise_failure(result)
  assert p.returncode==expected,(label,err.decode())
  if emits:r['generated'][emits]=sha(OUT/emits)
  guard();return out.decode(),err.decode()
 try:
  freshJS=str(LOCAL/'fresh.js');freshC=str(LOCAL/'fresh.c');creator=str(LOCAL/'world-io.bend')
  originals={p:(stage/p).read_text() for p in [freshJS,freshC,creator]}
  plans={'namespace-exhaustion':[(freshJS,'bendvy_namespace_next = 1;','bendvy_namespace_next = 0xfffffffd;'),(freshC,'bendvy_namespace_next = 1;','bendvy_namespace_next = UINT32_MAX - 2;')],'namespace-collision':[(freshJS,'return bendvy_namespace_next++;','return 1;'),(freshC,'return (Term)old;','return (Term)1;')],'creator-range-bypassed':[(creator,'Bool.and(U32.is_lt(0,namespace),U32.is_lt(namespace,4294967295))','True{}')]}
  changes={};r['plannedAnchors']={};r['intendedInputs']={}
  for name,edits in plans.items():
   changes[name]={};r['plannedAnchors'][name]=[]
   for path,anchor,replacement in edits:
    assert originals[path].count(anchor)==1,(name,'non-singleton anchor')
    changes[name][path]=originals[path].replace(anchor,replacement);r['plannedAnchors'][name].append({'path':path,'anchor':anchor,'replacement':replacement,'count':1})
   if name=='creator-range-bypassed':changes[name].update(changes['namespace-exhaustion'])
   r['intendedInputs'][name]={p:hashlib.sha256(text.encode()).hexdigest() for p,text in changes[name].items()}
  manifest=json.loads((ROOT/'.references/sources.json').read_text());r['referenceHeads']={}
  for name,entry in manifest['sources'].items():
   head=run('reference-'+name,['git','-C',ROOT/'.references'/name,'rev-parse','HEAD'],5)[0].strip();assert head==entry['commit'];r['referenceHeads'][name]=head
  observed=json.loads(run('reference-TS',['node',stage/LOCAL/'reference.mjs'],5)[0]);assert observed==json.loads((stage/LOCAL/'expected-reference.json').read_text());r['observedTS']=observed
  out,err=run('foreign-proof-boundary',['bend',stage/LOCAL/'world-io.bend','--check-only'],5,1);assert 'rely on unsafe or foreign code' in err and not out
  r['expectedConfinementDiagnostics']=json.loads((stage/LOCAL/'expected-confinement.json').read_text())
  for name,diagnostic in r['expectedConfinementDiagnostics'].items():
   out,err=run(name,['bend',stage/LOCAL/(name+'.bend'),'--check-only'],5,1);assert err==diagnostic and not out
  backends=['JS','Native'] if '--native' in sys.argv else ['JS'];r['cases']={}
  def execute(name,fixture,expectedFile):
   source=stage/LOCAL/(fixture+'.bend');expected=(stage/LOCAL/expectedFile).read_text()
   out,err=run(name+'-live-check',['bend',source],5);assert out==expected and not err,(name,out)
   for backend in backends:
    label=name+'-'+backend;suffix='js' if backend=='JS' else 'c';run(label+'-emit',['bend',source,'-o',OUT/(label+'.'+suffix)],30,emits=label+'.'+suffix)
    if backend=='Native':run(label+'-clang',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',OUT/(label+'.c'),'-pthread','-lm','-o',OUT/(label+'.native')],120,emits=label+'.native')
    out,err=run(label+'-run',['node',OUT/(label+'.js')] if backend=='JS' else [OUT/(label+'.native'),'--threads','1','--gpu','off'],5);assert out==expected and not err,(label,out);r['cases'][label]={'fullExpectedMatch':True,'stdoutSHA256':hashlib.sha256(out.encode()).hexdigest()}
  for fixture,expected in [('authority','expected-authority.stdout'),('authority-failure','expected-authority-failure.stdout'),('namespace-owners','expected-namespace.stdout')]:execute(fixture,fixture,expected)
  for name,fixture,expected in [('namespace-exhaustion','namespace-owners','expected-exhaustion.stdout'),('namespace-collision','authority','expected-collision.stdout'),('creator-range-bypassed','namespace-owners','expected-range-mutant.stdout')]:
   for path,text in originals.items():(stage/path).write_text(text);staged[path]=sha(stage/path)
   for path,text in changes[name].items():(stage/path).write_text(text);staged[path]=sha(stage/path);assert staged[path]==r['intendedInputs'][name][path]
   execute(name,fixture,expected)
  guard();r['status']='FINITE_CANONICAL_CREATOR_CANDIDATE_PASS';r['nativeExecuted']='--native' in sys.argv
 finally:
  (OUT/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(OUT)
