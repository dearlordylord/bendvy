"""Capture candidate: source-bound scale1 full-app CPU/collected-allocation diagnostics, not timing acceptance."""
from pathlib import Path
import argparse,hashlib,importlib.util,json,os,sys
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
sys.path.insert(0,str(ROOT/'scripts'));import task_runner
spec=importlib.util.spec_from_file_location('profile_logs',ROOT/'scripts/receipt-logs.py');logmodule=importlib.util.module_from_spec(spec);spec.loader.exec_module(logmodule)
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m

def main():
 p=argparse.ArgumentParser();p.add_argument('--stage',type=Path,required=True);p.add_argument('--semantic-receipt',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--cpu',type=int,default=11);a=p.parse_args();a.stage=a.stage.resolve();a.semantic_receipt=a.semantic_receipt.resolve();a.output=a.output.resolve();assert not a.output.exists();assert a.cpu in os.sched_getaffinity(0)
 semantic=json.loads(a.semantic_receipt.read_text());assert semantic['status']=='COMPLETE_CAPTURE_APPLICATION_SEMANTICS_PASS';assert len(semantic['commands'])==10 and all(c['status']=='PASS' and c['exit']==0 and c['failure'] is None for c in semantic['commands']);stage_receipt=a.stage/'stage.json';staged=json.loads(stage_receipt.read_text());assert sha(stage_receipt)==semantic['stage_sha256'];tree=a.stage/'stage';app=tree/'experiments/public-relations/promotion-stage/application/next-version/v1';generated=a.semantic_receipt.parent/'relations-1.js';assert sha(generated)==semantic['targets']['relations-1.js'];assert semantic['cpu']==a.cpu
 env=dict(os.environ,BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root',BEND_NO_TELEMETRY='1');env['LD_LIBRARY_PATH']=':'.join(['/tmp/bendvy-clang19-diagnostic/root/usr/lib/aarch64-linux-gnu','/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/lib','/home/node/.local/opt/dnd-clang14/usr/lib/aarch64-linux-gnu'])
 digest=hashlib.sha256(json.dumps(env,sort_keys=True,separators=(',', ':'),ensure_ascii=True).encode()).hexdigest();assert digest==semantic['tools']['environment_sha256'],'execution environment differs from current semantic receipt'
 tool_pin=load('profile_tool_pin',ROOT/'scripts/owned-tool-pins.py')
 tool_cfg=dict(execute=task_runner.execute_result,tools=semantic['tools']['tools'],resource_roots=semantic['tools']['resource_roots'],ldd=semantic['tools']['ldd'],taskset=semantic['tools']['taskset'],cpu=a.cpu,env=env,skip_ldd=semantic['tools']['skip_ldd'],capture_mode=semantic['tools']['capture_mode'])
 def baseline_guard():
  for name,h in staged['sources'].items():assert sha(ROOT/name)==h,('live source differs from admitted baseline',name)
  inventory={str(path.relative_to(tree)):sha(path) for path in sorted(tree.rglob('*')) if path.is_file()}
  assert inventory==staged['stage_inventory'],'current stage differs from admitted baseline'
  for name,h in semantic['config'].items():assert (sha(Path(name)) if Path(name).is_file() else None)==h
  assert tool_pin.snapshot(**tool_cfg)['pins']==semantic['tools']['pins'],'installed tools differ from admitted semantic baseline'
 baseline_guard()
 a.output.mkdir(parents=True);expected=json.loads((app/'expected.json').read_text());validator=load('profile_validator',app/'validate.py')
 labels=['node-version',*[f'{role}-{mode}' for role in ['JS','TS'] for mode in ['cpu','heap']]]
 logs=logmodule.CommandLogs(a.output,labels)
 files=[Path(__file__),ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',a.semantic_receipt,stage_receipt,generated,*[ROOT/n for n in staged['sources']],*[Path(n) for n in semantic['tools']['pins']],*[Path(n) for n in semantic['git_metadata']]]
 inputs=task_runner.Inputs(files=files,directories=[tree,ROOT/'.references/bevy-ts/packages/core/src'])
 runner=task_runner.Runner(logs,inputs=inputs,env=env,capture='split')
 receipt={'status':'INCOMPLETE','semantic_receipt_sha256':sha(a.semantic_receipt),'stage_sha256':sha(stage_receipt),'generated_sha256':sha(generated),'profile_runner_sha256':sha(Path(__file__)),'central_runner_sha256':sha(ROOT/'scripts/task_runner.py'),'iterations':20,'cpu':a.cpu,'inputs':inputs.expected,'commands':[],'runs':{},'scope':'Diagnostic attribution includes output flush and20ms GC-observer drain, unlike operation-region timing. Exploratory complete20 fresh registered lifecycles per role/profile,600 full records; original shared plus Bend physical-owner validation. Collected-object allocation sampling, not physical/RSS totals or performance acceptance. Static imports/declarations initialized before profiling; no owners cached.'}
 wrappers={};profiles={}
 source=generated.read_text();trailer='cli(process.argv.slice(1));\nio_exit($main$, null);';assert source.count(trailer)==1;assert source.count('$repeat$(1)')==1
 body=source.replace(trailer,'cli(process.argv.slice(1));').replace('$repeat$(1)','$repeat$(20)')
 receipt['generated_adaptation']={'exact_trailer_count':1,'exact_fuel_anchor_count':1,'changes':'Only checked repeat fuel1->20 and move terminal io_exit invocation after profiler start; all application/helper/timer bodies unchanged. Full output controls bind every lifecycle.'}
 head="""import inspector from 'node:inspector';
import {createRequire} from 'node:module';
import {PerformanceObserver} from 'node:perf_hooks';
import fs from 'node:fs';
const require=createRequire(import.meta.url);
const profSession=new inspector.Session();profSession.connect();
const profGc=[];const profObserver=new PerformanceObserver(list=>{for(const entry of list.getEntries())profGc.push({duration:entry.duration,kind:entry.detail.kind});});profObserver.observe({entryTypes:['gc']});
const profPost=(method,params={})=>new Promise((resolve,reject)=>profSession.post(method,params,(error,result)=>error?reject(error):resolve(result)));
const profExit=process.exit;let profZero=0;process.exit=code=>{if(code!==0)throw Error('nonzero application exit:'+code);profZero++;};
"""
 for role in ['JS','TS']:
  declaration=body if role=='JS' else f"import {{run}} from {json.dumps((app/'reference-callable.mjs').as_uri())};\nimport {{timed}} from {json.dumps((tree/'experiments/public-relations/timing/capture.mjs').as_uri())};\n"
  invocation='io_exit($main$, null);' if role=='JS' else 'await timed(async()=>{for(let i=0;i<20;i++)run();});'
  for mode in ['cpu','heap']:
   name=f'{role}-{mode}';profile=a.output/(name+'.profile.json');wrapper=a.output/(name+'.mjs');assert not wrapper.exists() and not profile.exists()
   start="await profPost('Profiler.enable');await profPost('Profiler.setSamplingInterval',{interval:100});await profPost('Profiler.start');" if mode=='cpu' else "await profPost('HeapProfiler.enable');await profPost('HeapProfiler.startSampling',{samplingInterval:16384,includeObjectsCollectedByMajorGC:true,includeObjectsCollectedByMinorGC:true});"
   stop="const profResult=await profPost('Profiler.stop');" if mode=='cpu' else "const profResult=await profPost('HeapProfiler.stopSampling');"
   tail=f"\n{start}\n{invocation}\nawait new Promise(resolve=>setTimeout(resolve,20));\n{stop}\nfs.writeFileSync({json.dumps(str(profile))},JSON.stringify(profResult.profile));profObserver.disconnect();profSession.disconnect();process.exit=profExit;process.stderr.write('PROFILE_AUDIT='+JSON.stringify({{zeroExits:profZero,gc:profGc}})+'\\n');\n"
   wrappers[name]=(wrapper,(head+declaration+tail).encode());profiles[name]=profile
 for name,(wrapper,content) in wrappers.items():wrapper.write_bytes(content)
 wrapper_pins={str(path):sha(path) for path,_ in wrappers.values()};receipt['prospective_wrappers']=wrapper_pins;receipt['prospective_profiles']={name:str(path) for name,path in profiles.items()}
 profile_pins={}
 def guard():
  baseline_guard();inputs.guard();logs.guard()
  for name,h in wrapper_pins.items():assert sha(Path(name))==h
  for name,h in semantic['config'].items():assert (sha(Path(name)) if Path(name).is_file() else None)==h
  assert {p.name for p in a.output.glob('*.profile.json')}==set(profile_pins)
  for name,h in profile_pins.items():assert sha(a.output/name)==h
 def save():(a.output/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
 try:
  guard();result=runner.run('node-version',['taskset','-c',str(a.cpu),'node','--version'],5);receipt['commands'].append({'label':'node-version','exit':result['exit'],'runner_sha256':result['runnerSHA256']});receipt['node_version']=result['stdout'].decode().strip();save()
  for name,(wrapper,content) in wrappers.items():
   guard();profile=profiles[name];assert not profile.exists();attempt={'label':name,'argv':['taskset','-c',str(a.cpu),'node',str(wrapper)],'limit_seconds':5,'status':'INCOMPLETE'};receipt['commands'].append(attempt);save()
   result=runner.run(name,attempt['argv'],5,expected=None)
   if profile.is_file():profile_pins[profile.name]=sha(profile)
   attempt.update(exit=result['exit'],failure=result['failure'],runner_sha256=result['runnerSHA256']);save();assert result['exit']==0 and result['failure'] is None
   stderr=result['stderr'].decode();metadata,audit_line=stderr.split('PROFILE_AUDIT=');transport=json.loads(metadata);audit=json.loads(audit_line);raw=result['stdout'];assert transport['bytes']==len(raw)
   value=2166136261
   for byte in raw:value=((value^byte)*16777619)&4294967295
   assert transport['digest']==value
   role,mode=name.split('-');assert audit['zeroExits']==(1 if role=='JS' else 0)
   if role=='TS':assert [json.loads(line) for line in raw.splitlines()]==expected*20
   else:
    chunks=raw.decode().split('Workshop\n');assert chunks[0]=='' and len(chunks)==21
    for chunk in chunks[1:]:
     shared,physical,witness=validator.validate('Workshop\n'+chunk);assert shared==expected and len(physical)==30 and not witness
   data=json.loads(profile.read_text());assert data.get('nodes') if mode=='cpu' else data.get('head') and data.get('samples')
   attempt['status']='FULL_OUTPUT_VALIDATED';receipt['runs'][name]={'profile_sha256':profile_pins[profile.name],'wrapper_sha256':wrapper_pins[str(wrapper)],'validated_records':600,'audit':audit,'transport':transport};guard();save()
  receipt['status']='COMPLETE_CPU_ALLOCATION_DIAGNOSTICS_PASS_NO_VERDICT'
 except Exception as error:
  receipt['error_type']=type(error).__name__
  if hasattr(error,'result'):
   result=error.result;receipt['failure_result']={'exit':result['exit'],'failure':result['failure'],'runner_sha256':result['runnerSHA256']}
  raise
 finally:receipt['raw_logs']=logs.hashes;save()
 guard()
if __name__=='__main__':main()
