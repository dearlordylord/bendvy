"""Whole independently derived retirement-loss counterfactual; no output inputs."""
from pathlib import Path
import importlib.util,json,copy
HERE=Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('independent_baseline',HERE.parent/'expected.py');B=importlib.util.module_from_spec(s);s.loader.exec_module(B)
def expected():
 report=B.expected()
 # The only mutated callsite receives one nonempty retirement batch per trace.
 # Standard returns owners[1,2,3] at window-second; capacity returns[1,2] at frame.
 for trace,start in [('standard','window-second'),('capacity','whole-batch-capacity')]:
  reached=False
  for snapshot in report[trace]['Trace']['snapshots']:
   reached=reached or snapshot['label']==start
   if reached:
    assert snapshot['retired'][0]['key']==1
    snapshot['retired']=copy.deepcopy(snapshot['retired'][1:])
 return report
if __name__=='__main__':print(json.dumps(expected(),indent=2))
