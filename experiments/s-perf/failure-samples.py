#!/usr/bin/env python3
"""Rotated diagnostic timings/RSS; explicitly not equivalent-work speed ratios."""
import pathlib,json,os,hashlib,importlib.util,statistics
os.sched_setaffinity(0,{7});H=pathlib.Path(__file__).resolve().parent;R=H.parents[1];ROOT=pathlib.Path('/workspace/formal-proofs/bendvy')
def module(name,path):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
M=module('clean_rss',ROOT/'experiments/s-perf/measure-run.py');B=module('bounded',R/'experiments/t05/run.py');V=module('full_validator',H/'failure-validate.py')
F=pathlib.Path('/tmp/bendvy-failure-samples');F.mkdir(exist_ok=True);launcher=F/'rss-launcher';source=ROOT/'experiments/s-integrate/measurement-samples-rss-launcher.c';B.command(['clang','-O2',source,'-o',launcher],timeout=120)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
report={'cpu':7,'repetitions':7,'runtime_limit_seconds':5,'ratio_acceptance':False,'scope':'Diagnostic inner durations only: extra Bend service/clock forcing and Audit representation remain unmatched; complete value gates required. RSS includes retained full diagnostic journals and final serialization.','runner_sha256':sha(pathlib.Path(__file__)),'rss_launcher_source_sha256':sha(source),'rss_launcher_sha256':sha(launcher),'manifest':json.loads((H/'failure-indexed-manifest.json').read_text()),'cases':[]}
def save():(H/'failure-samples-evidence.json').write_text(json.dumps(report,indent=2)+'\n')
full=json.loads((H/'failure-indexed-runtime-evidence.json').read_text())['results']
for idx,schema in enumerate(['Motion','Health']):
 for count in [64,256,1024]:
  case={'schema':schema,'count':count,'samples':{'Native':[],'TS':[],'JS':[]}};report['cases'].append(case)
  passed=all(next(x for x in full if x['schema']==schema and x['count']==count and x['backend']==backend)['status']=='FULL_VALUES_EQUAL' for backend in ['NativeO3','JS'])
  if not passed:case['status']='FULL_RUNTIME_GATE_FAILED_NO_SAMPLES';save();continue
  ref=json.loads(B.command(['node',ROOT/'experiments/s-integrate/measurement-reference.mjs',schema,'failed-transaction',str(count)]))
  commands={'Native':['/tmp/bendvy-perf-failure-indexed/driver-native',str(idx),str(count),'64','--threads','1','--gpu','off'],'JS':['node','/tmp/bendvy-perf-failure-indexed/driver.js',str(idx),str(count),'64'],'TS':['node',H/'failure-reference-timing.mjs',schema,str(count)]}
  def run(backend):
   meta,text=M.child(commands[backend],F,launcher)
   if text is not None:
    try:
     if backend=='TS':
      actual=json.loads(text);meta['innerMilliseconds']=actual.pop('innerMs');actual.pop('experimentalAlignment');actual.pop('peakRssKiB');want=dict(ref);want.pop('peakRssKiB');assert actual==want
     else:checked=V.validate(text,ref);meta['innerMilliseconds']=checked['transport']['elapsed_milliseconds_diagnostic']
    except Exception as error:meta.update(status='FAIL',error=str(error))
   return meta
  case['warmup']={backend:run(backend) for backend in commands};save()
  if not all(x['status']=='PASS' for x in case['warmup'].values()):case['status']='WARMUP_FAILED';save();continue
  for rep in range(7):
   order=['Native','TS','JS'];order=order[rep%3:]+order[:rep%3]
   for backend in order:
    row=run(backend);row.update(repetition=rep+1,backendOrder=order);case['samples'][backend].append(row);save()
  case['status']='DIAGNOSTIC_SAMPLES_COMPLETE' if all(len(rows)==7 and all(x['status']=='PASS' for x in rows) for rows in case['samples'].values()) else 'REPETITION_FAILED';save();print(schema,count,case['status'],flush=True)
