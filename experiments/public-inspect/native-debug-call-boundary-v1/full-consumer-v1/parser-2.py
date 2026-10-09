#!/usr/bin/env python3
"""Source-indexed complete ordinary App inventory transport; no runtime output basis."""
import argparse
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
OLD = HERE.parent / 'app-run-v1/nominal-carrier-v1/accumulated-v1'
spec = importlib.util.spec_from_file_location('inventory_prior_app', OLD / 'parse-app.py')
PRIOR = importlib.util.module_from_spec(spec)
SOURCE_LOADER(spec.origin,PRIOR)
BASE = PRIOR.BASE
L, M = BASE.L, BASE.M
BASE.FIELD_TYPES.update({
    'Output.Report': ['Inventory.Outcome', 'Inventory.Outcome', 'Inventory.Outcome'],
    'Inventory.Reported': ['Inventory.Report'],
    'Inventory.Report': ['App.ScenarioReport', 'Inventory.Origin', L('Snapshot'), L(M('Inventory.Description'))],
    'Inventory.Origin': ['Inventory.Debug', L('Entry'), 'U32', 'String', L('Step'), L('Requirement')],
    'Inventory.Description': [L('Inventory.SchemaEntry'), 'U32', 'String', L('Step'), L('Inventory.Entry')],
    'Inventory.SchemaEntry': ['Inventory.RegistryKind', 'String', 'String'],
    'Inventory.Entry': ['U32', 'String', L('String'), 'String', L('Clause')],
    'Resource.Reported': ['Resource.Report'],
    'Resource.Report': ['U32', 'Resource.Snapshot', 'Resource.Snapshot', L(M('Inventory.Description'))],
    'Resource.Snapshot': ['U32', 'U32', 'U32', 'U32', 'Nat', L('Bool'), 'Unit', 'FullCell', L('Unit'), 'U32', L('RegistrationMeta'), 'U32', 'U32'],
})
BASE.GROUPS.update({
    'Inventory.Outcome': ['Inventory.Reported'],
    'Inventory.Debug': ['Enabled', 'Disabled'],
    'Inventory.RegistryKind': ['Component', 'Resource', 'Event', 'Relation', 'Service'],
})


def build_identities(entrypoint):
    entry, imports, namespaces, hashes = BASE.source_inventory(entrypoint)
    if entry.parent != HERE or entry.name not in ('main.bend', 'resource-main.bend'):
        raise ValueError('Exact source consuming inventory entry required')
    old = PRIOR.build_identities(OLD / 'main.bend')
    _, _, old_namespaces, _ = BASE.source_inventory(OLD / 'main.bend')
    constructors = {}
    primitive = {'Some', 'None', 'Done', 'Fail', 'Unit', 'True', 'False'}
    for token, semantic in old['constructors'].items():
        if token in primitive:
            constructors[token] = semantic
            continue
        candidates = [(source, ns) for source, ns in old_namespaces.items() if ns and token.startswith(ns + '.')]
        if not candidates:
            continue  # The prior bare Complete root is not this entrypoint.
        source, namespace = max(candidates, key=lambda pair: len(pair[1]))
        if source not in namespaces:
            continue
        prefix = namespaces[source]
        constructors[(prefix + '.' if prefix else '') + token[len(namespace) + 1:]] = semantic

    def add(source, raw, semantic):
        source = Path(source).resolve(strict=True)
        if source not in namespaces:
            raise ValueError('Unbound source constructor')
        prefix = namespaces[source]
        token = (prefix + '.' if prefix else '') + raw
        if token in constructors and constructors[token] != semantic:
            raise ValueError('Source constructor identity collision')
        constructors[token] = semantic

    app = imports[entry]['App']
    normal = imports[app]['Normal']
    fragment = imports[normal]['Fragment']
    add(app, 'Description', 'Inventory.Description')
    add(app, 'Entry', 'Inventory.Entry')
    add(fragment, 'Entry', 'Inventory.SchemaEntry')
    for raw in ('Component', 'Resource', 'Event', 'Relation', 'Service'):
        add(fragment, raw, raw)
    if entry.name == 'main.bend':
        original = imports[entry]['Original']
        for raw in ('Enabled', 'Disabled'):
            add(original, raw, raw)
        add(entry, 'Complete', 'Output.Report')
        add(entry, 'Reported', 'Inventory.Reported')
        add(entry, 'Report', 'Inventory.Report')
        add(entry, 'Origin', 'Inventory.Origin')
        for raw in ('PriorFailed', 'BuildFailed'):
            add(entry, raw, 'Output.Failure')
    else:
        add(entry, 'Reported', 'Resource.Reported')
        add(entry, 'Report', 'Resource.Report')
        add(entry, 'Snapshot', 'Resource.Snapshot')
        for raw in ('BuildRejected', 'CreateRejected'):
            add(entry, raw, 'Output.Failure')
    return {'entrypoint': str(entry), 'constructors': constructors, 'sourceSHA256': hashes,
            'sourceImports': {str(source): {alias: str(child) for alias, child in aliases.items()} for source, aliases in imports.items()},
            'scope': 'Strict complete positive consuming inventory transport; explicit fixture refusals reject the whole gate; no runtime output used'}


def normalize(raw, inventory, join):
    entry = Path(inventory['entrypoint'])
    if entry.parent != HERE or entry.name not in ('main.bend', 'resource-main.bend'):
        raise ValueError('Exact inventory entry required')
    # Only the source root group changes; all nested context-sensitive rules remain.
    BASE.GROUPS['Output.Report'] = ['Output.Report'] if entry.name == 'main.bend' else ['Resource.Reported']
    return BASE.normalize(BASE.parse_term(raw), inventory['constructors'], join)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('entrypoint', type=Path)
    parser.add_argument('identities', type=Path)
    args = parser.parse_args()
    if args.identities.exists():
        raise ValueError('Identity inventory must start absent')
    args.identities.write_text(json.dumps(build_identities(args.entrypoint), indent=2) + '\n')


if __name__ == '__main__':
    main()
