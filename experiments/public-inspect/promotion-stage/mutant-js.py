"""Freeze/execute only an admitted complete reader-consumption JS control."""
from pathlib import Path
import argparse,json,os,sys,time,types
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
sys.dont_write_bytecode=True
B=types.ModuleType('inspect54_mutant_backend');B.__file__=str(HERE/'native-backends.py')
exec((HERE/'native-backends.py').read_text().split('\nparser = argparse.ArgumentParser()')[0],B.__dict__)
def prepare(source,baseline,native):
 source=Path(source).resolve();sp=source.parent/'plan.json';s=json.loads(sp.read_text());sr=json.loads(source.read_text())
 assert sr['status']=='SAFE_SOURCE_MUTANT_PASS' and sr['planSHA256']==B.sha(sp)
 assert sr['commands']==[{'label':'reader-mutant-pure-source','exit':0,'failure':None}]
 assert B.task_runner.Inputs(files=s['files'],directories=map(Path,s['directories'])).expected==s['inputs']
 baseline=Path(baseline).resolve();bp=baseline.parent/'plan.json';b=json.loads(bp.read_text());br=json.loads(baseline.read_text())
 assert br['status']=='FULL_CARDINALITY_CHECK_STANDALONE_JS_IO_PASS' and br['planSHA256']==B.sha(bp)
 assert B.task_runner.Inputs(files=b['files'],directories=[Path(b['stage']),*map(Path,b['directories'])]).expected==b['inputs']
 assert B.inventory(Path(b['stage']))==b['inventory']
 proposal=HERE/'controls/reader-mutant-js-proposal.json';v=json.loads(proposal.read_text());original=v['oracles']['originalFullStringPlusExactIOLF'];defect=v['oracles']['independentlyAuthoredDefectFullStringPlusExactIOLF']
 assert (baseline.parent/'cardinality-run-js-io.stdout').read_bytes()==original.encode()
 for name,digest in v['oracleInputs'].items():assert B.sha(name)==digest
 native=Path(native).resolve();n=B.decode(json.loads(native.read_text()));tools=n['tools']
 private_source=Path(n['privateEnvironment']);assert B.sha(private_source)==n['environmentSHA256'];env=json.loads(private_source.read_text())
 out=ROOT/'.artifacts'/('inspect54-reader-mutant-js-'+str(time.time_ns()));out.mkdir();private=out/'private-environment.json';private.write_bytes(private_source.read_bytes());private.chmod(0o600)
 stage=HERE/'controls/reader-mutant-stage';entry=stage/'experiments/public-inspect/promotion-stage/cardinality-io-main.bend';js=out/'reader-mutant.js'
 files=set(map(Path,s['files']))|set(map(Path,b['files']))|{Path(__file__).resolve(),HERE/'native-backends.py',source,sp,baseline,bp,native,proposal,private,HERE/'reader-mutant-oracle.py',HERE/'cardinality-oracle.py'}
 B.JOIN.closure(entry,files)
 for path,digest in tools['pins'].items():assert B.sha(path)==digest;files.add(Path(path))
 for receipt,path in [(sr,source),(br,baseline)]:
  for name,digest in receipt['logs'].items():raw=path.parent/name;assert B.sha(raw)==digest;files.add(raw)
 for field in ['generated','probePins']:
  for name,digest in br[field].items():assert B.sha(name)==digest;files.add(Path(name))
 oracle=out/'oracle.json';oracle.write_text(json.dumps({'original':original,'defect':defect},indent=2)+'\n');files.add(oracle)
 directories=set(map(Path,s['directories']))|set(map(Path,b['directories']))|{Path(b['stage']),stage}
 prefix=[tools['taskset'],'-c','5'];commands=[{'label':'reader-mutant-emit-js','argv':prefix+[tools['tools']['bend'],str(entry),'-o',str(js)],'seconds':30,'generated':str(js)},{'label':'reader-mutant-run-js-io','argv':prefix+[tools['tools']['node'],str(js)],'seconds':5}]
 inputs=B.task_runner.Inputs(files=files,directories=directories)
 plan={'status':'PREPARED_UNADMITTED','commands':commands,'files':sorted(map(str,files)),'directories':sorted(map(str,directories)),'inputs':inputs.expected,'stage':str(stage),'inventory':B.inventory(stage),'tools':tools,'privateEnvironment':str(private),'environmentSHA256':B.sha(private),'configurationStates':B.configurations(out,stage),'oracle':str(oracle),'sourceJoin':{'receipt':str(source),'receiptSHA256':B.sha(source),'planSHA256':B.sha(sp)},'baselineJoin':{'receipt':str(baseline),'receiptSHA256':B.sha(baseline),'planSHA256':B.sha(bp),'fullOriginalStdoutSHA256':B.sha(baseline.parent/'cardinality-run-js-io.stdout')},'executionProbeLabels':['guard-'+str(i)+'-ldd-'+name for i in range(5) for name in B.NAMES],'prepareProbeCount':0,'toolSnapshotReuse':{'plan':str(native),'planSHA256':B.sha(native),'rule':'Existing approved ordinary snapshot; exact current pins checked in preparation, ordinary verify executes only if plan admitted.'},'scope':'Only reached successful-reader cursor-consumption mutation. Original 74-line complete two-schema String plus exact IO LF must disagree semantically; actual full output must equal independently authored complete defect oracle. No framing-only kill, timeout acceptance, proof/Native/performance/full54 claim.'}
 p=out/'plan.json';p.write_text(json.dumps(plan,indent=2,default=B.encode)+'\n');print(p);print(B.sha(p))
