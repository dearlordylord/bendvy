"""Independent complete accepted-disposal batch-erasure counterfactual before outputs."""
import copy,importlib.util,json
from pathlib import Path
H=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('failed_batch_normal_model',H/'model.py');normal=importlib.util.module_from_spec(spec);spec.loader.exec_module(normal)
def expected():
 out=copy.deepcopy(normal.expected())
 for scene in out.values():
  for row in scene['worlds']['A']:
   if row['label'] in ['first-owned-cleanup','same-world-survivor-read','survivor-owned-cleanup']:row['fields']['flowStream']=row['fields']['flowStream'].replace('batches=[5:[Boot>Play]]','batches=[]')
  scene['instances'][5]='survivor-delivery=[actual:flow=[]:level=[]:lagged=false,false]'
 return out
if __name__=='__main__':print(json.dumps(expected(),indent=2))
