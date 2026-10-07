"""Bounded development source feasibility only; no acceptance/proof credit."""
import fcntl,hashlib,importlib.util,json,os,re,shutil,sys,time
from pathlib import Path
H=Path(__file__).resolve().parent;R=H.parents[2]
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(p,n):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
T=load(R/'scripts/task_runner.py','control_source_runner');L=load(R/'scripts/receipt-logs.py','control_source_logs')
def inventory(p):return {str(f.relative_to(p)):sha(f) for f in p.rglob('*') if f.is_file()}
def closure(p,files):
 p=p.resolve()
 if p in files:return
 files.add(p)
 for name in re.findall(r'^\s*import\s+(\S+)',p.read_text(),re.M):
  if name!='Base' and not name.startswith(chr(34)):closure(p.parent/name,files)
if len(sys.argv)==1:
 out=H/'development'/('authority-negative-cheap-'+str(time.time_ns()));stage=out/'stage';stage.mkdir(parents=True)
 entries={name:H/('full-negative-'+name+'.bend') for name in ['owner-duplicate','cross-schema','write-through-read','undeclared-next']};files=set()
 for entry in entries.values():closure(entry,files)
 for source in files:
  target=stage/source.relative_to(R);target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,target)
 prior=json.loads((H/'development/foreign-authority-source-1791406441952311812/plan.json').read_text());prefix=prior['commands'][0]['argv'][:-2]
 files.update([Path(prefix[0]).resolve(),Path(prefix[-1]).resolve(),Path('/home/node/.bend/bend2/base.bend'),Path(__file__).resolve(),R/'scripts/task_runner.py',R/'scripts/receipt-logs.py'])
 env=out/'private-environment.json';env.write_text(json.dumps(dict(os.environ,BEND_NO_TELEMETRY='1'),sort_keys=True));env.chmod(0o600)
 positive=H/'development/control-source-cheap-1791407861883379025';qualified=json.loads((positive/'receipt.json').read_text());assert qualified['status']=='AFFECTED_CONTROL_SOURCES_DEVELOPMENT_PASS_NO_ACCEPTANCE_CREDIT' and qualified['planSHA256']==sha(positive/'plan.json')
 files.update([positive/'plan.json',positive/'receipt.json',*[positive/n for n in qualified['logs']],H/'full-authority-positive.bend'])
 commands=[{'label':name+'-source-check','argv':prefix+[str(stage/entry.relative_to(R)),'--check-only'],'seconds':5} for name,entry in entries.items()]
 p={'status':'PREPARED_DEVELOPMENT_SOURCE_ONLY','pins':{str(f):sha(f) for f in sorted(files)},'stage':str(stage),'inventory':inventory(stage),'privateEnvironment':str(env),'environmentSHA256':sha(env),'commands':commands,'positiveSiblingReceiptSHA256':sha(positive/'receipt.json'),'lock':'/tmp/bendvy-parity-heavy.lock','scope':'Four intended authority negative source5 subjects; raw diagnostics must be retained and independently classified against matching positive siblings before authority acceptance. Expected nonzero1 is only diagnostic collection, not a semantic mutant kill or correct-reason acceptance. No probes/emitter/runtime/production/proof/performance credit; frozen closure/Base/executables/environment and unchanged prior positive sibling receipt.'}
 (out/'plan.json').write_text(json.dumps(p,indent=2)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
else:
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
 path=Path(sys.argv[1]).resolve();p=json.loads(path.read_text());out=path.parent;stage=Path(p['stage']);ep=Path(p['privateEnvironment']);assert sha(ep)==p['environmentSHA256'];assert all(sha(f)==h for f,h in p['pins'].items());assert inventory(stage)==p['inventory']
 logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);runner=T.Runner(logs,inputs=T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),cwd=stage,env=json.loads(ep.read_text()),capture='split');r={'status':'INCOMPLETE','planSHA256':sha(path),'commands':[],'scope':p['scope'],'acceptanceQualified':False}
 try:
  for c in p['commands']:
   try:
    runner.run(c['label'],c['argv'],c['seconds'])
   except RuntimeError as error:
    if not hasattr(error,'result'):raise
    result=error.result
    assert result['exit']==1 and result['failure'] is None,'timeout/other exit is not intended diagnostic'
    r['commands'].append({k:v for k,v in result.items() if k not in ['stdout','stderr']})
   else:raise AssertionError('intended negative unexpectedly accepted')
  r['status']='FOUR_AUTHORITY_NONZERO_DIAGNOSTICS_RETAINED_UNCLASSIFIED'
 except BaseException as e:
  r['error']=str(e)
  if hasattr(e,'result'):r['failedCommand']={k:v for k,v in e.result.items() if k not in ['stdout','stderr']}
  raise
 finally:r['logs']=dict(logs.hashes);(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(out)
