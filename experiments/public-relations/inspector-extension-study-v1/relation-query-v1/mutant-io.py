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
CASES=('outgoing-filter-negated','incoming-order-reversed','world-valid-omitted')
SUBJECTS=tuple((name,'next-qualification/mutants/'+name+'/boundary-io.bend','next-qualification/mutants/'+name+'/expected-defect.json') for name in CASES)
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
def config_state(p):
 if p.is_symlink():
  target=os.readlink(p);resolved=p.resolve()
  actual={'kind':'file','SHA256':sha(resolved)} if resolved.is_file() else {'kind':'directory'} if resolved.is_dir() else {'kind':'absent'}
  return {'kind':'symlink','target':target,'resolved':str(resolved),'resolvedState':actual}
 return {'kind':'file','SHA256':sha(p)} if p.is_file() else {'kind':'directory'} if p.is_dir() else {'kind':'absent'}
def configuration():
 paths=set()
 for origin in ({p.parent for p in closure()}|{H,R,COORDINATOR,INSTALLED}|{Path(shutil.which(n)).resolve().parent for n in ('bend','node','taskset')}):
  for parent in (origin,*origin.parents):
   for name in ('bend.json','bend.jsonc','bend.toml','check.json','check.jsonc','bender.json','bender.jsonc','.bend','package.json','tsconfig.json','.node-version','.nvmrc','.npmrc','.bend.json','bend.config.json','clang.cfg','.clang'):
    paths.add(parent/name)
 return {str(p):config_state(p) for p in sorted(paths)}
