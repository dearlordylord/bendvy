"""Independent complete typed synthetic transport, no backend."""
import importlib.util,json,copy
from pathlib import Path
HERE=Path(__file__).resolve().parent
SUBJECT=Path('/workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1')
def load(name,path):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
I=load('inverse',HERE.parent/'synthetic-raw.py');P=load('parser',SUBJECT/'parse-graph-machine.py');I.P=P
join=copy.deepcopy(I.join);records=join['recordsStripTagExactOrderedFields'];records['Inventory.Complete']=records['Output.Report'];records['Output.Report']=['inventory','resource','graphMachine']
records.update({'Graph.Report':['factoryNext','reservations','activations','queueOutcome','relationError','snapshots','descriptions'],'Graph.Description':['ordinary','relations','machines'],'Graph.MachineEntry':['name'],'Graph.Descriptor':['key','name','inverseName','kind'],'Graph.Graph':['edges','inverses'],'Graph.Edge':['relation','source','target'],'Graph.Inverse':['relation','target','sources'],'Graph.ResourceView':['array','slot','graph','relation'],'Graph.Handle':['namespace','id'],'Graph.Snapshot':['namespace','nextId','highWater','capacity','depth','liveBits','store','resource','events','pendingCount','registrations','nextSystemId','clock']})
join['taggedExactFieldNames'].update({'Graph.Reported':['report'],'Graph.Present':['current','pending','previous','changed'],'Graph.Queued':['value','skipSame'],'Graph.Reserved':['handle']});join['preserveEmptyTags']+=['Boot','Play','NoPending','Ordinary','Hierarchy','Success','MachineMissing'];I.join=join
if __name__=='__main__':
 (HERE/'CONSTRUCTOR-JOIN.json').write_text(json.dumps(join,indent=2)+'\n')
 for role,ids,expected in [('normal','main-identities.json','expected.json'),('mutant','drop-relations-identities.json','drop-relations-expected.json')]:
  inventory=json.loads((SUBJECT/ids).read_text());assert inventory==P.build_identities(Path(inventory['entrypoint']));value=json.loads((HERE/expected).read_text());raw=I.render(I.inverse(value,'Output.Report',inventory))+'\n';P.BASE.strict_equal(P.normalize(raw,inventory,join),value);(HERE/(role+'-synthetic.stdout')).write_text(raw);print(role,len(raw.encode()),'whole typed PASS')

  for label,broken in [('tail',raw+' None{}'),('nominal',raw.replace('Hierarchy{}','Ordinary{}',1))]:
   try:actual=P.normalize(broken,inventory,join);P.BASE.strict_equal(actual,value)
   except (ValueError,AssertionError):pass
   else:raise AssertionError(label+' corruption escaped whole gate')
  changed=copy.deepcopy(value);changed['graphMachine']['Reported']['report']['snapshots'][-1]['resource']['array']['values'][-1]=999
  altered=I.render(I.inverse(changed,'Output.Report',inventory))+'\n';assert P.normalize(altered,inventory,join)!=value
  print(role,'tail/graph-kind/last-affine-cell controls PASS')
