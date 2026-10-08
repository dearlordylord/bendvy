"""Remaining-only candidate depth16 CPU diagnostic; historical allocation timeout retained."""
import argparse,base64,hashlib,importlib.util,json,os,re,shutil,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];HERE=Path(__file__).resolve().parent
TOOL=ROOT/'experiments/public-relations/promotion-stage/application/next-version/v1/tool-pins.py'
sys.dont_write_bytecode=True

def load(p,n):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
T=load(ROOT/'scripts/task_runner.py','task_runner');L=load(ROOT/'scripts/receipt-logs.py','logs');P=load(TOOL,'tools')
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def encode(x):
 if isinstance(x,bytes):return {'rawBase64':base64.b64encode(x).decode()}
 raise TypeError(type(x))
def decode(x):
 if isinstance(x,dict):return base64.b64decode(x['rawBase64']) if set(x)=={'rawBase64'} else {k:decode(v) for k,v in x.items()}
 if isinstance(x,list):return [decode(v) for v in x]
 return x
def inventory(p):return {str(f.relative_to(p)):sha(f) for f in p.rglob('*') if f.is_file()}
def configs(out,stage):
 paths=set()
 for root in {ROOT,Path.cwd(),out,stage,stage/'src/ecs',stage/'experiments/public-relations/promotion-stage',*[p.parent for p in stage.rglob('*.bend')]}:
  for parent in [root,*root.parents]:
   for name in ['check.json','bend.json','bender.json','package.json','.bend.json','bend.config.json']:paths.add(parent/name)
 for name in ['check.json','bend.json','bender.json','package.json','.bend.json','bend.config.json']:paths.add(Path('/home/node/.bend')/name)
 return {str(p):sha(p) if p.is_file() else None for p in paths}
def closure(p,files):
 p=p.resolve()
 if p in files:return
 files.add(p)
 if p.suffix=='.bend':
  for name in re.findall(r'^\s*import\s+(\S+)',p.read_text(),re.M):
   if name!='Base' and not name.startswith(chr(34)):closure(p.parent/name,files)
class ProbeLedger:
 def __init__(self,directory,labels,inputs,env):
  directory.mkdir();self.directory=directory;self.labels=labels;self.index=0;self.receipts={};self.env=env
  self.logs=L.CommandLogs(directory,labels);self.runner=T.Runner(self.logs,inputs=inputs,env=env,cwd=ROOT,capture='merged-stdout')
 def execute(self,argv,limit,env):
  assert env==self.env and limit==5
  label=self.labels[self.index];self.index+=1
  result=self.runner.run(label,argv,limit)
  path=self.directory/(label+'.json');path.write_text(json.dumps({'argv':list(map(str,argv)),'seconds':limit,'exit':result['exit'],'failure':result['failure'],'runnerSHA256':result['runnerSHA256']},indent=2)+'\n');self.receipts[str(path)]=sha(path);self.guard();return result
 def guard(self):
  self.logs.guard();assert all(sha(p)==h for p,h in self.receipts.items())
  assert {str(p) for p in self.directory.iterdir()}==set(self.receipts)|{str(self.directory/n) for n in self.logs.hashes}
 def pins(self):return {**self.receipts,**{str(self.directory/n):h for n,h in self.logs.hashes.items()}}
def owned_configuration(ledger):
 return {'execute':ledger.execute,'tools':{'bend':shutil.which('bend'),'node':shutil.which('node'),'python':sys.executable,'taskset':shutil.which('taskset')},'resource_roots':['/home/node/.bend/bend2'],'ldd':shutil.which('ldd'),'taskset':shutil.which('taskset'),'cpu':5,'env':ledger.env,'skip_ldd':[],'capture_mode':'merged-stdout'}

