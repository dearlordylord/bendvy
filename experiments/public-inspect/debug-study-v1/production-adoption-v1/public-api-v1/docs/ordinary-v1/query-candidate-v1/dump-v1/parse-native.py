#!/usr/bin/env python3
"""Exact single-category compile partition, without omitted DTO observations."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('whole_dump_transport',HERE/'parse-dump.py')
P=importlib.util.module_from_spec(spec)
spec.loader.exec_module(P)
BASE=P.BASE
CATEGORIES=('plain','transient','constructed')


def build_identities(entrypoint):
    entry,imports,namespaces,hashes=BASE.source_inventory(entrypoint)
    if entry.parent!=HERE/'native-entries-v1' or entry.stem not in CATEGORIES:
        raise ValueError('Unknown admitted native category entry')
    original=HERE/'main.bend'
    if imports[entry]['Fixture']!=original:
        raise ValueError('Native entry must consume exact whole fixture implementation')
    old=P.build_identities(original)
    _,_,old_ns,_=BASE.source_inventory(original)
    constructors={}
    for token,semantic in old['constructors'].items():
        if token in {'Some','None','Done','Fail','Unit','True','False'}:
            constructors[token]=semantic
            continue
        candidates=[(source,ns) for source,ns in old_ns.items() if ns and token.startswith(ns+'.')]
        if candidates:
            source,ns=max(candidates,key=lambda pair:len(pair[1]))
            raw=token[len(ns)+1:]
        else:
            source,raw=original,token
        if source not in namespaces:
            raise ValueError('Whole DTO source absent from native category closure')
        constructors[namespaces[source]+'.'+raw]=semantic
    return {'entrypoint':str(entry),'category':entry.stem,'constructors':constructors,'sourceSHA256':hashes,
            'sourceImports':{str(source):{alias:str(child) for alias,child in aliases.items()} for source,aliases in imports.items()},
            'scope':'Same complete consuming category operations; namespaces from exact original native entry'}


def normalize(raw,inventory,join,category):
    if category not in CATEGORIES or inventory['category']!=category:
        raise ValueError('Actual native partition category mismatch')
    parsed=BASE.parse_term(raw)
    if not isinstance(parsed,dict) or set(parsed)!={'constructor','fields'} or inventory['constructors'].get(parsed['constructor'])!='Dump.Kept':
        raise ValueError('Exact complete successful native ReaderOutcome required')
    root='__internal_partition_typed_root__'
    if root in inventory['constructors']:
        raise ValueError('Internal transport root collision')
    # This synthetic root supplies type context only. No data is fabricated or
    # defaulted: the complete actual category term is converted, then returned.
    context={'constructor':root,'fields':[parsed,parsed,parsed]}
    converted=BASE.normalize(context,{**inventory['constructors'],root:'Output.Report'},join)
    return converted['plain']


def main():
    parser=argparse.ArgumentParser()
    sub=parser.add_subparsers(dest='command',required=True)
    ids=sub.add_parser('identities')
    ids.add_argument('entrypoint');ids.add_argument('output')
    compare=sub.add_parser('compare')
    for name in ('raw','inventory','join','expected','category'):compare.add_argument(name)
    args=parser.parse_args()
    if args.command=='identities':
        Path(args.output).write_text(json.dumps(build_identities(Path(args.entrypoint).resolve()),indent=2)+'\n')
        return
    inventory=json.loads(Path(args.inventory).read_text())
    if inventory!=build_identities(Path(inventory['entrypoint'])):
        raise ValueError('Native category source/constructor inventory drift')
    join=json.loads(Path(args.join).read_text())
    expected=Path(args.expected).read_bytes()
    if hashlib.sha256(expected).hexdigest()!=join['expectedSHA256']:
        raise ValueError('Independent complete expected digest mismatch')
    actual=normalize(Path(args.raw).read_text(),inventory,join,args.category)
    BASE.strict_equal(actual,json.loads(expected)[args.category])
    print('Complete actual native category DTO equals unchanged full oracle slice')


if __name__=='__main__':main()
