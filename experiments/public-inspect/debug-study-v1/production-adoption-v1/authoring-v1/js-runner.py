"""Fresh multi-owner JS preflight, exact actual IO prerequisite."""
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
   for n in ['check.json','check.jsonc','bender.jsonc','.bend','bend.json','bend.jsonc','bend.toml','bender.json','package.json','.bend.json','bend.config.json','tsconfig.json','.node-version','.nvmrc','.npmrc','.clang','clang.cfg','bunfig.toml']:paths.add(p/n)
 def state(p):
  if p.is_symlink():
   resolved=p.resolve();kind='file' if resolved.is_file() else 'directory' if resolved.is_dir() else 'absent' if not resolved.exists() else 'other'
   return {'kind':'symlink','target':os.readlink(p),'resolvedPath':str(resolved),'resolvedKind':kind,'resolvedSHA256':sha(resolved) if kind=='file' else None,'resolvedInventory':inv(resolved) if kind=='directory' else None}
  if p.is_file():return {'kind':'file','sha256':sha(p)}
  if p.is_dir():return {'kind':'directory','inventory':inv(p)}
  return {'kind':'absent'}
 return {str(p):state(p) for p in paths}
def equal(a,b):
 if type(a) is not type(b):return False
 if isinstance(a,dict):return a.keys()==b.keys() and all(equal(a[k],b[k]) for k in a)
 if isinstance(a,list):return len(a)==len(b) and all(equal(x,y) for x,y in zip(a,b))
 return a==b
