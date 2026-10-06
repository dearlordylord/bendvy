#!/usr/bin/env python3
"""Count-only nine-world source diagnostics; no profiler or clock comparison."""
import argparse,pathlib,json,hashlib,subprocess,os,signal,importlib.util,collections
H=pathlib.Path(__file__).resolve().parent;ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
p=argparse.ArgumentParser();p.add_argument('--baseline',type=pathlib.Path,required=True);p.add_argument('--candidate',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{9})
b=json.loads((a.baseline.parent/'build.json').read_text());assert hashlib.sha256(json.dumps(b['sourcePins'],sort_keys=True,separators=(',',':')).encode()).hexdigest()=='49614f72311af5b03123d536ff301115d28b8886bf516b0d7057a8c52e68ad38'
r={'status':'INCOMPLETE','scope':'Executed construction expressions only; nine complete worlds against fresh pinned TS; no timing comparison/profiling','CPU':9,'runtimeLimitSeconds':5,'inputs':{'baseline':sha(a.baseline),'candidate':sha(a.candidate)},'commands':[],'cases':[]}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(args):
 entry={'argv':list(map(str,args)),'limitSeconds':5};r['commands'].append(entry);save();child=subprocess.Popen(list(map(str,args)),stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True)
 try:out,err=child.communicate(timeout=5)
 except subprocess.TimeoutExpired:os.killpg(child.pid,signal.SIGKILL);out,err=child.communicate();entry.update(timeout=True,out=out,err=err);save();raise
 entry.update(exit=child.returncode);save();assert child.returncode==0,err;return out,err
spec=importlib.util.spec_from_file_location('validator',ROOT/'experiments/s-integrate/measurement-bend-run.py');V=importlib.util.module_from_spec(spec);spec.loader.exec_module(V)
try:
 run(['python3',ROOT/'experiments/s-prep/fivehour-measurement/prepare-ts.py','--source',ROOT/'experiments/s-integrate/measurement-samples-reference.mjs','--output',a.output/'reference.mjs','--schema','Motion','--batch','8']);ts,_=run(['node',a.output/'reference.mjs']);(a.output/'TS.json').write_text(ts);ref=json.loads(ts);assert len(ref['samples'])==8
 def validate(text):
  lines=[x for x in text.splitlines() if x.startswith('{')];assert len(lines)==9
  for line,world in zip(lines,[ref['warmup'],*ref['samples']]):V.validate(line,'Motion',False,256,world);assert V.normalized(json.loads(line),'Motion')==world['final']
 for role,source in [('baseline',a.baseline),('candidate',a.candidate)]:
  text=source.read_text();entries=[('return $choose$(0, 256, 64);','return $choose$(0, 256, 8);'),('return $motion_batch$(256, 64);','return $motion_batch$(256, 8);')];active=[(x,y) for x,y in entries if text.count(x)==1];assert len(active)==1 and sum(text.count(x) for x,_ in entries)==1;text=text.replace(*active[0],1)
  start=text.index('function $motion_timed$(');end=text.index('\nfunction ',start+1);body=text[start:end]
  for needle,phase in [('$IO$now$(_x_1)','start'),('$IO$now$(_x_6)','end')]:assert body.count(needle)==1;body=body.replace(needle,'(__count_phase("'+phase+'"), '+needle+')')
  text=text[:start]+body+text[end:];text='function __count_phase(phase){if(typeof __allocation_phase==="function")__allocation_phase(phase);}\n'+text;driver=a.output/(role+'.js');driver.write_text(text);out,_=run(['node',driver]);validate(out);(a.output/(role+'.txt')).write_text(out)
  counted=a.output/(role+'-counted.js');run(['node','--expose-internals',ROOT/'experiments/s-prep/js-allocation-map/instrument.cjs',driver,counted]);out,err=run(['node',counted]);validate(out);(a.output/(role+'-counted.txt')).write_text(out);(a.output/(role+'-counted.stderr')).write_text(err);reports=[x for x in err.splitlines() if x.startswith('ALLOCATION-COUNTS:')];assert len(reports)==1;counts=json.loads(reports[0].split(':',1)[1]);sites=json.loads(pathlib.Path(str(counted)+'.sites.json').read_text())['sites'];assert len(sites)==len(counts);kinds=collections.Counter()
  for site,n in zip(sites,counts):kinds[site['kind'].split('s-integrate/')[-1]]+=n
  r['cases'].append({'role':role,'total':sum(counts),'kinds':dict(kinds),'normalAndCountedNineFieldsPass':True,'derivedSHA256':sha(driver),'countedSHA256':sha(counted)});save()
 b,c=r['cases'];r.update(status='FRESH_NORMAL_COUNTED_NINE_FIELDS_PASS',removedExpressions=b['total']-c['total'],kindDelta={k:c['kinds'].get(k,0)-b['kinds'].get(k,0) for k in set(b['kinds'])|set(c['kinds']) if b['kinds'].get(k,0)!=c['kinds'].get(k,0)});save()
except Exception as e:r.update(status='FAILED_PRESERVED_SUBJECT',error=repr(e));save();raise
print(r['status'],r['removedExpressions'],r['kindDelta'])
