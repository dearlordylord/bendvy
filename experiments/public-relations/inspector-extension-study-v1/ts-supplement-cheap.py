"""One supplemental actual TS consumer; external coordinator owns flock."""
import argparse,hashlib,importlib.util,json,os,shutil,sys,time
from pathlib import Path
H=Path(__file__).resolve().parent;R=H.parents[2];ROOT=Path('/workspace/formal-proofs/bendvy');sys.dont_write_bytecode=True
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(p,n):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
T=load(R/'scripts/task_runner.py','task_runner');L=load(R/'scripts/receipt-logs.py','receipt_logs');B=load(ROOT/'scripts/evidence_boundary.py','evidence_boundary')
def proposal():return json.loads((H/'ts-supplement-proposal.json').read_text())
def configuration():
 paths=set()
 for origin in ({H,R,ROOT}|{Path(p).parent for p in proposal()['referenceClosure']}):
  for parent in (origin,*origin.parents):
   for n in ('package.json','tsconfig.json','.node-version','.nvmrc'):
    paths.add(parent/n)
 return {str(p):{'kind':'file','SHA256':sha(p)} if p.is_file() else {'kind':'directory'} if p.is_dir() else {'kind':'absent'} for p in sorted(paths)}
def strict(v):
 if isinstance(v,dict):return ('dict',tuple((k,strict(x)) for k,x in sorted(v.items())))
 if isinstance(v,list):return ('list',tuple(map(strict,v)))
 return (type(v).__name__,v)
def prepare():
 a=proposal();assert sha(H/a['source'])==a['sourceSHA256'];assert sha(H/a['oracle'])==a['oracleSHA256']
 history=R/'.artifacts/inspector-machine55-ts-cheap-1791435428607460927';hp=history/'plan.json';hr=history/'receipt.json'
 assert sha(hp)=='cb458229cc3d1f940039071487d150291157a70b19754ef28195936465aaa8fb'
 assert sha(hr)=='040dbc1e5bc21c122907f1360f801ca38afbe1b4f1cf645c38bd6c9a23fb0974'
 old=json.loads(hp.read_text());receipt=json.loads(hr.read_text());assert receipt['status']=='DEVELOPMENT_ACTUAL_TS_COMPLETE18_PASS_NOT_FULL55'
 assert all(sha(p)==v for p,v in old['pins'].items());assert sha(old['privateEnvironment'])==old['environmentSHA256']
 files=set(map(Path,old['pins']))|{hp,hr,Path(old['privateEnvironment']),H/a['source'],H/a['oracle'],H/'ts-supplement-proposal.json',Path(__file__).resolve(),ROOT/'scripts/evidence_boundary.py'}
 for n,v in receipt['logs'].items():assert sha(history/n)==v;files.add(history/n)
 for n,v in a['referenceClosure'].items():assert sha(n)==v;files.add(Path(n))
 node=Path(shutil.which('node')).resolve();taskset=Path(shutil.which('taskset')).resolve();files.update((node,taskset));configs=configuration();files.update(Path(n) for n,v in configs.items() if v['kind']=='file');pins={str(p):sha(p) for p in sorted(files)}
 env=dict(os.environ)
 for n in tuple(env):
  if n.startswith(('LD_','DYLD_')) or n in ('NODE_OPTIONS','NODE_PATH','NODE_REPL_EXTERNAL_MODULE'):env.pop(n,None)
 out=R/'.artifacts'/('inspector-machine55-ts-supplement-'+str(time.time_ns()));out.mkdir();private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True)+'\n');private.chmod(0o600)
 assert {str(p):sha(p) for p in files}==pins and configuration()==configs
 p={'scope':'One actual TS full18 supplemental DTO+four insideCheck complete public snapshots; no private cursor observation/full55/backendproof/perf/adoption','pins':pins,'configuration':configs,'privateEnvironment':str(private),'environmentSHA256':sha(private),'oracle':str(H/a['oracle']),'command':{'label':'ts-supplement','argv':[str(taskset),'-c','5',str(node),str(H/a['source'])],'seconds':5},'historicalComplete18ReceiptSHA256':sha(hr)}
 (out/'plan.json').write_text(json.dumps(p,indent=2)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def run(path):
 path=Path(path).resolve();p=json.loads(path.read_text());out=path.parent;c=p['command'];private=Path(p['privateEnvironment']);env=json.loads(private.read_text());logs=L.CommandLogs(out,[c['label']]);inputs=T.Inputs(files=[path,private,*p['pins']]);runner=T.Runner(logs,inputs=inputs,env=env,cwd=R,capture='split');item={'label':c['label'],'argv':c['argv'],'seconds':c['seconds'],'exit':None,'failure':None};r={'status':'INCOMPLETE','scope':p['scope'],'planSHA256':sha(path),'commands':[item]}
 def guard():
  assert all(sha(n)==v for n,v in p['pins'].items());assert sha(private)==p['environmentSHA256'];assert configuration()==p['configuration'];inputs.guard()
 def log_guard():logs.guard();r['logs']=dict(logs.hashes)
 with B.ReceiptBoundary(r,out/'receipt.json',[('source/config/env/tools',guard),('raw logs',log_guard)]):
  guard()
  with B.GuardBoundary([('post-child source/config',guard),('post-child raw',log_guard)]):
   try:result=runner.run(c['label'],c['argv'],c['seconds'],expected=None);item.update(exit=result['exit'],failure=result['failure'])
   except BaseException as e:
    v=getattr(e,'result',None)
    if v is not None:item.update(exit=v['exit'],failure=v['failure'])
    item['collectionError']=str(e);raise
  assert result['exit']==0 and result['failure'] is None and result['stderr']==b''
  actual=json.loads(result['stdout']);expected=json.loads(Path(p['oracle']).read_text());assert strict(actual)==strict(expected)
  assert len(actual['observations'])==18 and len(actual['checks'])==4;r['status']='DEVELOPMENT_ACTUAL_TS_FULL18_PLUS4_CHECK_SNAPSHOTS_PASS_NOT_FULL55';item['fullOracleMatched']=True;item['oracleSHA256']=sha(p['oracle'])
 print(out)
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');a=parser.parse_args();prepare() if a.prepare else run(a.run)
