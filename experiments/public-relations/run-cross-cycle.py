#!/usr/bin/env python3
"""Protected upstream discovery, not a Bend law/policy or runtime acceptance."""
import pathlib,sys,hashlib,json,os,time,importlib.util

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
import task_runner

HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[1]
sys.path.insert(0,str(ROOT/'scripts'));import task_runner
spec=importlib.util.spec_from_file_location('relation_tools',HERE/'tool-pins.py');tools=importlib.util.module_from_spec(spec);spec.loader.exec_module(tools)
sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
out=HERE/'evidence'/('cross-cycle-'+str(time.time_ns()));out.mkdir();tool_snapshot=tools.snapshot()
files={HERE/'cross-descriptor-cycle-reference.mjs',pathlib.Path(__file__).resolve(),HERE/'tool-pins.py',pathlib.Path(task_runner.__file__).resolve()};files|=set((ROOT/'.references/bevy-ts/packages/core/src').rglob('*.ts'));files|={pathlib.Path(p) for p in tool_snapshot['pins']}
pins={str(p):sha(p) for p in sorted(files)};argv=['taskset','-c','10','node',str(HERE/'cross-descriptor-cycle-reference.mjs')]
r={'status':'INCOMPLETE','pins':pins,'tools':tool_snapshot,'argv':argv,'capSeconds':5,'scope':'Actual upstream discovery only; no Bend policy/adoption/universal termination claim'}
def guard():tools.verify(tool_snapshot);assert all(sha(p)==h for p,h in pins.items()),'source drift'
try:
 guard();code,text=task_runner.execute(argv,5);guard();(out/'output.txt').write_text(text);r.update(exit=code,outputSHA256=sha(out/'output.txt'))
 rows=[json.loads(line) for line in text.splitlines() if line.startswith('{')]
 assert code==0 and len(rows)==4,(code,rows)
 for destroy,before,after in [(1,rows[0],rows[1]),(2,rows[2],rows[3])]:
  assert before['destroy']==destroy and before['phase']=='constructed'
  constructed=before['observations'][-1];assert constructed['lookups']==[{'target':2},{'target':1}];assert constructed['owners']==[{'id':1,'cells':[10,11]},{'id':2,'cells':[20,21]}]
  assert after['destroy']==destroy and after['phase']=='after-delete';final=after['observations'][-1]
  assert final['owners']==[],final
  assert final['removed']==([2,1] if destroy==1 else [2,1]),final
  assert final['despawned']==([2,1] if destroy==1 else [2,1,2]),final
 r['status']='ACTUAL_CROSS_DESCRIPTOR_CYCLE_CLEANUP_OBSERVED'
 r['observations']=rows

except Exception as e:r['status']='FAIL';r['error']=repr(e)
finally:(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n')
print(out,r['status']);sys.exit(0 if r['status'].startswith('ACTUAL_CROSS_DESCRIPTOR_CYCLE_') else 1)
