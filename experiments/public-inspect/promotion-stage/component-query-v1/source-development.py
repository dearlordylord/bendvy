"""Affected source development only; no runtime/proof/delivery qualification."""
import hashlib, importlib.util, json, os, pathlib, shutil, sys
HERE=pathlib.Path(__file__).resolve().parent
ROOT=HERE.parents[3]
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
T=load('task_runner',ROOT/'scripts/task_runner.py')
E=load('boundary',HERE/'evidence-boundary.py')
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def config():
 names=['bend.json','bend.jsonc','tsconfig.json','package.json','.npmrc','.node-version','.nvmrc']
 roots=[HERE,*[p.parent for p in HERE.rglob('*.bend') if not any('history-v1' in x for x in p.parts)],pathlib.Path('/home/node/.bend/bend2')]
 paths={p/n for r in roots for p in [r,*r.parents] for n in names}
 return {str(p):sha(p) if p.is_file() else None for p in sorted(paths)}
def prepare(out,target):
 out.mkdir(parents=True,exist_ok=False)
 sources=[p for p in HERE.rglob('*.bend') if not any('history-v1' in x for x in p.parts)]
 for p in sources:
  dest=out/'source'/p.relative_to(HERE);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,dest)
 env=dict(os.environ);(out/'environment.private.json').write_text(json.dumps(env,sort_keys=True))
 files=[*sources,HERE/'source-development.py',HERE/'evidence-boundary.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/bend-check',pathlib.Path(shutil.which('bend')).resolve(),pathlib.Path('/home/node/.bend/bend2/base.bend')]
 plan={'scope':'Source5 affected declarations feasibility only; no laws/proofs/runtime/acceptance','target':str(HERE/target),'command':['taskset','-c','5',str(ROOT/'scripts/bend-check'),str(HERE/target)],'inputs':T.Inputs(files=files).expected,'configuration':config(),'environmentSHA256':sha(out/'environment.private.json'),'sourceArchive':{str(p.relative_to(HERE)):sha(out/'source'/p.relative_to(HERE)) for p in sources}}
 (out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');print(sha(out/'plan.json'))
def run(out):
 plan=json.loads((out/'plan.json').read_text());envpath=out/'environment.private.json'
 def guard():
  assert {p:sha(pathlib.Path(p)) for p in plan['inputs']}==plan['inputs'];assert config()==plan['configuration'];assert sha(envpath)==plan['environmentSHA256']
 guard();receipt={'scope':plan['scope'],'planSHA256':sha(out/'plan.json'),'status':'INCOMPLETE'}
 with E.ReceiptBoundary(receipt,out/'receipt.json',[('full source/config/environment',guard)]):
  with E.GuardBoundary([('full source/config/environment',guard)]):
   result=T.execute_result(plan['command'],5,json.loads(envpath.read_text()),str(ROOT),'split')
   (out/'stdout.raw').write_bytes(result['stdout']);(out/'stderr.raw').write_bytes(result['stderr'])
   receipt.update(exit=result['exit'],logs={n:sha(out/n) for n in ['stdout.raw','stderr.raw']})
   assert result['exit']==0, 'source refusal or timeout; preserve raw'
  receipt['status']='SOURCE_FEASIBILITY_PASS'
 print(json.dumps(receipt))
if __name__=='__main__':
 if sys.argv[1]=='prepare':prepare(pathlib.Path(sys.argv[2]),sys.argv[3])
 else:run(pathlib.Path(sys.argv[2]))
