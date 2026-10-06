#!/usr/bin/env python3
"""Fresh exact eight cached/raw/suppressed row-owner JS controllers."""
import argparse,hashlib,json,os,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{11});here=Path(__file__).resolve().parent;catalog=json.loads((here/'input-pins.json').read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
r={'status':'INCOMPLETE','scope':'Fresh emitted JS controller full-record equality; no universal alias safety, source/compiler adoption or qualification','cpu':11,'runtimeLimitSeconds':5,'cases':[],'commands':[],'catalogSHA256':sha(here/'input-pins.json'),'recipeSHA256':sha(Path(__file__))}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def command(argv,label):
 c={'argv':list(map(str,argv)),'limitSeconds':5};r['commands'].append(c);save();code,out=supervisor.execute(c['argv'],5);f=a.output/(label+'.txt');f.write_text(out);c.update(exit=code,outputSHA256=sha(f));save();assert code==0,out[-1000:];return out
try:
 assert sum('getter' in x for x in catalog.values())==8,'Exactly eight controllers required'
 for digest,pin in catalog.items():
  if 'getter' not in pin:continue
  source=Path(pin['inputPath']);assert sha(source)==digest
  label=pin['mode']+'-'+pin['getter']+'-'+pin['schema'];target=a.output/(label+'.js');command(['node','--expose-internals',here/'rewrite.cjs',source,target,pin['schema']],label+'-rewrite')
  raw=[]
  for role,program in [('baseline',source),('rewritten',target)]:
   out=command(['node',program],label+'-'+role);records=[json.loads(x) for x in out.splitlines()];assert len(records)==72;raw.append(out)
  assert raw[0]==raw[1],label
  stored=Path(str(source)+'.jsonl')
  if stored.exists():assert stored.read_text().strip()==raw[0].strip()
  r['cases'].append({'label':label,'inputSHA256':digest,'outputSHA256':sha(target),'recipeSHA256':sha(Path(str(target)+'.recipe.json')),'records':72,'storedBaselineCompared':stored.exists()});save()
 assert len(r['cases'])==8 and sum(x['records'] for x in r['cases'])==576
 r['status']='ALL_EIGHT_CONTROLLERS_576_FULL_RECORDS_EQUAL'
except Exception as e:r.update(status='FAILED',error=repr(e))
finally:save()
print(json.dumps({'status':r['status'],'cases':len(r['cases']),'error':r.get('error')}));sys.exit(0 if r['status']=='ALL_EIGHT_CONTROLLERS_576_FULL_RECORDS_EQUAL' else 1)
