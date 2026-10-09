"""No-backend full independent model and typed corruption controls."""
import copy,importlib.util,json,os
from pathlib import Path
HERE=Path(__file__).resolve().parent
ORACLE_ROOT=Path('/workspace/formal-proofs/bendvy-worktrees/ordinary-system-retention')
ORACLE=Path('/workspace/formal-proofs/bendvy-worktrees/ordinary-system-retention/experiments/public-inspect/debug-study-v1/production-adoption-v1/canonical-system-retention-v1/oracle-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1')
s=importlib.util.spec_from_file_location('independent_handlers_synthetic',ORACLE/'synthetic.py');S=importlib.util.module_from_spec(s)
old=Path.cwd()
try:os.chdir(ORACLE_ROOT);s.loader.exec_module(S)
finally:os.chdir(old)
checks=[]
for role,ids,expected in [('normal','main-identities.json','expected.json'),('mutant','drop-handlers-identities.json','drop-handlers-expected.json')]:
 inventory=json.loads((HERE/ids).read_text());join=json.loads((ORACLE/'CONSTRUCTOR-JOIN.json').read_text());value=json.loads((ORACLE/expected).read_text());raw=(ORACLE/(role+'-synthetic.stdout')).read_text();S.P.BASE.strict_equal(S.P.normalize(raw,inventory,join),value)
 def reject(name,broken):
  try:S.P.BASE.strict_equal(S.P.normalize(broken,inventory,join),value)
  except(ValueError,AssertionError):checks.append(role+':'+name)
  else:raise AssertionError('Accepted full corruption '+name)
 root_token=next(t for t,v in inventory['constructors'].items()if v=='Handler.Reported')
 status=next(t for t,v in inventory['constructors'].items()if v=='Handler.Completed')
 for name,broken in [('trailingTerm',raw+' Unit{}'),('wrongRootNamespace',raw.replace(root_token+'{','Unknown.Reported{',1)),('boolAsU32',raw.replace('False{}','0',1)),('statusAsString',raw.replace(status+'{}','"Completed"',1))]:reject(name,broken)
 term=S.P.BASE.parse_term(raw);term['fields'][0]['fields'][0]['fields'][0]['fields'].pop();reject('omittedPreviousCategory',S.render(term)+'\n')
 for name,mutate in [
  ('omittedLastSnapshot',lambda report:report['handlers']['snapshots'].pop()),
  ('changedLastAffineCell',lambda report:report['handlers']['snapshots'][-1]['resource']['array']['values'].__setitem__(-1,999)),
  ('changedPendingPreservation',lambda report:report['handlers']['snapshots'][1].__setitem__('pendingCount',0)),
  ('changedMarkerMachineState',lambda report:report['handlers']['snapshots'][2]['resource']['slot']['Present'].__setitem__('changed',False)),
  ('changedReturnedRegistryCursor',lambda report:report['handlers']['owners']['Returned']['bundle']['entries'][-1]['registry'].__setitem__('cursor',999)),
  ('changedReturnedSelector',lambda report:report['handlers']['owners']['Returned']['bundle']['entries'][-1].__setitem__('selector',{'EnterTo':{'value':{'Boot':{}}}})),
  ('omittedReturnedRequirements',lambda report:report['handlers']['owners']['Returned']['bundle']['entries'][0]['requirements'].clear()),
  ('omittedReturnedAccess',lambda report:report['handlers']['owners']['Returned']['bundle']['entries'][0]['registry']['access'].clear()),
  ('disabledDescriptionExecuted',lambda report:report['handlers']['descriptions'].__setitem__(-1,copy.deepcopy(report['handlers']['descriptions'][0]))),
 ]:
  changed=copy.deepcopy(value);mutate(changed['Reported']['report'])
  broken=S.render(S.inverse(changed,'Output.Report',inventory))+'\n'
  reject(name,broken)
normal=json.loads((ORACLE/'expected.json').read_text());mutant=json.loads((ORACLE/'drop-handlers-expected.json').read_text())
try:S.P.BASE.strict_equal(mutant,normal)
except ValueError:checks.append('wholeReachedOmissionRejectsUnchangedBaseline')
else:raise AssertionError('Reached omission ignored')
result={'wholeTypedModels':2,'rejectedControls':checks,'actualBackendChildren':0,'scope':'Independent full typed models and corruptions; no runtime qualification'}
(HERE/'transport-controls.stdout').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
