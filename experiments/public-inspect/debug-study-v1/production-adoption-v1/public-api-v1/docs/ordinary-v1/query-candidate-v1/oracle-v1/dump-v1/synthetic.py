"""No-child full typed inverse controls; generated text is not runtime evidence."""
import importlib.util,json,hashlib
from pathlib import Path
HERE=Path(__file__).resolve().parent
WORKER=Path('/workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/dump-v1')
s=importlib.util.spec_from_file_location('dump_transport',WORKER/'parse-dump.py');P=importlib.util.module_from_spec(s);s.loader.exec_module(P)
def render(value,kind,join,identities):
 if kind=='U32':assert type(value)is int and 0<=value<2**32;return str(value)
 if kind=='String':assert type(value)is str;return json.dumps(value)
 if kind=='Nat':assert set(value)=={'nat'};return str(value['nat'])+'n'
 if isinstance(kind,tuple)and kind[0]=='List':return '['+', '.join(render(v,kind[1],join,identities)for v in value)+']'
 records=join['recordsStripTagExactOrderedFields'];tagged=join['taggedExactFieldNames'];flat=join['taggedSingleFieldFlatten']
 if kind=='Bool':semantic='True'if value else'False';fields=[]
 elif kind=='Mode':semantic=value;fields=[]
 elif not isinstance(kind,tuple)and kind in records:semantic=kind;fields=[value[k]for k in records[kind]]
 else:
  assert type(value)is dict and len(value)==1
  tag,payload=next(iter(value.items()))
  candidates=[x for x in identities.values()if x.split('.')[-1]==tag]
  allowed=({'Maybe':['Maybe.Some','None'],'Access':['Access.Found','ComponentAbsent'],'Result':['Result.Done','Result.Fail']}[kind[0]]if isinstance(kind,tuple)else P.BASE.GROUPS.get(kind,[kind]))
  semantic=next(x for x in candidates if x in allowed)
  if semantic in tagged:fields=[payload[k]for k in tagged[semantic]]
  elif semantic in flat:fields=[payload]
  else:assert payload=={};fields=[]
 if isinstance(kind,tuple):
  types=([kind[1]]if semantic in ['Maybe.Some','Access.Found','Result.Fail']else[kind[2]]if semantic=='Result.Done'else[])
 else:types=P.BASE.FIELD_TYPES.get(semantic,[])
 assert len(fields)==len(types),(semantic,fields,types)
 token=next(k for k,v in identities.items()if v==semantic)
 return token+'{'+', '.join(render(v,t,join,identities)for v,t in zip(fields,types))+'}'
if __name__=='__main__':
 for suffix,expected,inventory in [('', 'expected.json',WORKER/'constructor-identities.json'),('-disabled-mutant','expected-disabled-mutant.json',WORKER/'disabled-execution-mutant-v1/constructor-identities.json')]:
  join=json.loads((HERE/('CONSTRUCTOR-JOIN'+suffix+'.json')).read_text());inv=json.loads(inventory.read_text());data=json.loads((HERE/expected).read_text())
  assert inv==P.build_identities(inv['entrypoint'])
  raw=render(data,'Output.Report',join,inv['constructors'])+'\n';P.BASE.strict_equal(P.normalize(raw,inv,join),data)
  (HERE/('synthetic'+suffix+'.stdout')).write_text(raw)
  print(suffix or 'normal',len(raw.encode()),hashlib.sha256(raw.encode()).hexdigest(),'whole typed equality PASS')
