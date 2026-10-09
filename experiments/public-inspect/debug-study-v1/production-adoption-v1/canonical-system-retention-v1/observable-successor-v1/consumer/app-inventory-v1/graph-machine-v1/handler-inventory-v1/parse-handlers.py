#!/usr/bin/env python3
"""Source-bound full machine handler inventory transport; no output-derived repair."""
import importlib.util
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('handler_graph_prior',HERE.parent/'parse-graph-machine.py')
PRIOR=importlib.util.module_from_spec(spec);spec.loader.exec_module(PRIOR)
BASE=PRIOR.BASE
L,M=BASE.L,BASE.M
BASE.FIELD_TYPES['Previous.Complete']=list(BASE.FIELD_TYPES['Output.Report'])
BASE.FIELD_TYPES.update({
 'Handler.Reported':['Handler.Complete'],
 'Handler.Complete':['Previous.Complete','Handler.Report'],
 'Handler.Report':['U32',L('Graph.Snapshot'),L(M('Handler.Description')),'Handler.Status','Handler.OwnerView'],
 'Handler.Description':['Graph.Description','String','Handler.BundleView'],
 'Handler.BundleView':['U32',L('Handler.EntryView')],
 'Handler.EntryView':['Handler.Selector',L('Requirement'),'Handler.RegistryView'],
 'Handler.RegistryView':['U32','U32','U32','String',L('String'),'U32'],
 'Handler.ExitFrom':['Graph.State'],'Handler.TransitionPair':['Graph.State','Graph.State'],'Handler.EnterTo':['Graph.State'],
 'Handler.Returned':['Handler.BundleView'],
 'Handler.InternalRemainder':['U32','Handler.RecoveryView'],
 'Handler.RecoveryView':[L('Handler.EntryView'),L('Handler.Position'),L('Handler.RegistryView'),'Handler.OwnersView'],
 'Handler.OwnersView':[L('Handler.RegistryView'),L('Handler.RegistryView'),L('Handler.RegistryView')],
 'Handler.Position':['Handler.Selector',L('Requirement'),'Handler.Choice'],
 'Handler.HandlerFailed':['Handler.Phase','String'],
 'Handler.MissingRequirements':[L('Requirement')],
})
BASE.GROUPS.update({
 'Output.Report':['Handler.Reported'],
 'Handler.Status':['Handler.Completed','Handler.HandlerFailed','Handler.MissingRequirements','Handler.ForeignBundle','Handler.MachineUnavailable'],
 'Handler.OwnerView':['Handler.Returned','Handler.InternalRemainder'],
 'Handler.Selector':['Handler.ExitFrom','Handler.TransitionPair','Handler.EnterTo'],
 'Handler.Choice':['Handler.Kept','Handler.SelectedExit','Handler.SelectedTransition','Handler.SelectedEnter'],
 'Handler.Phase':['Handler.Exit','Handler.Transition','Handler.Enter'],
})
def build_identities(entrypoint):
 entry,imports,namespaces,hashes=BASE.source_inventory(entrypoint)
 if entry.parent!=HERE or entry.name not in ('main.bend','main-drop-handlers.bend'):
  raise ValueError('Exact complete handler consuming entry required')
 oldentry=HERE.parent/'main.bend';old=PRIOR.build_identities(oldentry)
 _,_,oldnames,_=BASE.source_inventory(oldentry)
 constructors={};primitive={'Some','None','Done','Fail','Unit','True','False'}
 for token,semantic in old['constructors'].items():
  if token in primitive:constructors[token]=semantic;continue
  choices=[(source,ns)for source,ns in oldnames.items()if ns and token.startswith(ns+'.')]
  if choices:source,ns=max(choices,key=lambda pair:len(pair[1]));raw=token[len(ns)+1:]
  else:source,raw=oldentry.resolve(),token
  if source not in namespaces:continue
  prefix=namespaces[source];new=(prefix+'.'if prefix else '')+raw
  if source==oldentry.resolve()and semantic=='Output.Report':semantic='Previous.Complete'
  constructors[new]=semantic
 def add(source,raw,semantic):
  source=Path(source).resolve(strict=True);prefix=namespaces[source];token=(prefix+'.'if prefix else '')+raw
  if token in constructors and constructors[token]!=semantic:raise ValueError('Exact identity collision: '+token)
  constructors[token]=semantic
 fixture=imports[entry]['Fixture'];app=imports[entry]['HandlerApp'];inspect=imports[entry]['Inspect'];bundle=imports[entry]['B'];handler=imports[inspect]['H'];provision=imports[entry]['SP']
 for tag in ('Reported','Complete','Report','Returned','InternalRemainder'):add(entry,tag,'Handler.'+tag)
 for tag in ('SetupFailed','PreviousFailed'):add(entry,tag,'Output.Failure')
 add(app,'Description','Handler.Description')
 for tag in ('RegistryView','EntryView','BundleView','OwnersView','RecoveryView'):add(inspect,tag,'Handler.'+tag)
 for tag in ('ExitFrom','TransitionPair','EnterTo','Position','Kept','SelectedExit','SelectedTransition','SelectedEnter','Completed','HandlerFailed','MissingRequirements','ForeignBundle','MachineUnavailable'):add(bundle,tag,'Handler.'+tag)
 for tag in ('Exit','Transition','Enter'):add(handler,tag,'Handler.'+tag)
 for tag in ('Component','Resource','Service'):add(provision,tag,'Requirement.'+tag)
 return {'entrypoint':str(entry),'constructors':constructors,'sourceSHA256':hashes,'sourceImports':{str(s):{a:str(c)for a,c in d.items()}for s,d in imports.items()},'scope':'Entire unchanged previous graph report plus actual typed handlers, full world and owner/status observations'}
def normalize(raw,inventory,join):
 if inventory!=build_identities(Path(inventory['entrypoint'])):raise ValueError('Exact source/constructor binding changed')
 BASE.GROUPS['Output.Report']=['Handler.Reported']
 return BASE.normalize(BASE.parse_term(raw),inventory['constructors'],join)
