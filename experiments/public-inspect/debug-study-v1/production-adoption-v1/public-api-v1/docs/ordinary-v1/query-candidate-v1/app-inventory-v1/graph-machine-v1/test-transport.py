import copy,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ORACLE=Path('/workspace/formal-proofs/bendvy-worktrees/parity-58-snapshot-research/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/oracle-v1/app-inventory-v1/graph-machine-v1')
s=importlib.util.spec_from_file_location('independent_graph_synthetic',ORACLE/'synthetic.py');S=importlib.util.module_from_spec(s);s.loader.exec_module(S)
checks=[]
for role,ids,expected in [('normal','main-identities.json','expected.json'),('mutant','drop-relations-identities.json','drop-relations-expected.json')]:
 inventory=json.loads((HERE/ids).read_text());join=json.loads((ORACLE/'CONSTRUCTOR-JOIN.json').read_text());value=json.loads((ORACLE/expected).read_text());raw=(ORACLE/(role+'-synthetic.stdout')).read_text();S.P.BASE.strict_equal(S.P.normalize(raw,inventory,join),value)
 def reject(name,broken):
  try:S.P.BASE.strict_equal(S.P.normalize(broken,inventory,join),value)
  except ValueError:checks.append(role+':'+name)
  else:raise AssertionError('Accepted complete corruption '+name)
 for name,broken in [('trailingTerm',raw+' Unit{}'),('wrongRootNamespace',raw.replace('Complete{','Unknown.Complete{',1)),('boolAsU32',raw.replace('False{}','0',1))]:reject(name,broken)
 term=S.P.BASE.parse_term(raw);term['fields'][0]['fields'].pop();reject('missingPreviousCategory',S.I.render(term))
 for name,mutate in [
  ('omittedLastSnapshot',lambda report:report['snapshots'].pop()),
  ('changedLastAffineCell',lambda report:report['snapshots'][-1]['resource']['array']['values'].__setitem__(-1,999)),
  ('changedInverseSources',lambda report:report['snapshots'][-1]['resource']['graph']['inverses'][0]['sources'].clear()),
  ('changedPendingPreservation',lambda report:report['snapshots'][1].__setitem__('pendingCount',0)),
  ('changedQueuedMachineState',lambda report:report['snapshots'][1]['resource']['slot']['Present']['pending']['Queued'].__setitem__('skipSame',True)),
  ('changedDescriptorAuthority',lambda report:report['snapshots'][1]['resource']['relation'].__setitem__('key',8)),
 ]:
  changed=copy.deepcopy(value);mutate(changed['graphMachine']['Reported']['report']);reject(name,S.I.render(S.I.inverse(changed,'Output.Report',inventory))+'\n')
baseline=json.loads((ORACLE/'expected.json').read_text());mutant=json.loads((ORACLE/'drop-relations-expected.json').read_text())
try:S.P.BASE.strict_equal(mutant,baseline)
except ValueError:checks.append('wholeReachedOmissionRejectsUnchangedBaseline')
else:raise AssertionError('Omission ignored')
result=json.dumps({'wholeTypedModels':2,'rejectedControls':checks,'actualChildren':0,'scope':'Full independent source-derived synthetic controls, no runtime qualification'},indent=2)
(HERE/'transport-controls.stdout').write_text(result+'\n')
print(result)
