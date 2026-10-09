"""Exact constructor relocation from old complete source inventory, no runtime output."""
import json
from pathlib import Path

def derive(P,original_inventory,candidate_entry):
 old=json.loads(Path(original_inventory).read_text())
 oldentry,_,oldnames,oldhash=P.BASE.source_inventory(old['entrypoint'])
 if oldhash!=old['sourceSHA256']:raise ValueError('original inventory source drift')
 entry,imports,namespaces,hashes=P.BASE.source_inventory(candidate_entry)
 if len(hashes)!=len(oldhash)or any(d!=oldhash[k]for k,d in hashes.items()if k!=str(entry)):raise ValueError('entry-only consuming source boundary changed')
 constructors={};mapping=[]
 for token,semantic in old['constructors'].items():
  source=None
  if token in {'Some','None','Done','Fail','Unit','True','False'}:newtoken=token
  else:
   choices=[(s,ns)for s,ns in oldnames.items()if ns and token.startswith(ns+'.')]
   if choices:source,prefix=max(choices,key=lambda x:len(x[1]));raw=token[len(prefix)+1:]
   else:source,raw=oldentry,token
   target=entry if source==oldentry else source;prefix=namespaces[target];newtoken=(prefix+'.'if prefix else '')+raw
  if newtoken in constructors:raise ValueError('constructor relocation collision')
  constructors[newtoken]=semantic;mapping.append(dict(originalToken=token,candidateToken=newtoken,semantic=semantic,source=None if source is None else str(source)))
 return dict(entrypoint=str(entry),constructors=constructors,sourceSHA256=hashes,sourceImports={str(k):{a:str(v)for a,v in row.items()}for k,row in imports.items()},namespaces={str(k):v for k,v in namespaces.items()},sourceDerivedConstructorRelocation=mapping,originalInventory=str(original_inventory),scope='Exact old observed constructor semantic mapping; entry-only private carriers; no output qualification')
