#!/usr/bin/env python3
"""Source-bound development checker/primary-reference preflight; no Native gate."""
import argparse,gzip,hashlib,importlib.util,json,os,pathlib,sys
ROOT=pathlib.Path(__file__).resolve().parents[2];HERE=pathlib.Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--cpu',type=int,default=7);a=p.parse_args()
OUT=a.output.resolve();assert not OUT.exists();OUT.mkdir()
sys.path.insert(0,str(ROOT/'scripts'));import task_runner
spec=importlib.util.spec_from_file_location('tools',ROOT/'benchmarks/parity-features/tool-pins.py');tools=importlib.util.module_from_spec(spec);spec.loader.exec_module(tools)
def sha(p):return hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
def inventory():
 paths=list((ROOT/'src/ecs').rglob('*'))+list(HERE.glob('*.bend'))+list(HERE.glob('*.mjs'))
 paths += [pathlib.Path(__file__).resolve(),HERE/'expected.json',HERE/'semantic-plan.md',ROOT/'.references/sources.json',ROOT/'scripts/task_runner.py',ROOT/'benchmarks/parity-features/tool-pins.py']
 return {str(p):sha(p) for p in sorted(set(paths)) if p.is_file()}
def external():return {str(p):sha(p) for p in sorted((ROOT/'.references/bevy-ts/packages/core/src').rglob('*')) if p.is_file()}
PINS=inventory();EXT=external();INSTALLED=tools.snapshot();INSTALLED['environment']['CPU']=a.cpu
r={'status':'INCOMPLETE','sources':PINS,'external':EXT,'installedTools':INSTALLED,'commands':[],'artifacts':{},'cpu':a.cpu,'scope':'Development checker and finite actual TS trace only; no Bend execution, feature completion, law/proof, Native or performance acceptance','coreBendCount':len(list((ROOT/'src/ecs').rglob('*.bend')))}
def guard():
 assert inventory()==PINS,'source inventory drift';assert external()==EXT,'reference inventory drift';tools.verify(INSTALLED)
 assert all(sha(OUT/n)==h for n,h in r['artifacts'].items()),'artifact drift'
def run(label,args,success=True,seams=()):
 guard();assert not (OUT/(label+'.stdout.gz')).exists();assert not (OUT/(label+'.stderr')).exists()
 q=task_runner.execute_result(['taskset','-c',str(a.cpu),*map(str,args)],5,dict(os.environ,BEND_NO_TELEMETRY='1'),capture='split')
 with gzip.open(OUT/(label+'.stdout.gz'),'wb') as f:f.write(q['stdout'])
 (OUT/(label+'.stderr')).write_bytes(q['stderr'])
 for suffix in ['.stdout.gz','.stderr']:r['artifacts'][label+suffix]=sha(OUT/(label+suffix))
 diagnostic=(q['stdout']+q['stderr']).decode(errors='replace')
 r['commands'].append({'label':label,'command':list(map(str,args)),'capSeconds':5,'exit':q['exit'],'failure':q['failure'],'runnerSHA256':q['runnerSHA256'],'expectedSuccess':success,'expectedDiagnosticSeams':list(seams)})
 assert q['failure'] is None,(label,q['failure'])
 assert (q['exit']==0)==success,(label,q['exit'],diagnostic)
 assert q['exit'] not in (124,137),'timeout is not a negative pass'
 assert all(s in diagnostic for s in seams),(label,diagnostic)
 if not success:
  assert 'expected :' in diagnostic and 'observed :' in diagnostic and 'Location:' in diagnostic,(label,diagnostic)
  assert not any(s in diagnostic.lower() for s in ['parse error','unknown name','unknown definition','unfilled hole']),(label,diagnostic)
 guard();return q['stdout']
try:
 run('version',['bend','version']);run('guide',['bend','guide'])
 manifest=json.loads((ROOT/'.references/sources.json').read_text())['sources']
 for name,known in manifest.items():assert run('head-'+name,['git','-C',ROOT/'.references'/name,'rev-parse','HEAD']).decode().strip()==known['commit']
 complete=json.loads(run('full-reference',['node',HERE/'reference.mjs']))
 assert complete==json.loads((HERE/'expected.json').read_text()),'complete original reference changed'
 observed=json.loads(run('probe-reference',['node',HERE/'probe-reference.mjs']))
 assert observed['applications'][0]['observations']==observed['applications'][1]['observations']
 assert len(observed['applications'][0]['observations'])==9
 (OUT/'probe-observed.json').write_text(json.dumps(observed,indent=2)+'\n');r['artifacts']['probe-observed.json']=sha(OUT/'probe-observed.json')
 for name in ['typecheck','probe','access','condition-controls','reader-controls']:run(name,['bend',HERE/(name+'.bend'),'--check-only'])
 controls={'negative-write-read':['ValueRead','ValueWrite'],'negative-pending-through-read':['ValueRead','ValueWrite'],'negative-undeclared-read':['FlowToken','LevelToken'],'negative-cross-schema':['SchemaA','SchemaB'],'negative-undeclared':['Frame','H'],'negative-reconstruct':['Frame','H'],'negative-owner-duplicate':['consumed more than once'],'negative-reader-schema':['SchemaA','SchemaB'],'negative-reader-duplicate':['consumed more than once'],'negative-transition-write':['ValueRead','ValueWrite'],'negative-undeclared-transition':['FlowToken','LevelToken'],'negative-reader-instance-duplicate':['consumed more than once']}
 for name,seams in controls.items():run(name,['bend',HERE/(name+'.bend'),'--check-only'],False,seams)
 guard();r['status']='DEVELOPMENT_CHECKER_AND_PRIMARY_TRACE_PASS'
finally:(OUT/'receipt.json').write_text(json.dumps(r,indent=2)+'\n')
print(r['status'])
