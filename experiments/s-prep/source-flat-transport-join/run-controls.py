#!/usr/bin/env python3
"""Run original source controls with only explicit root CPU affinity adaptation."""
import argparse,hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
p=argparse.ArgumentParser();p.add_argument('--runner',choices=['held-boundary','held-retained','held-tx','held-static','query-authority','query-threading','query-provider','query-frozen'],required=True);p.add_argument('--overlay',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--cpu',type=int,default=7);p.add_argument('--mutation',choices=['lost-mark','inverse-order']);a=p.parse_args();a.overlay=a.overlay.resolve(strict=True);a.output=a.output.absolute()
held=ROOT/'experiments/s-prep/source-held-owner-transport';query=ROOT/'experiments/s-prep/source-query-owner-fusion'
paths={'held-boundary':held/'boundary.py','held-retained':held/'retained.py','held-tx':held/'controls.py','held-static':held/'controls.py','query-authority':query/'authority-run.py','query-threading':query/'owner-threading-run.py','query-provider':query/'provider-run.py','query-frozen':query/'frozen-authority/run.py'}
runner=paths[a.runner];original=runner.read_text();derived=original
replacements=[]
for old,new in [('os.sched_setaffinity(0,{10})',f'os.sched_setaffinity(0,{{{a.cpu}}})'),("'CPU':10",f"'CPU':{a.cpu}"),("'--cpu','10'",f"'--cpu','{a.cpu}'"),('os.sched_setaffinity(0,{8})',f'os.sched_setaffinity(0,{{{a.cpu}}})'),("'cpu':[8]",f"'cpu':[{a.cpu}]"),("'--cpu','8'",f"'--cpu','{a.cpu}'"),("'--cpu', '8'",f"'--cpu', '{a.cpu}'"),("'taskset','-c','8'",f"'taskset','-c','{a.cpu}'")]:
 count=derived.count(old)
 if count:derived=derived.replace(old,new);replacements.append({'old':old,'new':new,'count':count})
assert replacements,'No explicit CPU adaptation found'
args=[str(runner),'--overlay',str(a.overlay),'--output',str(a.output)]
if a.runner in ['held-tx','held-static']:args+=['--gate','tx' if a.runner=='held-tx' else 'static']
if a.mutation:assert a.runner=='held-tx';args+=['--mutation',a.mutation]
receipt=a.output.parent/(a.output.name+'.root-cpu-adapter.json');assert not receipt.exists()
r={'status':'INCOMPLETE','originalRunner':str(runner),'originalSHA256':hashlib.sha256(original.encode()).hexdigest(),'derivedSHA256':hashlib.sha256(derived.encode()).hexdigest(),'adapterSHA256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'changes':'CPU affinity/receipt only; original fixtures, oracles, arguments other than CPU and all source/control algorithms remain unchanged','replacements':replacements,'argv':args,'sourceJoinManifestSHA256':hashlib.sha256((a.overlay/'overlay.json').read_bytes()).hexdigest()}
sys.argv=args
try:exec(compile(derived,str(runner),'exec'),{'__file__':str(runner),'__name__':'__main__'});r['status']='ORIGINAL_FINITE_CONTROL_WITH_ROOT_CPU_PASS'
except BaseException as e:r.update(status='FAIL',error=repr(e));raise
finally:receipt.write_text(json.dumps(r,indent=2)+'\n')
