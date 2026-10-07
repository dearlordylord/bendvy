"""Complete remaining five actual Native schema partitions; retain first A without replay."""
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

def prepare(draft,receipt):
 draft=Path(draft).resolve();d=json.loads(draft.read_text());receipt=Path(receipt).resolve();r=json.loads(receipt.read_text());previous_path=receipt.parent/'plan.json';previous=decode(json.loads(previous_path.read_text()));assert r['status']=='WHOLE_MARKER_A_NATIVE_COMPLETE48_AND6_PASS_PARTIAL_TWO_SCHEMA_SCOPE' and r['planSHA256']==sha(previous_path)
 assert all(sha(f)==digest for f,digest in previous['pins'].items());assert all(sha(receipt.parent/n)==digest for n,digest in r['logs'].items());assert all(sha(f)==digest for f,digest in r['probePins'].items());assert not (receipt.parent/'run-native.stderr').read_bytes()
 out=HERE/'development'/('mutants-native-remaining-'+str(time.time_ns()));out.mkdir();stage=out/'stage';stage.mkdir();files=set(map(Path,previous['pins']));files.update([draft,receipt,previous_path,Path(__file__).resolve()]);files.update(map(Path,r['probePins']));files.update(receipt.parent/n for n in r['logs']);commands=[];joins={};prefix=previous['commands'][0]['argv'][:3]
 historical=HERE/'development/mutants-complete-cheap-1791410160619766954/plan.json';qualified_stage=Path(json.loads(historical.read_text())['stage']);files.add(historical)
 manifest=HERE/'delivery-mutants-v1/manifest.json';selected=json.loads(manifest.read_text());assert all(sha(HERE/name)==digest for name,digest in selected['source'].items());files.add(manifest);files.update(HERE/name for name in selected['source'])
 for label in ['whole-marker-rollback-B','lost-retry-A','lost-retry-B','premature-publication-A','premature-publication-B']:
  entry=Path(d['nativeEntries'][label]);binding=d['nativeSubsetBindings'][label];assert sha(entry)==binding['wrapperSHA256'];subset=set();closure(entry,subset);partition=entry.parents[3]
  for source in sorted(subset):
   if source!=entry:
    original=Path(binding['sourceRoot'])/source.relative_to(partition);qualified=qualified_stage/original.relative_to(ROOT);assert sha(source)==sha(original)==sha(qualified);files.update([original,qualified]);joins[str(source)]={'original':str(original),'qualifiedGeneratedStageSource':str(qualified),'sha256':sha(original)}
   target=stage/source.relative_to(ROOT);target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,target);files.add(source)
  expected=entry.parent/'expected-native.stdout';assert sha(expected)==binding['completeRawSubsetSHA256'];files.add(expected);variant=label.rsplit('-',1)[0];files.add(HERE/('full-mutant-'+variant+'-expected.json'));c=out/(label+'.c');binary=out/(label+'-native')
  commands.extend([{'label':label+'-source','argv':prefix+[P.configuration()['tools']['bend'],str(stage/entry.relative_to(ROOT)),'--check-only'],'seconds':5}, {'label':label+'-emit','argv':prefix+[P.configuration()['tools']['bend'],str(stage/entry.relative_to(ROOT)),'-o',str(c)],'seconds':30}, {'label':label+'-clang','argv':prefix+[P.configuration()['tools']['clang-wrapper'],'-O3',str(c),'-pthread','-lm','-o',str(binary)],'seconds':120}, {'label':label+'-run','argv':prefix+[str(binary),'--threads','1','--gpu','off'],'seconds':5,'oracle':str(expected)}])
 envfile=out/'private-environment.json';ep=Path(previous['privateEnvironment']);assert sha(ep)==previous['environmentSHA256'];envfile.write_bytes(ep.read_bytes());envfile.chmod(0o600);files.add(ep)
 plan={'pins':{str(f):sha(f) for f in sorted(files)},'tools':previous['tools'],'privateEnvironment':str(envfile),'environmentSHA256':sha(envfile),'stage':str(stage),'inventory':inventory(stage),'configurationStates':configs(out,stage),'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+n for i in range(41) for n in ['bend','node','python','taskset','clang']],'sourceJoins':joins,'retainedWholeA':str(receipt.parent/'run-native.stdout'),'retainedWholeASHA256':sha(receipt.parent/'run-native.stdout'),'scope':'Five remaining actual per-nominal-schema partitions, source5/emit30/clang120/run5 each,205 ordinary guards. Full48+6 raw each; final three A+B byte unions equal original unchanged independent96+12 variant oracles. Retain successful wholeA output with no replay; no combined-root retry or cap raise. No timing/proof/production/completeIssue49 claim.'}
 (out/'plan.json').write_text(json.dumps(plan,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))

def run(path):
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));stage=Path(p['stage']);ep=Path(p['privateEnvironment']);assert sha(ep)==p['environmentSHA256'];env=json.loads(ep.read_text());os.environ.clear();os.environ.update(env);generated={};native={}
 ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env)
 def guard():
  assert all(sha(f)==h for f,h in p['pins'].items());assert inventory(stage)==p['inventory'];assert configs(out,stage)==p['configurationStates'];assert sha(ep)==p['environmentSHA256'];assert all(sha(f)==h for f,h in generated.items());P.shared.verify(p['tools'],**owned_configuration(ledger));ledger.guard()
 logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);runner=T.Runner(logs,inputs=T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env=env,cwd=stage,capture='split');r={'status':'INCOMPLETE','planSHA256':sha(path),'commands':[],'scope':p['scope'],'completeIssue49':False,'proofCredit':False}
 try:
  guard()
  for c in p['commands']:
   guard()
   if '-o' in c['argv']:assert not Path(c['argv'][-1]).exists()
   result=runner.run(c['label'],c['argv'],c['seconds']);r['commands'].append({k:v for k,v in result.items() if k not in ['stdout','stderr']})
   if '-o' in c['argv']:
    generated[c['argv'][-1]]=sha(c['argv'][-1]);runner.inputs=T.Inputs(files=[path,ep,*p['pins'],*generated],directories=[stage])
   if 'oracle' in c:
    assert result['stdout']==Path(c['oracle']).read_bytes() and not result['stderr'],'complete48+6 Native output/diagnostics differ';native[c['label'].removesuffix('-run')]=result['stdout']
   if c['label'].endswith('-source'):assert not result['stderr'],'unexpected source diagnostics'
   guard()
  assert ledger.index==205
  native['whole-marker-rollback-A']=Path(p['retainedWholeA']).read_bytes();assert sha(p['retainedWholeA'])==p['retainedWholeASHA256'];unions={}
  for variant in ['lost-retry','premature-publication','whole-marker-rollback']:
   oracle=json.loads((HERE/('full-mutant-'+variant+'-expected.json')).read_text())['bend'];names=[f'schema{s}_{phase}{position}{suffix}' for s in ['A','B'] for phase in ['exit','transition','enter'] for position in [0,1] for suffix in ['','_missing']];expected=('\n'.join(name+'|['+', '.join(oracle[name])+']' for name in names)+'\n').encode();actual=native[variant+'-A']+native[variant+'-B'];assert actual==expected;dest=out/(variant+'-union.stdout');dest.write_bytes(actual);unions[str(dest)]=sha(dest)
  r['unions']=unions;r['status']='THREE_NATIVE_COMPLETE96_AND12_VARIANT_BYTE_UNIONS_PASS'
 except BaseException as e:
  r['error']=str(e)
  if hasattr(e,'result'):r['failedCommand']={k:v for k,v in e.result.items() if k not in ['stdout','stderr']}
  raise
 finally:
  r.update(generated=generated,logs=dict(logs.hashes),probePins=ledger.pins(),probeCommandsExecuted=ledger.index);(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(out)

parser=argparse.ArgumentParser();parser.add_argument('--prepare');parser.add_argument('--first-receipt');parser.add_argument('--run');args=parser.parse_args()
prepare(args.prepare,args.first_receipt) if args.prepare else run(args.run)
