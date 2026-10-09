#!/usr/bin/env python3
"""Complete source-bound graph/machine inventory transport, pre-output only."""
import importlib.util
import json
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('graph_inventory_prior',HERE.parent/'parse-inventory.py')
PRIOR=importlib.util.module_from_spec(spec);spec.loader.exec_module(PRIOR)
BASE=PRIOR.BASE
L,M=BASE.L,BASE.M
BASE.FIELD_TYPES['Inventory.Complete']=list(BASE.FIELD_TYPES['Output.Report'])
BASE.FIELD_TYPES.update({
 'Output.Report':['Inventory.Complete','Resource.Reported','Graph.Outcome'],
 'Graph.Reported':['Graph.Report'],
 'Graph.Report':['U32',L('Graph.Reservation'),L('Graph.Status'),'Graph.QueueOutcome',M('Graph.Error'),L('Graph.Snapshot'),L(M('Graph.Description'))],
 'Graph.Description':['Inventory.Description',L('Graph.Descriptor'),L('Graph.MachineEntry')],
 'Graph.MachineEntry':['String'],
 'Graph.Descriptor':['U32','String','String','Graph.RelationKind'],
 'Graph.Graph':[L('Graph.Edge'),L('Graph.Inverse')],
 'Graph.Edge':['Graph.Descriptor','U32','U32'],
 'Graph.Inverse':['Graph.Descriptor','U32',L('U32')],
 'Graph.ResourceView':['FullCell','Graph.Slot','Graph.Graph','Graph.Descriptor'],
 'Graph.Present':['Graph.State','Graph.Pending',M('Graph.State'),'Bool'],
 'Graph.Queued':['Graph.State','Bool'],
 'Graph.Reserved':['Graph.Handle'],
 'Graph.Handle':['U32','U32'],
 'Graph.Snapshot':['U32','U32','U32','U32','Nat',L('Bool'),'Unit','Graph.ResourceView',L('Unit'),'U32',L('RegistrationMeta'),'U32','U32'],
})
BASE.GROUPS.update({'Graph.Outcome':['Graph.Reported'],'Graph.State':['Boot','Play'],
 'Graph.Pending':['NoPending','Graph.Queued'],'Graph.Slot':['MachineMissing','Graph.Present'],
 'Graph.RelationKind':['Ordinary','Hierarchy'],'Graph.Reservation':['Graph.Reserved'],
 'Graph.Status':['Accepted'],'Graph.QueueOutcome':['Success']})

def build_identities(entrypoint):
 entry,imports,namespaces,hashes=BASE.source_inventory(entrypoint)
 if entry.name not in ('main.bend','main-inspector-filter.bend') or entry.parent not in (HERE,HERE/'mutants/drop-relations'):
  raise ValueError('Exact whole graph/machine entry required')
 constructors={};primitive={'Some','None','Done','Fail','Unit','True','False'}
 for oldentry in (HERE.parent/('main-inspector-filter.bend' if entry.name=='main-inspector-filter.bend' else 'main.bend'),HERE.parent/'resource-main.bend'):
  old=PRIOR.build_identities(oldentry)
  _,_,oldnames,_=BASE.source_inventory(oldentry)
  for token,semantic in old['constructors'].items():
   if token in primitive:constructors[token]=semantic;continue
   choices=[(source,ns)for source,ns in oldnames.items()if ns and token.startswith(ns+'.')]
   if choices:
    source,ns=max(choices,key=lambda pair:len(pair[1]));raw=token[len(ns)+1:]
   else:source,raw=oldentry.resolve(),token
   if source not in namespaces:continue
   prefix=namespaces[source];new=(prefix+'.' if prefix else '')+raw
   if source==oldentry.resolve() and semantic=='Output.Report':semantic='Inventory.Complete'
   if new in constructors and constructors[new]!=semantic:raise ValueError('Inherited source identity collision')
   constructors[new]=semantic
 def add(source,raw,semantic):
  source=Path(source).resolve(strict=True);prefix=namespaces[source];token=(prefix+'.' if prefix else '')+raw
  if token in constructors and constructors[token]!=semantic:raise ValueError('Source identity collision')
  constructors[token]=semantic
 fixture=imports[entry]['Fixture'];app=imports[fixture]['App'];schema=imports[app]['Schema'];types=imports[fixture]['T'];observe=imports[fixture]['Observe'];rel=imports[types]['Rel'];machine=imports[types]['M'];world=imports[entry]['W'];tx=imports[types]['Tx']
 add(entry,'Complete','Output.Report');add(entry,'Reported','Graph.Reported')
 for raw in ('BuildFailed','CreateFailed'):add(entry,raw,'Output.Failure')
 add(fixture,'Report','Graph.Report');add(app,'Description','Graph.Description');add(schema,'MachineEntry','Graph.MachineEntry');add(types,'ResourceView','Graph.ResourceView');add(observe,'Snapshot','Graph.Snapshot')
 for raw in ('Descriptor','Graph','Edge','Inverse'):add(rel,raw,'Graph.'+raw)
 for raw in ('Ordinary','Hierarchy'):add(rel,raw,raw)
 add(machine,'Present','Graph.Present');add(machine,'Missing','MachineMissing');add(machine,'Queued','Graph.Queued');add(machine,'NoPending','NoPending')
 for raw in ('Boot','Play'):add(types,raw,raw)
 add(tx,'Success','Success');add(tx,'Failure','Output.Failure');add(world,'Reserved','Graph.Reserved');add(world,'Handle','Graph.Handle');add(world,'ReservationRejected','Output.Failure');add(world,'Rejected','Output.Failure');add(world,'Accepted','Accepted')
 return {'entrypoint':str(entry),'constructors':constructors,'sourceSHA256':hashes,'sourceImports':{str(s):{a:str(c)for a,c in d.items()}for s,d in imports.items()},'scope':'Complete prior inventory/resource plus actual graph-machine fixture; source-derived positive transport, no output basis'}

def normalize(raw,inventory,join):
 if inventory!=build_identities(Path(inventory['entrypoint'])):raise ValueError('Exact whole source/constructor binding changed')
 BASE.GROUPS['Output.Report']=['Output.Report']
 return BASE.normalize(BASE.parse_term(raw),inventory['constructors'],join)
