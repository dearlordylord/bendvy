#!/usr/bin/env python3
"""Compare every report field against the independent oracle after path joins."""
import argparse
import importlib.util
import json
import os
import re
from pathlib import Path
from prepare import SUBJECT, archived, digest, expected_stage


def parser_functions():
    specification = importlib.util.spec_from_file_location('simulation_report', SUBJECT / 'parse-report.py')
    module = importlib.util.module_from_spec(specification)
    specification.loader.exec_module(module)
    return module.parse, module.render


def transform(value, constructors):
    if isinstance(value, list):
        return [transform(item, constructors) for item in value]
    if isinstance(value, dict):
        return {key: constructors[item] if key == 'constructor' else transform(item, constructors)
                for key, item in value.items()}
    return value


def validate_report(raw, literal_to_neutral):
    parse, render = parser_functions()
    report = parse(raw.decode())
    assert render(report) == raw.decode().strip(), 'Whole report byte roundtrip failed'
    actual = transform(report, literal_to_neutral)
    oracle = json.loads((SUBJECT / 'independent-expected.json').read_text())
    assert digest((SUBJECT / 'independent-expected.json').read_bytes()) == 'f821c68264eb25c33a674841d0f2abcf466a9d6372e888cfc40b7ae691ae071a'
    assert actual == oracle, 'Complete report differs from independent oracle'
    return actual


def historical():
    data = archived()
    for cohort, labels, caps in (('full-js-v1', ['emit', 'run'], [30, 5]),
                                  ('full-native-v1', ['emit', 'build', 'run'], [30, 120, 5])):
        receipt = json.loads(data[cohort + '/result.json'])
        assert receipt['sourceChanges'] == []
        assert receipt['environment']['BEND_NO_TELEMETRY'] == '1'
        assert [c['label'] for c in receipt['commands']] == labels
        assert [c['capSeconds'] for c in receipt['commands']] == caps
        assert all(c['returncode'] == 0 and c['timeout'] is False for c in receipt['commands'])
        for label in labels:
            assert cohort + '/' + label + '.stdout' in data
            assert data[cohort + '/' + label + '.stderr'] == b''
    assert json.loads(data['full-js-v1/sources.json']) == json.loads(data['full-native-v1/sources.json'])
    joins = json.loads(data['full-js-v1/constructor-source-join.json'])
    reverse = {record['literal']: neutral for neutral, record in joins.items()}
    assert len(reverse) == len(joins) == 32
    raw = data['full-js-v1/run.stdout']
    assert digest(raw) == '70e20e1c253b14d044d0c3a3ff346a248fbf8ec99336215dbf0b3262d140b1d2'
    validate_report(raw, reverse)
    assert json.loads(data['full-js-v1/parsed.json']) == parser_functions()[0](raw.decode())
    native_raw = data['full-native-v1/run.stdout']
    assert native_raw == raw, 'Historical Native and JS whole stdout differ'
    return {'scope': 'Historical development observations only; no relocated execution claim.',
            'completeMatch': True, 'stdoutSha256': digest(raw), 'constructorJoins': len(joins)}


def stage_joins(stage):
    manifest = json.loads((stage / 'stage.json').read_text())
    expected, transformed = expected_stage()
    assert manifest == expected, 'Stage manifest does not match pinned relocation'
    actual = {str(path.relative_to(stage)) for path in stage.rglob('*.bend')}
    assert actual == set(transformed), 'Stage Bend membership drift'
    assert not any(path.is_symlink() for path in stage.rglob('*')), 'Stage symlinks refused'
    for name, value in transformed.items():
        path = stage / name
        assert path.is_file() and path.read_bytes() == value, ('Stage drift', name)
    old = json.loads(archived()['full-js-v1/constructor-source-join.json'])
    entry = stage / manifest['entry']
    reverse = {}
    for neutral in old:
        filename, constructor = neutral.split('::')
        if filename == 'Base':
            literal = constructor
        else:
            if filename in ('pair.bend', 'readers.bend'):
                relative = 'experiments/public-simulation/readers-v1/' + filename
            elif filename in ('world.bend', 'transaction.bend', 'event-runtime.bend'):
                relative = 'src/ecs/' + filename
            else:
                relative = 'experiments/public-simulation/bend-v1/' + filename
            assert relative in manifest['sources']
            source = stage / relative
            declared = set()
            in_type = False
            for line in source.read_text().splitlines():
                if line.startswith('type '):
                    in_type = True
                    tail = line.partition(' is ')[2].partition(':')[2].strip()
                elif line and not line[0].isspace() and not line.startswith('#'):
                    in_type = False
                    tail = ''
                else:
                    tail = line.strip() if in_type else ''
                match = re.match(r'([A-Za-z_][A-Za-z0-9_]*)\s*\{', tail)
                if match:
                    declared.add(match.group(1))
            assert constructor in declared, ('Not a declared constructor', neutral)
            literal = constructor if filename == 'main.bend' else os.path.relpath(source.with_suffix(''), entry.parent) + '.' + constructor
        assert literal not in reverse
        reverse[literal] = neutral
    return reverse


if __name__ == '__main__':
    arguments = argparse.ArgumentParser(description=__doc__)
    arguments.add_argument('--stage', type=Path)
    arguments.add_argument('--stdout', type=Path)
    options = arguments.parse_args()
    if options.stage is None:
        assert options.stdout is None
        print(json.dumps(historical()))
    else:
        assert options.stdout is not None
        raw = options.stdout.read_bytes()
        validate_report(raw, stage_joins(options.stage.resolve()))
        print(json.dumps({'scope': 'Complete relocated report semantic comparison; execution receipts separately required.',
                          'completeMatch': True, 'stdoutSha256': digest(raw)}))
