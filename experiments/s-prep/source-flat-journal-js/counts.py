#!/usr/bin/env python3
"""Pinned source Health nine-world expression counts; no allocation/time claim."""
import argparse,collections,gzip,hashlib,importlib.util,json,os,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
p=argparse.ArgumentParser();p.add_argument('--candidate-profile',type=Path,required=True);p.add_argument('--candidate-build',type=Path,required=True);p.add_argument('--overlay',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{11});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
r={'status':'INCOMPLETE','scope':'Executed expression counts only; no physical allocations, speed or qualification','cpu':11,'commands':[],'cases':[],'recipeSHA256':sha(Path(__file__))}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def command(argv,label):
 c={'argv':list(map(str,argv)),'limitSeconds':5};r['commands'].append(c);save();code,out=supervisor.execute(c['argv'],5);f=a.output/(label+'.txt');f.write_text(out);c.update(exit=code,outputSHA256=sha(f));save();assert code==0;return out
try:
 origin=ROOT/'experiments/s-prep/source-fold-noaux-join/profile';index=json.loads((origin/'index.json').read_text());baseline=a.output/'baseline-profile';baseline.mkdir()
 for name in ['bend.js','TS.observed.txt']:
  raw=gzip.decompress((origin/(name+'.gz')).read_bytes());assert hashlib.sha256(raw).hexdigest()==index['files'][name]['decodedSHA256'];(baseline/name).write_bytes(raw)
 pins={str(f.relative_to(a.overlay)):sha(f) for f in a.overlay.rglob('*.bend')};manifest=json.loads((a.overlay/'overlay.json').read_text());cache=json.loads((a.overlay/'cache-specialization.json').read_text());assert manifest['cacheSpecialization']==cache and cache['runtimeClosure']==cache['specializedClosure']==pins;build=json.loads((a.candidate_build/'build.json').read_text());assert pins==manifest['sources']==build['sourcePins'] and len(pins)==29 and build['status']=='BUILD_PASS';assert sha(a.candidate_build/'batch.js')==build['artifacts']['batch.js'];r['sourcePins']=pins;r['buildReceiptSHA256']=sha(a.candidate_build/'build.json');r['profileReceiptSHA256']=sha(a.candidate_profile/'evidence.json')
 creceipt=json.loads((a.candidate_profile/'evidence.json').read_text());assert creceipt['generatedOriginalSHA256']==sha(a.candidate_build/'batch.js') and creceipt['status']=='PROFILE_AND_NINE_FULL_WORLDS_PASS' and sha(a.candidate_profile/'bend.js')==creceipt['derivedPins']['bend.js']
 spec=importlib.util.spec_from_file_location('V',ROOT/'experiments/s-integrate/measurement-bend-run.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
 for role,profile in [('baseline',baseline),('candidate',a.candidate_profile)]:
  counted=a.output/(role+'.js');command(['node','--expose-internals',ROOT/'experiments/s-prep/js-allocation-map/instrument.cjs',profile/'bend.js',counted],role+'-instrument');out=command(['node',counted],role+'-counted');ts=json.loads((profile/'TS.observed.txt').read_text());records=[x for x in out.splitlines() if x.startswith('{')];assert len(records)==9 and len(ts['samples'])==8
  for line,world in zip(records,[ts['warmup'],*ts['samples']]):v.validate(line,'Health',False,256,world);assert v.normalized(json.loads(line),'Health')==world['final']
  reports=[x for x in out.splitlines() if x.startswith('ALLOCATION-COUNTS:')];assert len(reports)==1;counts=json.loads(reports[0].split(':',1)[1]);sites=json.loads(Path(str(counted)+'.sites.json').read_text())['sites'];assert len(counts)==len(sites);kinds=collections.Counter()
  for site,n in zip(sites,counts):kinds[site['kind'].split('s-integrate/')[-1]]+=n
  r['cases'].append({'role':role,'driverSHA256':sha(profile/'bend.js'),'countedSHA256':sha(counted),'ordinaryCount':sum(counts)-1,'markerExtra':1,'kinds':dict(kinds),'nineFullFieldsEqual':True});save()
 b,c=r['cases'];delta={k:c['kinds'].get(k,0)-b['kinds'].get(k,0) for k in set(b['kinds'])|set(c['kinds']) if c['kinds'].get(k,0)!=b['kinds'].get(k,0)};r.update(status='SOURCE_PINNED_EXPRESSION_COUNTS_NINE_FIELDS_PASS',delta=delta)
except Exception as e:r.update(status='FAILED',error=repr(e))
finally:save()
print(json.dumps({k:r.get(k) for k in ['status','delta','error']}));sys.exit(0 if r['status']=='SOURCE_PINNED_EXPRESSION_COUNTS_NINE_FIELDS_PASS' else 1)
