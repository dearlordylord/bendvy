"""Frozen development preflight only; no tool discovery or delivery qualification."""
import argparse,hashlib,importlib.util,json,os,re,shutil,sys,time
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy');HERE=Path(__file__).resolve().parent
sys.dont_write_bytecode=True
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(p,n):
 spec=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
T=load(ROOT/'scripts/task_runner.py','task_runner');L=load(ROOT/'scripts/receipt-logs.py','logs');B=load(ROOT/'scripts/evidence_boundary.py','boundary')
def inv(p):return {str(f.relative_to(p)):sha(f) for f in p.rglob('*') if f.is_file()}
def configs(roots):
 paths=set()
 for root in roots:
  for p in [root,*root.parents]:
   for n in ['check.json','check.jsonc','bender.jsonc','.bend','bend.json','bend.jsonc','bender.json','package.json','.bend.json','bend.config.json','tsconfig.json','.node-version','.nvmrc','.npmrc','.clang','clang.cfg','bunfig.toml']:paths.add(p/n)
 def state(p):
  if p.is_symlink():
   resolved=p.resolve();kind='file' if resolved.is_file() else 'directory' if resolved.is_dir() else 'absent' if not resolved.exists() else 'other'
   return {'kind':'symlink','target':os.readlink(p),'resolvedPath':str(resolved),'resolvedKind':kind,'resolvedSHA256':sha(resolved) if kind=='file' else None,'resolvedInventory':inv(resolved) if kind=='directory' else None}
  if p.is_file():return {'kind':'file','sha256':sha(p)}
  if p.is_dir():return {'kind':'directory','inventory':inv(p)}
  return {'kind':'absent'}
 return {str(p):state(p) for p in paths}
def prepare():
 prior=HERE/'mutant-source-v1/1791443641809591245';old=json.loads((prior/'plan.json').read_text());receipt=json.loads((prior/'receipt.json').read_text())
 assert sha(prior/'plan.json')=='ee3cbc31897583f74f158fb665c39c6576d239d2487f84190116e2c035a969f4'
 assert sha(prior/'receipt.json')=='aca9f58f7eb0210fff526d5473fb27d061cda39be3f3c94eeb2789b99b456ad1'
 assert receipt['status']=='MUTANT_SOURCE_SHAPES_TYPECHECKED_NOT_REACHED_NOT_PROOF_NOT_DELIVERY' and receipt.get('guardFailures',[])==[]
 assert [(c['label'],c['seconds'],c['exit'],c['failure']) for c in receipt['commands']]==[('omit-with-index',5,0,None),('dedup-next-queuers',5,0,None)]
 assert all(all(c[k]==old['commands'][j][k] for k in old['commands'][j]) for j,c in enumerate(receipt['commands']))
 assert set(receipt['logs'])=={label+'.'+stream for label in ['omit-with-index','dedup-next-queuers'] for stream in ['stdout','stderr']}
 assert all(sha(prior/n)==h for n,h in receipt['logs'].items())
 for label in ['omit-with-index','dedup-next-queuers']:
  assert (prior/(label+'.stdout')).read_bytes()==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n'
  assert (prior/(label+'.stderr')).read_bytes() in [b'',b'bend 2.0.36 is available: run bend update\n']
 assert inv(Path(old['stage']))==old['inventory'] and all(sha(n)==h for n,h in old['pins'].items())
 out=HERE/'mutant-js-v1'/str(time.time_ns());out.mkdir(parents=True);stage=out/'stage';shutil.copytree(Path(old['stage']),stage)
 taskset=str(Path(shutil.which('taskset')).resolve());bend=str(Path(shutil.which('bend')).resolve());node=str(Path(shutil.which('node')).resolve());commands=[]
 for m in old['mutations']['mutants']:
  expected=stage/m['name']/'study/EXPECTED.stdout';expected.write_text(''.join(json.dumps(row,separators=(',',':'))+'\n' for row in m['expectedFull9']))
  artifact=out/(m['name']+'.js')
  commands.extend([{'label':'emit-'+m['name'],'kind':'emit','argv':[taskset,'-c','5',bend,str(stage/m['name']/'study/main.bend'),'-o',str(artifact)],'seconds':30,'artifact':str(artifact)},{'label':'run-'+m['name'],'kind':'run','argv':[taskset,'-c','5',node,str(artifact)],'seconds':5,'expected':str(expected),'changedCaseIndices':m['changedCaseIndices']}])
 for name,h in old['inventory'].items():
  if not name.endswith('/study/EXPECTED.stdout'):assert sha(stage/name)==h
 pins={**old['pins'],str(Path(__file__)):sha(__file__)}
 for f in prior.rglob('*'):
  if f.is_file():pins[str(f)]=sha(f)
 private=out/'private-environment.json';private.write_bytes(Path(old['environment']).read_bytes());private.chmod(0o600);pins[str(private)]=sha(private)
 roots=[Path(json.loads(private.read_text())['HOME'])/'.bend',*map(Path,old['configRoots']),out,stage,HERE,*[Path(tool).parent for tool in [taskset,bend,node]],*[f.parent for f in stage.rglob('*') if f.is_file()]]
 plan={**old,'scope':'Development full9 reached two declared defects on actual JS; no Native/ordinary-loader/proof/full56 claim','pins':pins,'stage':str(stage),'inventory':inv(stage),'environment':str(private),'environmentSHA256':sha(private),'configRoots':list(map(str,roots)),'configs':configs(roots),'commands':commands,'sourceCohort':{'plan':str(prior/'plan.json'),'receipt':str(prior/'receipt.json')}}
 path=out/'plan.json';path.write_text(json.dumps(plan,indent=2)+'\n');print(path);print(sha(path))
