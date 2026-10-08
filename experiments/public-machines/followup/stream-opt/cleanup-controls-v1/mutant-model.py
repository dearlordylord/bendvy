"""Source-derived full rejected-disposal cursor deletion mutant oracle, before output."""
import copy, importlib.util, json
from pathlib import Path
H=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('cleanup_normal_model',H/'model.py');normal=importlib.util.module_from_spec(spec);spec.loader.exec_module(normal)
def expected():
 result=copy.deepcopy(normal.expected())
 for schema,scene in result.items():
  rows=scene['worlds']['B']
  rejected=next(row for row in rows if row['label']=='foreign-disposal-rejected')
  rejected['fields']['flowStream']='batches=[5:[Boot>Play]],positions=[],dropped=0,frameStart=2'
  rejected['fields']['levelStream']='batches=[],positions=[],dropped=0,frameStart=2'
  survivor=next(row for row in rows if row['label']=='B-survivor-empty')
  survivor['fields']['flowStream']='batches=[5:[Boot>Play]],positions=[5:7:6],dropped=0,frameStart=2'
  survivor['fields']['levelStream']='batches=[],positions=[5:7:6],dropped=0,frameStart=2'
  scene['instances'][-2]='B-survivor-delivery=[actual:flow=[Boot>Play]:level=[]:lagged=false,false]'
 return result
if __name__=='__main__':print(json.dumps(expected(),indent=2))
