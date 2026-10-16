"""Independent source-only ordinary App captured-query binding trace."""
from pathlib import Path
from copy import deepcopy
import argparse
import gzip
import hashlib
import json
import base_model as base
import query_model as query

HERE = Path(__file__).resolve().parent


def derive(namespace):
    world = query.World(namespace, high=3)
    world.replace(1, 10)
    world.replace(2, 20)
    first, second = query.Owner(namespace), query.Owner(namespace, cells=[100, 101, 102, 103])
    rows = []

    def record(label, debug=True):
        rows.append(deepcopy((label, debug, world, first, second)))

    record('disabled', False)
    record('enabled')
    record('first:' + query.invoke(world, first, 1, 0))
    record('second:' + query.invoke(world, second, 10, 0))
    record('first-sees-second:' + query.invoke(world, first, 1, 0))
    record('first-no-changes:' + query.invoke(world, first, 99, 0))
    world.registered = False
    return rows, world, first, second


def world_text(world):
    # Reuse exact logical column/live serialization; App has two registrations
    # whose order is newest first, unlike fold/debug declaration order.
    text = query.world_text(world)
    return text.replace('[1:captured-query:[Value, Value]]', '[2:query-b:[Value, Value], 1:query-a:[Value, Value]]').replace(',2,' + str(world.clock) + '}', ',3,' + str(world.clock) + '}')


def owner_text(owner, identity, name):
    return str(owner.namespace) + ':' + str(identity) + ':' + name + ':[Value, Value]:cursor=' + str(owner.cursor) + ':' + base.show_pack(owner.cells)


def binding(owner, identity, name):
    return ':'.join(map(str, [owner.namespace, identity, name, '[Value, Value]', owner.cursor, name, '[Value:write, Value:changed]']))


def render(namespace):
    rows, world, first, second = derive(namespace)
    text = ''
    for label, debug, w, a, b in rows:
        view = base.show_list([binding(a, 1, 'query-a'), binding(b, 2, 'query-b')]) + '/[]' if debug else 'disabled'
        text += '|'.join([label, view, world_text(w), owner_text(a, 1, 'query-a'), owner_text(b, 2, 'query-b')]) + '\n'
    return text + '|'.join(['removed', world_text(world), base.show_pack(first.cells), base.show_pack(second.cells)]) + '\n'


def expected():
    return ('Workshop\n' + render(1) + 'Garden\n' + render(2) + '\n').encode()


def selftest():
    for namespace in [1, 2]:
        rows, world, first, second = derive(namespace)
        assert len(rows) == 6
        assert rows[0][2:] == rows[1][2:]  # enabling snapshot does not enter body
        assert [r[2].clock for r in rows] == [2, 2, 4, 6, 8, 8]
        assert [r[3].cursor for r in rows] == [0, 0, 4, 4, 8, 8]
        assert [r[4].cursor for r in rows] == [0, 0, 0, 6, 6, 6]
        assert rows[2][0] == 'first:success:[10, 20]'
        assert rows[3][0] == 'second:success:[11, 21]'
        assert rows[4][0] == 'first-sees-second:success:[21, 31]'
        assert rows[5][0] == 'first-no-changes:success:[]'
        assert rows[4][2:] == rows[5][2:]
        assert world.values == {1: 22, 2: 32}
        assert world.stamps == {1: (1, 7), 2: (2, 8)}
        assert first.cells == [5, 6, 43, 44] and second.cells == [120, 121, 302, 303]
        assert first.cursor == 8 and second.cursor == 6
        assert not world.registered
        assert world_text(world).endswith(',pending=0,[],3,8}')
        enabled = render(namespace).splitlines()[1]
        assert enabled.index(':1:query-a:') < enabled.index(':2:query-b:')
        assert '[2:query-b:[Value, Value], 1:query-a:[Value, Value]]' in enabled
    base.source_bindings()
    basis = json.loads((HERE / 'model-basis.json').read_text())
    for name, digest in basis['modelHashes'].items():
        assert hashlib.sha256((HERE / name).read_bytes()).hexdigest() == digest
    raw = expected()
    assert raw.count(b'\n') == 17 and raw.endswith(b'\n\n') and not raw.endswith(b'\n\n\n')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    selftest()
    raw = expected()
    if args.write:
        (HERE / 'normal.stdout').write_bytes(raw)
        (HERE / 'normal.stdout.gz').write_bytes(gzip.compress(raw, mtime=0))
    assert (HERE / 'normal.stdout').read_bytes() == raw
    assert gzip.decompress((HERE / 'normal.stdout.gz').read_bytes()) == raw
    print(json.dumps({'status': 'PASS', 'bytes': len(raw), 'sha256': base.digest(raw), 'worldSnapshots': 14, 'debugProducts': 10}))


if __name__ == '__main__':
    main()
