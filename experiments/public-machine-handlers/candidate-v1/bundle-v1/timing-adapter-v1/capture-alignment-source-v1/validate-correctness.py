"""Independent aligned captures58/schema plus unchanged physical/common42."""
import importlib.util,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
H=Path(__file__).resolve().parent
canonical=lambda v:json.dumps(v,sort_keys=True,separators=(',',':'),ensure_ascii=False)
def load(p,n):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
def strict(raw):
 def pairs(items):
  out={}
  for key,value in items:
   assert key not in out;out[key]=value
  return out
 return json.loads(raw,object_pairs_hook=pairs,parse_constant=lambda x:(_ for _ in ()).throw(ValueError(x)))
def validate(raw):
 actual=strict(raw);expected=strict((H/'expected-before-output.json').read_bytes());model=load(H/'model.py','aligned_independent_model')
 assert canonical(expected)==canonical(model.expected())
 descriptors=strict((H.parent/'operations.json').read_bytes())['scenarios'];prior={};captured={}
 assert set(actual)=={'A','B'}
 for schema in ['A','B']:
  assert len(actual[schema])==len(descriptors)==13
  prior[schema]=[];captured[schema]=[];count=0
  for descriptor,result,wanted in zip(descriptors,actual[schema],expected['captures'][schema],strict=True):
   assert set(result)=={'rows','sampleKinds','captures'}
   assert wanted['scenario']==descriptor['scenario']
   assert canonical(result['captures'])==canonical(wanted['captures'])
   assert len(result['captures'])==1+len(descriptor['steps']);count+=len(result['captures'])
   named=[{'name':entry['checkpoint'],'values':entry['values']} for entry in result['captures'] if entry['checkpoint'] is not None]
   assert canonical(named)==canonical(result['rows'])
   prior[schema].append({'rows':result['rows'],'sampleKinds':result['sampleKinds']})
   captured[schema].append({'scenario':descriptor['scenario'],'captures':result['captures']})
  assert count==58
 validated=load(H.parent/'ledger-driver-source-v1/validate-correctness.py','unaltered_checkpoint_model').validate(json.dumps(prior))
 return {'status':'FULL116_ALIGNED_CAPTURES_AND_UNCHANGED42_CORRECTNESS_PASS_NO_TIMING_CREDIT','captures':captured,'checkpoints':validated}
if __name__=='__main__':print(json.dumps(validate(Path(sys.argv[1]).read_text()),separators=(',',':')))
