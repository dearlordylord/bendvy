"""Independent complete58 physical/common captures and21 checkpoints, one actual schema."""
import importlib.util,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
H=Path(__file__).resolve().parent
canonical=lambda value:json.dumps(value,sort_keys=True,separators=(',',':'),ensure_ascii=False)
def load(path,name):
 spec=importlib.util.spec_from_file_location(name,path);module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module);return module
def strict(raw):
 def pairs(items):
  result={}
  for key,value in items:
   assert key not in result
   result[key]=value
  return result
 return json.loads(raw,object_pairs_hook=pairs,parse_constant=lambda x:(_ for _ in ()).throw(ValueError(x)))
def validate(schema,raw):
 assert schema in ['A','B']
 actual=strict(raw);assert set(actual)=={schema}
 expected=strict((H/'expected-before-output.json').read_bytes())
 assert canonical(expected)==canonical(load(H/'model.py','independent_aligned_schema_model').expected())
 descriptors=strict((H.parent/'operations.json').read_bytes())['scenarios']
 assert len(actual[schema])==len(descriptors)==13
 captured=[];prior=[];count=0
 for descriptor,result,wanted in zip(descriptors,actual[schema],expected['captures'][schema],strict=True):
  assert set(result)=={'rows','sampleKinds','captures'}
  assert wanted['scenario']==descriptor['scenario']
  assert canonical(result['captures'])==canonical(wanted['captures'])
  assert len(result['captures'])==1+len(descriptor['steps']);count+=len(result['captures'])
  assert result['sampleKinds']==['setup']+[step['kind'] for step in descriptor['steps']]
  named=[{'name':entry['checkpoint'],'values':entry['values']} for entry in result['captures'] if entry['checkpoint'] is not None]
  assert canonical(named)==canonical(result['rows'])
  prior.append({'rows':result['rows'],'sampleKinds':result['sampleKinds']})
  captured.append({'scenario':descriptor['scenario'],'captures':result['captures']})
 assert count==58
 validated=load(H.parent/'ledger-native-source-v1/validate-schema.py','unchanged_checkpoint_schema_model').validate(schema,json.dumps({schema:prior}))
 return {'status':'SCHEMA_'+schema+'_COMPLETE58_PHYSICAL_COMMON_AND21_CORRECTNESS_PASS_NO_FULL116_TIMING_CREDIT','captures':{schema:captured},'checkpoints':validated}