F=load(HERE.parents[2]/'trace-cheap.py','summary')
def prepare():
 d=ROOT/'.artifacts/relations-chunk-profiles-1791419733173894934';hp=d/'plan.json';hr=d/'receipt.json';old=decode(json.loads(hp.read_text()));r=json.loads(hr.read_text());assert r['planSHA256']==sha(hp) and r['status']=='INCOMPLETE';assert r['commands']==[{'label':'original-cpu','status':'FULL30_PROFILE_OUTPUT_PASS'},{'label':'original-allocation','status':'INCOMPLETE'}];assert all(sha(n)==s for n,s in old['pins'].items());assert sha(old['privateEnvironment'])==old['environmentSHA256'];assert inventory(Path(old['stage']))==old['inventory'];assert configs(d,Path(old['stage']))==old['configurationStates'];assert all(sha(n)==s for n,s in r['profiles'].items());assert all(sha(d/n)==s for n,s in r['logs'].items());prep=d/'prepare-receipt.json';preparation=json.loads(prep.read_text());assert preparation['status']=='OWNED_TOOL_PREPARATION_PASS' and preparation['probeCommandsExecuted']==4;assert all(sha(n)==s for n,s in preparation['probePins'].items())
 out=ROOT/'.artifacts'/('relations-profile-candidate-cpu-'+str(time.time_ns()));out.mkdir();command=old['commands'][2];assert command['label']=='candidate-cpu' and command['seconds']==5 and command['mode']=='cpu';assert not Path(command['profile']).exists();files={hp,hr,prep,Path(__file__).resolve(),HERE/'profile-candidate-cpu-proposal.json',Path(old['privateEnvironment']),*[Path(n) for n in old['pins']],*[Path(n) for n in r['profiles']],*[d/n for n in r['logs']],*[Path(n) for n in preparation['probePins']]};p={'pins':{str(f):sha(f) for f in sorted(files)},'tools':old['tools'],'privateEnvironment':old['privateEnvironment'],'environmentSHA256':old['environmentSHA256'],'stage':old['stage'],'inventory':old['inventory'],'configurationStates':configs(out,Path(old['stage'])),'command':command,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+n for i in range(3) for n in ['bend','node','python','taskset']],'historicalPlanSHA256':sha(hp),'historicalReceiptSHA256':sha(hr),'scope':'ONE remaining candidateCPU consumer matched to qualifiedoriginalCPU depth16; originalallocationtimeout retained/no retry; no allocation/performance/cause/verdict'};(out/'plan.json').write_text(json.dumps(p,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def run(path):
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));private=Path(p['privateEnvironment']);assert sha(private)==p['environmentSHA256'];env=json.loads(private.read_text());stage=Path(p['stage']);profiles={};ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],T.Inputs(files=[path,*p['pins']],directories=[stage]),env)
 def guard():
  assert all(sha(n)==s for n,s in p['pins'].items());assert inventory(stage)==p['inventory'];assert configs(out,stage)==p['configurationStates'];assert sha(private)==p['environmentSHA256'];assert all(sha(n)==s for n,s in profiles.items());P.shared.verify(p['tools'],**owned_configuration(ledger));ledger.guard()
 guard();c=p['command'];logs=L.CommandLogs(out,[c['label']]);runner=T.Runner(logs,inputs=T.Inputs(files=[path,*p['pins']],directories=[stage]),env=env,cwd=stage);receipt={'status':'INCOMPLETE','planSHA256':sha(path),'scope':p['scope']}
 try:
  guard();assert not Path(c['profile']).exists();result=runner.run(c['label'],c['argv'],5);assert result['exit']==0 and result['failure'] is None;expected=json.loads(Path(c['oracle']).read_text());assert json.loads(result['stdout'])==expected;assert [json.loads(x) for x in result['stderr'].splitlines()]==[{'boundary':'begin'},{'boundary':'complete-trace-forced',**F.force(expected)}];data=json.loads(Path(c['profile']).read_text());assert data['zeroExits']==1 and data['invocations']==1 and data['mode']=='cpu' and data['profile']['nodes'];profiles[c['profile']]=sha(c['profile']);guard();assert ledger.index==12;receipt['status']='REMAINING_CANDIDATE_CPU_FULL30_PROFILE_PASS_NO_VERDICT'
 except BaseException as e:receipt['error']=str(e);raise
 finally:receipt['profiles']=profiles;receipt['logs']=dict(logs.hashes);receipt['probePins']=ledger.pins();receipt['probeCommandsExecuted']=ledger.index;(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(out)
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');args=parser.parse_args();prepare() if args.prepare else run(args.run)
