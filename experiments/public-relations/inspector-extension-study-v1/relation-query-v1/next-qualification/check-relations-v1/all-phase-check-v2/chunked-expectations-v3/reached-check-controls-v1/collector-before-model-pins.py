"""Four Check diagnostic-control source feasibility subjects; external flock required."""
import argparse,hashlib,importlib.util,json,os,re,shutil,sys,time
from pathlib import Path
H=Path(__file__).resolve().parent;R=next(p for p in H.parents if (p/"scripts/task_runner.py").exists())
COORDINATOR=Path('/workspace/formal-proofs/bendvy')
sys.dont_write_bytecode=True
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(p,n):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
T=load(R/'scripts/task_runner.py','task_runner');L=load(R/'scripts/receipt-logs.py','receipt_logs');B=load(COORDINATOR/'scripts/evidence_boundary.py','evidence_boundary')
NAMES=('normal','outgoing-filter-negated','incoming-order-reversed','world-valid-omitted')
SOURCES=[H/n/'source-positive.bend' for n in NAMES]
INSTALLED=Path('/home/node/.bend/bend2')
def installed_membership():
 return {str(p.relative_to(INSTALLED)):str(p.resolve()) for p in sorted(INSTALLED.rglob('*')) if p.is_file()}
def closure():
 pending=list(SOURCES);seen=set()
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
 for origin in ({p.parent for p in closure()}|{H,R,COORDINATOR,INSTALLED,Path.home(),Path.home()/'.bend'}|{Path(shutil.which(n)).resolve().parent for n in ('bend','node','taskset')}):
  for parent in (origin,*origin.parents):
   for name in ('.bend.json','bend.config.json','bend.json','bend.jsonc','bend.toml','check.json','check.jsonc','bender.json','bender.jsonc','.bend','package.json','tsconfig.json','.node-version','.nvmrc','.npmrc'):
    paths.add(parent/name)
 def actual(p,ancestors):
  if p.is_file():return {'kind':'file','SHA256':sha(p)}
  if p.is_dir():
   resolved=str(p.resolve())
   if resolved in ancestors:return {'kind':'directory-cycle','resolvedPath':resolved}
   chain=ancestors|{resolved}
   return {'kind':'directory','inventory':{q.name:state(q,chain) for q in sorted(p.iterdir())}}
  return {'kind':'absent'}
 def state(p,ancestors=frozenset()):
  if p.is_symlink():return {'kind':'symlink','target':os.readlink(p),'resolvedPath':str(p.resolve()),'resolvedState':actual(p.resolve(),ancestors)}
  return actual(p,ancestors)

 return {str(p):state(p) for p in sorted(paths)}

def prepare():
 proposal=H/'collector-proposal.json';decl=json.loads(proposal.read_text());assert sha(__file__)==decl['wrapperSHA256'] and sha(H/'source-oracle-manifest.json')==decl['sourceOracleManifestSHA256']
 files=closure()|{Path(__file__).resolve(),proposal,H/'source-oracle-manifest.json',H/'variant-source-joins.json',H/'normal/source-copy-joins.json',H/'author-oracles.py',R/'scripts/task_runner.py',R/'scripts/receipt-logs.py',COORDINATOR/'scripts/evidence_boundary.py',H.parents[5]/'pinned-bend-notice.bytes'}
 for name in NAMES:
  files.add(H/name/'expected-complete.json')
  if name!='normal':files.add(H/name/'expected-witnesses.json')
 membership=installed_membership();files.update(INSTALLED/n for n in membership)
 bend=Path(shutil.which('bend')).resolve();taskset=Path(shutil.which('taskset')).resolve();files.update((bend,taskset))
 configs=configuration();files.update(Path(n) for n,state in configs.items() if state['kind']=='file');pins={str(p):sha(p) for p in sorted(files)}
 env=dict(os.environ,BEND_NO_TELEMETRY='1')
 for n in tuple(env):
  if n.startswith(('LD_','DYLD_')) or n in ('NODE_OPTIONS','NODE_PATH','NODE_REPL_EXTERNAL_MODULE'):env.pop(n,None)
 out=R/'.artifacts'/('check-relation55-reached-controls-source-'+str(time.time_ns()));out.mkdir();private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True)+'\n');private.chmod(0o600)
 assert all(sha(n)==digest for n,digest in pins.items()) and configuration()==configs and installed_membership()==membership
 p={'scope':'development four complete Check control source feasibility only; no runtime kill','pins':pins,'configuration':configs,'installedMembership':membership,'consumedClosure':list(map(str,sorted(closure()))),'privateEnvironment':str(private),'environmentSHA256':sha(private),'commands':[{'label':source.parent.name,'argv':[str(taskset),'-c','5',str(bend),str(source),'--check-only'],'seconds':5,'role':'positive'} for source in SOURCES]}
 (out/'plan.json').write_text(json.dumps(p,indent=2)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def run(path):
 path=Path(path).resolve();out=path.parent;original=sha(path);p=None;private=None;logs=None;inputs=None;runner=None;record={'status':'INCOMPLETE','planSHA256':original,'commands':[]}
 def guard():
  assert sha(path)==original==record['planSHA256']
  if p is None:return
  assert all(sha(n)==digest for n,digest in p['pins'].items()) and sha(private)==p['environmentSHA256'];assert configuration()==p['configuration'] and installed_membership()==p['installedMembership'] and list(map(str,sorted(closure())))==p['consumedClosure']
  if inputs is not None:inputs.guard()
 def raw():
  if logs is not None:logs.guard();record['logs']=dict(logs.hashes)
 with B.ReceiptBoundary(record,out/'receipt.json',[('all source/config/env',guard),('all raw',raw)]):
  guard();p=json.loads(path.read_text());private=Path(p['privateEnvironment']);guard();env=json.loads(private.read_text());inputs=T.Inputs(files=[path,private,*p['pins']]);logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);runner=T.Runner(logs,inputs=inputs,env=env,cwd=R,capture='split')
  for c in p['commands']:
   item={**c,'exit':None,'failure':None};record['commands'].append(item)
   with B.GuardBoundary([('post-source guard',guard),('post-source raw',raw)]):
    try:result=runner.run(c['label'],c['argv'],5,expected=None);item.update(exit=result['exit'],failure=result['failure'])
    except BaseException as e:
     result=getattr(e,'result',None)
     if result is not None:item.update(exit=result['exit'],failure=result['failure'])
     item['collectionError']=str(e);raise
   assert result['failure'] is None
   if c['role']=='positive':
    assert result['exit']==0 and result['stdout']==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n';assert result['stderr'] in (b'',(H.parents[5]/'pinned-bend-notice.bytes').read_bytes());item['status']='POSITIVE_SOURCE_FEASIBLE_NOT_PROOF'
   else:item['status']='RAW_UNCLASSIFIED_REQUIRES_INDEPENDENT_DIAGNOSTIC_REVIEW'
  record['status']='DEVELOPMENT_FOUR_CHECK_CONTROL_SOURCES_FEASIBLE_NOT_RUNTIME'
 print(out)
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');a=parser.parse_args();prepare() if a.prepare else run(a.run)
