"""Independent finite typed heterogeneous captured schedule oracle."""
from pathlib import Path
from copy import deepcopy
import argparse
import gzip
import hashlib
import json
import base_model as base
import query_model as query

HERE = Path(__file__).resolve().parent
PLAN = '(phase:outer:[],((system:1:0:[component:1],phase:inner:[]),(system:2:0:[resource:2],barrier:[])))'


def derive(namespace):
    world, foreign = query.World(namespace, high=3), query.World(namespace + 1)
    world.replace(1, 10)
    world.replace(2, 20)
    owner = query.Owner(namespace)
    resource, resource_capture = 10, [100, 101]
    rows = []

    def record(label, delta=10, fails=False, enabled=True):
        rows.append(deepcopy((label, delta, fails, enabled, world, foreign, owner, resource, resource_capture)))

    record('registered')
    for label, delta, fails, enabled in [('first', 10, False, True), ('resource-skip', 999, False, False), ('resource-failure', 2, True, True), ('retry', 3, False, True)]:
        query.invoke(world, owner, 1, 0)
        logs = ['phase:outer', 'ran:1', 'phase:inner']
        if enabled:
            resource_capture = [v + delta for v in resource_capture]
            logs.append('ran:2')
            if not fails:
                resource += delta
        else:
            logs.append('skipped:2')
        if not fails:
            logs.append('barrier')
        status = ':failure:resource:Failed:' if fails else ':success:'
        record(label + status + base.show_list(logs), delta, fails, enabled)
    # Whole catalog namespace/identity validation fails before any phase,
    # provisioning or dispatch; schedule args and owners returned unchanged.
    record('foreign:refused:[]', 3)
    return rows


def world_text(world, resource, primary):
    text = query.world_text(world)
    regs = '[2:resource-counter:[Counter], 1:captured-query:[Value, Value]]' if primary else '[]'
    text = text.replace(',Unit,', ',' + str(resource) + ',').replace('[1:captured-query:[Value, Value]]', regs)
    return text.replace(',2,' + str(world.clock) + '}', ',' + ('3' if primary else '1') + ',' + str(world.clock) + '}')


def render(namespace):
    text = ''
    for label, delta, fails, enabled, world, foreign, owner, resource, cells in derive(namespace):
        args = 'args=1:0:True,' + str(delta) + ':' + ('True' if fails else 'False') + ':' + ('True' if enabled else 'False')
        resource_owner = str(namespace) + ':2:resource-counter:[Counter]:(' + ','.join(map(str, cells)) + ')'
        text += '|'.join([label, 'nested-captures:' + PLAN, args, world_text(world, resource, True), world_text(foreign, 10, False), query.owner_text(owner), resource_owner]) + '\n'
    return text


def expected():
    return ('Workshop\n' + render(1) + 'Garden\n' + render(3) + '\n').encode()


def selftest():
    for namespace in [1, 3]:
        rows = derive(namespace)
        assert len(rows) == 6
        assert [r[4].clock for r in rows] == [2, 4, 4, 4, 4, 4]
        assert [r[6].cursor for r in rows] == [0, 4, 4, 4, 4, 4]
        assert [r[7] for r in rows] == [10, 20, 20, 20, 23, 23]
        assert [r[8] for r in rows] == [[100, 101], [110, 111], [110, 111], [112, 113], [115, 116], [115, 116]]
        assert rows[0][6].cells == [1, 2, 3, 4]
        assert all(row[6].cells == [3, 4, 23, 24] for row in rows[1:])
        assert rows[-1][4:] == rows[-2][4:]
        assert rows[3][4] == rows[2][4]  # completed query prefix preserved
        assert rows[3][7] == rows[2][7] and rows[3][8] != rows[2][8]
        assert 'barrier' not in rows[3][0]
        assert rows[-1][4].values == {1: 11, 2: 21}
        assert rows[-1][4].stamps == {1: (1, 3), 2: (2, 4)}
        assert all(row[5] == query.World(namespace + 1) for row in rows)
    base.source_bindings()
    for name, sha in json.loads((HERE / 'model-basis.json').read_text())['modelHashes'].items():
        assert hashlib.sha256((HERE / name).read_bytes()).hexdigest() == sha
    raw = expected()
    assert raw.count(b'\n') == 15 and raw.endswith(b'\n\n') and not raw.endswith(b'\n\n\n')


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
    print(json.dumps({'status': 'PASS', 'bytes': len(raw), 'sha256': base.digest(raw), 'snapshots': 12}))


if __name__ == '__main__':
    main()
