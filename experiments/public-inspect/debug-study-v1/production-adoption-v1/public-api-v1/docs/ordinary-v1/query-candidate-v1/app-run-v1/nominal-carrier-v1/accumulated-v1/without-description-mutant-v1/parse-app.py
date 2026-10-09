#!/usr/bin/env python3
"""Strict inherited full DTO parser with explicit reverse-closure source transport."""
import importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('clean_accumulated_app',HERE.parent/'parse-app.py')
CLEAN=importlib.util.module_from_spec(spec);spec.loader.exec_module(CLEAN)
BASE=CLEAN.BASE

def build_identities(entrypoint):
    source_map=json.loads((HERE/'SOURCE-MAP.json').read_text())['sourceMap']
    clean_entry=HERE.parent/'main.bend'
    old=CLEAN.build_identities(clean_entry)
    _,_,old_ns,_=BASE.source_inventory(clean_entry)
    entry,imports,namespaces,hashes=BASE.source_inventory(entrypoint)
    constructors={}
    base={'Some','None','Done','Fail','Unit','True','False'}
    for token,semantic in old['constructors'].items():
        if token in base: constructors[token]=semantic;continue
        if token=='Complete': source=clean_entry.resolve();raw='Complete'
        else:
            choices=[(source,ns)for source,ns in old_ns.items()if ns and token.startswith(ns+'.')]
            if not choices:raise ValueError('No exact clean source constructor')
            source,ns=max(choices,key=lambda pair:len(pair[1]));raw=token[len(ns)+1:]
        actual=Path(source_map.get(str(source),str(source))).resolve(strict=True)
        if actual not in namespaces:raise ValueError('Mapped source absent from actual import graph')
        prefix=namespaces[actual];name=(prefix+'.'if prefix else'')+raw
        if name in constructors:raise ValueError('Mapped constructor collision')
        constructors[name]=semantic
    return {'entrypoint':str(entry),'constructors':constructors,'sourceSHA256':hashes,
      'sourceImports':{str(source):{alias:str(child)for alias,child in aliases.items()}for source,aliases in imports.items()},
      'scope':'Exact source-map transport of complete clean typed DTO identities; no backend output'}

def normalize(raw,inventory,join,category=None):return CLEAN.normalize(raw,inventory,join,category)
