"""Frozen complete independent variant consumers; no source/probe replay."""
import fcntl,hashlib,importlib.util,json,os,re,shutil,sys,time
from pathlib import Path
H=Path(__file__).resolve().parent;R=H.parents[2]
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(p,n):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
T=load(R/'scripts/task_runner.py','mutant_complete_runner');L=load(R/'scripts/receipt-logs.py','mutant_complete_logs')
def inventory(p):return {str(f.relative_to(p)):sha(f) for f in p.rglob('*') if f.is_file()}
def closure(p,files):
 p=p.resolve()
 if p in files:return
 files.add(p)
 for name in re.findall(r'^\s*import\s+(\S+)',p.read_text(),re.M):
  if name!='Base' and not name.startswith(chr(34)):closure(p.parent/name,files)
VARIANTS=['lost-retry','premature-publication','whole-marker-rollback']
if len(sys.argv)==1:
 out=H/'development'/('mutants-complete-cheap-'+str(time.time_ns()));stage=out/'stage';stage.mkdir(parents=True)
 first=H/'development/handler-mutants-source-1791406676461764447';last=H/'development/whole-marker-source-repair-v6-1791409886258517688';files=set();joins={};sourceEvidence={}
 commands=[];normal=H/'full-expected.json';consumer=H/'full-mutant-complete-consumer.mjs';node=Path(shutil.which('node')).resolve()
 for name in VARIANTS:
  version='v6' if name=='whole-marker-rollback' else 'v2';entry=H/'development'/('handler-mutants-prepared-'+version)/name/'experiments/public-machine-handlers/candidate-v1/full-driver-v2.bend'
  cohort=last if name=='whole-marker-rollback' else first;plan=json.loads((cohort/'plan.json').read_text());receipt=json.loads((cohort/'receipt.json').read_text());assert receipt['planSHA256']==sha(cohort/'plan.json')
  label='whole-marker-rollback-source-check' if name=='whole-marker-rollback' else name+'-source-check'
  assert (name=='whole-marker-rollback' and receipt['commands'][0]['exit']==0) or any(c.get('label')==label and c['exit']==0 for c in receipt['commands'])
  assert sha(cohort/(label+'.stdout'))==receipt['logs'][label+'.stdout'] and sha(cohort/(label+'.stderr'))==receipt['logs'][label+'.stderr']
  subset=set();closure(entry,subset)
  for source in sorted(subset):
   previous=Path(plan['stage'])/source.relative_to(R);assert source.read_bytes()==previous.read_bytes()
   joins[str(source)]={'sourceSHA256':sha(source),'qualifiedStageSource':str(previous),'qualifiedStageSHA256':sha(previous)};files.update([source,previous])
   target=stage/source.relative_to(R);target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,target)
  files.update([cohort/'plan.json',cohort/'receipt.json',cohort/(label+'.stdout'),cohort/(label+'.stderr')]);sourceEvidence[name]={'receipt':str(cohort/'receipt.json'),'sha256':sha(cohort/'receipt.json'),'label':label,'credit':'source typing only, IO root present, not --verdict/proof/semantic kill'}
  generated=out/(name+'.mjs');oracle=H/('full-mutant-'+name+'-expected.json');files.add(oracle)
  oldprefix=json.loads((H/'development/control-source-cheap-1791407861883379025/plan.json').read_text())['commands'][0]['argv'][:-2]
  commands.extend([{'label':name+'-emit','argv':oldprefix+[str(stage/entry.relative_to(R)),'-o',str(generated)],'seconds':30},{'label':name+'-consume','argv':[str(node),str(consumer),str(generated),str(normal),name,str(oracle)],'seconds':5}])
 files.update([normal,consumer,H/'full-oracle.py',H/'full-mutant-oracle.py',H/'development/handler-mutants-prepared-v2/mutants.json',H/'development/handler-mutants-prepared-v6/repair.json',Path(oldprefix[0]).resolve(),Path(oldprefix[-1]).resolve(),node,Path('/home/node/.bend/bend2/base.bend'),Path(__file__).resolve(),R/'scripts/task_runner.py',R/'scripts/receipt-logs.py'])
 env=out/'private-environment.json';env.write_text(json.dumps(dict(os.environ,BEND_NO_TELEMETRY='1'),sort_keys=True));env.chmod(0o600)
 p={'status':'PREPARED_COMPLETE_VARIANT_CONSUMERS','pins':{str(f):sha(f) for f in sorted(files)},'stage':str(stage),'inventory':inventory(stage),'privateEnvironment':str(env),'environmentSHA256':sha(env),'commands':commands,'sourceEvidence':sourceEvidence,'exactSourceStageJoins':joins,'lock':'/tmp/bendvy-parity-heavy.lock','scope':'Three compiling controlled mutants with six minimal JS subjects emit30/Node5 each; no source/probe/normal96 or TS replay. Every variant must match independent complete96/12 physical oracle then both-schema exact intended witness, normal prefixes/refusals and actual Local/log preservation. Existing typed source closures rejoined byte exactly; complete output retained. World inverse finite Array<U32>/Bool ordinary Column, no arbitraryType clone policy. Development-only no final resolver/production/proof/performance credit.'}
 (out/'plan.json').write_text(json.dumps(p,indent=2)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
else:
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
 path=Path(sys.argv[1]).resolve();p=json.loads(path.read_text());out=path.parent;stage=Path(p['stage']);ep=Path(p['privateEnvironment']);assert sha(ep)==p['environmentSHA256'];assert all(sha(f)==h for f,h in p['pins'].items());assert inventory(stage)==p['inventory']
 logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);runner=T.Runner(logs,inputs=T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),cwd=stage,env=json.loads(ep.read_text()),capture='split');generated={};r={'status':'INCOMPLETE','planSHA256':sha(path),'commands':[],'scope':p['scope'],'acceptanceQualified':False,'proofCredit':False}
 try:
  for c in p['commands']:
   if '-o' in c['argv']:assert not Path(c['argv'][c['argv'].index('-o')+1]).exists()
   result=runner.run(c['label'],c['argv'],c['seconds'])
   if '-o' in c['argv']:
    f=c['argv'][c['argv'].index('-o')+1];generated[f]=sha(f);runner.inputs=T.Inputs(files=[path,ep,*p['pins'],*generated],directories=[stage])
   r['commands'].append({k:v for k,v in result.items() if k not in ['stdout','stderr']})
  r['status']='THREE_COMPLETE96_AND12_VARIANTS_REACHED_BOTH_SCHEMA_SEMANTIC_WITNESSES'
 except BaseException as e:
  r['error']=str(e)
  if hasattr(e,'result'):r['failedCommand']={k:v for k,v in e.result.items() if k not in ['stdout','stderr']}
  raise
 finally:r['generated']=generated;r['logs']=dict(logs.hashes);(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(out)
