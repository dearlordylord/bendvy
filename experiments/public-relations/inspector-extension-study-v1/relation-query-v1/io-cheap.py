"""One complete actual IO CLI development consumers; external coordinator owns flock."""
import argparse,hashlib,importlib.util,json,os,re,shutil,sys,time
from pathlib import Path
H=Path(__file__).resolve().parent;R=H.parents[3]
COORDINATOR=Path('/workspace/formal-proofs/bendvy')
sys.dont_write_bytecode=True
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(p,n):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
T=load(R/'scripts/task_runner.py','task_runner');L=load(R/'scripts/receipt-logs.py','receipt_logs');B=load(COORDINATOR/'scripts/evidence_boundary.py','evidence_boundary')
SUBJECTS=(('boundary-io','boundary-io.bend','expected-relations.json'),)
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
 for origin in ({p.parent for p in closure()}|{H,R,COORDINATOR,INSTALLED}|{Path(shutil.which(n)).resolve().parent for n in ('bend','node','taskset')}):
  for parent in (origin,*origin.parents):
   for name in ('bend.json','bend.jsonc','bend.toml','check.json','check.jsonc','bender.json','bender.jsonc','.bend','package.json','tsconfig.json','.node-version','.nvmrc','.npmrc'):
    paths.add(parent/name)
 return {str(p):{'kind':'file','SHA256':sha(p)} if p.is_file() else {'kind':'directory'} if p.is_dir() else {'kind':'absent'} for p in sorted(paths)}
def prepare():
 proposal=json.loads((H/'io-proposal.json').read_text())
 assert sha(H/proposal['source'])==proposal['sourceSHA256'] and sha(H/proposal['oracle'])==proposal['oracleSHA256'] and sha(Path(__file__).resolve())==proposal['wrapperSHA256']
 assert sha(H/'source-joins.json')==proposal['sourceJoinsSHA256']
 historical=R/'.artifacts/inspector-relation55-ts-1791440748625764734'
 hp=historical/'plan.json';hr=historical/'receipt.json'
 assert sha(hp)=='34594a20166fd66c1cf80d5c3e08ea4048ed6a23ff339d199e7b8e341b472f4a'
 assert sha(hr)=='31a3fb82cb1eebec8e5634d38a0ac8f54372707974ce01bf069923e2a8da6069'
 old=json.loads(hp.read_text());receipt=json.loads(hr.read_text());assert receipt['status']=='DEVELOPMENT_ACTUAL_TS_RELATION192_PASS_NOT_FULL55'
 assert all(sha(name)==expected for name,expected in old['pins'].items());assert sha(old['privateEnvironment'])==old['environmentSHA256']
 for name,expected in receipt['logs'].items():assert sha(historical/name)==expected
 files=closure()|{H/oracle for _,_,oracle in SUBJECTS}|set(map(Path,old['pins']))|{hp,hr,Path(old['privateEnvironment'])}|{historical/name for name in receipt['logs']}
 # Exact4worker+24current-root joins; source-only authority, no runtime transfer.
 joins=H/'source-joins.json';files.add(joins)
 for entry in json.loads(joins.read_text())['files']:
  original=Path(entry['source']);copy=H/entry['copy'];assert sha(original)==sha(copy)==entry['SHA256'];files.update((original,copy))
 for directory in ('fixture-output-1791440787714716609','boundary-io-1791440788582957020'):
  dev=H/'development'/directory;record=json.loads((dev/'receipt.json').read_text());assert record['exitCode']==0 and record['sourceGuardPass'] is True
  assert all(sha(H/name)==digest for name,digest in record['localSourcePins'].items())
  files.update(p for p in dev.iterdir() if p.is_file())
 membership=installed_membership();files.update(INSTALLED/name for name in membership)
 files.update((Path(__file__).resolve(),H.parent/'pinned-bend-notice.bytes',R/'scripts/task_runner.py',R/'scripts/receipt-logs.py',COORDINATOR/'scripts/evidence_boundary.py',H/'io-proposal.json'))
 formatter=COORDINATOR/'.references/bend2/bend2'
 files.update((formatter/'main.ts',formatter/'bend.ts'))
 bend=Path(shutil.which('bend')).resolve();taskset=Path(shutil.which('taskset')).resolve();files.update((bend,taskset,Path(shutil.which('node')).resolve()))
 configs=configuration();files.update(Path(p) for p,v in configs.items() if v['kind']=='file');pins={str(p):sha(p) for p in sorted(files)}
 env=dict(os.environ,BEND_NO_TELEMETRY='1')
 for n in tuple(env):
  if n.startswith(('LD_','DYLD_')) or n in ('NODE_OPTIONS','NODE_PATH','NODE_REPL_EXTERNAL_MODULE'):env.pop(n,None)
 out=R/'.artifacts'/('inspector-relation55-boundary-io-'+str(time.time_ns()));out.mkdir();private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True)+'\n');private.chmod(0o600)
 assert {str(p):sha(p) for p in files}==pins and configuration()==configs and installed_membership()==membership
 p={'actualTSPlanSHA256':sha(hp),'actualTSReceiptSHA256':sha(hr),'scope':'One actual IO CLI generated-JS relation development, full independent192-query/owners/cursors/barrier oracle; not standalone emittedJS/Native/proof/performance/full55/adoption or closed installed resolver qualification','pins':pins,'installedMembership':membership,'consumedClosure':list(map(str,sorted(closure()))),'configuration':configs,'privateEnvironment':str(private),'environmentSHA256':sha(private),'commands':[{'label':label,'argv':[str(taskset),'-c','5',str(bend),str(H/source)],'seconds':5,'oracle':str(H/oracle)} for label,source,oracle in SUBJECTS],'failure':'stop first failure; retain raw/result/postguards; no unchanged repeat/cap raise/oracle relearning'}
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
   notice=(H.parent/'pinned-bend-notice.bytes').read_bytes();assert result['stderr'] in (b'',notice),'unexpected stderr whole bytes'
   # Actual IO prints the complete JSON DTO, unlike historical pure String framing.
   text=result['stdout'].decode('utf-8');value,end=json.JSONDecoder().raw_decode(text)
   assert isinstance(value,dict)
   assert text[end:].encode() in (b'\n',b'\n'+notice),'unexpected trailing stdout whole bytes'
   actual=value;expected=json.loads(Path(c['oracle']).read_text());assert strict(actual)==strict(expected),'full independent typed oracle mismatch'
   assert len(actual['schemas'])==2 and sum(len(phase['queries']) for subject in actual['schemas'] for phase in subject['phases'])==192
   item['oracleSHA256']=sha(c['oracle']);item['fullOracleMatched']=True
  r['status']='DEVELOPMENT_ACTUAL_IO_RELATION192_PASS_NOT_FULL55'
 print(out)
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');a=parser.parse_args();prepare() if a.prepare else run(a.run)
