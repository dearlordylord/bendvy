#!/usr/bin/env python3
"""Fresh actual compact tuple/full-field gates, separate from timing acceptance."""
import pathlib,json,os,sys,importlib.util,hashlib
os.sched_setaffinity(0,{7});H=pathlib.Path(__file__).resolve().parent;R=H.parents[1];sys.path.insert(0,str(R/'experiments/t05'));from run import command,execute
s=importlib.util.spec_from_file_location('full',H/'failure-validate.py');V=importlib.util.module_from_spec(s);s.loader.exec_module(V)
F=pathlib.Path('/tmp/bendvy-perf-failure-quiet-fair');F.mkdir(exist_ok=True)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
report={'cpu':7,'runtime_limit':5,'ratio_acceptance':False,'source_sha256':{str(p.relative_to(R)):sha(p) for p in sorted((H/'failure-quiet-overlay').rglob('*.bend'))},'codec_sha256':{p.name:sha(p) for p in [H/'failure-quiet-codec.bend',H/'failure-quiet-codec.mjs']},'results':[]}
def save():(H/'failure-quiet-runtime-evidence.json').write_text(json.dumps(report,separators=(',',':'))+'\n')
for idx,schema in enumerate(['Motion','Health']):
 for count in [64,256,1024]:
  ref=json.loads(command(['node','/workspace/formal-proofs/bendvy/experiments/s-integrate/measurement-reference.mjs',schema,'failed-transaction',str(count)]));expected=None
  for backend,program in [('TS',H/'failure-quiet-reference.mjs'),('NativeO3',F/'driver-native'),('JS',F/'driver.js')]:
   case={'schema':schema,'count':count,'backend':backend}
   try:
    out=command(['node',program,schema,str(count)]) if backend=='TS' else execute(program,[str(idx),str(count),'64']);path=F/f'{schema}-{count}-{backend}.txt';path.write_text(out)
    decoded=json.loads(command(['node',H/'failure-quiet-decode.mjs',schema,path]));events=decoded['events'];effects=decoded['effects']
    complete={'events':events,'effects':effects}
    if backend=='TS':expected=complete
    else:assert complete==expected,('complete actual TS/Bend tuple mismatch',schema,count,backend)
    # Registry completion is actual retained owner observation for Bend; TS actual callback counters map to the same fixture cells.
    captures=decoded['captures'];countline=decoded['countLine']
    if backend=='TS':
     order=['DisposeTransient','Observe','PublicationObserver','B','A','Seed'];counts=[{'system':x,'value':{'a':captures[x],'b':0,'c':0,'d':0}} for x in order]
     frames=sum(1 for e in events if e['kind']=='FailureResult');countline=json.dumps(counts,separators=(',',':'))+':'+str(frames)
    raw='FAILURE-TIMING:'+str(int(decoded['elapsed']))+'\n'+'\n'.join(effects)+'\n'+'\n'.join('FAILURE-DEFERRED:'+json.dumps(x,separators=(',',':')) for x in events)+'\nFAILURE-COUNTS:'+countline
    full=V.validate(raw,ref)
    if count in [64,256]:
     previous=pathlib.Path('/tmp/bendvy-perf-failure-indexed')/f'{schema}-{count}-NativeO3.txt'
     if previous.exists():assert full['validation']==V.validate(previous.read_text(),ref)['validation'],('existing full actual diagnostic',schema,count)
    case.update(status='FULL_VALUES_EQUAL',elapsed_milliseconds_diagnostic=decoded['elapsed'],full_validation=full['validation'],tuple_file_sha256=sha(path))
   except Exception as error:case.update(status='FAILED_OR_UNRESOLVED',diagnostic=str(error))
   report['results'].append(case);save();print(schema,count,backend,case['status'],flush=True)
assert report['source_sha256']=={str(p.relative_to(R)):sha(p) for p in sorted((H/'failure-quiet-overlay').rglob('*.bend'))},'subject changed during gate'
