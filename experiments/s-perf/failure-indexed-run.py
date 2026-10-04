#!/usr/bin/env python3
"""Fresh full values gate for deferred diagnostic transport, not timing acceptance."""
import pathlib,sys,json,os,importlib.util,hashlib
os.sched_setaffinity(0,{7});H=pathlib.Path(__file__).resolve().parent;R=H.parents[1];sys.path.insert(0,str(R/'experiments/t05'));from run import command,execute
spec=importlib.util.spec_from_file_location('deferred',H/'failure-validate.py');V=importlib.util.module_from_spec(spec);spec.loader.exec_module(V)
F=pathlib.Path('/tmp/bendvy-perf-failure-indexed');report={'cpu':7,'limits_seconds':{'runtime':5,'reference':5},'status':'RUNNING','results':[],'timing_acceptance':False}
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
subjects={str(p.relative_to(R)):digest(p) for p in sorted((H/'failure-indexed-overlay').rglob('*.bend'))};subjects.update({str(p.relative_to(R)):digest(p) for p in [H/'failure-indexed-checks.bend',H/'failure-indexed-service-guard.bend']});report['source_sha256']=subjects;report['artifact_sha256']={p.name:digest(p) for p in F.glob('driver*') if p.is_file()};report['baseline']='a976667 + frozen indexed-final2 IO overlay';report['measurement_status']='Diagnostic inner durations only; aligned TS forcing/checksum and repetitions pending'
freeze=json.loads((H/'failure-freeze.json').read_text());reference_path=pathlib.Path('/workspace/formal-proofs/bendvy/experiments/s-integrate/measurement-reference.mjs');assert digest(reference_path)==freeze['authoritative_artifacts']['experiments/s-integrate/measurement-reference.mjs'],'frozen TS adapter changed'
original=json.loads((R/'experiments/s-integrate/measurement-failure-evidence.json').read_text())['results']
for idx,schema in enumerate(['Motion','Health']):
 for count in [64,256,1024]:
  for backend,program in [('NativeO3',F/'driver-native'),('JS',F/'driver.js')]:
   case={'schema':schema,'count':count,'iterations':64,'backend':backend}
   try:
    out=execute(program,[str(idx),str(count),'64']);(F/f'{schema}-{count}-{backend}.txt').write_text(out)
    ref=json.loads(command(['node','/workspace/formal-proofs/bendvy/experiments/s-integrate/measurement-reference.mjs',schema,'failed-transaction',str(count)]));result=V.validate(out,ref)
    if count==64:
     prior=next(x for x in original if x['schema']==schema)
     for key in ['audit','captures','reservations','actual_reads','actual_effects']:assert result['validation'][key]==prior[key],('existing full actual diagnostics',key)
    case.update(status='FULL_VALUES_EQUAL',result=result)
   except Exception as e:case.update(status='FAILED_OR_UNRESOLVED',diagnostic=str(e))
   report['results'].append(case);(H/'failure-indexed-runtime-evidence.json').write_text(json.dumps(report,indent=2)+'\n');print(schema,count,backend,case['status'],flush=True)
assert subjects=={str(p.relative_to(R)):digest(p) for p in sorted((H/'failure-indexed-overlay').rglob('*.bend'))}|{str(p.relative_to(R)):digest(p) for p in [H/'failure-indexed-checks.bend',H/'failure-indexed-service-guard.bend']},'source changed during run'
report['status']='BOUNDED_ATTEMPTS_COMPLETE';(H/'failure-indexed-runtime-evidence.json').write_text(json.dumps(report,indent=2)+'\n')
