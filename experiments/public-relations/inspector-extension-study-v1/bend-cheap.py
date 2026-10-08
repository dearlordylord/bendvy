"""Three bounded pure CLI development consumers; external coordinator owns flock."""
import argparse,hashlib,importlib.util,json,os,re,shutil,sys,time
from pathlib import Path
H=Path(__file__).resolve().parent;R=H.parents[2]
COORDINATOR=Path('/workspace/formal-proofs/bendvy')
sys.dont_write_bytecode=True
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(p,n):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
T=load(R/'scripts/task_runner.py','task_runner');L=load(R/'scripts/receipt-logs.py','receipt_logs');B=load(COORDINATOR/'scripts/evidence_boundary.py','evidence_boundary')
SUBJECTS=(('boundary','format-output.bend','expected-bend-worlds.json'),('metadata','metadata-controls.bend','expected-metadata.json'),('direct-check','check-output.bend','expected-check-boundaries.json'))
INSTALLED=Path('/home/node/.bend/bend2')
def installed_membership():
 return {str(p.relative_to(INSTALLED)):str(p.resolve()) for p in sorted(INSTALLED.rglob('*')) if p.is_file()}
def closure():
 pending=[H/source for _,source,_ in SUBJECTS];seen=set()
 while pending:
  p=pending.pop().resolve()
  if p in seen:continue
  assert p.is_file(),str(p);seen.add(p)
  for imp in re.findall(r'^import\s+(\S+)',p.read_text(),re.M):
   target=INSTALLED/'base.bend' if imp=='Base' else p.parent/imp
   pending.append(target)
 return seen
def strict(value):
 if isinstance(value,dict):return ('dict',tuple((k,strict(v)) for k,v in sorted(value.items())))
 if isinstance(value,list):return ('list',tuple(map(strict,value)))
 return (type(value).__name__,value)
def configuration():
 paths=set()
 for origin in ({p.parent for p in closure()}|{H,R,COORDINATOR,INSTALLED}):
  for parent in (origin,*origin.parents):
   for name in ('bend.json','bend.jsonc','bend.toml','check.json','check.jsonc','bender.json','bender.jsonc','.bend','package.json','tsconfig.json','.node-version','.nvmrc'):
    paths.add(parent/name)
 return {str(p):{'kind':'file','SHA256':sha(p)} if p.is_file() else {'kind':'directory'} if p.is_dir() else {'kind':'absent'} for p in sorted(paths)}
def prepare():
 files=closure()|{H/oracle for _,_,oracle in SUBJECTS}
 membership=installed_membership();files.update(INSTALLED/name for name in membership)
 files.update((Path(__file__).resolve(),H/'pinned-bend-notice.bytes',R/'scripts/task_runner.py',R/'scripts/receipt-logs.py',COORDINATOR/'scripts/evidence_boundary.py',H/'bend-cheap-proposal.json'))
 # Exact current root copies, not historical runtime credit transfer.
 for copy in sorted(p for p in closure() if p.parent==H/'root-source'):
  root=COORDINATOR/'src/ecs'/copy.name;assert copy.read_bytes()==root.read_bytes();files.add(root)
 formatter=COORDINATOR/'.references/bend2/bend2'
 files.update((formatter/'main.ts',formatter/'bend.ts'))
 bend=Path(shutil.which('bend')).resolve();taskset=Path(shutil.which('taskset')).resolve();files.update((bend,taskset))
 configs=configuration();files.update(Path(p) for p,v in configs.items() if v['kind']=='file');pins={str(p):sha(p) for p in sorted(files)}
 env=dict(os.environ,BEND_NO_TELEMETRY='1')
 for n in tuple(env):
  if n.startswith(('LD_','DYLD_')) or n in ('NODE_OPTIONS','NODE_PATH','NODE_REPL_EXTERNAL_MODULE'):env.pop(n,None)
 out=R/'.artifacts'/('inspector-machine55-bend-cheap-'+str(time.time_ns()));out.mkdir();private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True)+'\n');private.chmod(0o600)
 assert {str(p):sha(p) for p in files}==pins and configuration()==configs and installed_membership()==membership
 p={'scope':'Pure main CLI term_snf development, full independent value oracles; not IO/generated JS/Native/proof/performance/full55/adoption or closed installed resolver qualification','pins':pins,'installedMembership':membership,'consumedClosure':list(map(str,sorted(closure()))),'configuration':configs,'privateEnvironment':str(private),'environmentSHA256':sha(private),'commands':[{'label':label,'argv':[str(taskset),'-c','5',str(bend),str(H/source)],'seconds':5,'oracle':str(H/oracle)} for label,source,oracle in SUBJECTS],'failure':'stop first failure; retain raw/result/postguards; no unchanged repeat/cap raise/oracle relearning'}
 (out/'plan.json').write_text(json.dumps(p,indent=2)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def run(path):
 path=Path(path).resolve();p=json.loads(path.read_text());out=path.parent;private=Path(p['privateEnvironment']);env=json.loads(private.read_text());logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);inputs=T.Inputs(files=[path,private,*p['pins']]);runner=T.Runner(logs,inputs=inputs,env=env,cwd=R,capture='split');r={'status':'INCOMPLETE','planSHA256':sha(path),'scope':p['scope'],'commands':[]}
 def guard():
  assert all(sha(n)==s for n,s in p['pins'].items());assert sha(private)==p['environmentSHA256'];assert configuration()==p['configuration'];assert installed_membership()==p['installedMembership'];assert list(map(str,sorted(closure())))==p['consumedClosure'];inputs.guard()
 def log_guard():
  logs.guard();r['logs']=dict(logs.hashes)
 with B.ReceiptBoundary(r,out/'receipt.json',[('source/environment/config/tools',guard),('raw logs',log_guard)]):
  guard()
  for c in p['commands']:
   item={'label':c['label'],'argv':c['argv'],'seconds':c['seconds'],'exit':None,'failure':None};r['commands'].append(item)
   with B.GuardBoundary([('post-child source/config',guard),('post-child raw logs',log_guard)]):
    try:
     result=runner.run(c['label'],c['argv'],c['seconds'],expected=None);item.update(exit=result['exit'],failure=result['failure'])
    except BaseException as e:
     v=getattr(e,'result',None)
     if v is not None:item.update(exit=v['exit'],failure=v['failure'])
     item['collectionError']=str(e);raise
   assert result['exit']==0 and result['failure'] is None
   notice=(H/'pinned-bend-notice.bytes').read_bytes();assert result['stderr'] in (b'',notice),'unexpected stderr whole bytes'
   # Pinned Bend pure String display wraps escaped JSON in one quoted string.
   text=result['stdout'].decode('utf-8');value,end=json.JSONDecoder().raw_decode(text)
   assert isinstance(value,str)
   assert text[end:].encode() in (b'\n',b'\n'+notice),'unexpected trailing stdout whole bytes'
   actual=json.loads(value);expected=json.loads(Path(c['oracle']).read_text());assert strict(actual)==strict(expected),'full independent typed oracle mismatch'
   item['oracleSHA256']=sha(c['oracle']);item['fullOracleMatched']=True
  r['status']='DEVELOPMENT_PURE_THREE_FULL_ORACLES_PASS_NOT_FULL55'
 print(out)
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');a=parser.parse_args();prepare() if a.prepare else run(a.run)
