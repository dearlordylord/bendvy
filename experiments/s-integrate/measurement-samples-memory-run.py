#!/usr/bin/env python3
"""Separate corrected process-RSS samples; retain prior timing evidence unchanged."""
import datetime,hashlib,importlib.util,json,os,pathlib,statistics,subprocess,tempfile
HERE=pathlib.Path(__file__).resolve().parent
def module(name,file):
 spec=importlib.util.spec_from_file_location(name,HERE/file);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
D=module('dense','measurement-samples-run.py');R=module('readers','measurement-samples-readers-run.py')
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def stamp():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def stats(values):return {'raw':values,'min':min(values),'median':statistics.median(values),'max':max(values)}
def main():
 os.sched_setaffinity(0,{5})
 sources=[('dense-sparse',D,'measurement-samples-evidence.json','measurement-samples-bend.bend','measurement-samples-reference.mjs'),('readers',R,'measurement-samples-readers-evidence.json','measurement-samples-readers.bend','measurement-samples-readers-reference.mjs')]
 result={'scope':'corrected whole-child process peak RSS, seven fresh samples on previously fully verified cases; not component allocations or performance acceptance','startedAt':stamp(),'cpuAffinity':sorted(os.sched_getaffinity(0)),'rssMethod':'small exec-reset C launcher forks/execs actual workload; launcher wait4(child).ru_maxrss in Linux KiB; excludes launcher RSS, includes workload startup/warmup/setup/serialization/child-owned validation','limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'iterations':64,'warmup':'one fresh identical world followed by one measured world, unchanged; no timing ratios recomputed','launcherSha256':sha(HERE/'measurement-samples-rss-launcher.c'),'runnerSha256':sha(pathlib.Path(__file__)),'compiler':D.B.command(['bend','version']).strip(),'node':D.B.command(['node','--version']).strip(),'clang':D.B.command(['clang','--version']).splitlines()[0],'baseSha256':sha(pathlib.Path.home()/'.bend/bend2/base.bend'),'packages':{},'excluded':[],'cases':[]}
 def save():(HERE/'measurement-samples-memory-evidence.json').write_text(json.dumps(result,indent=2)+'\n')
 save()
 with tempfile.TemporaryDirectory(prefix='measurement-memory-') as tmp:
  root=pathlib.Path(tmp);launcher=root/'launcher';D.B.command(['clang','-std=c11','-O2',HERE/'measurement-samples-rss-launcher.c','-o',launcher],timeout=120)
  result['launcherExecutableSha256']=sha(launcher)
  for lane,m,priorname,entry,reference in sources:
   prior=json.loads((HERE/priorname).read_text());folder=root/lane;folder.mkdir()
   result['packages'][lane]={'priorCorrectnessEvidenceSha256':sha(HERE/priorname),'sourceClosure':{n:hashlib.sha256(v).hexdigest() for n,v in m.frozen.items()},'timingReferenceSha256':sha(HERE/reference),'fullReferenceSha256':sha(HERE/'measurement-reference.mjs'),'validatorRunnerSha256':sha(pathlib.Path(m.__file__))}
   for n,value in m.frozen.items():(folder/n).write_bytes(value)
   bins=m.B.build(folder/entry,folder)
   result['packages'][lane]['artifacts']={b:sha(f) for b,f in [('Native',bins[0]),('JS',bins[1])]};save()
   for previous in prior['cases']:
    if previous['status']!='MEASURED':
     result['excluded'].append({'schema':previous['schema'],'workload':previous['workload'],'count':previous['count'],'reason':'original complete-process correctness prerequisite failed; no memory sampling'});save();continue
    schema=previous['schema'];sn=0 if schema=='Motion' else 1;n=previous['count'];workload=previous['workload'];sparse=workload=='sparse'
    ref=json.loads(m.B.command(['node',HERE/'measurement-reference.mjs',schema,workload,str(n)]))
    args=[str(sn),str(n)] if lane=='readers' else [str(sn),str(int(sparse)),str(n),'1']
    tsargs=[schema,str(n)] if lane=='readers' else [schema,workload,str(n),'1']
    commands={'Native':[bins[0],*args,'--threads','1','--gpu','off'],'JS':['node',bins[1],*args],'TS':['node',HERE/reference,*tsargs]}
    case={'schema':schema,'workload':workload,'count':n,'samples':{b:[] for b in commands},'summary':{}};result['cases'].append(case)
    for repetition in range(7):
     base=['Native','TS','JS'];k=repetition%3;order=base[k:]+base[:k]
     for backend in order:
      output=root/'rss.json';output.unlink(missing_ok=True);started=stamp()
      meta,text=m.child([launcher,output,*commands[backend]],folder)
      sample={**meta,'startedAt':started,'finishedAt':stamp(),'repetition':repetition+1,'backendOrder':order,'workloadCommand':[str(x) for x in commands[backend]]}
      if text is not None:
       try:
        checked=m.checked(backend,text,schema,n,ref) if lane=='readers' else m.checked(backend,text,schema,sparse,n,1,ref)
        rss=json.loads(output.read_text());assert rss['exitCode']==0
        sample.update({'peakRssKiB':rss['childPeakRssKiB'],'launcherInheritedPeakRssKiB':rss['launcherPeakRssKiB'],'fullValidation':checked})
       except (AssertionError,json.JSONDecodeError,OSError) as e:sample.update(status='FAILED',error=str(e))
      case['samples'][backend].append(sample);save()
    complete=all(len(ss)==7 and all(v['status']=='PASS' for v in ss) for ss in case['samples'].values());case['status']='MEASURED' if complete else 'REGRESSION'
    if complete:
     for backend,ss in case['samples'].items():case['summary'][backend]={'peakRssKiB':stats([v['peakRssKiB'] for v in ss])}
    save();print(schema,workload,n,case['status'],{b:s['peakRssKiB']['median'] for b,s in case['summary'].items()},flush=True)
 result['finishedAt']=stamp();result['status']='VERIFIED_CASES_MEASURED' if all(c['status']=='MEASURED' for c in result['cases']) else 'PARTIAL_MEMORY';save()
if __name__=='__main__':main()
