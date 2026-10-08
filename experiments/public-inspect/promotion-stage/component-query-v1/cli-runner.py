"""One reviewed CLI IO execution. No interpreter/emitted backend/proof credit."""
import hashlib,importlib.util,json,os,pathlib,shutil,sys,time
sys.dont_write_bytecode=True
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
T=load('task_runner',ROOT/'scripts/task_runner.py');E=load('boundary',HERE/'evidence-boundary.py')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def configurations(roots):
 names=['check.json','bender.json','.bend.json','bend.config.json','bend.json','bend.jsonc','tsconfig.json','package.json','.npmrc','.node-version','.nvmrc']
 paths={p/n for r in roots for p in [r,*r.parents] for n in names}
 return {str(p):sha(p) if p.is_file() else None for p in sorted(paths)}
def prepare():
 prior=ROOT/'.artifacts/inspect54-output-dev03';sp=prior/'plan.json';sr=prior/'receipt.json';p=json.loads(sp.read_text());r=json.loads(sr.read_text())
 assert sha(sp)=='9bcc867ad0af8051da70641e3eea0b128698afa56990b22b41c3d5ee1c99f991'
 assert r['planSHA256']==sha(sp) and r['exit']==0 and r['status']=='SOURCE_FEASIBILITY_PASS' and r.get('error') is None
 for n,d in r['logs'].items():assert sha(prior/n)==d
 for n,d in p['sourceArchive'].items():assert sha(prior/'source'/n)==d and sha(HERE/n)==d
 wrapperPrior=ROOT/'.artifacts/inspect54-io-wrapper-dev01';wsp=wrapperPrior/'plan.json';wsr=wrapperPrior/'receipt.json';wp=json.loads(wsp.read_text());wr=json.loads(wsr.read_text())
 assert sha(wsp)=='a7aaf974f4e4fc184220a09ab2233cd295e64bbed812e19cefe2fb36fd334317'
 assert wr['planSHA256']==sha(wsp) and wr['exit']==0 and wr['status']=='SOURCE_FEASIBILITY_PASS' and wr.get('error') is None
 for n,d in wr['logs'].items():assert sha(wrapperPrior/n)==d
 for n,d in wp['sourceArchive'].items():assert sha(wrapperPrior/'source'/n)==d and sha(HERE/n)==d
 out=ROOT/'.artifacts'/('inspect54-component-cli-'+str(time.time_ns()));out.mkdir()
 env=out/'environment.private.json';env.write_text(json.dumps({name:os.environ[name] for name in ['PATH','HOME','TMPDIR','LANG','LC_ALL','TZ'] if name in os.environ},sort_keys=True));env.chmod(0o600)
 sources=[HERE/n for n in p['sourceArchive']]+[HERE/'output-io-main.bend'];rootdeps=[]
 origin=HERE/'core-v1/source-origin.json';orig=json.loads(origin.read_text())
 # Exact current source-origin equality is separately bound below, not old runtime transfer.
 for staged in (HERE/'core-v1/src/ecs').glob('*.bend'):
  actual=pathlib.Path('/workspace/formal-proofs/bendvy/src/ecs')/staged.name
  assert sha(actual)==sha(staged);rootdeps.append(actual)
 files=[*sources,*rootdeps,origin,pathlib.Path(__file__).resolve(),HERE/'evidence-boundary.py',ROOT/'scripts/task_runner.py',HERE/'physical-oracle.py',HERE/'BEND-PHYSICAL-EXPECTED-v1.txt',HERE/'COMPONENT-ORACLE-v2.json',pathlib.Path('/home/node/.bend/bin/bend'),pathlib.Path('/usr/bin/taskset'),sp,sr,*[prior/n for n in r['logs']],*[prior/'source'/n for n in p['sourceArchive']]]
 roots=[HERE,ROOT,out,pathlib.Path('/home/node/.bend/bend2'),*[q.parent for q in sources+rootdeps]]
 archive=out/'source';archive.mkdir()
 for source in sources:
  dest=archive/source.relative_to(HERE);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,dest)
 files.extend([wsp,wsr,*[wrapperPrior/n for n in wr['logs']],*[wrapperPrior/'source'/n for n in wp['sourceArchive']]])
 inputs=T.Inputs(files=files,directories=[pathlib.Path('/home/node/.bend/bend2'),archive])
 plan={'status':'PREPARED_UNADMITTED_CLI_IO_ONLY','command':['/usr/bin/taskset','-c','5','/home/node/.bend/bin/bend',str(HERE/'output-io-main.bend')],'seconds':5,'inputs':inputs.expected,'configurationRoots':list(map(str,roots)),'configurationStates':configurations(roots),'privateEnvironment':str(env),'environmentSHA256':sha(env),'environmentPolicy':'Explicit six-name PATH/HOME/TMPDIR/LANG/LC_ALL/TZ allowlist; no NODE/LD/DYLD loader injection','oracle':str(HERE/'BEND-PHYSICAL-EXPECTED-v1.txt'),'oracleSHA256':sha(HERE/'BEND-PHYSICAL-EXPECTED-v1.txt'),'oracleBytes':(HERE/'BEND-PHYSICAL-EXPECTED-v1.txt').stat().st_size,'sourceJoin':{'planSHA256':sha(sp),'receiptSHA256':sha(sr),'sourceArchive':p['sourceArchive'],'raw':r['logs'],'newIOWrapperSeparate':True},'wrapperSourceJoin':{'planSHA256':sha(wsp),'receiptSHA256':sha(wsr),'sourceArchive':wp['sourceArchive'],'raw':wr['logs'],'scope':'Affected IO wrapper source feasibility only, no safe proof/runtime'},'currentRootDependencies':{str(q):sha(q) for q in rootdeps},'stderrPolicy':'Empty or exact installed Bend update notice already source-observed; reject every other byte','scope':'Actual Bend CLI IO in-process generatedJS; full two-schema14queries5phases17real targets/nine genuine registered SysSchCheck gates plus failure/retry/repeat. Complete World/columnstamp/Array/Instance/registry/Args diagnostic owner oracle. Instrumentation writes outside Check.run; ordinary Sys.run registry cursor stays0; Inspect success advances own cursor/world clock. Trusted constructors/closed setup and fixture-only diagnostic disposal; no generaltruth/proof/emittedJSNative/full54/adoption credit.'}
 path=out/'plan.json';path.write_text(json.dumps(plan,indent=2)+'\n');print(path);print(sha(path))