def run(path):
 path=Path(path).resolve();p=json.loads(path.read_text());out=path.parent;stage=Path(p['stage']);env=json.loads(Path(p['environment']).read_text());r={'status':'INCOMPLETE','planSHA256':sha(path),'scope':p['scope'],'commands':[]};generated=dict(p.get('preexistingGenerated',{}));logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);inputs=T.Inputs(files=[path,*p['pins']],directories=[stage]);runner=T.Runner(logs,inputs=inputs,env=env,cwd=stage,capture='split')
 def source_guard():
  assert sha(path)==r['planSHA256']
  assert all(sha(n)==s for n,s in p['pins'].items());assert inv(stage)==p['inventory'];assert inv(Path(p['resource']))==p['resourceInventory'];assert sha(p['environment'])==p['environmentSHA256'];assert configs(list(map(Path,p['configRoots'])))==p['configs']
 def generated_guard():
  assert all(sha(n)==s for n,s in generated.items());runner.inputs.guard()
 def generated_registration():
  assert sha(path)==r['planSHA256']
  for c in p['commands']:
   if 'artifact' in c and Path(c['artifact']).is_file() and c['artifact'] not in generated:generated[c['artifact']]=sha(c['artifact'])
  runner.inputs=T.Inputs(files=[path,*p['pins'],*generated],directories=[stage])
 def evidence_record():
  r['logs']=dict(logs.hashes);r['generated']=dict(generated)
 guards=[('generated-registration',generated_registration),('source-config-env',source_guard),('raw',logs.guard),('generated',generated_guard),('record-evidence',evidence_record)]
 with B.ReceiptBoundary(r,out/'receipt.json',guards):
  source_guard();logs.guard()
  for c in p['commands']:
   item={**c,'exit':None,'failure':None};r['commands'].append(item)
   with B.GuardBoundary(guards):
    source_guard();logs.guard();generated_guard()
    if 'artifact' in c:assert not Path(c['artifact']).exists()
    try:
     result=runner.run(c['label'],c['argv'],c['seconds'],expected=None);item.update(exit=result['exit'],failure=result['failure'])
    except BaseException as e:
     result=getattr(e,'result',None)
     if result is not None:item.update(exit=result['exit'],failure=result['failure'])
     raise
    assert result['exit']==0 and result['failure'] is None
    if c['kind']=='emit':
     assert result['stdout']==b'' and result['stderr'] in [b'',b'bend 2.0.36 is available: run bend update\n']
     generated[c['artifact']]=sha(c['artifact'])
    else:
     assert result['stderr']==b'' and result['stdout']==Path(c['expected']).read_bytes()
     rows=[json.loads(line) for line in result['stdout'].splitlines()]
     normal=json.loads((HERE/'ORACLE.json').read_text())['cases']
     assert len(rows)==9 and [j for j,(a,b) in enumerate(zip(rows,normal)) if a!=b]==c['changedCaseIndices']
   r['logs']=dict(logs.hashes);r['generated']=dict(generated)
  r['status']='MUTANTS_JS_REACHED_FULL9_NOT_NATIVE_NOT_PROOF_NOT_DELIVERY'
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');a=parser.parse_args();prepare() if a.prepare else run(a.run)
