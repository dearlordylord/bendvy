"""Single retained-artifact N1024 development preflight; no discovery or emission."""
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
def historical(directory, files):
 hp=directory/'plan.json';hr=directory/'receipt.json';p=decode(json.loads(hp.read_text()));r=json.loads(hr.read_text());assert r['planSHA256']==sha(hp)
 files.update([hp,hr,Path(p['privateEnvironment'])]);assert sha(p['privateEnvironment'])==p['environmentSHA256']
 for name,digest in p['pins'].items():assert sha(name)==digest;files.add(Path(name))
 for name,digest in r['probePins'].items():assert sha(name)==digest;files.add(Path(name))
 for name,digest in r['logs'].items():assert sha(directory/name)==digest;files.add(directory/name)
 prep=directory/'prepare-receipt.json';pr=json.loads(prep.read_text());files.add(prep)
 for name,digest in pr['probePins'].items():assert sha(name)==digest;files.add(Path(name))
 return p,r

def prepare():
 # Metadata only. Coordinator must enclose both prepare/run in shared flock.
 files={Path(__file__).resolve(),HERE/'population1024-preflight-proposal.json'}
 d=ROOT/'.artifacts/relations-phase2-standalone-js-1791418616178805603';old,r=historical(d,files);assert r['status']=='CHUNK_DEPTH128_COMPLETE30_JS_PASS_NO_TIMING'
 hd=ROOT/'.artifacts/relations-normal-first-1791416550923842697';hp,hr=historical(hd,files);assert hr['status']=='INCOMPLETE';assert hr['commands']==[{'label':'0-ts','exit':0,'failure':None}]
 proposal=json.loads((HERE/'population1024-preflight-proposal.json').read_text())
 for name,digest in proposal['binding'].items():assert sha(ROOT/name)==digest;files.add(ROOT/name)
 c=proposal['command'];assert c['seconds']==5 and c['argv'][-4:]==['population','1024','0','0']
 oracle=Path(c['oracle']);assert json.loads((hd/'0-ts.stdout').read_text())==json.loads(oracle.read_text());assert (hd/'0-js.stdout').read_bytes()==b'';assert b'complete-trace-forced' not in (hd/'0-js.stderr').read_bytes()
 artifact=d/'trace.js';assert sha(artifact)=='3874ce25fe86ebf8b935488a0880dfcdf086c4ebd6a7f2cb2fcf1d883195e67e';files.add(artifact)
 stage=Path(old['stage']);assert inventory(stage)==old['inventory'];assert configs(d,stage)==old['configurationStates']
 out=ROOT/'.artifacts'/('relations-chunk-population1024-'+str(time.time_ns()));out.mkdir()
 p={'pins':{str(f):sha(f) for f in sorted(files)},'tools':old['tools'],'privateEnvironment':old['privateEnvironment'],'environmentSHA256':old['environmentSHA256'],'stage':old['stage'],'inventory':old['inventory'],'configurationStates':configs(out,stage),'command':c,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+n for i in range(3) for n in ['bend','node','python','taskset']],'scope':proposal['scope'],'preparation':'Metadata only; explicit unchanged four owned firstcandidate preparation probes reused. No installed-tool discovery/emission/new snapshot.'}
 (out/'plan.json').write_text(json.dumps(p,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))

def run(path):
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));private=Path(p['privateEnvironment']);assert sha(private)==p['environmentSHA256'];env=json.loads(private.read_text());stage=Path(p['stage']);ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],T.Inputs(files=[path,*p['pins']],directories=[stage]),env)
 def guard():
  assert all(sha(n)==s for n,s in p['pins'].items());assert inventory(stage)==p['inventory'];assert configs(out,stage)==p['configurationStates'];assert sha(private)==p['environmentSHA256'];P.shared.verify(p['tools'],**owned_configuration(ledger));ledger.guard()
 c=p['command'];logs=L.CommandLogs(out,[c['label']]);runner=T.Runner(logs,inputs=T.Inputs(files=[path,*p['pins']],directories=[stage]),env=env,cwd=stage);receipt={'status':'INCOMPLETE','planSHA256':sha(path),'scope':p['scope']}
 try:
  guard();guard()
  try:result=runner.run(c['label'],c['argv'],5)
  finally:logs.guard();guard()
  assert result['exit']==0 and result['failure'] is None;expected=json.loads(Path(c['oracle']).read_text());assert sum(len(root['records']) for root in expected['roots'])==30;assert json.loads(result['stdout'])==expected;assert [json.loads(x) for x in result['stderr'].splitlines()]==[{'boundary':'begin'},{'boundary':'complete-trace-forced',**F.force(expected)}];assert ledger.index==12;receipt['status']='CHUNK_POPULATION1024_SEED0_FULL30_DEVELOPMENT_PASS_NO_TIMING'
 except BaseException as e:receipt['error']=str(e);raise
 finally:logs.guard();receipt['logs']=dict(logs.hashes);receipt['probePins']=ledger.pins();receipt['probeCommandsExecuted']=ledger.index;(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(out)
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');args=parser.parse_args();prepare() if args.prepare else run(args.run)
