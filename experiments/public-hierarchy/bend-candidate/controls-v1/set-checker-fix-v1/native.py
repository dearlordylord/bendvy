from pathlib import Path
import argparse,hashlib,json,os,shutil,types,time
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4];BACK=ROOT/'experiments/public-inspect/bend-candidate/full-v2/backends.py'
B=types.ModuleType('set_owned_backend');B.__file__=str(BACK);exec(BACK.read_text().split('\np=argparse.ArgumentParser()')[0],B.__dict__)
CHEAP=HERE/'cheap-1791399144219083899';BASE=HERE/'cheap-1791399100203438697'
sha=B.sha

def configs(out,stage):
 result=B.configs(out,stage)
 for root in [HERE,stage/'experiments/public-hierarchy/bend-candidate/full-v1']:
  for parent in [root,*root.parents]:
   for name in ['check.json','bend.json','bender.json','package.json','.bend.json','bend.config.json']:
    p=parent/name;result[str(p)]=sha(p) if p.is_file() else None
 return result

def prepare():
 cp=json.loads((CHEAP/'plan.json').read_text());cr=json.loads((CHEAP/'receipt.json').read_text());assert cr['status']=='COMPLETE_SIX_RECORD_SET_BASELINE_REACHED_MUTANT_JS_PASS';assert (BASE/'baseline-run-js.stdout').read_bytes()==(BASE/'baseline-oracle.txt').read_bytes();assert (CHEAP/'mutant-run-js.stdout').read_bytes()==(CHEAP/'mutant-oracle.txt').read_bytes()
 out=HERE/('native-'+str(time.time_ns()));out.mkdir();stages={};commands=[];files=set(map(Path,cp['files']));files.update([Path(__file__),BACK,CHEAP/'plan.json',CHEAP/'receipt.json',CHEAP/'mutant-run-js.stdout',BASE/'baseline-run-js.stdout'])
 for mode,info in cp['stages'].items():
  source=Path(info['path']);assert B.inventory(source)==info['inventory'];stage=out/mode/'stage';stage.parent.mkdir();shutil.copytree(source,stage);stages[mode]={'path':str(stage),'inventory':B.inventory(stage),'configurationStates':configs(out,stage),'oracle':str(CHEAP/(mode+'-oracle.txt'))};files.add(CHEAP/(mode+'-oracle.txt'));entry=stage/'experiments/public-hierarchy/bend-candidate/full-v1/application.bend';c=stage.parent/'application.c';binary=stage.parent/'application-native';prefix=['taskset','-c','8']
  for phase,argv,cap in [('emit-c',['bend',str(entry),'-o',str(c)],30),('clang',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',str(c),'-pthread','-lm','-o',str(binary)],120),('run-native',[str(binary),'--threads','1','--gpu','off'],5)]:commands.append({'label':mode+'-'+phase,'mode':mode,'phase':phase,'argv':prefix+argv,'seconds':cap})
 env=B.P.configuration()['env'];prepinputs=B.T.Inputs(files=[Path(__file__),BACK,B.TOOL,ROOT/'scripts/owned-tool-pins.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py'],directories=[Path(i['path']) for i in stages.values()]);labels=['prepare-ldd-'+n for n in ['bend','node','python','taskset','clang']];ledger=B.ProbeLedger(out/'prepare-probes',labels,prepinputs,env);tools=B.P.shared.snapshot(**B.owned_configuration(ledger));assert ledger.index==5;files.update(Path(p) for p in ledger.pins());files.update([B.TOOL,ROOT/'scripts/owned-tool-pins.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',ROOT/'.references/sources.json']);files.update(Path(p) for p in tools['pins']);files.update((ROOT/'.references/bend2/bend2').rglob('*.ts'));ef=out/'private-environment.json';ef.write_text(json.dumps(env,sort_keys=True));ef.chmod(0o600)
 plan={'pins':{str(p):sha(p) for p in sorted(files)},'stages':stages,'tools':tools,'privateEnvironment':str(ef),'environmentSHA256':sha(ef),'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+n for i in range(13) for n in ['bend','node','python','taskset','clang']],'scope':'Native only source-current focused actual child-set baseline/reached compiling mismatch-refusal mutant; independent six records/two schemas complete rows graph inverse affine owners/live cells pending and notices. No full46/44/proof/performance acceptance.'};p=out/'plan.json';p.write_text(json.dumps(plan,indent=2,default=B.encode));print(p);print(sha(p))
def run(path):
 path=Path(path).resolve();out=path.parent;p=B.decode(json.loads(path.read_text()));ef=Path(p['privateEnvironment']);assert sha(ef)==p['environmentSHA256'];env=json.loads(ef.read_text());os.environ.clear();os.environ.update(env);dirs=[Path(i['path']) for i in p['stages'].values()];generated={};ledger=B.ProbeLedger(out/'execution-probes',p['executionProbeLabels'],B.T.Inputs(files=[path,*p['pins']],directories=dirs),env)
 def guard():
  assert all(sha(f)==h for f,h in p['pins'].items());assert sha(ef)==p['environmentSHA256'];assert all(sha(f)==h for f,h in generated.items())
  for i in p['stages'].values():stage=Path(i['path']);assert B.inventory(stage)==i['inventory'];assert configs(out,stage)==i['configurationStates']
  B.P.shared.verify(p['tools'],**B.owned_configuration(ledger));ledger.guard()
 guard();logs=B.L.CommandLogs(out,[c['label'] for c in p['commands']]);runner=B.T.Runner(logs,inputs=B.T.Inputs(files=[path,*p['pins']],directories=dirs),env=env,cwd=ROOT);r={'status':'INCOMPLETE','planSHA256':sha(path),'commands':[],'scope':p['scope']}
 try:
  for c in p['commands']:
   guard()
   if '-o' in c['argv']:assert not Path(c['argv'][c['argv'].index('-o')+1]).exists()
   x=runner.run(c['label'],c['argv'],c['seconds']);r['commands'].append({'label':c['label'],'exit':x['exit'],'failure':x['failure']});assert x['exit']==0 and x['failure'] is None
   if '-o' in c['argv']:f=c['argv'][c['argv'].index('-o')+1];generated[f]=sha(f);runner.inputs=B.T.Inputs(files=[path,*p['pins'],*generated],directories=dirs)
   if c['phase']=='run-native':assert x['stdout']==Path(p['stages'][c['mode']]['oracle']).read_bytes()
   guard()
  assert ledger.index==len(p['executionProbeLabels']);r['status']='COMPLETE_SIX_RECORD_SET_BASELINE_REACHED_MUTANT_NATIVE_PASS'
 except BaseException as e:r['error']=str(e);raise
 finally:r['logs']=logs.hashes;r['generated']=generated;r['probePins']=ledger.pins();r['probeCommandsExecuted']=ledger.index;(out/'receipt.json').write_text(json.dumps(r,indent=2));print(out)
a=argparse.ArgumentParser();a.add_argument('--prepare',action='store_true');a.add_argument('--run');v=a.parse_args()
if v.prepare:prepare()
else:run(v.run)
