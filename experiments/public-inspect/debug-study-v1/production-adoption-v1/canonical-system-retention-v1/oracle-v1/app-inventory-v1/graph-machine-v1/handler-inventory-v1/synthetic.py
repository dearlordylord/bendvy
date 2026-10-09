"""Independent complete pre-backend typed handler synthetic and corruption controls."""
import copy,json,importlib.util
from pathlib import Path
HERE=Path(__file__).resolve().parent
Q=Path("experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1")
SUBJECT=Path('/workspace/formal-proofs/bendvy-worktrees/ordinary-system-retention/experiments/public-inspect/debug-study-v1/production-adoption-v1/canonical-system-retention-v1/consumer/app-inventory-v1/graph-machine-v1/handler-inventory-v1')
s=importlib.util.spec_from_file_location("handler",SUBJECT/"parse-handlers.py");P=importlib.util.module_from_spec(s);s.loader.exec_module(P)
join=json.loads((HERE.parent/"CONSTRUCTOR-JOIN.json").read_text())
r=join["recordsStripTagExactOrderedFields"]
r["Previous.Complete"]=r["Output.Report"]
r.update({"Handler.Complete":["previous","handlers"],"Handler.Report":["factoryNext","snapshots","descriptions","status","owners"],"Handler.Description":["ordinary","machine","handlers"],"Handler.BundleView":["namespace","entries"],"Handler.EntryView":["selector","requirements","registry"],"Handler.RegistryView":["ordinal","namespace","id","name","access","cursor"],"Handler.RecoveryView":["entries","positions","kept","owners"],"Handler.OwnersView":["exit","transition","enter"],"Handler.Position":["selector","requirements","choice"]})
join["taggedExactFieldNames"].update({"Handler.Reported":["report"],"Handler.ExitFrom":["value"],"Handler.TransitionPair":["from","to"],"Handler.EnterTo":["value"],"Handler.Returned":["bundle"],"Handler.InternalRemainder":["namespace","recovery"],"Handler.HandlerFailed":["phase","error"],"Handler.MissingRequirements":["missing"],**{"Handler."+k:[] for k in ("Completed","ForeignBundle","MachineUnavailable","Kept","SelectedExit","SelectedTransition","SelectedEnter","Exit","Transition","Enter")}})
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
if __name__=="__main__":
 (HERE/"CONSTRUCTOR-JOIN.json").write_text(json.dumps(join,indent=2)+"\n")
 for role,ids,model in [("normal","main-identities.json","expected.json"),("mutant","drop-handlers-identities.json","drop-handlers-expected.json")]:
  inv=json.loads((SUBJECT/ids).read_text());assert inv==P.build_identities(Path(inv["entrypoint"]))
  expected=json.loads((HERE/model).read_text());raw=render(inverse(expected,"Output.Report",inv))+"\n"
  P.BASE.strict_equal(P.normalize(raw,inv,join),expected);(HERE/(role+"-synthetic.stdout")).write_text(raw)
  for label,broken in [("trailing",raw+" None{}"),("empty-status-string",raw.replace(next(t for t,v in inv["constructors"].items() if v=="Handler.Completed")+"{}",'"Completed"',1))]:
   try:P.BASE.strict_equal(P.normalize(broken,inv,join),expected)
   except(ValueError,AssertionError):pass
   else:raise AssertionError(label)
  modified=copy.deepcopy(expected);modified["Reported"]["report"]["handlers"]["owners"]["Returned"]["bundle"]["entries"][-1]["registry"]["cursor"]=999
  bad=render(inverse(modified,"Output.Report",inv))+"\n";assert P.normalize(bad,inv,join)!=expected
  print(role,len(raw.encode()),"whole typed PASS; trailing/status-context/returned-owner controls PASS")
