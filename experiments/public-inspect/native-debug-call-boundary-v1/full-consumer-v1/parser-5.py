#!/usr/bin/env python3
"""Exact namespace relocation of the existing complete typed handler transport."""
import importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
SOURCE=HERE.parent
spec=importlib.util.spec_from_file_location('original_handler_transport',SOURCE/'parse-handlers.py')
ORIGINAL=importlib.util.module_from_spec(spec);SOURCE_LOADER(spec.origin,ORIGINAL)
BASE=ORIGINAL.BASE

def build_identities(entrypoint):
 manifest=json.loads((HERE/'FULL-CONSUMER.json').read_text())
 mapping={Path(old).resolve():Path(new).resolve()for old,new in manifest['sourceMapping'].items()}
 entry,imports,namespaces,hashes=BASE.source_inventory(entrypoint)
 admitted={Path(manifest['entrypoint']).resolve():SOURCE/'main.bend',Path(manifest['mutantEntrypoint']).resolve():SOURCE/'main-drop-handlers.bend'}
 if entry not in admitted:raise ValueError('Exact complete recursive successor entry required')
 oldentry=admitted[entry];old=ORIGINAL.build_identities(oldentry)
 _,_,oldnames,_=BASE.source_inventory(oldentry)
 constructors={};primitive={'Some','None','Done','Fail','Unit','True','False'}
 for token,semantic in old['constructors'].items():
  if token in primitive:constructors[token]=semantic;continue
  choices=[(source,ns)for source,ns in oldnames.items()if ns and token.startswith(ns+'.')]
  if choices:source,ns=max(choices,key=lambda pair:len(pair[1]));raw=token[len(ns)+1:]
  else:source,raw=oldentry.resolve(),token
  target=mapping.get(source,source)
  if target not in namespaces:raise ValueError('Missing original observed source: '+str(source))
  prefix=namespaces[target];new=(prefix+'.'if prefix else '')+raw
  if new in constructors:raise ValueError('Relocated constructor collision')
  constructors[new]=semantic
 return {'entrypoint':str(entry),'constructors':constructors,'sourceSHA256':hashes,'sourceImports':{str(s):{a:str(c)for a,c in d.items()}for s,d in imports.items()},'scope':'Entire unchanged1f54/f4eb reports; recursive registration carrier only'}

def normalize(raw,inventory,join):
 if inventory!=build_identities(Path(inventory['entrypoint'])):raise ValueError('Exact successor source/constructor binding changed')
 BASE.GROUPS['Output.Report']=['Handler.Reported']
 return BASE.normalize(BASE.parse_term(raw),inventory['constructors'],join)