def prepare():
 normal=HERE/'preflight/1791455746087739558';old=json.loads((normal/'plan.json').read_text());receipt=json.loads((normal/'receipt.json').read_text())
 assert sha(normal/'plan.json')=='9af7bdda8c653abf080cc640292e65e95a98ff4012ab061fae825e1b95df988c'
 assert sha(normal/'receipt.json')=='8e9d73bc7f853be56c81232c26d6de7d29009d4fd6d0761bdbcf93b4821f3c9a'
 assert receipt['status']=='DEVELOPMENT_ACTUAL_MULTI_OWNER_IO_FULL_ORACLE_PASS_NOT_DELIVERY_NOT_FULL56' and receipt.get('guardFailures',[])==[]
 assert inv(Path(old['stage']))==old['inventory'] and all(sha(n)==h for n,h in old['pins'].items()) and configs(list(map(Path,old['configRoots'])))==old['configs']
 assert len(receipt['commands'])==1 and receipt['commands'][0]['argv']==old['commands'][0]['argv'] and receipt['commands'][0]['seconds']==5 and receipt['commands'][0]['exit']==0 and receipt['commands'][0]['failure'] is None
 assert set(receipt['logs'])=={'candidate.stdout','candidate.stderr'} and all(sha(normal/n)==h for n,h in receipt['logs'].items())
 assert (normal/'candidate.stdout').read_bytes()==Path(old['expected']).read_bytes() and (normal/'candidate.stderr').read_bytes() in [b'',Path(old['notice']).read_bytes()]
 out=HERE/'preflight'/str(time.time_ns());out.mkdir(parents=True);stage=out/'stage';shutil.copytree(old['stage'],stage);assert inv(stage)==old['inventory'];sources=dict(old['pins'])
 for p in normal.rglob('*'):
  if p.is_file():sources[str(p)]=sha(p)
 env=dict(os.environ)
 for name in list(env):
  if name in ['NODE_OPTIONS','NODE_PATH','NODE_REPL_EXTERNAL_MODULE'] or name.startswith(('LD_','DYLD_')):env.pop(name,None)
 env.update(OMP_NUM_THREADS='1',BEND_THREADS='1',CUDA_VISIBLE_DEVICES='')
 private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True));private.chmod(0o600)
 tools={n:str(Path(shutil.which(n)).resolve()) for n in ['bend','node','taskset']}
 files=[Path(__file__),ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',ROOT/'scripts/evidence_boundary.py',private,*map(Path,tools.values())]
 roots=[ROOT,HERE,out,stage,Path(env['HOME'])/'.bend',*[Path(n).parent for n in tools.values()],*[p.parent for p in stage.rglob('*') if p.is_file()],*[Path(n).parent for n in sources]]
 entry=stage/Path(old['entry']).relative_to(old['stage']);expected=stage/Path(old['expected']).relative_to(old['stage']);artifact=out/'main.js'
 plan={'scope':'Development fresh JS fullmultiowner2DTO/World/Registry/Provisioned oracle; exact actual IO+TS reuse only, no Native/adoption/full56','pins':{**sources,**{str(p):sha(p) for p in files}},'rootJoins':old['rootJoins'],'normalIO':{'plan':str(normal/'plan.json'),'receipt':str(normal/'receipt.json')},'stage':str(stage),'inventory':inv(stage),'environment':str(private),'environmentSHA256':sha(private),'configRoots':list(map(str,roots)),'configs':configs(roots),'notice':old['notice'],'expected':str(expected),'commands':[{'label':'emit','argv':[tools['taskset'],'-c','5',tools['bend'],str(entry),'-o',str(artifact)],'seconds':30,'artifact':str(artifact)},{'label':'candidate','argv':[tools['taskset'],'-c','5',tools['node'],str(artifact)],'seconds':5}]}
 path=out/'plan.json';path.write_text(json.dumps(plan,indent=2)+'\n');print(path);print(sha(path))
def run(path):
 path=Path(path).resolve();p=json.loads(path.read_text());out=path.parent;stage=Path(p['stage']);env=None;r={'status':'INCOMPLETE','planSHA256':sha(path),'scope':p['scope'],'commands':[]};generated=dict(p.get('preexistingGenerated',{}));logs=None;runner=None
 def source_guard():
  assert sha(path)==r['planSHA256']
  assert all(sha(n)==s for n,s in p['pins'].items());assert inv(stage)==p['inventory'];assert sha(p['environment'])==p['environmentSHA256'];assert configs(list(map(Path,p['configRoots'])))==p['configs'];assert sha(p['notice'])=='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
 def generated_guard():
  assert all(sha(n)==s for n,s in generated.items())
  if runner is not None:runner.inputs.guard()
 def generated_registration():
  assert sha(path)==r['planSHA256']
  for c in p['commands']:
   if 'artifact' in c and Path(c['artifact']).is_file() and c['artifact'] not in generated:generated[c['artifact']]=sha(c['artifact'])
  if runner is not None:runner.inputs=T.Inputs(files=[path,*p['pins'],*generated],directories=[stage])
 def evidence_record():
  r['logs']=dict(logs.hashes) if logs is not None else {};r['generated']=dict(generated)
 def raw_guard():
  if logs is not None:logs.guard()
 guards=[('generated-registration',generated_registration),('source-config-env',source_guard),('raw',raw_guard),('generated',generated_guard),('record-evidence',evidence_record)]
 with B.ReceiptBoundary(r,out/'receipt.json',guards):
  source_guard()
  env=json.loads(Path(p['environment']).read_text());logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);logs.guard()
  runner=T.Runner(logs,inputs=T.Inputs(files=[path,*p['pins']],directories=[stage]),env=env,cwd=stage,capture='split')
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
    if c['label']=='emit':
     assert result['stdout']==b'' and result['stderr'] in [b'',Path(p['notice']).read_bytes()] and Path(c['artifact']).is_file()
    else:
     assert result['stdout']==Path(p['expected']).read_bytes() and result['stderr']==b''
   r['logs']=dict(logs.hashes) if logs is not None else {};r['generated']=dict(generated)
  r['status']='DEVELOPMENT_ACTUAL_MULTI_OWNER_JS_FULL_ORACLE_PASS_NOT_DELIVERY_NOT_FULL56'
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');a=parser.parse_args();prepare() if a.prepare else run(a.run)
