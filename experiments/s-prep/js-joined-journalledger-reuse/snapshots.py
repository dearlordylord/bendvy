#!/usr/bin/env python3
"""Four fresh trusted-helper frozen-view witnesses, plus retained failed scaffolds."""
import argparse,hashlib,json,os,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];HERE=Path(__file__).resolve().parent;sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
p=argparse.ArgumentParser();p.add_argument('--motion',type=Path,required=True);p.add_argument('--health',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{11});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','scope':'Trusted private helper frozen snapshots/true-old inverses; not universal raw-owner API or alias proof','cases':[],'commands':[],'recipeSHA256':sha(Path(__file__))}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def command(args,label):
 c={'argv':list(map(str,args)),'limitSeconds':5};r['commands'].append(c);save();code,out=supervisor.execute(c['argv'],5);f=a.output/(label+'.txt');f.write_text(out);c.update(exit=code,outputSHA256=sha(f));save();assert code==0;return out
try:
 for schema in ['motion','health']:
  for role,source in [('baseline',Path('/tmp/bendvy-joined-flatjournal-ledger-'+schema+'-build-v1/batch.js')),('candidate',getattr(a,schema))]:
   label=schema+'-'+role;driver=a.output/(label+'.js');command(['node','--expose-internals',HERE/'snapshot-witness.cjs',source,driver,schema],label+'-prepare');out=command(['node',driver],label+'-observe');v=json.loads(out);assert v['status']=='RETAINED_FROZEN_DATA_VIEWS_UNCHANGED_NEW_VIEWS_AND_TRUEOLD_PASS';r['cases'].append({'schema':schema,'role':role,'inputSHA256':sha(source),'driverSHA256':sha(driver),'snapshot':v});save()
 assert len(r['cases'])==4
 r['status']='FOUR_FROZEN_VIEW_TRUEOLD_SNAPSHOTS_PASS'
except Exception as e:r.update(status='FAILED',error=repr(e))
finally:save()
print(json.dumps({'status':r['status'],'cases':len(r['cases']),'error':r.get('error')}));sys.exit(0 if r['status']=='FOUR_FROZEN_VIEW_TRUEOLD_SNAPSHOTS_PASS' else 1)
