#!/usr/bin/env python3
"""Common full-field fold; seven rotated fresh worlds and clean child RSS."""
import pathlib,json,os,importlib.util,sys,hashlib,statistics
os.sched_setaffinity(0,{7});H=pathlib.Path(__file__).resolve().parent;R=H.parents[1];ROOT=pathlib.Path('/workspace/formal-proofs/bendvy')
def module(name,path):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
M=module('rss',ROOT/'experiments/s-perf/measure-run.py');B=module('bounded',R/'experiments/t05/run.py');V=module('validator',H/'failure-validate.py')
F=pathlib.Path('/tmp/bendvy-failure-quiet-samples');F.mkdir(exist_ok=True);source=ROOT/'experiments/s-integrate/measurement-samples-rss-launcher.c';launcher=F/'rss-launcher';B.command(['clang','-O2',source,'-o',launcher],timeout=120)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
full=json.loads((H/'failure-quiet-runtime-evidence.json').read_text())['results'];replay=json.loads((H/'failure-quiet-motion1024-replay-evidence.json').read_text())
report={'cpu':7,'repetitions':7,'warmup_fresh_children':1,'runtime_limit_seconds':5,'common_work_shape':'Actual authored callbacks/providers/readers/transactions/barriers, ordered lossless U32 full-record/effect-character codec+fold, one small checksum print immediately before end. No timed finite expected-state guards.','performance_acceptance':False,'scope':'Finite measured evidence; no approved numerical threshold. Fresh child per sample, no exclusive machine reservation; integer Bend milliseconds/fractional TS performance.now. RSS includes actual retained journals/tuple and final serialization.','runner_sha256':sha(pathlib.Path(__file__)),'launcher_source_sha256':sha(source),'launcher_sha256':sha(launcher),'codec_sha256':{p.name:sha(p) for p in [H/'failure-quiet-codec.bend',H/'failure-quiet-codec.mjs']},'cases':[]}
def save():(H/'failure-quiet-samples-evidence.json').write_text(json.dumps(report,indent=2)+'\n')
for idx,schema in enumerate(['Motion','Health']):
 for count in [64,256,1024]:
  case={'schema':schema,'count':count,'samples':{'Native':[],'TS':[],'JS':[]}};report['cases'].append(case)
  entries=[x for x in full if x['schema']==schema and x['count']==count];passed=all(x['status']=='FULL_VALUES_EQUAL' or (x['backend']=='JS' and schema=='Motion' and count==1024 and replay['status']=='FULL_VALUES_EQUAL') for x in entries)
  if not passed:case['status']='FULL_GATE_FAILED';save();continue
  ref=json.loads(B.command(['node',ROOT/'experiments/s-integrate/measurement-reference.mjs',schema,'failed-transaction',str(count)]))
  ts=pathlib.Path('/tmp/bendvy-perf-failure-quiet-fair')/f'{schema}-{count}-TS.txt';expected=json.loads(B.command(['node',H/'failure-quiet-decode.mjs',schema,ts]));expected_data={'events':expected['events'],'effects':expected['effects']}
  commands={'Native':['/tmp/bendvy-perf-failure-quiet-fair/driver-native',str(idx),str(count),'64','--threads','1','--gpu','off'],'JS':['node','/tmp/bendvy-perf-failure-quiet-fair/driver.js',str(idx),str(count),'64'],'TS':['node',H/'failure-quiet-reference.mjs',schema,str(count)]};case['commands']={k:list(map(str,v)) for k,v in commands.items()}
  def run(backend):
   meta,text=M.child(commands[backend],F,launcher)
   if text is not None:
    try:
     decoded=json.loads(B.command(['node',H/'failure-quiet-decode.mjs',schema,F/'child-output.txt']));assert {'events':decoded['events'],'effects':decoded['effects']}==expected_data,'complete actual tuple mismatch'
     counts=decoded['countLine']
     if backend=='TS':
      c=decoded['captures'];counts=json.dumps([{'system':x,'value':{'a':c[x],'b':0,'c':0,'d':0}} for x in ['DisposeTransient','Observe','PublicationObserver','B','A','Seed']],separators=(',',':'))+':'+str(sum(1 for e in decoded['events'] if e['kind']=='FailureResult'))
     raw='FAILURE-TIMING:'+str(int(decoded['elapsed']))+'\n'+'\n'.join(decoded['effects'])+'\n'+'\n'.join('FAILURE-DEFERRED:'+json.dumps(e,separators=(',',':')) for e in decoded['events'])+'\nFAILURE-COUNTS:'+counts
     V.validate(raw,ref);meta.update(innerMilliseconds=decoded['elapsed'],fullFields='FULL_VALUES_EQUAL',actualTupleSHA256=sha(F/'child-output.txt'))
    except Exception as error:meta.update(status='FAIL',error=str(error),stage='full-validation-after-runtime')
   return meta
  case['warmup']={backend:run(backend) for backend in commands};save()
  if not all(x['status']=='PASS' for x in case['warmup'].values()):case['status']='WARMUP_FAILED';save();print(schema,count,case['status'],flush=True);continue
  for repetition in range(7):
   order=['Native','TS','JS'];order=order[repetition%3:]+order[:repetition%3]
   for backend in order:
    row=run(backend);row.update(repetition=repetition+1,backendOrder=order);case['samples'][backend].append(row);save()
  case['status']='MEASURED' if all(len(rows)==7 and all(x['status']=='PASS' for x in rows) for rows in case['samples'].values()) else 'REPETITION_FAILED'
  if case['status']=='MEASURED':
   case['summary']={b:{'innerMilliseconds':{'raw':[x['innerMilliseconds'] for x in rows],'median':statistics.median(x['innerMilliseconds'] for x in rows)},'peakRssKiB':{'raw':[x['peakRssKiB'] for x in rows],'median':statistics.median(x['peakRssKiB'] for x in rows)}} for b,rows in case['samples'].items()}
   med={b:v['innerMilliseconds']['median'] for b,v in case['summary'].items()};case['observedRatios']={'NativeOverTS':med['Native']/med['TS'],'JSOverTS':med['JS']/med['TS']}
  save();print(schema,count,case['status'],flush=True)
