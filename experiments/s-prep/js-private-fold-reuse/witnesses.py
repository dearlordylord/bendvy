#!/usr/bin/env python3
import hashlib,json,os,subprocess
from pathlib import Path
H=Path(__file__).resolve().parent;out=Path('/tmp/bendvy-js-private-fold-witnesses-v3');out.mkdir(exist_ok=False);os.sched_setaffinity(0,{11});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','scope':'Trusted private finite wholeFold/immutableData/fallback witness; no public owner exposure or universal alias claim','cases':[]}
try:
 for schema in ['motion','health']:
  baseline=Path('/tmp/bendvy-js-joined-journalledger-pool-controls-v3/normal-cached-'+schema+'.js');candidate=Path('/tmp/bendvy-js-private-fold-controls-v3/normal-cached-'+schema+'.js');observed=[]
  for label,source in [('baseline',baseline),('candidate',candidate)]:
   driver=out/(schema+'-'+label+'.js');p=subprocess.run(['node','--expose-internals',H/'fold-witness.cjs',source,driver,schema],capture_output=True,text=True,timeout=5);assert p.returncode==0,p.stderr
   p=subprocess.run(['node',driver],capture_output=True,text=True,timeout=5);(out/(schema+'-'+label+'.txt')).write_text(p.stdout+p.stderr);assert p.returncode==0,p.stderr
   lines=[x for x in p.stderr.splitlines() if x.startswith('FOLD-WITNESS:')];assert len(lines)==1;frames=json.loads(lines[0].split(':',1)[1]);assert frames and any(x['success'] for x in frames) and any(not x['success'] for x in frames) and any(x['retainedViews'] for x in frames);observed.append((p.stdout,frames));r['cases'].append({'schema':schema,'role':label,'inputSHA256':sha(source),'driverSHA256':sha(driver),'wholeFoldFrames':len(frames),'successFrames':sum(x['success'] for x in frames),'fallbackFrames':sum(not x['success'] for x in frames)})
  assert observed[0]==observed[1],schema
 r['status']='BOTH_SCHEMAS_WHOLE_FOLD_SUCCESS_FALLBACK_FROZEN_DATA_EQUAL'
finally:(out/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
print(r['status'])
