"""Independent finite disposal refusal/retry/survivor oracle, authored before outputs."""
import copy, importlib.util, json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]/'model-root'
def module(path, name):
 spec = importlib.util.spec_from_file_location(name, path)
 value = importlib.util.module_from_spec(spec); spec.loader.exec_module(value); return value
base = module(ROOT/'experiments/public-machines/followup/foreign-model.py', 'cleanup_base_model')
def expected():
 result = copy.deepcopy(base.expected())
 for schema, scene in result.items():
  for side, rows in scene['worlds'].items():
   last = rows[-2]
   rows.insert(-1, {'label':'foreign-disposal-rejected', 'status':'cleanup-rejected', 'fields':copy.deepcopy(last['fields'])})
   if side == 'A':
    survivor = copy.deepcopy(rows[-1]); survivor['label'] = 'B-survivor-empty'; survivor['status'] = 'ok'
    rows.append(survivor)
   else:
    survivor = copy.deepcopy(rows[-2]); survivor['label'] = 'B-survivor-empty'; survivor['status'] = 'ok'
    survivor['fields']['tick'] = '7'
    survivor['fields']['flowStream'] = 'batches=[5:[Boot>Play]],positions=[5:7:5],dropped=0,frameStart=2'
    survivor['fields']['levelStream'] = 'batches=[],positions=[5:7:5],dropped=0,frameStart=2'
    rows.insert(-1, survivor); rows[-1]['fields']['tick'] = '7'
  # Actual rejected disposal returns the same affine A registry/reader tokens.
  scene['instances'].insert(-2, scene['instances'][-3].replace('B-independent-instance|', 'foreign-disposal-rejected|'))
  scene['instances'].insert(-1, 'B-survivor-delivery=[actual:flow=[]:level=[]:lagged=false,false]')
 return result
if __name__ == '__main__':
 print(json.dumps(expected(), indent=2))
