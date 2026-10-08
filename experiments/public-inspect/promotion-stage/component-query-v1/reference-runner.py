"""One pinned TS public-operation comparator; no Bend runtime acceptance transfer."""
import hashlib,importlib.util,json,os,pathlib,sys,time
sys.dont_write_bytecode=True
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
T=load('task_runner',ROOT/'scripts/task_runner.py');E=load('boundary',HERE/'evidence-boundary.py')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def configurations(roots):
 names=['bend.json','bend.jsonc','tsconfig.json','package.json','.npmrc','.node-version','.nvmrc']
 paths={p/n for r in roots for p in [r,*r.parents] for n in names}
 return {str(p):sha(p) if p.is_file() else None for p in sorted(paths)}
def prepare():
 prior=ROOT/'.artifacts/inspect54-declarations-dev02';sp=prior/'plan.json';sr=prior/'receipt.json';p=json.loads(sp.read_text());r=json.loads(sr.read_text())
 assert sha(sp)=='dc69a0a942e38fe8c40dde4edf7dc3bf33fe9dca0346797351a429e367519562';assert r['planSHA256']==sha(sp) and r['exit']==0 and r['status']=='SOURCE_FEASIBILITY_PASS'
 for n,d in r['logs'].items():assert sha(prior/n)==d
 for n,d in p['sourceArchive'].items():assert sha(prior/'source'/n)==d and sha(HERE/n)==d
 out=ROOT/'.artifacts'/('inspect54-component-reference-'+str(time.time_ns()));out.mkdir()
 env=out/'environment.private.json';env.write_text(json.dumps({name:os.environ[name] for name in ['PATH','HOME','TMPDIR','LANG','LC_ALL','TZ'] if name in os.environ},sort_keys=True));env.chmod(0o600)
 ts=ROOT/'.references/bevy-ts/packages/core';node=pathlib.Path('/home/node/.local/share/mise/installs/node/24.20.0/bin/node')
 roots=[HERE,ROOT,out,ts,ts/'src']
 files=[pathlib.Path(__file__).resolve(),HERE/'evidence-boundary.py',ROOT/'scripts/task_runner.py',HERE/'reference.mjs',HERE/'REFERENCE-EXPECTED-v2.json',HERE/'COMPONENT-ORACLE-v2.json',ROOT/'.references/sources.json',node,pathlib.Path('/usr/bin/taskset'),sp,sr,*[prior/n for n in r['logs']],*[prior/'source'/n for n in p['sourceArchive']],*[HERE/n for n in p['sourceArchive']]]
 inputs=T.Inputs(files=files,directories=[ts/'src'])
 plan={'status':'PREPARED_UNADMITTED_NODE_ONLY','command':['/usr/bin/taskset','-c','5',str(node),str(HERE/'reference.mjs')],'seconds':5,'inputs':inputs.expected,'configurationRoots':list(map(str,roots)),'configurationStates':configurations(roots),'privateEnvironment':str(env),'environmentSHA256':sha(env),'environmentPolicy':'Explicit PATH/HOME/TMPDIR/LANG/LC_ALL/TZ allowlist; no NODE_*/LD_*/DYLD_* loader injection variables','oracle':str(HERE/'REFERENCE-EXPECTED-v2.json'),'sourceJoin':{'planSHA256':sha(sp),'receiptSHA256':sha(sr),'sourceArchive':p['sourceArchive']},'scope':'Actual pinned TS public readonly component queries/check gates/retry: two nominal schemas,16 subsets,17 real targets,14 combinations,5 phases,full rows/cardinality/payload arrays and eight structural gate observations. Payload-owner comparison is not wholeWorld reflection; physical own-reader/tick conclusions source-backed only. No Bend runtime/backend/authority refusal/proof/adoption/general constructor truth.'}
 (out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def run(path):
 p=json.loads(path.read_text());out=path.parent;env=pathlib.Path(p['privateEnvironment']);r={'status':'INCOMPLETE','planSHA256':sha(path),'scope':p['scope']}
 def guard():
  observed={}
  for name,expected in p['inputs'].items():
   q=pathlib.Path(name);observed[name]=T.Inputs(directories=[q]).expected[name] if isinstance(expected,dict) else sha(q)
  assert observed==p['inputs'];assert sha(env)==p['environmentSHA256'];assert configurations(list(map(pathlib.Path,p['configurationRoots'])))==p['configurationStates']
 with E.ReceiptBoundary(r,out/'receipt.json',[('source/tool/environment/configuration',guard)]):
  guard()
  with E.GuardBoundary([('source/tool/environment/configuration',guard)]):
   result=T.execute_result(p['command'],5,json.loads(env.read_text()),str(ROOT),'split')
   (out/'stdout.raw').write_bytes(result['stdout']);(out/'stderr.raw').write_bytes(result['stderr'])
   r.update(exit=result['exit'],failure=result['failure'],logs={n:sha(out/n) for n in ['stdout.raw','stderr.raw']})
   assert result['stderr']==b'', 'unexpected stderr; preserve raw'
   assert result['failure'] is None and result['exit']==0,'actual public TS consumer failed'
   assert json.loads(result['stdout'])==json.loads(pathlib.Path(p['oracle']).read_text()),'complete independent oracle mismatch'
  r['status']='COMPLETE_PINNED_TS_PUBLIC_COMPONENT_PASS'
 print(json.dumps(r))
if __name__=='__main__':
 if sys.argv[1]=='prepare':prepare()
 else:run(pathlib.Path(sys.argv[2]).resolve())
