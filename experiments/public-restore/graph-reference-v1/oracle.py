"""Source-derived finite TS restore projection; no subject execution or output input."""
import copy
import json
from pathlib import Path

UNDEFINED = {'undefined': True}
EMPTY = {'ping': [], 'mode': [], 'weather': [], 'failures': []}
FAILURE = {'operation': 'relate', 'relation': 'Link', 'source': 1, 'target': 1,
           'error': {'_tag': 'SelfRelationNotAllowed', 'entityId': 1, 'relation': 'Link'}}


def reading(name, populated=False):
    return dict(reader=name, **({'ping': [17], 'mode': [{'from': 0, 'to': 1}],
                                 'weather': [{'from': 9, 'to': 8}],
                                 'failures': [copy.deepcopy(FAILURE)]} if populated else copy.deepcopy(EMPTY)))


def state(label, phase):
    fresh = phase == 0
    restored = phase >= 2
    omitted = phase >= 4
    frame = [0, 1, 1, 2, 2, 3][phase]
    tick = [0, 10, 11, 13, 14, 15][phase]
    names = [] if fresh else ['x', 'y', 'z'] if restored else ['a', 'b', 'c']
    entities = [{'id': i + 1, 'components': {'Name': value}} for i, value in enumerate(names)]
    graph = {'Link': [], 'Parent': []}
    if not fresh and not restored:
        graph = {'Link': [[1, [3, 2]]], 'Parent': [[1, [2]]]}
    if restored and not omitted:
        graph = {'Link': [[2, [3, 1]]], 'Parent': [[1, [2, 3]]]}
    dump_entities = copy.deepcopy(entities)
    for row in dump_entities:
        row['relations'] = {}
        for relation, groups in graph.items():
            for target, sources in groups:
                if row['id'] in sources:
                    row['relations'][relation] = target
    resources = {'Score': 42 if restored else 5, 'Spare': 7}
    machines = {'Mode': 2 if restored else 0 if fresh else 1,
                'Weather': 9 if fresh else 8}
    dump_machines = {name: {'current': value} for name, value in machines.items()}
    if not fresh:
        dump_machines['Mode']['previous'] = 0
        dump_machines['Weather']['previous'] = 9
    if phase == 1:
        dump_machines = {'Mode': {'current': 1, 'pending': 2, 'previous': 0},
                         'Weather': {'current': 8, 'pending': 7, 'previous': 9}}
    streams = []
    if not fresh:
        for kind, name, size, fast, slow in [('event', 'Ping', 2, 1, 2),
                                           ('transitionEvent', 'Mode', 1, 0, 1),
                                           ('transitionEvent', 'Weather', 1, 0, 1),
                                           ('relationFailure', 'Link', 1, 0, 1)]:
            streams.append({'kind': kind, 'stream': name, 'size': 0 if restored else size,
                            'capacity': 65536,
                            'readers': [{'system': 'fast', 'unread': 0 if restored else fast, 'lagged': False},
                                        {'system': 'slow', 'unread': 0 if restored else slow, 'lagged': False}],
                            'heldBy': copy.deepcopy(UNDEFINED)})
    history = [] if fresh else [reading('fast'), reading('slow'), reading('fast', True)]
    if phase >= 3:
        history.extend([reading('fast'), reading('slow')])
    if phase >= 5:
        history.append(reading('slow'))
    trace = [] if fresh else [{'system': 'seed', 'ids': [1, 2, 3]}, {'system': 'queued', 'pending': 4}]
    return {'label': label,
            'snapshot': {'version': 1, 'nextEntity': 1 if fresh else 5, 'entities': entities,
                         'relations': graph, 'resources': resources, 'machines': machines},
            'dump': {'version': 1, 'frame': frame, 'tick': tick, 'entityCount': len(entities),
                     'entities': dump_entities, 'resources': dict(resources, Cache=9),
                     'machines': dump_machines,
                     'pendingCommands': [{'tag': 'spawn', 'system': 'queued'}] if phase == 1 else []},
            'streams': streams, 'history': history, 'trace': trace}


def expected(root):
    labels = ['fresh', 'populated-pending', 'restored', 'readers-after-restore',
              'omitted-machines-resources', 'retained-slow-reader']
    rows = [state(label, phase) for phase, label in enumerate(labels)]
    rows[2]['result'] = {'ok': True}
    rows[4]['result'] = {'ok': True}
    return {'root': root, 'rows': rows}


def selftest():
    rows = expected('Workshop')['rows']
    assert rows[1]['snapshot']['relations']['Link'] == [[1, [3, 2]]]
    assert rows[2]['snapshot']['relations']['Link'] == [[2, [3, 1]]]
    assert rows[2]['dump']['machines'] == {'Mode': {'current': 2, 'previous': 0}, 'Weather': {'current': 8, 'previous': 9}}
    assert rows[4]['snapshot']['machines'] == rows[2]['snapshot']['machines']
    assert rows[2]['dump']['pendingCommands'] == []
    assert all(stream['size'] == 0 for stream in rows[2]['streams'])
    assert len(rows[-1]['history']) == 6 and rows[-1]['history'][-1] == reading('slow')


if __name__ == '__main__':
    selftest()
    Path(__file__).with_name('expected.json').write_text(json.dumps([expected('Workshop'), expected('Garden')], separators=(',', ':')) + '\n')
