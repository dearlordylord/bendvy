#!/usr/bin/env python3
"""Independent source-derived normal and fallible-guard-bypass outputs.

The expected rows are constructed from the pinned codec/factory/request/world
source and copied fixture source. Runtime output is never an oracle input.
"""
from __future__ import annotations
import gzip
import hashlib
import importlib.util
import json
import os
from pathlib import Path

ROOT = Path('/workspace/formal-proofs/bendvy')
CHILD = Path(__file__).resolve().parents[1]
SOURCE = CHILD / 'source'
ENTRY = SOURCE / 'main.bend'
FIXTURE = SOURCE / 'fixture.bend'
REQUEST = SOURCE / 'fallible-composition-v1/request-fixture.bend'
BUSINESS = SOURCE / 'fallible-composition-v1/business.bend'
CONSTRUCTOR = SOURCE / 'ecs/decode-construction.bend'
CONSTRUCTED = SOURCE / 'ecs/decode-fallible-constructed-requests.bend'
DECODE = SOURCE / 'ecs/decode-data.bend'
TRANSACTION = SOURCE / 'ecs/transaction.bend'
PARSER_PATH = ROOT / 'experiments/public-simulation/bend-v1/parse-report.py'
BASELINE_EXPECTED = CHILD.parent / 'oracle/expected.json'


def module_name(module: Path | None) -> str:
    if module is None or module.resolve() == ENTRY.resolve():
        return ''
    return os.path.relpath(str(module.resolve().with_suffix('')), str(ENTRY.parent.resolve()))


def node(module: Path | None, tag: str, *fields):
    name = tag if module is None or module.resolve() == ENTRY.resolve() else module_name(module) + '.' + tag
    return {'constructor': name, 'fields': list(fields)}


def nat(value: int):
    assert type(value) is int and value >= 0
    return {'nat': value}


def boolean(value: bool):
    assert type(value) is bool
    return node(None, 'True' if value else 'False')


def raw_text(value: str):
    return node(DECODE, 'Text', value)


def raw_number(value: int):
    return node(DECODE, 'Number', value)


def unit():
    return node(None, 'Unit')


def snapshot():
    # world.create_checked starts at namespace=1, nextId=1, highWater=0,
    # one false live slot, capacity=1, and empty registries/queue/events.
    meta = node(FIXTURE, 'Meta', 1, 1, 0, 1, nat(0), [], [], 1, 0)
    resource = node(FIXTURE, 'View', raw_number(100), raw_number(100), [81, 82],
                    [boolean(False), boolean(True)])
    return node(FIXTURE, 'Snapshot', meta, [boolean(False)], unit(), resource, 0)


def input_view(raw):
    # The exact incoming raw payload and affine word/flag owner are retained.
    return node(FIXTURE, 'InputView', raw, [71, 72],
                [boolean(True), boolean(False)])


def refused(raw, kind: str):
    if kind == 'validation':
        error = node(CONSTRUCTED, 'Construction',
                     node(CONSTRUCTOR, 'Validation',
                          node(DECODE, 'Invalid', '$', 'integer', raw)))
    elif kind == 'constructor':
        error = node(CONSTRUCTED, 'Construction',
                     node(CONSTRUCTOR, 'Constructor', node(BUSINESS, 'Denied', 403)))
    else:
        raise AssertionError(kind)
    return node(REQUEST, 'Report', snapshot(), snapshot(), nat(0),
                node(REQUEST, 'Refused', node(None, 'Some', input_view(raw)), error),
                [], node(TRANSACTION, 'Failure', unit()))


def expected_term(mutant: bool):
    invalid_kind = 'constructor' if mutant else 'validation'
    cases = node(None, 'Cases', refused(raw_text('wrong'), invalid_kind),
                 refused(raw_number(7), 'constructor'))
    return node(None, 'Candidate', cases, cases)


def render(term) -> bytes:
    spec = importlib.util.spec_from_file_location('bendvy_precedence_parser', PARSER_PATH)
    parser = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(parser)
    raw = (parser.render(term) + '\n').encode('utf-8')
    assert parser.parse(raw.decode('utf-8')) == term
    return raw


def replace_mutant_error(row):
    """Project the result error away, retaining every other report field."""
    assert row['constructor'] == module_name(REQUEST) + '.Report'
    fields = list(row['fields'])
    result = dict(fields[3])
    assert result['constructor'] == module_name(REQUEST) + '.Refused'
    result_fields = list(result['fields'])
    result_fields[1] = {'constructor': '$ERROR$', 'fields': []}
    result['fields'] = result_fields
    fields[3] = result
    return {'constructor': row['constructor'], 'fields': fields}


