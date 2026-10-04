#!/usr/bin/env python3
"""Fresh TS/Native/JS full failed workload correctness; no timing acceptance."""
import pathlib,sys,re,hashlib,json,importlib.util,time
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parent.parent
sys.path.insert(0,str(HERE.parent/'t05'))
from run import command,execute
spec=importlib.util.spec_from_file_location('oracle',HERE/'measurement-failure-oracle.py');O=importlib.util.module_from_spec(spec);spec.loader.exec_module(O)
FOLDER=pathlib.Path('/tmp/bendvy-measurement-failure')

def closure(p,seen):
 if p in seen:return
 seen.add(p)
 for ref in re.findall(r'^import (\./\S+\.bend)',p.read_text(),re.M):closure((p.parent/ref).resolve(),seen)
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
files=set();closure((HERE/'measurement-failure-driver.bend').resolve(),files)
pins={str(p.relative_to(ROOT)):digest(p) for p in files}
report={'status':'RUNNING','scope':'exact frozen dynamic failed-transaction; all actual public/fullfield observations; Native -O0 correctness-only; no numeric/RSS/performance claim','limits_seconds':{'checker':5,'runtime_each':5,'reference_each':5,'codegen':30,'clang':120},'compiler':command(['bend','version']).strip(),'source_sha256':pins,'oracle_sha256':digest(HERE/'measurement-failure-oracle.py'),'results':[],'failures':[]}
# Build command is a separate existing phase, explicitly bounded internally.
for schema_index,schema in enumerate(['Motion','Health']):
 for count in [64,256,1024]:
  case={'schema':schema,'count':count,'iterations':64};started=time.monotonic()
  try:
   ref_path=pathlib.Path('/workspace/formal-proofs/bendvy/experiments/s-integrate/measurement-reference.mjs')
   assert digest(ref_path)==digest(HERE/'measurement-reference.mjs'),'reference adapter differs from frozen local subject'
   reference=json.loads(command(['node',ref_path,schema,'failed-transaction',str(count)]))
   (FOLDER/f'{schema}-{count}-reference.json').write_text(json.dumps(reference)+'\n')
   outputs=[]
   for platform,path in [('native',FOLDER/'driver-native'),('javascript',FOLDER/'driver.js')]:
    output=execute(path,[str(schema_index),str(count),'64']);outputs.append(output);(FOLDER/f'{schema}-{count}-{platform}.txt').write_text(output)
   assert outputs[0]==outputs[1], 'complete Native/JS output differs'
   validated=O.validate(outputs[0],reference)
   assert pins=={str(p.relative_to(ROOT)):digest(p) for p in files},'frozen source changed during execution'
   validated['fresh_reference_sha256']=digest(FOLDER/f'{schema}-{count}-reference.json')
   validated['fresh_reference_adapter_sha256']=digest(ref_path)
   validated['execution_and_validation_elapsed_seconds_diagnostic']=round(time.monotonic()-started,3)
   report['results'].append(validated);print(schema,str(count),'FULL VALUES PASS',flush=True)
  except Exception as exc:
   case.update({'status':'FAILED_OR_UNRESOLVED','diagnostic':str(exc),'elapsed_seconds_diagnostic':round(time.monotonic()-started,3)});report['failures'].append(case);print(schema,str(count),case['diagnostic'],flush=True)
  (HERE/'measurement-failure-evidence.json').write_text(json.dumps(report,indent=2)+'\n')
report['status']='FULL_CORRECTNESS_PASS' if len(report['results'])==6 and not report['failures'] else 'PARTIAL_OR_BLOCKED'
(HERE/'measurement-failure-evidence.json').write_text(json.dumps(report,indent=2)+'\n')
print(report['status'])
raise SystemExit(0 if report['status']=='FULL_CORRECTNESS_PASS' else 1)
