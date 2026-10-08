"""Read complete actual cleanup records against the independently authored oracle."""
import importlib.util, json
from pathlib import Path
H = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('cleanup_expected', H/'mutant-model.py')
model = importlib.util.module_from_spec(spec); spec.loader.exec_module(model)
def validate(raw):
 expected = json.loads((H/'mutant-expected.json').read_text())
 assert expected == model.expected(), 'independent model bytes changed'
 observed = {}; schema = None; world = None; instances = False
 for line in raw.decode('utf-8', errors='strict').splitlines():
  if line.startswith('SCHEMA='):
   schema=line[7:]; assert schema in expected and schema not in observed
   observed[schema]={'worlds':{},'instances':[]}; world=None; instances=False; continue
  if line.startswith('WORLD='):
   world=line[6:]; assert schema and world in expected[schema]['worlds'] and world not in observed[schema]['worlds']
   observed[schema]['worlds'][world]=[]; instances=False; continue
  if line=='INSTANCES':
   assert schema and not instances; instances=True; continue
  assert schema and line, 'unframed or empty actual observation'
  if instances: observed[schema]['instances'].append(line); continue
  assert world
  label,status,body=line.split('|',2); pairs=[part.split('=',1) for part in body.split(';')]
  assert len(pairs)==len({k for k,v in pairs}) and all(k and v for k,v in pairs)
  observed[schema]['worlds'][world].append({'label':label,'status':status,'fields':dict(pairs)})
 assert list(observed)==list(expected)==['A','B']
 for schema in expected:
  assert list(observed[schema]['worlds'])==['A','B']
  assert len(observed[schema]['instances'])==len(expected[schema]['instances'])==8
  for world in ['A','B']:
   assert len(observed[schema]['worlds'][world])==len(expected[schema]['worlds'][world])==8
 assert json.dumps(observed,sort_keys=True,separators=(',',':'))==json.dumps(expected,sort_keys=True,separators=(',',':')), 'complete cleanup oracle mismatch'
 return observed