def prepare():
 proposal=json.loads((H/'mutant-io-proposal.json').read_text());assert sha(Path(__file__).resolve())==proposal['wrapperSHA256']
 files=closure()|{H/source for _,_,source in SUBJECTS}|{Path(__file__).resolve(),H/'mutant-io-proposal.json',H/'next-qualification/mutants/source-proposal.json',H/'next-qualification/mutants/author-defects.py',H/'author-oracle-v2.py',H/'expected-relations-v2.json',H/'source-joins.json',R/'scripts/task_runner.py',R/'scripts/receipt-logs.py',COORDINATOR/'scripts/evidence_boundary.py',H.parent/'pinned-bend-notice.bytes'}
 for name,digest in proposal['binding'].items():assert sha(H/name)==digest;files.add(H/name)
 for name in CASES:
  case=H/'next-qualification/mutants'/name;record=json.loads((H/'development/mutant-source-1791443472352846772'/name/'receipt.json').read_text())
  assert record['exit']==0 and record['sourceGuardPass'] is True and record['sourcePins']==record['postSourcePins']
  for path,digest in record['sourcePins'].items():assert sha(case/path)==digest
  files.update(p for p in (H/'development/mutant-source-1791443472352846772'/name).iterdir() if p.is_file());files.add(case/'expected-witnesses.json')
  joins=json.loads((H/'next-qualification/mutants/source-proposal.json').read_text())['mutants'][name]
  assert sha(case/joins['changedPath'])==joins['mutatedSHA256']
  for path,digest in joins['unchangedCopyJoins'].items():assert sha(case/path)==sha(H/path)==digest
 old=R/'.artifacts/inspector-relation55-boundary-io-1791441401493444111';plan=old/'plan.json';receipt=old/'receipt.json'
 assert sha(plan)=='be67bdcdc49377484a83d628f6a98222fe400a3719dbf24f48dfa306c038862c' and sha(receipt)=='747c6c45d6a5be6bd1261e01e2efb791b86e5810321d41c2540831406b750d6c'
 files.update((plan,receipt));hp=json.loads(plan.read_text());hr=json.loads(receipt.read_text());assert hr['status']=='INCOMPLETE' and hr['guardFailures']==[]
 for name,digest in hp['pins'].items():assert sha(name)==digest;files.add(Path(name))
 assert sha(hp['privateEnvironment'])==hp['environmentSHA256'];files.add(Path(hp['privateEnvironment']))
 for name,digest in hr['logs'].items():assert sha(old/name)==digest;files.add(old/name)
 assert sha(H/'reconciliation-v2.json')=='592ab358877a90f2654ff2fa8ca220e65ef18c63150efe8be8d327ba07399704';files.add(H/'reconciliation-v2.json')
 membership=installed_membership();files.update(INSTALLED/name for name in membership)
 files.update(Path(shutil.which(name)).resolve() for name in ('bend','node','taskset'))
 config=configuration();files.update(Path(n) for n,v in config.items() if v['kind']=='file');pins={str(p):sha(p) for p in sorted(files)}
 env=dict(os.environ,BEND_NO_TELEMETRY='1')
 for n in tuple(env):
  if n.startswith(('LD_','DYLD_')) or n in ('NODE_OPTIONS','NODE_PATH','NODE_REPL_EXTERNAL_MODULE'):env.pop(n,None)
 out=R/'.artifacts'/('inspector-relation55-mutant-io-'+str(time.time_ns()));out.mkdir();private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True)+'\n');private.chmod(0o600)
 assert all(sha(n)==s for n,s in pins.items()) and configuration()==config and installed_membership()==membership
 commands=[{'label':label,'argv':[str(Path(shutil.which('taskset')).resolve()),'-c','5',str(Path(shutil.which('bend')).resolve()),str(H/source)],'seconds':5,'oracle':str(H/oracle),'witnesses':str(H/'next-qualification/mutants'/label/'expected-witnesses.json')} for label,source,oracle in SUBJECTS]
 actual={'pins':pins,'configuration':config,'installedMembership':membership,'consumedClosure':list(map(str,sorted(closure()))),'privateEnvironment':str(private),'environmentSHA256':sha(private),'commands':commands,'scope':'Three same full192 relation adapter mutant IO consumers; exact independently authored complete defect outputs and witnesses, no Native/proof/full55/performance'}
 (out/'plan.json').write_text(json.dumps(actual,indent=2)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def run(path):
 path=Path(path).resolve();p=json.loads(path.read_text());out=path.parent;private=Path(p['privateEnvironment']);env=json.loads(private.read_text());planSHA=sha(path);logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);inputs=T.Inputs(files=[path,private,*p['pins']]);runner=T.Runner(logs,inputs=inputs,env=env,cwd=R,capture='split');record={'status':'INCOMPLETE','planSHA256':planSHA,'scope':p['scope'],'commands':[]}
 def guard():
  assert sha(path)==planSHA and all(sha(n)==s for n,s in p['pins'].items()) and sha(private)==p['environmentSHA256'];assert configuration()==p['configuration'] and installed_membership()==p['installedMembership'] and list(map(str,sorted(closure())))==p['consumedClosure'];inputs.guard()
 def rawguard():logs.guard();record['logs']=dict(logs.hashes)
 with B.ReceiptBoundary(record,out/'receipt.json',[('final input/config',guard),('final complete raw',rawguard)]):
  guard()
  model={'__name__':'independent_defect_model','__file__':str(H/'next-qualification/mutants/author-defects.py')};exec(compile((H/'next-qualification/mutants/author-defects.py').read_text(),'author-defects.py','exec'),model)
  for c in p['commands']:
   guard();item={**c,'exit':None,'failure':None};record['commands'].append(item)
   with B.GuardBoundary([('postchild input/config',guard),('postchild complete raw',rawguard)]):
    try:
     result=runner.run(c['label'],c['argv'],c['seconds'],expected=None);item.update(exit=result['exit'],failure=result['failure'])
    except BaseException as error:
     failed=getattr(error,'result',None)
     if failed is not None:item.update(exit=failed['exit'],failure=failed['failure'])
     item['collectionError']=str(error);raise
   assert result['exit']==0 and result['failure'] is None
   notice=(H.parent/'pinned-bend-notice.bytes').read_bytes();assert result['stderr'] in (b'',notice)
   text=result['stdout'].decode();actual,end=json.JSONDecoder().raw_decode(text);assert text[end:].encode() in (b'\n',b'\n'+notice)
   expected=json.loads(Path(c['oracle']).read_text());assert strict(expected)==strict(model['variants'][c['label']]) and strict(actual)==strict(expected)
   witnesses=model['differences'](model['normal'],actual);assert strict(witnesses)==strict(json.loads(Path(c['witnesses']).read_text())) and witnesses
   assert sum(len(phase['queries']) for schema in actual['schemas'] for phase in schema['phases'])==192
   item.update(fullDefectOracleMatched=True,reachedWitnessCount=len(witnesses),oracleSHA256=sha(c['oracle']),witnessesSHA256=sha(c['witnesses']))
  record['status']='DEVELOPMENT_THREE_RELATION192_MUTANTS_REACHED_IO_NOT_FULL55'
 print(out)
if __name__=='__main__':
 parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');args=parser.parse_args();prepare() if args.prepare else run(args.run)
