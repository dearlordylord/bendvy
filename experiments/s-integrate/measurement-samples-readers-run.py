#!/usr/bin/env python3
"""Seven rotated actual Dense/Sparse repetitions, common kernel-reported RSS."""
import hashlib,importlib.util,json,os,pathlib,shutil,signal,statistics,sys,tempfile,time
HERE=pathlib.Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('base',HERE/'measurement-bend-run.py');B=importlib.util.module_from_spec(spec);spec.loader.exec_module(B)
spec=importlib.util.spec_from_file_location('readers',HERE/'measurement-readers-run.py');Q=importlib.util.module_from_spec(spec);spec.loader.exec_module(Q)
files={};B.closure(HERE/'measurement-samples-readers.bend',files);frozen={n:p.read_bytes() for n,p in files.items()}
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

def ts_rows(schema,n,i,phase):
 rows=[{'id':j+1,'main':B.payload(schema,j,0),'aux':B.auxiliary(schema) if j%3==0 else None,'flag':{'group':8} if j%3==1 else None} for j in range(n)]
 if phase=='read':rows.append({'id':n+i+1,'main':B.payload(schema,i,1),'aux':None,'flag':None})
 return Q.L.norm(rows,schema)
def checked(backend,text,schema,n,ref):
 if backend=='TS':
  parsed=json.loads(text);samples=[parsed['warmup'],parsed['sample']]
  for sample in samples:
   assert sample['status']=='PASS' and sample['finalSha256']==ref['finalSha256']
   assert sample['diagnostics']==ref['diagnostics']
   assert len(sample['audit'])==84
   for actual,want in zip(sample['audit'],ref['audit']):
    rows=ts_rows(schema,n,want['iteration'],want['phase'])
    expected={'who':want['who'],'phase':want['phase'],'iteration':want['iteration'],'rows':rows,'added':[r for r in rows if r['rawId'] in want['added']],'changed':[r for r in rows if r['rawId'] in want['changed']],'removed':want['removed'],'despawned':want['despawned'],'messages':want['messages'],'lagged':False}
    assert actual==expected,('full TS reader observation',want['who'],want['iteration'])
   assert sample['final']=={'rows':ts_rows(schema,n,63,'drain'),'ledger':{'totals':[0,101,102,103],'epoch':4}}
  warmup,milliseconds=[v['executionMilliseconds'] for v in samples]
 else:
  lines=text.splitlines();assert len(lines)==470,len(lines)
  for offset in [0,235]:Q.validate('\n'.join(lines[offset:offset+234]),schema,n,ref)
  warmup=json.loads(lines[234])['timingMilliseconds'];milliseconds=json.loads(lines[469])['timingMilliseconds']
 assert milliseconds>0,'timer below resolution; no ratio may be reported'
 return {'milliseconds':milliseconds,'warmupMilliseconds':warmup,'freshMeasuredWorlds':1,'fullReadObservationsPerWorld':84,'finalSha256':ref['finalSha256']}
