#!/usr/bin/env python3
"""Validate an unapplied promotion patch in a guarded stage; no live core edits."""
import pathlib,hashlib,json,os,re,shutil,subprocess,signal,tempfile,time,sys,runpy
ROOT=pathlib.Path(__file__).resolve().parents[4];LOCAL=pathlib.Path('experiments/public-identity/production-candidate')
os.sched_setaffinity(0,{10})
OUT=ROOT/'.artifacts'/('identity-creator-promotion-'+str(time.time_ns()));OUT.mkdir()
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def inventory(p):return {str(f.relative_to(p)):sha(f) for f in sorted(p.rglob('*')) if f.is_file()}
def imports(p,seen):
 p=p.resolve()
 if p in seen:return
 seen.add(p)
 for name in re.findall(r'^\s*import\s+(\S+)',p.read_text(),re.M):
  if name!='Base':imports(p.parent/name.strip('"'),seen)
files=set()
for p in (ROOT/LOCAL).glob('*.bend'):imports(p,files)
files.update(p for p in (ROOT/LOCAL).iterdir() if p.is_file() and p.suffix in {'.py','.json','.mjs','.stdout'})
files.add(ROOT/'experiments/s-prep/fivehour-connected-gates/supervisor.py')
files.update(p for p in (ROOT/LOCAL/'promotion').iterdir() if p.is_file() and p.suffix in {'.py','.patch','.json'})
sources={str(p.relative_to(ROOT)):sha(p) for p in files}
external={str(p):inventory(p) for p in [ROOT/'.references/bevy-ts/packages/core/src',pathlib.Path('/home/node/.bend/bend2')]}
patchTool=pathlib.Path(shutil.which('patch')).resolve()
fixed={str(p):sha(p) for p in [patchTool,pathlib.Path(shutil.which('bend')).resolve(),pathlib.Path(shutil.which('node')).resolve(),pathlib.Path(sys.executable).resolve(),pathlib.Path('/tmp/bendvy-clang19-diagnostic/clang19'),pathlib.Path('/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang'),pathlib.Path('/home/node/.bend/check.json'),ROOT/'.references/sources.json',ROOT/'.references/bevy-ts/package.json',ROOT/'.references/bevy-ts/packages/core/package.json']}
tool=runpy.run_path(str(ROOT/LOCAL/'tool-pins.py'));toolSnapshot=tool['snapshot']()
r={'status':'INCOMPLETE','scope':'Finite same-emitted-program canonical IO creator/foreign owner/refusal controls; no global constructor confinement or cross-program uniqueness','sources':sources,'externalInventories':external,'fixedInputs':fixed,'toolSnapshot':toolSnapshot,'commands':[],'generated':{},'immutableLogs':{}}
env=dict(os.environ,BEND_NO_TELEMETRY='1',BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root')
with tempfile.TemporaryDirectory(prefix='bendvy-world-io-') as tmp:
 stage=pathlib.Path(tmp)
 for rel in sources:
  dest=stage/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/rel,dest)
 staged=dict(sources)
 provenance=json.loads((stage/LOCAL/'promotion/supervisor-provenance.json').read_text())
 originalSupervisor=(stage/provenance['origin']).read_bytes();copiedSupervisor=(stage/LOCAL/'promotion/supervisor.py').read_bytes()
 assert hashlib.sha256(originalSupervisor).hexdigest()==provenance['originSHA256'] and copiedSupervisor[:provenance['unchangedPrefixBytes']]==originalSupervisor
 supervisor=runpy.run_path(str(stage/LOCAL/'promotion/supervisor.py'));r['supervisorProvenance']=provenance
 def guard():
  tool['verify'](toolSnapshot)
  assert all(sha(ROOT/p)==h for p,h in sources.items()),'live source drift'
  assert inventory(stage)==staged,'stage inventory drift'
  assert all(inventory(pathlib.Path(p))==h for p,h in external.items()),'reference/Base inventory drift'
  assert all(sha(pathlib.Path(p))==h for p,h in fixed.items()),'fixed input drift'
  assert all(sha(OUT/p)==h for p,h in r['generated'].items()),'generated runtime drift'
  assert all(sha(OUT/p)==h for p,h in r['immutableLogs'].items()),'immutable raw log drift'
  assert {f.name for f in OUT.iterdir() if f.suffix in {'.stdout','.stderr'}}==set(r['immutableLogs']),'raw log inventory drift'
  assert all(not (ROOT/p).exists() for p in promotion['requiredAbsentDestinations']),'live core promotion occurred during staged replay'
 def run(label,args,cap,expected=0,emits=None,promote=False,cwd=None):
  guard()
  if emits:assert not (OUT/emits).exists(),'prospective output exists'
  argv=['taskset','-c','10']+list(map(str,args))
  try:code,out,err=supervisor['execute_split'](argv,cap,env=env,cwd=cwd)
  except (TimeoutError,RuntimeError) as error:
   out=getattr(error,'stdout',b'');err=getattr(error,'stderr',b'')
   for suffix,data in [('.stdout',out),('.stderr',err)]:
    log=label+suffix;(OUT/log).write_bytes(data);r['immutableLogs'][log]=sha(OUT/log)
   r['commands'].append({'label':label,'argv':argv,'cap':cap,'supervisionFailure':str(error)});raise
  for suffix,data in [('.stdout',out),('.stderr',err)]:
   log=label+suffix;assert not (OUT/log).exists(),'prospective raw log exists';(OUT/log).write_bytes(data);r['immutableLogs'][log]=sha(OUT/log)
  r['commands'].append({'label':label,'argv':argv,'cap':cap,'exit':code,'stdoutSHA256':sha(OUT/(label+'.stdout')),'stderrSHA256':sha(OUT/(label+'.stderr'))})
  assert code==expected,(label,err.decode())
  if emits:r['generated'][emits]=sha(OUT/emits)
  if promote:
   expectedStage=dict(staged);expectedStage.update(promotion['prospectiveNewFiles']);assert inventory(stage)==expectedStage,'nonexact promotion patch result'
   staged.update(promotion['prospectiveNewFiles']);r['promotedStageInputs']=dict(promotion['prospectiveNewFiles'])
  guard();return out.decode(),err.decode()
 try:
  promotion=json.loads((stage/LOCAL/'promotion/manifest.json').read_text());r['promotionManifest']=promotion
  assert sha(stage/'src/ecs/world.bend')==promotion['existingWorldSHA256']
  assert sha(stage/LOCAL/'promotion/world-io.patch')==promotion['patchSHA256']
  for path in promotion['requiredAbsentDestinations']:assert not (stage/path).exists() and not (ROOT/path).exists()
  mapped={};r['mappedFixturePlans']={}
  for name in ['authority','authority-failure','namespace-owners','negative-owner']:
   path=str(LOCAL/(name+'.bend'));original=(stage/path).read_text();anchor='import ./world-io.bend as H';replacement='import ../../../src/ecs/world-io.bend as H'
   assert original.count(anchor)==1
   mapped[path]=original.replace(anchor,replacement);r['mappedFixturePlans'][path]={'anchor':anchor,'replacement':replacement,'count':1,'intendedSHA256':hashlib.sha256(mapped[path].encode()).hexdigest()}
  rawOut,rawErr=run('supervisor-raw-control',[sys.executable,stage/LOCAL/'promotion/supervisor-control.py','raw'],5)
  assert rawOut=='raw-out\n' and rawErr=='raw-err\n'
  guard()
  try:supervisor['execute_split'](['taskset','-c','10',sys.executable,str(stage/LOCAL/'promotion/supervisor-control.py'),'escape'],0.5,env=env)
  except TimeoutError as error:
   out=error.stdout;err=error.stderr;assert out.startswith(b'escaped:') and not err
   escaped=int(out.decode().strip().split(':')[1]);assert not pathlib.Path('/proc',str(escaped)).exists() and not supervisor['child_pids'](os.getpid())
   for suffix,data in [('.stdout',out),('.stderr',err)]:
    log='supervisor-escape-control'+suffix;assert not (OUT/log).exists();(OUT/log).write_bytes(data);r['immutableLogs'][log]=sha(OUT/log)
   r['commands'].append({'label':'supervisor-escape-control','cap':0.5,'expectedTimeoutControl':True,'escapedPID':escaped,'reaped':True,'stdoutSHA256':sha(OUT/'supervisor-escape-control.stdout'),'stderrSHA256':sha(OUT/'supervisor-escape-control.stderr')})
  else:raise AssertionError('escaping descendant control did not hit deadline')
  guard()
  run('apply-promotion-patch',[patchTool,'-p1','--batch','--forward','-i',stage/LOCAL/'promotion/world-io.patch'],5,promote=True,cwd=stage)
  for path,text in mapped.items():
   (stage/path).write_text(text);staged[path]=sha(stage/path);assert staged[path]==r['mappedFixturePlans'][path]['intendedSHA256']
  freshJS='src/ecs/world-namespace.js';freshC='src/ecs/world-namespace.c';creator='src/ecs/world-io.bend'
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
  out,err=run('foreign-proof-boundary',['bend',stage/creator,'--check-only'],5,1);assert 'rely on unsafe or foreign code' in err and not out
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
  guard();r['status']='FINITE_STAGED_CREATOR_PROMOTION_PASS';r['nativeExecuted']='--native' in sys.argv
 finally:
  (OUT/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(OUT)
