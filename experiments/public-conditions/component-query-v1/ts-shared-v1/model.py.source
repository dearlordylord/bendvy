"""Independent full actual TS component-query shared witness projection."""
import copy
import json


def pair(value):
    return [value, value + 1]


def entity_id(value):
    return {'kind': 'EntityId', 'value': value}


def entities(schema):
    rows = []
    for ident in range(1, 6):
        components = {}
        if ident != 4:
            components[schema + '/Primary'] = pair(ident * 10)
        if ident not in (2, 5):
            components[schema + '/Bonus'] = pair(ident * 100)
        if ident != 5:
            components[schema + '/Active'] = {}
        if ident == 3:
            components[schema + '/Hidden'] = {}
        rows.append({'id': ident, 'components': components, 'relations': {}})
    return rows


def run_session(schema, missing):
    counter = pair(10)
    threshold = None if missing else pair(5)
    trace = []
    frame = 0
    tick = 0
    live = []
    pending = []

    def point(label):
        resources = {schema + '/Counter': copy.deepcopy(counter)}
        if threshold is not None:
            resources[schema + '/Threshold'] = copy.deepcopy(threshold)
        resources[schema + '/Sentinel'] = pair(900)
        return {'label': label, 'world': {'version': 1, 'frame': frame, 'tick': tick,
                                         'entityCount': len(live), 'entities': copy.deepcopy(live),
                                         'resources': resources, 'machines': {},
                                         'pendingCommands': copy.deepcopy(pending)},
                'streams': [], 'trace': copy.deepcopy(trace)}

    rows = [point('empty')]

    def execute(label, kind, value=None):
        nonlocal frame, tick, counter, threshold, live, pending
        if kind == 'guard' and missing:
            result = {'ok': False, 'error': {'kind': 'MissingRuntimeRequirements',
                                           'requirements': [{'kind': 'resource', 'name': schema + '/Threshold'}]}}
        else:
            frame += 1
            if kind == 'threshold':
                tick += 1
                trace.append({'system': 'threshold', 'before': copy.deepcopy(threshold), 'value': pair(value)})
                threshold = pair(value)
            elif kind == 'populate':
                tick += 1
                pending = [{'tag': 'spawn', 'system': 'populate-five'} for _ in range(5)]
                trace.append({'system': 'populate-five'})
            elif kind == 'apply':
                tick += 1
                live = entities(schema)
                pending = []
            elif kind == 'guard':
                presence = [{'id': entity_id(ident), 'value': 'Unit'} for ident in range(1, 5)] if live else []
                trace.append({'check': 'presence', 'rows': presence})
                if presence:
                    joined = [{'id': entity_id(1), 'primary': pair(10), 'bonus': {'present': True, 'value': pair(100)}},
                              {'id': entity_id(2), 'primary': pair(20), 'bonus': {'present': False}}]
                    trace.append({'check': 'joined', 'rows': joined, 'threshold': copy.deepcopy(threshold)})
                    if threshold[0] < joined[0]['primary'][0]:
                        tick += 1
                        before = counter[0]
                        counter = pair(before + 1)
                        trace.append({'system': 'increment', 'before': before})
            else:
                raise AssertionError(kind)
            result = {'ok': True}
        rows.append({**point(label), 'result': result})

    if not missing:
        execute('empty-guarded', 'guard')
        execute('threshold-high', 'threshold', 50)
    execute('populate-pending', 'populate')
    execute('populate-visible', 'apply')
    if missing:
        execute('populated-missing-threshold', 'guard')
    else:
        execute('threshold-false', 'guard')
        execute('threshold-five', 'threshold', 5)
        execute('threshold-true', 'guard')
        execute('threshold-true-repeat', 'guard')
    return {'schema': schema, 'missingThreshold': missing, 'rows': rows}


def values():
    return [run_session(schema, missing) for schema in ['Workshop', 'Garden'] for missing in [False, True]]


def render():
    return (json.dumps(values(), separators=(',', ':'), ensure_ascii=False) + '\n').encode()


def selftest():
    for case in values():
        rows = case['rows']
        final = rows[-1]
        if case['missingThreshold']:
            assert len(rows) == 4
            assert (final['world']['frame'], final['world']['tick']) == (2, 2)
            assert final['trace'] == [{'system': 'populate-five'}]
            assert not final['result']['ok']
        else:
            assert len(rows) == 9
            assert (final['world']['frame'], final['world']['tick']) == (8, 6)
            assert final['world']['resources'][case['schema'] + '/Counter'] == [12, 13]
        assert final['world']['entityCount'] == 5
        assert rows[-1]['world']['pendingCommands'] == []


if __name__ == '__main__':
    import sys
    selftest()
    if '--selftest' not in sys.argv:
        sys.stdout.buffer.write(render())
