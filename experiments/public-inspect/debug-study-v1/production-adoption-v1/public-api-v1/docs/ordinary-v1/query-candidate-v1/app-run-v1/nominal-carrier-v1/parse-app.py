#!/usr/bin/env python3
"""Exact App fixture transport, extending the reviewed canonical typed parser."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('app_typed_canonical', HERE.parent.parent / 'parse-scenario.py')
BASE = importlib.util.module_from_spec(spec)
spec.loader.exec_module(BASE)
L, M = BASE.L, BASE.M
BASE.FIELD_TYPES.update({
    'Output.Report': ['App.Outcome', 'App.Outcome', 'App.Outcome'],
    'App.Report': ['App.ScenarioReport'],
    'App.ScenarioReport': ['String', 'ScenarioReport', L('App.Phase'), L('RegistrationMeta'), L('RegistrationMeta')],
    'App.Phase': ['String', 'App.Details', 'Snapshot'],
    'App.Details': ['App.Status', L('App.Observation'), 'App.Trace', 'U32', 'String', L('Step'), L('Requirement')],
    'App.Trace': ['U32', L('App.DispatchRecord')],
    'App.DispatchRecord': ['U32', 'Operation'],
    'App.Failed': ['ApplicationError'],
    'App.Missing': [L('Requirement')],
    'App.BodyFailure': ['U32', 'Error'],
    'App.RegistrationRefused': ['U32', 'RejectedArgs', 'WorldSnapshot', 'RegistrySnapshot'],
    'App.UnknownSystem': ['U32'],
    'Observation.Entered': ['String'],
    'Observation.Ran': ['U32'],
    'Observation.Skipped': ['U32'],
    'Requirement.Component': ['U32'],
    'Requirement.Resource': ['U32'],
    'Requirement.Service': ['U32'],
})
BASE.GROUPS.update({
    'App.Outcome': ['App.Report'],
    'App.Status': ['Finished', 'App.Failed', 'Rejected', 'App.Missing'],
    'App.Observation': ['Observation.Entered', 'Observation.Ran', 'Observation.Skipped', 'Applied'],
    'ApplicationError': ['App.BodyFailure', 'App.RegistrationRefused', 'App.UnknownSystem'],
    'Requirement': ['Requirement.Component', 'Requirement.Resource', 'Requirement.Service'],
})


def build_identities(entrypoint):
    entry, imports, namespaces, hashes = BASE.source_inventory(entrypoint)
    old = BASE.build_identities(HERE.parent.parent / 'scenario-main.bend')
    _, _, old_namespaces, _ = BASE.source_inventory(HERE.parent.parent / 'scenario-main.bend')
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
            raise ValueError('Unbound inherited exact constructor')
        source, ns = max(sources, key=lambda pair: len(pair[1]))
        raw = token[len(ns) + 1:]
        if source not in namespaces:
            raise ValueError('Inherited constructor source absent from actual App graph')
        constructors[namespaces[source] + '.' + raw] = semantic

    def add(source, raw, semantic):
        source = source.resolve(strict=True)
        if source not in namespaces:
            raise ValueError('Constructor source not imported by actual entry')
        prefix = namespaces[source]
        token = (prefix + '.' if prefix else '') + raw
        if token in constructors:
            raise ValueError('Exact constructor collision')
        constructors[token] = semantic

    if entry.name == 'main.bend':
        add(entry, 'Complete', 'Output.Report')
    elif entry.name not in ('plain.bend', 'transient.bend', 'constructed.bend'):
        raise ValueError('Unknown admitted App entry')
    add(HERE / 'output.bend', 'Report', 'App.Report')
    for raw in ('Failure', 'SeedFailure'):
        add(HERE / 'output.bend', raw, 'Output.Failure')
    add(HERE / 'scenario.bend', 'Report', 'App.ScenarioReport')
    add(HERE / 'observation.bend', 'Phase', 'App.Phase')
    for raw, semantic in [('Details', 'App.Details'), ('Finished', 'Finished'), ('Failed', 'App.Failed'), ('Rejected', 'Rejected'), ('Missing', 'App.Missing')]:
        add(HERE / 'application.bend', raw, semantic)
    for raw in ('Trace', 'DispatchRecord', 'BodyFailure', 'RegistrationRefused', 'UnknownSystem'):
        add(HERE / 'dispatch.bend', raw, 'App.' + raw)
    sch = imports[HERE / 'dispatch.bend']['Sch']
    for raw, semantic in [('Entered', 'Observation.Entered'), ('Ran', 'Observation.Ran'), ('Skipped', 'Observation.Skipped'), ('Applied', 'Applied')]:
        add(sch, raw, semantic)
    sp = imports[HERE / 'dispatch.bend']['SP']
    for raw in ('Component', 'Resource', 'Service'):
        add(sp, raw, 'Requirement.' + raw)
    return {'entrypoint': str(entry), 'constructors': constructors, 'sourceSHA256': hashes,
            'sourceImports': {str(source): {alias: str(child) for alias, child in aliases.items()} for source, aliases in imports.items()},
            'scope': 'Exact App constructor/import identities; no backend output used'}


def normalize(raw, inventory, join, category=None):
    term = BASE.parse_term(raw)
    if category is None:
        return BASE.normalize(term, inventory['constructors'], join)
    if category not in ('plain', 'transient', 'constructed'):
        raise ValueError('Unknown App partition category')
    if not isinstance(term, dict) or set(term) != {'constructor', 'fields'} or inventory['constructors'].get(term['constructor']) != 'App.Report':
        raise ValueError('Exact successful App partition report required')
    root = '__fixture_transport_complete__'
    if root in inventory['constructors']:
        raise ValueError('Synthetic transport identity collision')
    lifted = {'constructor': root, 'fields': [term, term, term]}
    complete = BASE.normalize(lifted, {**inventory['constructors'], root: 'Output.Report'}, join)
    result = complete['plain']
    if result['Report']['category'] != category:
        raise ValueError('Actual App partition category mismatch')
    return result


def main():
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest='command', required=True)
    identities = sub.add_parser('identities')
    identities.add_argument('entrypoint')
    identities.add_argument('output')
    comparison = sub.add_parser('compare')
    comparison.add_argument('raw')
    comparison.add_argument('inventory')
    comparison.add_argument('join')
    comparison.add_argument('expected')
    comparison.add_argument('--category', choices=('plain', 'transient', 'constructed'))
    args = parser.parse_args()
    if args.command == 'identities':
        Path(args.output).write_text(json.dumps(build_identities(args.entrypoint), indent=2) + '\n')
        return
    inventory = json.loads(Path(args.inventory).read_text())
    if build_identities(inventory['entrypoint']) != inventory:
        raise ValueError('App consuming source identity inventory drift')
    join = json.loads(Path(args.join).read_text())
    expected_bytes = Path(args.expected).read_bytes()
    if hashlib.sha256(expected_bytes).hexdigest() != join['expectedSHA256']:
        raise ValueError('Independent complete App oracle digest mismatch')
    actual = normalize(Path(args.raw).read_text(), inventory, join, args.category)
    expected = json.loads(expected_bytes)
    BASE.strict_equal(actual, expected[args.category] if args.category else expected)
    print('Complete App typed constructor join equals independent oracle')


if __name__ == '__main__': main()
