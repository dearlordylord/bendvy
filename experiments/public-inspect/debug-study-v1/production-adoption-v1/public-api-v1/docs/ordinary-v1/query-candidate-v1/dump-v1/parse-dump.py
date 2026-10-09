#!/usr/bin/env python3
"""Typed complete dump fixture transport; expected data remains independent."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('dump_canonical_typed', HERE.parent / 'parse-scenario.py')
BASE = importlib.util.module_from_spec(spec)
spec.loader.exec_module(BASE)
L, M = BASE.L, BASE.M
BASE.FIELD_TYPES.update({
    'Output.Report': ['Dump.Kept', 'Dump.Kept', 'Dump.Kept'],
    'Dump.Kept': ['Dump.ReaderSnapshot', 'Dump.Reported'],
    'Dump.ReaderSnapshot': ['U32', 'Nat'],
    'Dump.Reported': ['Dump.Report'],
    'Dump.Report': ['ScenarioReport', L('Snapshot'), L(M('Dump.Population'))],
    'Dump.Population': [L('Clause'), L('Dump.Row')],
    'Dump.Row': ['Dump.Handle', ('Access', 'FullCell'), M('Dump.WorldError')],
    'Dump.Handle': ['U32', 'U32'],
})
BASE.GROUPS['Dump.WorldError'] = ['MissingEntity', 'CapacityExceeded', 'NamespaceExhausted', 'SystemIdExhausted']


def build_identities(entrypoint):
    entry, imports, namespaces, hashes = BASE.source_inventory(entrypoint)
    old = BASE.build_identities(HERE.parent / 'scenario-main.bend')
    _, _, old_namespaces, _ = BASE.source_inventory(HERE.parent / 'scenario-main.bend')
    constructors = {}
    base_tokens = {'Some', 'None', 'Done', 'Fail', 'Unit', 'True', 'False'}
    for token, semantic in old['constructors'].items():
        if semantic.startswith('Output.'):
            continue
        if token in base_tokens:
            constructors[token] = semantic
            continue
        sources = [(source, ns) for source, ns in old_namespaces.items() if ns and token.startswith(ns + '.')]
        if not sources:
            raise ValueError('Unbound inherited constructor identity')
        source, ns = max(sources, key=lambda pair: len(pair[1]))
        if source not in namespaces:
            raise ValueError('Inherited source missing from exact dump graph')
        constructors[namespaces[source] + '.' + token[len(ns) + 1:]] = semantic

    def add(source, raw, semantic):
        prefix = namespaces[source]
        token = (prefix + '.' if prefix else '') + raw
        if token in constructors:
            raise ValueError('Constructor identity collision')
        constructors[token] = semantic

    add(entry, 'Output', 'Output.Report')
    for raw in ('Kept', 'ReaderSnapshot', 'Reported', 'Report'):
        add(entry, raw, 'Dump.' + raw)
    for raw in ('Failed', 'SeedFailed'):
        add(entry, raw, 'Output.Failure')
    dump = imports[entry]['D']
    for raw in ('Population', 'Row'):
        add(dump, raw, 'Dump.' + raw)
    world = imports[dump]['W']
    add(world, 'Handle', 'Dump.Handle')
    for raw in BASE.GROUPS['Dump.WorldError']:
        add(world, raw, raw)
    return {'entrypoint': str(entry), 'constructors': constructors, 'sourceSHA256': hashes,
            'sourceImports': {str(source): {alias: str(child) for alias, child in aliases.items()} for source, aliases in imports.items()},
            'scope': 'Complete dump constructor identities from source, no output-derived aliases'}


def normalize(raw, inventory, join):
    return BASE.normalize(BASE.parse_term(raw), inventory['constructors'], join)


def main():
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest='command', required=True)
    identities = sub.add_parser('identities')
    identities.add_argument('entrypoint')
    identities.add_argument('output')
    compare = sub.add_parser('compare')
    for name in ('raw', 'inventory', 'join', 'expected'):
        compare.add_argument(name)
    args = parser.parse_args()
    if args.command == 'identities':
        Path(args.output).write_text(json.dumps(build_identities(args.entrypoint), indent=2) + '\n')
        return
    inventory = json.loads(Path(args.inventory).read_text())
    if inventory != build_identities(inventory['entrypoint']):
        raise ValueError('Dump constructor/source inventory drift')
    join = json.loads(Path(args.join).read_text())
    expected = Path(args.expected).read_bytes()
    if hashlib.sha256(expected).hexdigest() != join['expectedSHA256']:
        raise ValueError('Independent complete expected digest mismatch')
    actual = normalize(Path(args.raw).read_text(), inventory, join)
    BASE.strict_equal(actual, json.loads(expected))
    print('Complete typed dump observation equals independent oracle')


if __name__ == '__main__':
    main()
