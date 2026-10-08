#!/usr/bin/env python3
"""Join shared fixed-scenario observations after full Bend oracle validation.

The separate whole structural oracle checks every Bend-specific field. This
join covers live component values, resource Step, pending count, per-phase
success and complete independent reader journals in the executed TS trace.
Clocks, dump metadata and representation-specific owners remain explicit.
"""
import hashlib
import importlib.util
import json
from pathlib import Path
from source_evidence import validate_sources

HERE = Path(__file__).resolve().parent
OUT = HERE / 'development/full-js-v1'
REF = HERE.parent / 'reference-v1'

def fields(value, name):
    assert value['constructor'].rsplit('.', 1)[-1] == name, (name, value)
    return value['fields']

def journal(readings):
    result = []
    for reading in readings:
        items, lagged = fields(reading, 'Reading')
        assert lagged == {'constructor': 'False', 'fields': []}
        hits = []; deaths = []
        for item in items:
            name = item['constructor'].rsplit('.', 1)[-1]
            if name == 'SimulationHit':
                entity, damage = fields(item, name)
                hits.append({'entity': entity, 'damage': damage})
            elif name == 'SimulationDeath':
                entity, = fields(item, name)
                deaths.append({'entity': entity})
            else:
                raise AssertionError('Unknown event')
        result.append({'hits': hits, 'deaths': deaths})
    return result

def shared(phase):
    observation, outcome = fields(phase, 'Phase')
    runtime, ja, jb = fields(observation, 'Observation')
    world = fields(runtime, 'Snapshot')[0]
    label, allocation, resource, cells, events, pending, clock, live = fields(world, 'Snapshot')
    step = fields(resource, 'FullCell')[1][0]
    entities = []
    for physical in cells:
        entity, *slots = fields(physical, 'EntityCells')
        if entity not in live:
            continue
        components = {}
        for name, slot in zip(('Position', 'Velocity', 'Health'), slots):
            cell, = fields(slot, 'Some')
            components['Simulation/' + name] = fields(cell, 'FullCell')[1][0]
        entities.append({'id': entity, 'components': components, 'relations': {}})
    tag = outcome['constructor'].rsplit('.', 1)[-1]
    ok = True
    if tag == 'ReadersResult':
        statuses = fields(fields(outcome, tag)[0], 'ReaderResults')
        ok = all(status['constructor'].rsplit('.', 1)[-1] in ('Succeeded', 'Skipped') for status in statuses)
    elif tag == 'GameplayResult':
        completion, = fields(outcome, tag)
        output, = fields(completion, 'GameplayRan')
        ok = fields(fields(output, 'FrameOutput')[0], 'Success') == []
    elif tag == 'SpawnResult':
        fields(fields(outcome, tag)[0], 'SpawnSucceeded')
    else:
        assert tag == 'BarrierResult'
    return {'label': label, 'ok': ok, 'entities': entities, 'step': step,
            'pendingCount': pending, 'readers': {'a': journal(ja), 'b': journal(jb)}}

if __name__ == '__main__':
    qualified = json.loads((OUT / 'oracle-comparison.json').read_text())
    assert qualified['completeMatch'] and qualified['differences'] == []
    bend_raw = (OUT / 'run.stdout').read_bytes()
    assert hashlib.sha256(bend_raw).hexdigest() == qualified['actualStdoutSha256']
    spec = importlib.util.spec_from_file_location('simulation_report_parser', HERE / 'parse-report.py')
    parser = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(parser)
    actual = parser.parse(bend_raw.decode())
    assert parser.render(actual) == bend_raw.decode().strip()
    assert actual == json.loads((OUT / 'parsed.json').read_text())
    assert actual == json.loads((OUT / 'expected-literal.json').read_text())
    pins = json.loads((OUT / 'sources.json').read_text())
    validate_sources(pins)
    raw = (REF / 'evidence/corrected-oracle-v1/fixed-step-complete-reference.stdout').read_bytes()
    assert raw == (REF / 'expected.stdout').read_bytes()
    reference = json.loads(raw)
    bend = json.loads((OUT / 'parsed.json').read_text())
    schemas = fields(bend, 'TwoSchemaReport')
    assert len(schemas) == len(reference) == 2
    compared = []
    for phases, ts in zip(schemas, reference):
        assert len(phases) == len(ts['phases']) == 14
        for b, t in zip(phases, ts['phases']):
            expected = {'label': t['label'], 'ok': t['result']['ok'], 'entities': t['dump']['entities'],
                        'step': t['dump']['resources']['Simulation/Step'],
                        'pendingCount': len(t['dump']['pendingCommands']), 'readers': t['readers']}
            observed = shared(b)
            assert observed == expected, (ts['root'], t['label'], observed, expected)
            compared.append({'schema': ts['root'], 'label': t['label']})
    record = {'match': True, 'checkpoints': compared,
              'executedTsStdoutSha256': hashlib.sha256(raw).hexdigest(),
              'fullBendOracleSha256': qualified['oracleSha256'],
              'scope': __doc__, 'limitations': 'No Native, negative, mutation or regression gate qualification.'}
    (OUT / 'ts-comparison.json').write_text(json.dumps(record, indent=2) + '\n')
    print('PASS: 28 executed-TS shared checkpoints; separate full Bend structural oracle passes.')