def normalized_prior(term):
    """Rebase only prior absolute ECS module names to the private ./ecs copy."""
    if isinstance(term, dict):
        out = {k: normalized_prior(v) for k, v in term.items()}
        value = out.get('constructor')
        if isinstance(value, str) and '/bendvy/src/ecs/' in value:
            out['constructor'] = 'ecs/' + value.split('/bendvy/src/ecs/', 1)[1]
        return out
    if isinstance(term, list):
        return [normalized_prior(x) for x in term]
    return term


def build_files():
    normal = expected_term(False)
    counter = expected_term(True)
    # Bind the new source-derived normal model to the already-qualified normal
    # oracle after the one intentional module-path relocation into ./ecs.
    prior = json.loads(BASELINE_EXPECTED.read_text(encoding='utf-8'))
    assert normalized_prior(prior) == normal
    normal_cases, counter_cases = normal['fields'], counter['fields']
    assert normal_cases[0] == normal_cases[1] and counter_cases[0] == counter_cases[1]
    for normal_case, counter_case in zip(normal_cases, counter_cases):
        assert normal_case['constructor'] == counter_case['constructor'] == 'Cases'
        assert len(normal_case['fields']) == len(counter_case['fields']) == 2
        normal_invalid, normal_valid = normal_case['fields']
        counter_invalid, counter_valid = counter_case['fields']
        assert replace_mutant_error(normal_invalid) == replace_mutant_error(counter_invalid)
        assert normal_valid == counter_valid
        assert normal_invalid != counter_invalid
    normal_bytes = render(normal)
    counter_bytes = render(counter)
    if normal_bytes == counter_bytes:
        raise AssertionError('mutant counter must differ from full normal output')
    out = CHILD / 'oracle'
    out.mkdir(parents=True, exist_ok=True)
    files = {
        'normal.stdout': normal_bytes,
        'normal.stdout.gz': gzip.compress(normal_bytes, compresslevel=9, mtime=0),
        'normal.json': (json.dumps(normal, sort_keys=True, indent=2, ensure_ascii=False) + '\n').encode(),
        'counter.stdout': counter_bytes,
        'counter.stdout.gz': gzip.compress(counter_bytes, compresslevel=9, mtime=0),
        'counter.json': (json.dumps(counter, sort_keys=True, indent=2, ensure_ascii=False) + '\n').encode(),
    }
    rows = {}
    for name, value in files.items():
        (out / name).write_bytes(value)
        rows[name] = {'path': str(out / name), 'bytes': len(value), 'sha256': hashlib.sha256(value).hexdigest()}
    metadata = {
        'schema': 'fallible-guard-bypass-independent-oracle-v1',
        'reportCount': 4,
        'schemas': ['First', 'Second'],
        'casesPerSchema': ['invalidCodec', 'acceptedCodec'],
        'runtimeOutputsUsed': False,
        'baselineNormalOracle': {'path': str(BASELINE_EXPECTED), 'sha256': hashlib.sha256(BASELINE_EXPECTED.read_bytes()).hexdigest(), 'rebasing': 'only absolute /bendvy/src/ecs/ module-name prefix to ecs/ for the copied closure'},
        'sourcePremises': {
            'invalidNormal': 'Decode.decode_owner returns D.Receipt{owner,D.Rejected{D.Invalid("$","integer",Text("wrong"))}}; fallible_checked returns Build.Invalid{owner,Validation(error)} without calling the builder.',
            'invalidCounter': 'the single private rejected-branch mutation calls the existing always-denying builder with D.Array{[]}; custom_result wraps Business.Denied{403} as Constructor error while preserving owner.',
            'acceptedBoth': 'Number(7) with Integer codec reaches Accepted{canonical}; builder returns Denied{403}; both normal and counter return Constructor error.',
            'observations': 'before and after equal full Snapshot; same raw input, InputView words [71,72], flags [true,false], resource payload and live column, zero prepared requests, empty recovered list, Failure(Unit), unchanged queue/stamps/owner.',
        },
        'differenceAssertion': 'all four reports are rendered; the two accepted rows and every non-error field in both invalid rows are equal to normal, while exactly the two invalid error values differ from Validation(Invalid) to Constructor(Denied(403)).',
        'files': rows,
    }
    (out / 'ORACLES.json').write_text(json.dumps(metadata, sort_keys=True, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    return metadata


if __name__ == '__main__':
    print(json.dumps(build_files(), sort_keys=True))
