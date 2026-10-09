"""Pre-runtime complete model roundtrips; synthetic streams are not observations."""
import copy,json,importlib.util
from pathlib import Path
HERE=Path(__file__).resolve().parent
SUBJECT=HERE.parent/'consumer/app-inventory-v1/graph-machine-v1/handler-inventory-v1'
spec=importlib.util.spec_from_file_location('parser',SUBJECT/'parse-handlers.py')
P=importlib.util.module_from_spec(spec);spec.loader.exec_module(P)
join=json.loads((HERE/'CONSTRUCTOR-JOIN.json').read_text())
def inverse(value,expected,inventory):
 if expected in ['U32','String','Nat']:return value
 if isinstance(expected,tuple) and expected[0]=='List':return [inverse(x,expected[1],inventory) for x in value]
 if isinstance(expected,tuple):
  allowed={'Maybe':['Maybe.Some','None'],'Result':['Result.Done','Result.Fail'],'Access':['Access.Found','ComponentAbsent'],'Product':['Inspector.Product'],'ProjectedRow':['Inspector.ProjectedRow']}[expected[0]]
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
  kinds=([expected[1],expected[2]] if expected[0]=='Product' else ['Graph.Handle',expected[1]] if expected[0]=='ProjectedRow' else [expected[1]] if semantic in ['Maybe.Some','Access.Found','Result.Fail'] else [expected[2]] if semantic=='Result.Done' else []) if isinstance(expected,tuple) else P.BASE.FIELD_TYPES.get(semantic,[])
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

if __name__ == '__main__':
 checks={}
 for role in ('normal','inspector-filter','handler-drop'):
  inv=json.loads((HERE/(role+'-identities.json')).read_text())
  assert inv==P.build_identities(Path(inv['entrypoint']))
  expected=json.loads((HERE/(role+'-expected.json')).read_text())
  raw=render(inverse(expected,'Output.Report',inv))+'\n'
  P.BASE.strict_equal(P.normalize(raw,inv,join),expected)
  (HERE/(role+'-synthetic.stdout')).write_text(raw)
  controls=[]
  for category in (('plain','transient','constructed') if role=='normal' else ()):
   for label in ('row-value','row-handle','cursor','disabled','repeat','owner-clock','owner-registry'):
    bad=copy.deepcopy(expected)
    outcome=bad['Reported']['report']['previous']['inventory'][category]['Reported']
    observations=outcome['detached']
    observation=observations[0]['Some']
    if label=='row-value':observation['base'][0]['data']['left']['left']['Found']['values'][0]+=1
    elif label=='row-handle':observation['base'][0]['entity']['namespace']+=1
    elif label=='cursor':observation['cursor']=1
    elif label=='disabled':observations[2]={'Some':copy.deepcopy(observation)}
    elif label=='repeat':observations[1]['Some']['base']=[]
    elif label=='owner-clock':outcome['detachedOwners'][1]['world']['clock']+=1
    else:outcome['detachedOwners'][1]['registries'][0]['cursor']+=1
    broken=render(inverse(bad,'Output.Report',inv))+'\n'
    assert P.normalize(broken,inv,join)!=expected
    controls.append(category+':'+label)
  try:P.normalize(raw+' None{}',inv,join)
  except ValueError:controls.append('trailing')
  else:raise AssertionError('trailing')
  checks[role]={'bytes':len(raw.encode()),'wholeRoundtrip':True,'rejectedCorruptions':controls}
 checks['status']='PRE_RUNTIME_MODEL_ONLY'
 (HERE/'TRANSPORT-CHECKS.json').write_text(json.dumps(checks,indent=2)+'\n')
 print('three complete whole roundtrips; 24 observation/owner/trailing corruptions rejected')
