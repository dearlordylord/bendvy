#!/usr/bin/env python3
"""Seven rotated actual Dense/Sparse repetitions, common kernel-reported RSS."""
import hashlib,importlib.util,json,os,pathlib,shutil,signal,statistics,sys,tempfile,time
HERE=pathlib.Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('base',HERE/'measurement-bend-run.py');B=importlib.util.module_from_spec(spec);spec.loader.exec_module(B)
files={};B.closure(HERE/'measurement-samples-bend.bend',files);frozen={n:p.read_bytes() for n,p in files.items()}
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def child(args,folder):
 # Diagnostic only: wait4 RSS inherits a parent floor here; never report it as child peak RSS.
 output=folder/'child-output';fd=os.open(output,os.O_WRONLY|os.O_CREAT|os.O_TRUNC,0o600)
 actions=[(os.POSIX_SPAWN_DUP2,fd,1),(os.POSIX_SPAWN_DUP2,fd,2),(os.POSIX_SPAWN_CLOSE,fd)]
 started=time.monotonic();pid=os.posix_spawnp(str(args[0]),[str(x) for x in args],os.environ.copy(),file_actions=actions,setsid=True);os.close(fd)
 expired=False
 while True:
  done,status,usage=os.wait4(pid,os.WNOHANG)
  if done:break
  if time.monotonic()-started>=5:
   expired=True;os.killpg(pid,signal.SIGKILL);_,status,usage=os.wait4(pid,0);break
  time.sleep(.002)
 elapsed=time.monotonic()-started;value=output.read_text()
 meta={'wholeProcessSeconds':elapsed,'contaminatedWait4RssKiB':usage.ru_maxrss,'exitCode':os.waitstatus_to_exitcode(status),'command':[str(x) for x in args]}
 if expired:return {'status':'FAILED','error':'five-second process-group deadline',**meta},None
 if meta['exitCode']!=0:return {'status':'FAILED','error':value[-2000:],**meta},None
 return {'status':'PASS',**meta},value

def checked(backend,text,schema,sparse,n,batch,ref):
 expected=B.expected(schema,sparse,n)
 if backend=='TS':
  parsed=json.loads(text);samples=[parsed['warmup'],*parsed['samples']];assert len(samples)==batch+1
  for value in samples:
   assert value['status']=='PASS' and value['finalSha256']==ref['finalSha256']
   assert value['worksum']==expected['readsum']
  milliseconds=parsed['milliseconds'];warmup=parsed['warmup']['executionMilliseconds']
 else:
  samples=[B.validate(line,schema,sparse,n,ref) for line in text.splitlines()];assert len(samples)==batch+1
  milliseconds=sum(v['milliseconds'] for v in samples[1:]);warmup=samples[0]['milliseconds']
 assert milliseconds>0,'timer below resolution; no ratio may be reported'
 return {'milliseconds':milliseconds,'millisecondsPerFreshWorld':milliseconds/batch,'warmupMilliseconds':warmup,'freshMeasuredWorlds':batch,'finalSha256':ref['finalSha256'],'worksumPerWorld':expected['readsum']}
