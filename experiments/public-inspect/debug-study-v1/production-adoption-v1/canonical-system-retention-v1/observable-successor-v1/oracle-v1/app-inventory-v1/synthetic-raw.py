"""Typed complete pre-output synthetic; never calls a backend."""
import importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
SUBJECT=Path('/workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1')
s=importlib.util.spec_from_file_location('inventory_parser',SUBJECT/'parse-inventory.py');P=importlib.util.module_from_spec(s);s.loader.exec_module(P)
join=json.loads((HERE.parent/'app-run-v1/CONSTRUCTOR-JOIN.json').read_bytes())
join['recordsStripTagExactOrderedFields'].update({'Inventory.Report':['baseline','origin','observations','descriptions'],'Inventory.Origin':['debug','entries','namespace','name','steps','requirements'],'Inventory.Description':['schema','namespace','name','steps','systems'],'Inventory.SchemaEntry':['kind','key','name'],'Inventory.Entry':['id','name','access','slot','clauses'],'Resource.Report':['factoryNext','before','after','descriptions'],'Resource.Snapshot':['namespace','nextId','highWater','capacity','depth','liveBits','store','resource','events','pendingCount','registrations','nextSystemId','clock']})
join['taggedExactFieldNames'].update({'Inventory.Reported':['report'],'Resource.Reported':['report']})
join['preserveEmptyTags']+=['Enabled','Disabled','Component','Resource','Event','Relation','Service']
join['scope']='Independent exact new ordinary App inventory fields, inherited complete60 semantic transport, pre-output only'
def inverse(value,expected,inventory):
 if expected in ['U32','String','Nat']:return value
 if isinstance(expected,tuple) and expected[0]=='List':return [inverse(x,expected[1],inventory) for x in value]
 if isinstance(expected,tuple):
  allowed={'Maybe':['Maybe.Some','None'],'Result':['Result.Done','Result.Fail'],'Access':['Access.Found','ComponentAbsent']}[expected[0]]
 else:allowed=P.BASE.GROUPS.get(expected,[expected])
 for semantic in allowed:
  records=join['recordsStripTagExactOrderedFields'];tagged=join['taggedExactFieldNames'];flat=join['taggedSingleFieldFlatten'];key=semantic.split('.')[-1]
  if semantic in records:
   if not isinstance(value,dict) or set(value)!=set(records[semantic]):continue
   fields=[value[k] for k in records[semantic]]
  elif semantic in tagged:
   if not isinstance(value,dict) or set(value)!={key}:continue
   fields=[value[key][k] for k in tagged[semantic]]
  elif semantic in flat:
   if not isinstance(value,dict) or set(value)!={key}:continue
   fields=[value[key]]
  elif semantic in join['preserveEmptyTags']:
   if value!={semantic:{}}:continue
   fields=[]
  elif semantic in join['modeNullaryAsExactString']:
   if value!=semantic:continue
   fields=[]
  elif semantic in join['booleanNullaryToJSON']:
   if type(value)is not bool or value!=join['booleanNullaryToJSON'][semantic]:continue
   fields=[]
  else:continue
  kinds=([expected[1]] if semantic in ['Maybe.Some','Access.Found','Result.Fail'] else [expected[2]] if semantic=='Result.Done' else []) if isinstance(expected,tuple) else P.BASE.FIELD_TYPES.get(semantic,[])
  tokens=[t for t,s in inventory['constructors'].items() if s==semantic]
  if len(tokens)!=1:raise ValueError('Ambiguous exact nominal token '+semantic)
  return {'constructor':tokens[0],'fields':[inverse(x,k,inventory) for x,k in zip(fields,kinds)]}
 raise ValueError('No exact source constructor for '+str((expected,value)))
def render(value):
 if isinstance(value,str):return json.dumps(value,ensure_ascii=False)
 if type(value)is int:return str(value)
 if isinstance(value,list):return '['+', '.join(render(x) for x in value)+']'
 if set(value)=={'nat'}:return str(value['nat'])+'n'
 return value['constructor']+'{'+', '.join(render(x) for x in value['fields'])+'}'
if __name__=='__main__':
 (HERE/'CONSTRUCTOR-JOIN.json').write_text(json.dumps(join,indent=2)+'\n')
 for role,entry,expected,ids in [('main','main.bend','expected-v2.json','main-identities.json'),('resource','resource-main.bend','resource-expected-v2.json','resource-identities.json')]:
  inventory=json.loads((SUBJECT/ids).read_bytes());assert P.build_identities(SUBJECT/entry)==inventory
  value=json.loads((HERE/expected).read_bytes());raw=render(inverse(value,'Output.Report' if role=='main' else 'Resource.Reported',inventory))+'\n';P.BASE.strict_equal(P.normalize(raw,inventory,join),value);(HERE/(role+'-synthetic.stdout')).write_text(raw)
  print(role,len(raw.encode()),'whole typed source roundtrip PASS')
