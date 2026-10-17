"""Source-derived full-key successor; prior independent constructor model retained."""
from pathlib import Path
import hashlib
import json
import base_model

HERE = Path(__file__).resolve().parent


def key(index):
    return {'index': index, 'generation': 0}


def migrate_ids(value):
    # Authored IDs in the prior report are only Entity/CheckedEntity/Handle IDs.
    # Raw component arrays, payload numbers and stamp ticks are not converted.
    if isinstance(value, list):
        return [migrate_ids(item) for item in value]
    if isinstance(value, dict):
        return {name: key(item) if name == 'id' and isinstance(item, int)
                else migrate_ids(item) for name, item in value.items()}
    return value


def allocator():
    # Setup.reserve/activate twice, then reserve an inactive third key.
    # reserve_id leaves Consumed (not command-tracked Pending).
    leaf = lambda phase: {'ALeaf': {'generation': 0, 'phase': phase}}
    return {'next': 4, 'high': 3, 'capacity': 4, 'depth': 2,
            'slots': {'ANode': [
                {'ANode': [leaf('Consumed'), leaf('Live')]},
                {'ANode': [leaf('Live'), leaf('Consumed')]}]},
            'free': [], 'order': [key(1), key(2), key(3)]}


def expected_object():
    value = migrate_ids(base_model.expected_object())
    for namespace, name in enumerate(('Workshop', 'Garden'), 1):
        report = value['scenario'][name]
        for checkpoint in ('before', 'firstOwner', 'secondOwner', 'owner'):
            owner = report[checkpoint]
            assert owner['namespace'] == namespace
            owner['allocator'] = allocator()
    return value


def render_cost(raw):
    # Exact Value expansion plus Text-token consumption in Format.render.
    if isinstance(raw, dict):
        return 1 + 2 + len(raw) + max(len(raw) - 1, 0) + sum(map(render_cost, raw.values()))
    if isinstance(raw, list):
        return 1 + 2 + max(len(raw) - 1, 0) + sum(map(render_cost, raw))
    return 2


def render():
    return (json.dumps(expected_object(), separators=(',', ':'), ensure_ascii=False) + '\n').encode()


def selftest():
    value = expected_object()
    assert render_cost(allocator()) == 142 and render_cost(allocator()) <= 256
    for namespace, name in enumerate(('Workshop', 'Garden'), 1):
        report = value['scenario'][name]
        assert report['first'] == report['second']
        assert report['before'] == report['firstOwner'] == report['secondOwner']
        for checkpoint in ('before', 'firstOwner', 'secondOwner', 'owner'):
            owner = report[checkpoint]
            assert owner['handles'] == [{'namespace': namespace, 'id': key(index)} for index in (1, 2)]
            assert owner['allocator']['order'] == [key(index) for index in (1, 2, 3)]
            assert owner['store']['saved']['rows'][2] == {'id': key(3), 'components': {}}
            assert owner['store']['transient']['rows'][2] == {'id': key(3), 'components': {}}
            assert (owner['clock'], owner['pendingCount']) == (0, 0)
        assert report['first']['entities'][0] == {'id': key(1), 'components': {'Payload': [7, 9]}}
        assert report['after']['entities'][0] == {'id': key(1), 'components': {'Payload': [11, 13]}}
        assert report['afterValidation']['entities'][0]['id'] == key(1)
        assert report['firstValidation']['resources'][0]['result']['Rejected']['Invalid']['actual'] == 27
    assert value['ordinary'] == base_model.expected_object()['ordinary']
    raw = render()
    assert b'RENDER-FUEL' not in raw and raw.count(b'\n') == 1
    assert json.loads(raw) == value


def verify_basis():
    basis = json.loads((HERE / 'SOURCE-BASIS.json').read_text())
    for path, digest in basis['sourcePins'].items():
        assert hashlib.sha256(Path(path).read_bytes()).hexdigest() == digest, path
    assert hashlib.sha256((HERE / 'base_model.py').read_bytes()).hexdigest() == basis['oldBasis']['sha256']
    freeze = basis['freeze']
    assert hashlib.sha256(Path(freeze['path']).read_bytes()).hexdigest() == freeze['sha256']


if __name__ == '__main__':
    import sys
    verify_basis()
    selftest()
    if '--selftest' not in sys.argv:
        sys.stdout.buffer.write(render())
