"""Independent pre-execution source model; never reads Node observations."""
import copy
import json
from pathlib import Path

UNDEFINED = {'undefined': True}
EMPTY_WATCH = {'added': [], 'despawned': [], 'events': []}

def state(frame, tick, *, restored=False, pending=True, read=False, readers=False, later=False):
    rows = [{'id': 1, 'components': {'Name': 'restored' if restored else 'a'}}]
    if not restored: rows.append({'id': 2, 'components': {'Name': 'b'}})
    if later: rows.append({'id': 7, 'components': {'Name': 'later'}})
    resources = {'Score': 42 if restored else 11, 'Spare': 7}
    dump_rows = copy.deepcopy(rows)
    if not restored: dump_rows[0]['components']['Scratch'] = 101
    for row in dump_rows: row['relations'] = {}
    watch = [copy.deepcopy(EMPTY_WATCH)]
    if read: watch.append({'added': [[1, 'a'], [2, 'b']], 'despawned': [], 'events': [17]})
    if readers: watch.append({'added': [[1, 'restored']], 'despawned': [1, 2], 'events': []})
    return {
        'snapshot': {'version': 1, 'nextEntity': 8 if later else 7, 'entities': rows,
                     'relations': {}, 'resources': resources, 'machines': {}},
        'dump': {'version': 1, 'frame': frame, 'tick': tick, 'entityCount': len(rows),
                 'entities': dump_rows, 'resources': dict(resources, Cache=9), 'machines': {},
                 'pendingCommands': [{'tag': 'spawn', 'system': 'queue'}]*4 if pending else []},
        'streams': [{'kind': 'event', 'stream': 'Ping', 'size': 0 if restored else 1,
                     'capacity': 65536,
                     'readers': [{'system': 'watch', 'unread': 0 if restored or read else 1, 'lagged': False},
                                 {'system': 'slow', 'unread': 0 if restored else 1, 'lagged': False}],
                     'heldBy': copy.deepcopy(UNDEFINED)}],
        'watch': watch, 'slow': [[], []] if readers else [[]],
    }


def invalid(path): return {'_tag': 'InvalidSnapshot', 'path': path}
def unknown(tag, name, entity=False):
    return dict({'_tag': tag, 'name': name}, **({'entityId': 1} if entity else {}))
def decode(tag, name, expected, actual, entity=False):
    return dict(unknown(tag, name, entity), error={'_tag': 'DecodeError', 'path': '$', 'expected': expected, 'actual': actual})

def expected(root):
    initial = state(3, 6)
    errors = [
        ('null', invalid('$')), ('missing-version', {'_tag': 'UnsupportedVersion', 'version': UNDEFINED}),
        ('version-before-next', {'_tag': 'UnsupportedVersion', 'version': 2}),
        ('next-before-name', invalid('$.nextEntity')), ('entities-shape', invalid('$.entities')),
        ('entity-id', invalid('$.entities[0].id')), ('components-shape', invalid('$.entities[0].components')),
        ('relations-required', invalid('$.relations')), ('relation-path', invalid('$.relations.R[0]')),
        ('resources-shape', invalid('$.resources')), ('machines-required', invalid('$.machines')),
        ('machine-path', invalid('$.machines.M')),
        ('duplicate-before-second-name', {'_tag': 'DuplicateEntity', 'entityId': 1}),
        ('first-name-before-later-duplicate', unknown('UnknownComponent', 'Missing', True)),
        ('name-before-value', unknown('UnknownComponent', 'Missing', True)),
        ('value-before-later-name', decode('InvalidComponent', 'Name', 'string', 12, True)),
        ('transient-component', unknown('UnknownComponent', 'Scratch', True)),
        ('unknown-resource', unknown('UnknownResource', 'Missing')),
        ('transient-resource', unknown('UnknownResource', 'Cache')),
        ('late-invalid-resource', decode('InvalidResource', 'Score', 'integer', 'bad')),
    ]
    return {'root': root, 'initial': initial,
            'failures': [{'label': label, 'result': {'ok': False, 'error': error}, 'state': copy.deepcopy(initial)}
                         for label, error in errors],
            'afterFailureRead': state(4, 7, read=True), 'restored': {'ok': True},
            'afterRestore': state(4, 8, restored=True, pending=False, read=True),
            'stale': [{'ok': True, 'id': 1, 'name': 'restored'}]
                     + [{'ok': False, 'error': {'_tag': 'MissingEntity', 'entityId': n}} for n in range(2, 7)],
            'afterReaders': state(5, 11, restored=True, pending=False, read=True, readers=True),
            'allocated': 7,
            'afterAllocate': state(6, 13, restored=True, pending=False, read=True, readers=True, later=True)}

if __name__ == '__main__':
    Path(__file__).with_name('expected.json').write_text(json.dumps([expected('Workshop'), expected('Garden')], separators=(',', ':'))+'\n')