def stats(values):return {'min':min(values),'median':statistics.median(values),'max':max(values),'raw':values}
def main():
 os.sched_setaffinity(0,{5})
 result={'scope':'Readers actual dispatcher/affine updates; 64 iterations and retained full event batches; seven repetitions; no acceptance','cpuAffinity':sorted(os.sched_getaffinity(0)),'iterationsPerWorld':64,'warmup':'one fresh identical world per child before measured fresh worlds','batch':'one fresh measured world per child for all counts','clock':'Bend IO.now integer milliseconds, TS performance.now; sum only inner execution intervals','rssMethod':'WITHDRAWN: direct posix_spawn/wait4 inherits observer RSS floor; contaminated raw values retained only for diagnosis','limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'compiler':B.command(['bend','version']).strip(),'clang':B.command(['clang','--version']).splitlines()[0],'node':B.command(['node','--version']).strip(),'compilerSha256':digest(pathlib.Path(shutil.which('bend')).resolve()),'baseSha256':digest(pathlib.Path.home()/'.bend/bend2/base.bend'),'sources':{n:hashlib.sha256(v).hexdigest() for n,v in frozen.items()},'runnerSha256':digest(pathlib.Path(__file__)),'referenceSha256':digest(HERE/'measurement-reference.mjs'),'timingReferenceSha256':digest(HERE/'measurement-samples-readers-reference.mjs'),'contractSha256':digest(HERE/'measurement-samples-plan.md'),'cases':[]}
 def save():(HERE/'measurement-samples-readers-evidence.json').write_text(json.dumps(result,indent=2)+'\n')
 with tempfile.TemporaryDirectory(prefix='measurement-samples-') as tmp:
  root=pathlib.Path(tmp)
  for n,value in frozen.items():(root/n).write_bytes(value)
  bins=B.build(root/'measurement-samples-readers.bend',root)
  for schema,sn in [('Motion',0),('Health',1)]:
   for n in [64,256,1024]:
     ref=json.loads(B.command(['node',HERE/'measurement-reference.mjs',schema,'readers',str(n)]))
     commands={'Native':[bins[0],str(sn),str(n),'--threads','1','--gpu','off'],'JS':['node',bins[1],str(sn),str(n)],'TS':['node',HERE/'measurement-samples-readers-reference.mjs',schema,str(n)]}
     case={'schema':schema,'workload':'readers','count':n,'retainedLiveCount':n,'payloadWidth':4,'finalCommandOccupancy':0,'readers':'same Fast/Slow instances; Slow every fourth iteration','verification':{},'samples':{b:[] for b in commands},'summary':{}}
     result['cases'].append(case)
     # Fresh full validation for every backend before any measured repetition.
     for backend,args in commands.items():
      meta,text=child(args,root)
      if text is not None:
       try:meta.update(checked(backend,text,schema,n,ref))
       except (AssertionError,json.JSONDecodeError) as e:meta={'status':'FAILED','error':str(e),**{k:v for k,v in meta.items() if k!='status'}}
      case['verification'][backend]=meta;save()
     if not all(v['status']=='PASS' for v in case['verification'].values()):
      case['status']='UNVERIFIED';case['reason']='No timing ratios: at least one identical-work verification child failed';save();print(schema,'readers',n,'UNVERIFIED',flush=True);continue
     base=['Native','TS','JS']
     for repetition in range(7):
      offset=repetition%3;order=base[offset:]+base[:offset]
      for backend in order:
       meta,text=child(commands[backend],root);meta['repetition']=repetition+1;meta['backendOrder']=order
       if text is not None:
        try:meta.update(checked(backend,text,schema,n,ref))
        except (AssertionError,json.JSONDecodeError) as e:meta={'status':'FAILED','error':str(e),**{k:v for k,v in meta.items() if k!='status'}}
       case['samples'][backend].append(meta);save()
     complete=all(len(v)==7 and all(s['status']=='PASS' for s in v) for v in case['samples'].values());case['status']='MEASURED' if complete else 'REGRESSION'
     for backend,samples in case['samples'].items():
      if all(v['status']=='PASS' for v in samples):case['summary'][backend]={'milliseconds':stats([v['milliseconds'] for v in samples])}
     if complete:
      med={b:case['summary'][b]['milliseconds']['median'] for b in base};case['ratios']={'Native/TS':med['Native']/med['TS'],'JS/TS':med['JS']/med['TS']}
      case['resolutionLimited']=any(v['milliseconds']<10 for v in case['samples']['Native']);case['acceptance']='none: thresholds unapproved; sub-10ms native samples are resolution-limited' if case['resolutionLimited'] else 'none: thresholds unapproved'
     save();print(schema,'readers',n,case['status'],case.get('ratios'),flush=True)
 result['status']='PARTIAL_MEASURED' if any(c['status']=='MEASURED' for c in result['cases']) else 'NO_MEASUREMENTS';save();return 0
if __name__=='__main__':sys.exit(main())