def stats(values):return {'min':min(values),'median':statistics.median(values),'max':max(values),'raw':values}
def main():
 os.sched_setaffinity(0,{5})
 result={'scope':'Dense/Sparse actual public/affine authored work; seven repetitions; descriptive ratios only, no numerical acceptance','cpuAffinity':sorted(os.sched_getaffinity(0)),'iterationsPerWorld':64,'warmup':'one fresh identical world per child before measured fresh worlds','batch':'one fresh measured world per child for all counts','clock':'Bend IO.now integer milliseconds, TS performance.now; sum only inner execution intervals','rssMethod':'WITHDRAWN: direct posix_spawn/wait4 inherits observer RSS floor; contaminated raw values retained only for diagnosis','limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'compiler':B.command(['bend','version']).strip(),'clang':B.command(['clang','--version']).splitlines()[0],'node':B.command(['node','--version']).strip(),'compilerSha256':digest(pathlib.Path(shutil.which('bend')).resolve()),'baseSha256':digest(pathlib.Path.home()/'.bend/bend2/base.bend'),'sources':{n:hashlib.sha256(v).hexdigest() for n,v in frozen.items()},'runnerSha256':digest(pathlib.Path(__file__)),'referenceSha256':digest(HERE/'measurement-reference.mjs'),'timingReferenceSha256':digest(HERE/'measurement-samples-reference.mjs'),'contractSha256':digest(HERE/'measurement-samples-plan.md'),'cases':[]}
 def save():(HERE/'measurement-samples-evidence.json').write_text(json.dumps(result,indent=2)+'\n')
 with tempfile.TemporaryDirectory(prefix='measurement-samples-') as tmp:
  root=pathlib.Path(tmp)
  for n,value in frozen.items():(root/n).write_bytes(value)
  bins=B.build(root/'measurement-samples-bend.bend',root)
  for schema,sn in [('Motion',0),('Health',1)]:
   for sparse in [False,True]:
    for n in [64,256,1024]:
     workload='sparse' if sparse else 'dense';batch=1
     ref=json.loads(B.command(['node',HERE/'measurement-reference.mjs',schema,workload,str(n)]))
     commands={'Native':[bins[0],str(sn),str(int(sparse)),str(n),str(batch),'--threads','1','--gpu','off'],'JS':['node',bins[1],str(sn),str(int(sparse)),str(n),str(batch)],'TS':['node',HERE/'measurement-samples-reference.mjs',schema,workload,str(n),str(batch)]}
     case={'schema':schema,'workload':workload,'count':n,'batch':batch,'retainedLiveCount':n,'payloadWidth':4,'finalCommandOccupancy':0,'readers':'not used','verification':{},'samples':{b:[] for b in commands},'summary':{}}
     result['cases'].append(case)
     # Fresh full validation for every backend before any measured repetition.
     for backend,args in commands.items():
      meta,text=child(args,root)
      if text is not None:
       try:meta.update(checked(backend,text,schema,sparse,n,batch,ref))
       except (AssertionError,json.JSONDecodeError) as e:meta={'status':'FAILED','error':str(e),**{k:v for k,v in meta.items() if k!='status'}}
      case['verification'][backend]=meta;save()
     if not all(v['status']=='PASS' for v in case['verification'].values()):
      case['status']='UNVERIFIED';case['reason']='No timing ratios: at least one identical-work verification child failed';save();print(schema,workload,n,'UNVERIFIED',flush=True);continue
     base=['Native','TS','JS']
     for repetition in range(7):
      offset=repetition%3;order=base[offset:]+base[:offset]
      for backend in order:
       meta,text=child(commands[backend],root);meta['repetition']=repetition+1;meta['backendOrder']=order
       if text is not None:
        try:meta.update(checked(backend,text,schema,sparse,n,batch,ref))
        except (AssertionError,json.JSONDecodeError) as e:meta={'status':'FAILED','error':str(e),**{k:v for k,v in meta.items() if k!='status'}}
       case['samples'][backend].append(meta);save()
     complete=all(len(v)==7 and all(s['status']=='PASS' for s in v) for v in case['samples'].values());case['status']='MEASURED' if complete else 'REGRESSION'
     for backend,samples in case['samples'].items():
      if all(v['status']=='PASS' for v in samples):case['summary'][backend]={'milliseconds':stats([v['milliseconds'] for v in samples])}
     if complete:
      med={b:case['summary'][b]['milliseconds']['median'] for b in base};case['ratios']={'Native/TS':med['Native']/med['TS'],'JS/TS':med['JS']/med['TS']}
      case['resolutionLimited']=any(v['milliseconds']<10 for v in case['samples']['Native']);case['acceptance']='none: thresholds unapproved; sub-10ms native samples are resolution-limited' if case['resolutionLimited'] else 'none: thresholds unapproved'
     save();print(schema,workload,n,case['status'],case.get('ratios'),flush=True)
 result['status']='PARTIAL_MEASURED' if any(c['status']=='MEASURED' for c in result['cases']) else 'NO_MEASUREMENTS';save();return 0
if __name__=='__main__':sys.exit(main())