def run(path):
 p=json.loads(path.read_text());out=path.parent;env=pathlib.Path(p['privateEnvironment']);r={'status':'INCOMPLETE','planSHA256':sha(path),'scope':p['scope']};captured={}
 def guard():
  observed={}
  for name,expected in p['inputs'].items():
   q=pathlib.Path(name);observed[name]=T.Inputs(directories=[q]).expected[name] if isinstance(expected,dict) else sha(q)
  assert observed==p['inputs'];assert sha(env)==p['environmentSHA256'];assert configurations(list(map(pathlib.Path,p['configurationRoots'])))==p['configurationStates']
 def raw_guard():
  assert {q.name for q in out.glob('*.raw')}==set(captured),'raw log membership drift'
  assert {n:sha(out/n) for n in captured}==captured,'raw log hash drift'
  assert r.get('logs',{})==captured,'receipt raw log binding drift'
 checks=[('source/tool/library/root/environment/configuration',guard),('complete captured stdout/stderr raw membership/hash',raw_guard)]
 with E.ReceiptBoundary(r,out/'receipt.json',checks):
  guard();raw_guard()
  with E.GuardBoundary(checks):
   result=T.execute_result(p['command'],5,json.loads(env.read_text()),str(ROOT),'split')
   captured.update({n+'.raw':hashlib.sha256(result[n]).hexdigest() for n in ['stdout','stderr']});r['logs']=dict(captured)
   (out/'stdout.raw').write_bytes(result['stdout']);(out/'stderr.raw').write_bytes(result['stderr'])
   r.update(exit=result['exit'],failure=result['failure'])
   assert result['failure'] is None and result['exit']==0,'actual CLI consumer failed or timed out'
   assert result['stderr'] in [b'',b'bend 2.0.36 is available: run bend update\n'],'unexpected stderr'
   expected=pathlib.Path(p['oracle']).read_bytes();assert result['stdout']==expected,'complete independent public/physical oracle mismatch'
   r['oracle']={'expectedSHA256':p['oracleSHA256'],'actualSHA256':hashlib.sha256(result['stdout']).hexdigest(),'bytes':len(expected),'exactIOFinalLF':True}
  r['status']='COMPLETE_COMPONENT_CLI_IO_PUBLIC_AND_PHYSICAL_PASS'
 print(json.dumps(r))
if __name__=='__main__':
 if sys.argv[1]=='prepare':prepare()
 else:run(pathlib.Path(sys.argv[2]).resolve())
