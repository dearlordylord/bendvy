#!/usr/bin/env python3
"""Unchanged generic affine storage gate on current29, explicit Clang19 process adapter."""
from pathlib import Path
import argparse,json,hashlib,os,subprocess,runpy,signal
H=Path(__file__).resolve().parent;ROOT=Path('/workspace/formal-proofs/bendvy');script=ROOT/'experiments/s-prep/fivehour-connected-gates/owned-storage-run.py';p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();assert not a.output.exists();os.sched_setaffinity(0,{9});base=Path('/tmp/bendvy-slot-host-v1');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();m=json.loads((base/'overlay.json').read_text());pins=m['sources'];digest=hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest();assert digest=='4baad4960575cda216576e8b90593fbd7ed7dcd44cfa86836b8d87dd5af71f5c' and all(sha(base/n)==h for n,h in pins.items());c=json.loads((base/'cache-specialization.json').read_text());assert c==m['cacheSpecialization'] and c['runtimeClosure']==c['specializedClosure']==pins and c['runtimeClosureSHA256']==c['specializedClosureSHA256']==digest
os.environ.update(BENDVY_FINAL_OVERLAY=str(base),BENDVY_OWNED_ARTIFACT=str(a.output),BENDVY_CPU='9',BENDVY_CHECKER_SECONDS='15',BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root')
r={'status':'INCOMPLETE','scope':'Unchanged generic affine Type storage catalogue; no private Slot Host/provider route claim','sourcePins':pins,'sourceClosure':digest,'protectedRunnerSHA256':sha(script),'adapterSHA256':sha(Path(__file__)),'commands':[]};Original=subprocess.Popen
class Logged(Original):
 def __init__(self,args,*extra,**kw):
  args=list(args);before=list(map(str,args))
  if len(args)>3 and args[:3]==['taskset','-c','9'] and args[3]=='clang':args[3]='/tmp/bendvy-clang19-diagnostic/clang19'
  self.record={'originalArgv':before,'actualArgv':list(map(str,args))};r['commands'].append(self.record);super().__init__(args,*extra,**kw)
 def communicate(self,*args,**kw):
  self.record['limitSeconds']=kw.get('timeout');result=super().communicate(*args,**kw);self.record['exit']=self.returncode
  if a.output.exists():
   i=r['commands'].index(self.record)
   for j,v in enumerate(result):
    if v is not None:
     f=a.output/('command-'+str(i)+('-stdout.txt' if j==0 else '-stderr.txt'));f.write_bytes(v) if isinstance(v,bytes) else f.write_text(v);self.record['stdoutSHA256' if j==0 else 'stderrSHA256']=sha(f)
  return result
subprocess.Popen=Logged
try:runpy.run_path(str(script),run_name='__main__');r['status']='FRESH_GENERIC_AFFINE_STORAGE_ORIGINAL_NEGATIVES_THREE_MUTANTS_PASS'
except Exception as e:r.update(status='FAIL_OR_LIMIT',error=repr(e));raise
finally:
 subprocess.Popen=Original
 if a.output.exists():(a.output/'source-bound-receipt.json').write_text(json.dumps(r,indent=2)+'\n')
