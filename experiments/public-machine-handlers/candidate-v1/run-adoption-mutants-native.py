"""One selected current-core Native mutation group with full independent union; no proof credit."""
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

def prepare(variant):
 prior=HERE/'development/adoption-mutants-js-1791420308252044834'
 old=decode(json.loads((prior/'plan.json').read_text()));receipt=json.loads((prior/'receipt.json').read_text())
 assert receipt['status']=='PROPOSED_HANDLER_EXTRACTION_THREE_MUTANTS_FULL96_AND12_JS_PASS' and receipt['planSHA256']==sha(prior/'plan.json')
 assert receipt['probeCommandsExecuted']==65 and all(c['exit']==0 and c['failure'] is None for c in receipt['commands'])
 assert all(sha(p)==h for p,h in old['pins'].items()) and inventory(Path(old['stage']))==old['inventory']
 assert all(sha(prior/n)==h for n,h in receipt['logs'].items()) and all(sha(p)==h for p,h in receipt['generated'].items())
 mapping=HERE/'development/adoption-native-mutant-roots-1791420190021431684/manifest.json'
 assert sha(mapping)=='19546e27ef109ee42b29f90881914a6a47f78346bee2878f5fc70c1d1ec13f3d';roots=json.loads(mapping.read_text())
 out=HERE/'development'/('adoption-mutants-native-'+variant+'-'+str(time.time_ns()));out.mkdir();stage=out/'stage';stage.mkdir()
 files={Path(p) for p in old['pins']}|{prior/'plan.json',prior/'receipt.json',mapping,Path(__file__).resolve(),HERE/'prepare-adoption-native-mutant-roots.py',Path(roots['historicalManifest'])}
 files.update(prior/n for n in receipt['logs']);files.update(Path(p) for p in receipt['generated']);files.update(Path(p) for p in receipt['probePins'])
 for p,h in receipt['probePins'].items():assert sha(p)==h
 assert sha(roots['historicalManifest'])==roots['historicalManifestSHA256']
 ep=out/'private-environment.json';original_env=Path(old['privateEnvironment']);assert sha(original_env)==old['environmentSHA256'];files.add(original_env);ep.write_bytes(original_env.read_bytes());ep.chmod(0o600);assert sha(ep)==old['environmentSHA256']
 cfg=P.configuration();prefix=[cfg['taskset'],'-c',str(cfg['cpu'])];commands=[];bindings={}
 selected={label:r for label,r in roots['roots'].items() if label.startswith(variant+'-')}
 assert len(selected)==(5 if variant=='premature-publication' else 2)
 for label,r in selected.items():
  src=Path(r['stage']);assert inventory(src)==r['inventory'];files.update(p for p in src.rglob('*') if p.is_file())
  base=Path(old['stage'])/variant
  for rel,h in inventory(base).items():assert sha(src/rel)==h
  dst=stage/label;shutil.copytree(src,dst);entry=dst/Path(r['entry']).relative_to(src);code=out/(label+'.c');binary=out/(label+'-native')
  bindings[label]={**r,'stage':str(dst),'entry':str(entry),'expected':str(dst/'expected.stdout')}
  commands.extend([{'label':label+'-source','argv':prefix+[cfg['tools']['bend'],str(entry),'--check-only'],'seconds':5,'typingOnly':True},{'label':label+'-emit','argv':prefix+[cfg['tools']['bend'],str(entry),'-o',str(code)],'seconds':30,'generated':str(code)},{'label':label+'-clang','argv':prefix+[cfg['tools']['clang-wrapper'],'-O3',str(code),'-pthread','-lm','-o',str(binary)],'seconds':120,'generated':str(binary)},{'label':label+'-run','argv':prefix+[str(binary),'--threads','1','--gpu','off'],'seconds':5,'partition':label}])
 plan={'pins':{str(f):sha(f) for f in sorted(files)},'tools':old['tools'],'environmentSHA256':sha(ep),'privateEnvironment':str(ep),'stage':str(stage),'inventory':inventory(stage),'configurationStates':configs(out,stage),'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+n for i in range(2*len(commands)+1) for n in ['bend','node','python','taskset','clang']],'variant':variant,'expectedProbeCount':5*(2*len(commands)+1),'sourceMapping':old['sourceMapping'],'sourceAndJSQualification':{'receipt':str(prior/'receipt.json'),'sha256':sha(prior/'receipt.json')},'nominalRoots':bindings,'scope':'One independently selected mutation group, historical successful partition root sources byte-exact on current relocated mutation closure. Whole/lost8 or premature20 fresh subjects source5/emit30/clang120/run5 each;85 or205 ordinary guards/privateClang/CPU8/thread1GPUoff. Complete selected variant96+12 independent union; exact48+6 or16+2/8+1 partitions. No oldC or oldkills replay, never combinedB/enter timeout roots; no caps/oracle/policy/proof/timing/adoption/issueclosure change.'}
 (out/'plan.json').write_text(json.dumps(plan,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))

def run(path):
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));stage=Path(p['stage']);ep=Path(p['privateEnvironment']);assert sha(ep)==p['environmentSHA256'];env=json.loads(ep.read_text());os.environ.clear();os.environ.update(env)
 generated={};ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env)
 def guard():
  assert all(sha(f)==h for f,h in p['pins'].items());assert inventory(stage)==p['inventory'];assert configs(out,stage)==p['configurationStates'];assert sha(ep)==p['environmentSHA256'];assert all(sha(f)==h for f,h in generated.items());P.shared.verify(p['tools'],**owned_configuration(ledger));ledger.guard()
 logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);runner=T.Runner(logs,inputs=T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env=env,cwd=stage,capture='split');r={'status':'INCOMPLETE','planSHA256':sha(path),'commands':[],'scope':p['scope'],'completeIssue49':False,'proofCredit':False,'productionAdopted':False}
 native={}
 try:
  guard()
  for c in p['commands']:
   guard()
   if c.get('generated'):assert not Path(c['generated']).exists()
   result=runner.run(c['label'],c['argv'],c['seconds']);r['commands'].append({k:v for k,v in result.items() if k not in ['stdout','stderr']})
   assert not result['stderr'],'unexpected emission/compile/runtime stderr'
   if c.get('generated'):
    generated[c['generated']]=sha(c['generated']);runner.inputs=T.Inputs(files=[path,ep,*p['pins'],*generated],directories=[stage])
   if c.get('typingOnly'):assert result['stdout']==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n'
   if c.get('partition'):
    label=c['partition'];assert result['stdout']==Path(p['nominalRoots'][label]['expected']).read_bytes(),'complete partition Native bytes differ';native[label]=result['stdout']
   guard()
  r['unions']={}
  for variant in [p['variant']]:
   labels=[label for label in p['nominalRoots'] if label.startswith(variant+'-')];union=b''.join(native[label] for label in labels)
   first=Path(p['nominalRoots'][labels[0]]['stage'])/'experiments/public-machine-handlers/candidate-v1'
   expected=json.loads((first/('full-mutant-'+variant+'-expected.json')).read_text())['bend']
   names=[f'schema{s}_{phase}{position}{suffix}' for s in ['A','B'] for phase in ['exit','transition','enter'] for position in [0,1] for suffix in ['', '_missing']]
   wanted=('\n'.join(n+'|['+', '.join(expected[n])+']' for n in names)+'\n').encode();assert union==wanted,'full96+12 unchanged variant union differs'
   (out/(variant+'-full96-and12-union.stdout')).write_bytes(union);r['unions'][variant]=hashlib.sha256(union).hexdigest()
  assert ledger.index==p['expectedProbeCount'];r['status']='PROPOSED_HANDLER_EXTRACTION_ONE_MUTANT_NATIVE_FULL96_AND12_UNION_PASS'
 except BaseException as e:
  r['error']=str(e)
  if hasattr(e,'result'):r['failedCommand']={k:v for k,v in e.result.items() if k not in ['stdout','stderr']}
  raise
 finally:
  r.update(generated=generated,logs=dict(logs.hashes),probePins=ledger.pins(),probeCommandsExecuted=ledger.index);(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(out)

parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');parser.add_argument('--variant',choices=['whole-marker-rollback','lost-retry','premature-publication']);args=parser.parse_args()
prepare(args.variant) if args.prepare else run(args.run)
