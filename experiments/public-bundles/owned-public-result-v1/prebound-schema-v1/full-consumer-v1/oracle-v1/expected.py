"""Independent source-only prebinding outputs; no runtime files consulted."""
import importlib.util,json
from pathlib import Path
BASE=Path('/workspace/formal-proofs/bendvy/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/registered-lifecycle-v1/oracle-v1/expected.py')
spec=importlib.util.spec_from_file_location('registered_source_model',BASE);B=importlib.util.module_from_spec(spec);spec.loader.exec_module(B)
def normal():return B.expected()
def empty_world(ns):
 return dict(namespace=ns,nextId=1,highWater=0,capacity=1,depth=0,live=[False],columns={f:dict(values=[None],stamps=[])for f in ['a','b','tag','value']},clock=0,events=[],pending=[],registrations=[],nextSystemId=1,mail=dict(context=0,returned=[],installed=[],quarantine=[],errors=[]))
def wrong_binding():
 # Empty First catalog passes duplicate validation, but first required a descriptor is absent.
 # No initializer/register/body/observer runs. Actual IO creator still consumes namespaces1..5;
 # subsequent Second creates namespaces6..10 and keeps complete original lifecycle results.
 lines=[]
 for ns,mode in enumerate(B.b.MODES,1):
  lines.append('A-'+mode+'=SEED_SCHEMA_BIND_REJECTED|error=UndeclaredDescriptor:component:a:a|world='+B.world_text(empty_world(ns)))
 lines.extend(model['text']for model in B.models()if model['schema']=='B')
 return '\n'.join(lines)+'\n'
if __name__=='__main__':
 here=Path(__file__).resolve().parent
 for name,value in [('expected',normal()),('wrong-binding-expected',wrong_binding())]:
  (here/(name+'.stdout')).write_text(value);(here/(name+'.json')).write_text(json.dumps(value,ensure_ascii=False,indent=2)+'\n')
