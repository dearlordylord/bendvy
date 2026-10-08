"""Fresh resolver-guarded authority sources and retained complete JS controls; no baseline replay."""
import argparse,base64,hashlib,importlib.util,json,os,re,shutil,sys,time,fcntl
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
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
 for root in [ROOT,Path.cwd(),out,stage,stage/'src/ecs',stage/'experiments/public-machine-handlers/candidate-v1',*[p.parent for p in stage.rglob('*.bend')]]:
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
 c=P.configuration();c['execute']=ledger.execute;return c

def prepare():
 # Pure source copying/freezing only: no snapshot probes or backend execution.
 production=Path('/workspace/formal-proofs/bendvy');proposal=HERE/'adoption-proposal-v1'
 selected=json.loads((proposal/'manifest.json').read_text())
 assert selected['status']=='SOURCE_ONLY_UNEXECUTED_PROPOSAL'
 out=HERE/'development'/('adoption-source-controls-'+str(time.time_ns()));out.mkdir()
 stage=out/'stage';stage.mkdir();fixture=stage/'experiments/public-machine-handlers/candidate-v1';fixture.mkdir(parents=True)
 pins={};mapping={};sha_bytes=lambda data:hashlib.sha256(data).hexdigest()
 for source in sorted((production/'src/ecs').rglob('*.bend')):
  destination=stage/source.relative_to(production);destination.parent.mkdir(parents=True,exist_ok=True)
  destination.write_bytes(source.read_bytes());pins[str(source)]=sha(source)
  mapping[str(destination.relative_to(stage))]={'original':str(source),'sha256':sha(source),'kind':'readonly current production dependency'}
 changes={'../../public-machines/machine.bend':'../../../src/ecs/machine.bend','../../public-machines/stream.bend':'../../../src/ecs/machine-stream.bend','handlers-tracked.bend':'../../../src/ecs/machine-handlers.bend','event-stream.bend':'../../../src/ecs/internal/machine-handler-events.bend'}
 consumers={e['path']:e for e in selected['consumerImports']}
 for source in sorted(HERE.glob('full-*.bend')):
  old=source.read_text();new=old
  for before,after in changes.items():new=new.replace('import '+before+' as ','import '+after+' as ')
  relative=str(source.relative_to(ROOT));recorded=consumers.get(relative)
  if recorded:assert sha(source)==recorded['beforeSha256'] and sha_bytes(new.encode())==recorded['afterSha256']
  (fixture/source.name).write_text(new);pins[str(source)]=sha(source)
  mapping[str((fixture/source.name).relative_to(stage))]={'original':str(source),'sha256':sha(source),'proposedSHA256':sha_bytes(new.encode()),'kind':'fixture import migration only'}
 for entry in selected['modules']:
  source=ROOT/entry['source'];assert sha(source)==entry['sourceSha256'];pins[str(source)]=sha(source)
  target=stage/entry['target'];actual=production/entry['target']
  assert actual.is_file(),'root draft missing; bind actual source before freeze'
  assert sha(actual)==entry['proposedSha256'],'root actual draft differs from reviewed extraction'
  pins[str(actual)]=sha(actual)
  patch=proposal/entry['patch'];lines=patch.read_text().splitlines(True)
  text=''.join(line[1:] for line in lines[3:] if line.startswith('+'))
  assert sha_bytes(text.encode())==entry['proposedSha256'];target.parent.mkdir(parents=True,exist_ok=True);target.write_text(text)
  mapping[entry['target']]={'original':str(source),'sha256':sha(source),'proposedSHA256':sha_bytes(text.encode()),'kind':entry.get('visibility','generic import-only extraction')}
 for name in ['world.bend','conditions.bend']:
  source=ROOT/'experiments/public-machines'/name;old=source.read_text()
  new=old.replace('import machine.bend as M','import ../../src/ecs/machine.bend as M')
  target=stage/'experiments/public-machines'/name;target.parent.mkdir(parents=True,exist_ok=True);target.write_text(new)
  pins[str(source)]=sha(source)
  mapping[str(target.relative_to(stage))]={'original':str(source),'sha256':sha(source),'proposedSHA256':sha_bytes(new.encode()),'kind':'retained fixture helper; M import rebind only'}
 classified=json.loads((HERE/'authority-diagnostic-classification-v1.json').read_text())
 entries={'normal-full-driver':fixture/'full-driver-v2.bend','authority-positive':fixture/'full-authority-positive.bend','foreign':fixture/'full-foreign-controls.bend'}
 for name in classified['controls']:entries[name]=fixture/('full-negative-'+name+'.bend')
 needed=set()
 for entry in entries.values():closure(entry,needed)
 assert all(path.is_relative_to(stage) for path in needed)
 # Reuse tooling snapshot only, never prior source/runtime qualification.
 prior=HERE/'development/controls-qualified-1791412550172483507';oldplan=decode(json.loads((prior/'plan.json').read_text()))
 oldreceipt=json.loads((prior/'receipt.json').read_text());assert oldreceipt['planSHA256']==sha(prior/'plan.json')
 assert oldreceipt['status']=='ORDINARY_RESOLVER_CONTROLS_COMPLETE_DIAGNOSTICS_AND_PHYSICAL_JS_PASS'
 environment=Path(oldplan['privateEnvironment']);env=json.loads(environment.read_text());assert sha(environment)==oldplan['environmentSHA256']
 ep=out/'private-environment.json';ep.write_text(json.dumps(env,sort_keys=True));ep.chmod(0o600)
 tools=oldplan['tools'];files={Path(x) for x in pins}|{Path(x) for x in tools['pins']}|{proposal/p for p in ['README.md','manifest.json',*[x['patch'] for x in selected['modules']],'05-full-consumer-imports.patch']}|{Path(__file__).resolve(),HERE/'authority-diagnostic-classification-v1.json',prior/'plan.json',prior/'receipt.json',TOOL,ROOT/'scripts/owned-tool-pins.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py'}
 commands=[]
 positiveHistory={'normal-full-driver':(HERE/'development/driver-v2-cheap-1791404921410873785','source-check'),'authority-positive':(prior,'authority-positive-source'),'foreign':(prior,'foreign-source')}
 for name,entry in entries.items():
  negative=classified['controls'].get(name)
  positive=None
  if not negative:
   directory,label=positiveHistory[name];receipt=json.loads((directory/'receipt.json').read_text());stdout=directory/(label+'.stdout');stderr=directory/(label+'.stderr')
   assert sha(stdout)==receipt['logs'][stdout.name] and sha(stderr)==receipt['logs'][stderr.name] and not stderr.read_bytes()
   files.update([directory/'receipt.json',stdout,stderr]);positive={'expectedStdoutSHA256':sha(stdout),'positiveHistoryReceipt':str(directory/'receipt.json')}
  commands.append({'label':name+'-source','argv':[oldplan['commands'][0]['argv'][0],'-c',oldplan['commands'][0]['argv'][2],oldplan['commands'][0]['argv'][3],str(entry),'--check-only'],'seconds':5,'expected':1 if negative else 0,'diagnostic':negative['intendedErrorSnippets'] if negative else None,**({'expectedStderrSHA256':negative['rawStderrSHA256']} if negative else positive)})
 plan={'pins':{str(f):sha(f) for f in sorted(files)},'tools':tools,'environmentSHA256':sha(ep),'privateEnvironment':str(ep),'stage':str(stage),'inventory':inventory(stage),'configurationStates':configs(out,stage),'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+n for i in range(15) for n in ['bend','node','python','taskset','clang']],'sourceMapping':mapping,'toolingSnapshotReuseOnly':{'plan':str(prior/'plan.json'),'sha256':sha(prior/'plan.json')},'scope':'SOURCE ONLY prospective extracted generic3 plus INTERNAL Data handler events. Seven source5 controls/75 ordinary guards; normal two nominal schemas, matched positive, real foreign and four exact intended diagnostics. Current production dependencies readonly bytepinned. No actualsrc changes, JSNative replay, proof/laws/ownership policy/adoption/issue closure claim.'}
 (out/'plan.json').write_text(json.dumps(plan,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))

def run(path):
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));stage=Path(p['stage']);ep=Path(p['privateEnvironment']);assert sha(ep)==p['environmentSHA256'];env=json.loads(ep.read_text());os.environ.clear();os.environ.update(env)
 ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env)
 def guard():
  assert all(sha(f)==h for f,h in p['pins'].items());assert inventory(stage)==p['inventory'];assert configs(out,stage)==p['configurationStates'];assert sha(ep)==p['environmentSHA256'];P.shared.verify(p['tools'],**owned_configuration(ledger));ledger.guard()
 logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);runner=T.Runner(logs,inputs=T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env=env,cwd=stage,capture='split');r={'status':'INCOMPLETE','planSHA256':sha(path),'commands':[],'scope':p['scope'],'completeIssue49':False,'proofCredit':False}
 try:
  guard()
  for c in p['commands']:
   guard();result=runner.run(c['label'],c['argv'],c['seconds'],expected=c['expected']);r['commands'].append({k:v for k,v in result.items() if k not in ['stdout','stderr']})
   if c.get('diagnostic'):
    assert not result['stdout'] and all(snippet.encode() in result['stderr'] for snippet in c['diagnostic']),'unrelated negative error is inconclusive'
    assert hashlib.sha256(result['stderr']).hexdigest()==c['expectedStderrSHA256'],'changed/unrelated diagnostic is inconclusive'
   elif c['label'].endswith('-source'):
    assert not result['stderr'],'positive source emitted unexpected diagnostics'
    assert hashlib.sha256(result['stdout']).hexdigest()==c['expectedStdoutSHA256'],'positive typing-only output drift; no proof credit'
   guard()
  assert ledger.index==75;r['status']='PROPOSED_HANDLER_EXTRACTION_SEVEN_SOURCE_CONTROLS_PASS_NO_RUNTIME'
 except BaseException as e:
  r['error']=str(e)
  if hasattr(e,'result'):r['failedCommand']={k:v for k,v in e.result.items() if k not in ['stdout','stderr']}
  raise
 finally:
  r.update(logs=dict(logs.hashes),probePins=ledger.pins(),probeCommandsExecuted=ledger.index);(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(out)

parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');args=parser.parse_args()
prepare() if args.prepare else run(args.run)
