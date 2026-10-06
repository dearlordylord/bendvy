#!/usr/bin/env python3
"""Actual normal-nine equivalence and timed-phase constructor counts only."""
import argparse,collections,hashlib,importlib.util,json,os,pathlib,signal,subprocess,time
p=argparse.ArgumentParser();p.add_argument('--candidate',type=pathlib.Path,required=True);p.add_argument('--baseline',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{10});ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');BASE=a.baseline;sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest();assert sha(BASE)==sha(pathlib.Path('/tmp/bendvy-query-frozen-provider-motion-build-v2/batch.js'));r={'status':'INCOMPLETE','scope':'Construction expressions in eight-world timed phase; nine full world semantics, no heap/time acceptance','cpu':10,'commands':[],'cases':[],'frozenSourceBaselineCount':9562688,'instrumentedMarkerExtraConstructors':1}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,limit=5):
 start=time.monotonic();child=subprocess.Popen(list(map(str,argv)),stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True);timed=False
 try:out=child.communicate(timeout=limit)[0]
 except subprocess.TimeoutExpired:timed=True;os.killpg(child.pid,signal.SIGKILL);out=child.communicate()[0]
 r['commands'].append({'argv':list(map(str,argv)),'limitSeconds':limit,'exit':child.returncode,'timeout':timed,'seconds':time.monotonic()-start,'output':out});save();assert child.returncode==0,r['commands'][-1];return out
spec=importlib.util.spec_from_file_location('V',ROOT/'experiments/s-integrate/measurement-bend-run.py');V=importlib.util.module_from_spec(spec);spec.loader.exec_module(V)
try:
 for role,source in [('baseline',BASE),('candidate',a.candidate)]:
  profile=a.output/role;run(['python3',ROOT/'experiments/s-prep/js-profile/run.py','--generated-js',source,'--output',profile,'--cpu','10','--no-gc'],25)
  receipt=json.loads((profile/'evidence.json').read_text());assert receipt['status']=='PROFILE_AND_NINE_FULL_WORLDS_PASS'
  counted=a.output/(role+'-counted.js');run(['node','--expose-internals',ROOT/'experiments/s-prep/js-allocation-map/instrument.cjs',profile/'bend.js',counted]);raw=run(['node',counted]);(a.output/(role+'-counted.txt')).write_text(raw)
  ts=json.loads((profile/'TS.observed.txt').read_text());records=[x for x in raw.splitlines() if x.startswith('{')];assert len(records)==9
  for line,world in zip(records,[ts['warmup'],*ts['samples']]):V.validate(line,'Motion',False,256,world);assert V.normalized(json.loads(line),'Motion')==world['final']
  reports=[x for x in raw.splitlines() if x.startswith('ALLOCATION-COUNTS:')];assert len(reports)==1;counts=json.loads(reports[0].split(':',1)[1]);sites=json.loads(pathlib.Path(str(counted)+'.sites.json').read_text())['sites'];assert len(counts)==len(sites);kinds=collections.Counter()
  for site,n in zip(sites,counts):kinds[site['kind'].split('s-integrate/')[-1]]+=n
  r['cases'].append({'role':role,'inputSHA256':sha(source),'profileDriverSHA256':sha(profile/'bend.js'),'countedSHA256':sha(counted),'totalIncludingMarker':sum(counts),'ordinaryPhaseTotal':sum(counts)-1,'kinds':dict(kinds),'quietAndCountedNineFullFieldsPass':True});save()
 b,c=r['cases'];keys=set(b['kinds'])|set(c['kinds']);delta={k:c['kinds'].get(k,0)-b['kinds'].get(k,0) for k in keys if c['kinds'].get(k,0)!=b['kinds'].get(k,0)};r.update(status='FRESH_QUIET_AND_COUNTED_NINE_WORLDS_PASS',kindDelta=delta,incrementalRemovedConstructors=b['ordinaryPhaseTotal']-c['ordinaryPhaseTotal']);save()
except Exception as error:r.update(status='FAILED',error=repr(error));save();raise
print(r['status'])
