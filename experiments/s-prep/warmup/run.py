import pathlib,sys,os,json,importlib.util,hashlib
os.sched_setaffinity(0,{7});H=pathlib.Path(__file__).resolve().parent;R=H.parents[2];sys.path.insert(0,str(R/'experiments/t05'));from run import command,execute
T=H/'materialized';F=pathlib.Path('/tmp/bendvy-prep22-warmup');F.mkdir(exist_ok=True)
spec=importlib.util.spec_from_file_location('validator',R/'experiments/s-perf/failure-validate.py');V=importlib.util.module_from_spec(spec);spec.loader.exec_module(V)
report={'source_commit':'56b72f6','cpu':7,'protocol':'same-process fresh warmup owner consumed before distinct fresh measured world; no cross-root handle transfer','limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'build':{},'cases':[]}
def save():(H/'evidence.json').write_text(json.dumps(report,separators=(',',':'))+'\n')
p=T/'overlay/experiments/s-integrate/measurement-failure-driver.bend'
for name,args,limit in [('checker',['bend',p,'--check-only'],5),('c',['bend',p,'-o',F/'driver.c'],30),('native',['clang','-std=c11','-O3',F/'driver.c','-lpthread','-lm','-o',F/'driver-native'],120),('js',['bend',p,'-o',F/'driver.js'],30)]:
 try:report['build'][name]={'status':'PASS','output':command(args,timeout=limit)}
 except Exception as e:report['build'][name]={'status':'FAILED','diagnostic':str(e)};save();raise
 save();print(name,'PASS',flush=True)
for i,schema in enumerate(['Motion','Health']):
 for count in [64,256,1024]:
  original=json.loads(command(['node',R/'experiments/s-integrate/measurement-reference.mjs',schema,'failed-transaction',str(count)]));expected=None
  for backend,prog in [('TS',T/'reference.mjs'),('NativeO3',F/'driver-native'),('JS',F/'driver.js')]:
   row={'schema':schema,'count':count,'backend':backend}
   try:
    out=command(['node',prog,schema,str(count)]) if backend=='TS' else execute(prog,[str(i),str(count),'64']);raw=F/f'{schema}-{count}-{backend}.txt';raw.write_text(out)
    warm=[x for x in out.splitlines() if x.startswith('WARMUP-FOLD:')];assert len(warm)==1,warm
    d=json.loads(command(['node',T/'failure-quiet-decode.mjs',schema,raw]));assert warm[0].split(':')[1]==next(x.split(':')[1] for x in out.splitlines() if x.startswith('FAILURE-FOLD:')),('fresh identical full work warmup fold',d.keys())
    complete={'events':d['events'],'effects':d['effects']}
    if backend=='TS':expected=complete
    else:assert complete==expected,'full actual same-process TS fields/effects'
    counts=d['countLine']
    if backend=='TS':
     order=['DisposeTransient','Observe','PublicationObserver','B','A','Seed'];counts=json.dumps([{'system':n,'value':{'a':d['captures'][n],'b':0,'c':0,'d':0}} for n in order],separators=(',',':'))+':'+str(sum(e['kind']=='FailureResult' for e in d['events']))
    text='FAILURE-TIMING:'+str(int(d['elapsed']))+'\n'+'\n'.join(d['effects'])+'\n'+'\n'.join('FAILURE-DEFERRED:'+json.dumps(e,separators=(',',':')) for e in d['events'])+'\nFAILURE-COUNTS:'+counts
    row.update(status='FULL_VALUES_EQUAL',validation=V.validate(text,original)['validation'],warmup_fold=warm[0],raw_sha256=hashlib.sha256(raw.read_bytes()).hexdigest(),elapsed=d['elapsed'])
   except Exception as e:row.update(status='FAILED_OR_UNRESOLVED',diagnostic=str(e))
   report['cases'].append(row);save();print(schema,count,backend,row['status'],flush=True)
report['artifacts']={x.name:hashlib.sha256(x.read_bytes()).hexdigest() for x in F.glob('driver*')};save()