def run(path):
 path=Path(path).resolve();out=path.parent;p=B.decode(json.loads(path.read_text()));stage=Path(p['stage']);private=Path(p['privateEnvironment']);assert B.sha(private)==p['environmentSHA256'];env=json.loads(private.read_text());os.environ.clear();os.environ.update(env)
 original=B.task_runner.Inputs(files=p['files'],directories=map(Path,p['directories']));assert original.expected==p['inputs']
 inputs=B.task_runner.Inputs(files=[path,*p['files']],directories=map(Path,p['directories']));ledger=B.ProbeLedger(out/'execution-probes',p['executionProbeLabels'],inputs,env);logs=B.LOGS.CommandLogs(out,[c['label'] for c in p['commands']]);runner=B.task_runner.Runner(logs,inputs=inputs,env=env,cwd=stage);oracle=json.loads(Path(p['oracle']).read_text());generated={};receipt={'status':'INCOMPLETE','planSHA256':B.sha(path),'commands':[],'scope':p['scope']}
 def guard():
  runner.inputs.guard();logs.guard();assert B.inventory(stage)==p['inventory'];assert B.configurations(out,stage)==p['configurationStates'];assert B.sha(private)==p['environmentSHA256'];assert all(B.sha(f)==d for f,d in generated.items());B.TOOLS.shared.verify(p['tools'],**B.configuration(ledger));ledger.guard()
 try:
  guard()
  for c in p['commands']:
   guard()
   if 'generated' in c:assert not Path(c['generated']).exists()
   try:r=runner.run(c['label'],c['argv'],c['seconds'])
   except BaseException as error:
    r=getattr(error,'result',None);receipt['commands'].append({'label':c['label'],'exit':r['exit'] if r else None,'failure':r['failure'] if r else str(error)});raise
   receipt['commands'].append({'label':c['label'],'exit':r['exit'],'failure':r['failure']})
   if 'generated' in c:
    generated[c['generated']]=B.sha(c['generated']);runner.inputs=B.task_runner.Inputs(files=[path,*p['files'],*generated],directories=map(Path,p['directories']))
   else:
    assert r['stdout']==oracle['defect'].encode(),'actual complete defect oracle mismatch'
    assert r['stdout']!=oracle['original'].encode(),'original full oracle did not kill mutation'
    actual=r['stdout'].decode().splitlines();expected=oracle['original'].splitlines();assert len(actual)==len(expected)==75
    differences=[{'line':i+1,'original':a,'actual':b} for i,(a,b) in enumerate(zip(expected,actual)) if a!=b]
    assert len(differences)==12 and all(d['original'].startswith(('added|','changed|')) for d in differences)
    receipt['reachedSemanticDifferences']=differences
   guard()
  assert ledger.index==25;receipt['status']='REACHED_COMPLETE_READER_CONSUMPTION_JS_CONTROL_PASS'
 except BaseException as error:receipt['error']=str(error);raise
 finally:
  receipt['generated']=generated;receipt['logs']=dict(logs.hashes);receipt['probePins']=ledger.pins();receipt['probeCount']=ledger.index;(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(out)
p=argparse.ArgumentParser();p.add_argument('--prepare',action='store_true');p.add_argument('--source');p.add_argument('--baseline');p.add_argument('--native');p.add_argument('--run');a=p.parse_args()
if a.prepare:prepare(a.source,a.baseline,a.native)
else:run(a.run)
