"""Independent source-derived TS machine/query condition shared trace."""
import copy
import json


def pair(value):
    return [value, value + 1]


def entities(schema):
    result = []
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
        result.append({'id': ident, 'components': components, 'relations': {}})
    return result


def session(schema, missing):
    counter = pair(10)
    trace = []
    frame = tick = frame_start = boundary = 0
    live = []
    pending_commands = []
    current = None if missing else 0
    pending_mode = previous_mode = None
    transition_ticks = []
    has_transition_log = False

    def point(label):
        machine = {}
        if current is not None:
            value = {'current': current}
            if pending_mode is not None:
                value['pending'] = pending_mode
            if previous_mode is not None:
                value['previous'] = previous_mode
            machine[schema + '/Mode'] = value
        streams = []
        if has_transition_log:
            streams.append({'kind': 'transitionEvent', 'stream': schema + '/Mode',
                            'size': len(transition_ticks), 'capacity': 65536, 'readers': []})
        return {'label': label, 'world': {'version': 1, 'frame': frame, 'tick': tick,
                'entityCount': len(live), 'entities': copy.deepcopy(live),
                'resources': {schema + '/Counter': copy.deepcopy(counter),
                              schema + '/Threshold': pair(5), schema + '/Sentinel': pair(900)},
                'machines': machine, 'pendingCommands': copy.deepcopy(pending_commands)},
                'streams': streams, 'trace': copy.deepcopy(trace)}

    rows = [point('empty')]

    def execute(label, operation, value=None):
        nonlocal frame, tick, frame_start, boundary, counter, live, pending_commands
        nonlocal current, pending_mode, previous_mode, has_transition_log, transition_ticks
        if operation == 'guard' and missing:
            result = {'ok': False, 'error': {'kind': 'MissingRuntimeRequirements',
                       'requirements': [{'kind': 'stateMachine', 'name': schema + '/Mode'}]}}
        else:
            frame += 1
            if frame_start > 0:
                boundary = frame_start
            frame_start = tick
            transition_ticks = [stamp for stamp in transition_ticks if stamp > boundary]
            if operation == 'populate':
                tick += 1
                pending_commands = [{'tag': 'spawn', 'system': 'populate-five'} for _ in range(5)]
                trace.append({'system': 'populate-five'})
            elif operation == 'apply':
                tick += 1
                live = entities(schema)
                pending_commands = []
            elif operation == 'guard':
                trace.append({'check': 'machine-presence', 'current': current})
                joined = [] if not live else [
                    {'id': {'kind': 'EntityId', 'value': 1}, 'primary': pair(10),
                     'bonus': {'present': True, 'value': pair(100)}},
                    {'id': {'kind': 'EntityId', 'value': 2}, 'primary': pair(20), 'bonus': {'present': False}}]
                trace.append({'check': 'query-threshold-mode', 'rows': joined, 'threshold': pair(5), 'current': current})
                if joined and pair(5)[0] < joined[0]['primary'][0] and current == 0:
                    tick += 1
                    before = counter[0]
                    counter = pair(before + 1)
                    trace.append({'system': 'increment', 'before': before})
            elif operation == 'queue':
                tick += 1
                before = pending_mode
                pending_mode = value
                trace.append({'system': 'queue-mode', 'current': current, 'beforePending': before,
                              'afterPending': value, 'requested': value})
            elif operation == 'transition':
                tick += 1  # The marker first applies deferred commands, even an empty list.
                assert pending_mode is not None
                previous_mode, current = current, pending_mode
                pending_mode = None
                tick += 1
                transition_ticks.append(tick)
                has_transition_log = True
            else:
                raise AssertionError(operation)
            result = {'ok': True}
        rows.append({**point(label), 'result': result})

    execute('populate-pending', 'populate')
    execute('populate-visible', 'apply')
    if missing:
        execute('populated-missing-machine', 'guard')
    else:
        execute('mode0-true', 'guard')
        execute('queued1-current0', 'queue', 1)
        execute('queued1-still-true', 'guard')
        execute('mode1-applied', 'transition')
        execute('mode1-false', 'guard')
        execute('queued0-current1', 'queue', 0)
        execute('mode0-applied', 'transition')
        execute('mode0-true-again', 'guard')
    return {'schema': schema, 'missingMachine': missing, 'rows': rows}


def values():
    return [session(schema, missing) for schema in ['Workshop', 'Garden'] for missing in [False, True]]


def render():
    return (json.dumps(values(), separators=(',', ':'), ensure_ascii=False) + '\n').encode()


def selftest():
    for case in values():
        schema = case['schema']
        rows = case['rows']
        final = rows[-1]
        if case['missingMachine']:
            assert len(rows) == 4
            assert (final['world']['frame'], final['world']['tick']) == (2, 2)
            assert final['trace'] == [{'system': 'populate-five'}]
            assert final['result']['error']['requirements'] == [{'kind': 'stateMachine', 'name': schema + '/Mode'}]
            assert final['world']['machines'] == {} and final['streams'] == []
        else:
            assert len(rows) == 11
            assert [(r['world']['frame'], r['world']['tick']) for r in rows] == [
                (0, 0), (1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 7), (7, 7), (8, 8), (9, 10), (10, 11)]
            assert final['world']['resources'][schema + '/Counter'] == [13, 14]
            assert final['world']['machines'][schema + '/Mode'] == {'current': 0, 'previous': 1}
            assert rows[4]['world']['machines'][schema + '/Mode'] == {'current': 0, 'pending': 1}
            assert rows[7]['world']['resources'][schema + '/Counter'] == [12, 13]
            assert [r['streams'][0]['size'] for r in rows[6:]] == [1, 1, 0, 1, 1]
            checks = [t for t in final['trace'] if 'check' in t]
            assert len(checks) == 8
            assert [t['current'] for t in checks] == [0, 0, 0, 0, 1, 1, 0, 0]
        assert final['world']['entityCount'] == 5
        assert final['world']['pendingCommands'] == []


if __name__ == '__main__':
    import sys
    selftest()
    if '--selftest' not in sys.argv:
        sys.stdout.buffer.write(render())
