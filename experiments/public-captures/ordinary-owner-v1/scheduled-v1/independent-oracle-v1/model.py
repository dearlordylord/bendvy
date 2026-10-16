"""Source-only extension of the unchanged independent capture state model."""
from pathlib import Path
from copy import deepcopy
import argparse
import gzip
import hashlib
import json
import base_model as base

HERE = Path(__file__).resolve().parent
BASE_MODEL_SHA = '3d0276df65f8ac33dcb1a51bd527e86464d0a719a3e147d4da2a856618d53e49'


def derive(namespace):
    world, foreign = base.World(namespace, 10), base.World(namespace + 1, 900)
    twin = base.Capture.fresh(namespace + 1, foreign.register('first'), 'first', 500)
    first = base.Capture.fresh(namespace, world.register('first'), 'first', 1)
    second = base.Capture.fresh(namespace, world.register('second'), 'second', 100)
    rows, plans = [], []

    def record(label, status, a=first, b=second):
        rows.append(deepcopy((label, status, world, foreign, a, b)))

    record('registered', 'registered')
    operations = [
        ('scheduled-success', first, second, 0, 1, False),
        ('second-success', second, first, 0, 10, False),
        ('scheduled-skip', first, second, 1, 999, False),
        ('scheduled-failure', first, second, 0, 2, True),
        ('scheduled-retry', first, second, 0, 3, False),
        ('second-repeat', second, first, 0, 20, False),
    ]
    for label, active, passive, condition, delta, fails in operations:
        # Every invocation rebuilds a validated plan from actual namespace/ID,
        # returning its original complete step list and all original arguments.
        steps = ['Phase:capture', 'System:' + str(active.identity) + ':' + str(condition), 'Barrier']
        observations = ['Entered:capture']
        if condition == 0:
            world.invoke(active, delta, fails)
            observations.append('Ran:' + str(active.identity))
        else:
            observations.append('Skipped:' + str(active.identity))
        if not fails:
            observations.append('Applied')  # empty pending journal, no tick
        plans.append((label, namespace, steps, delta, fails, observations))
        # Finished is Success even when its system was condition-skipped.
        record(label, 'failure:Failed' if fails else 'success', active, passive)
    assert first.identity == twin.identity == 1
    assert first.name == twin.name == 'first'
    assert first.namespace != twin.namespace
    # Both foreign calls reject based on namespace, despite the complete
    # ID/name/access collision; neither callback nor disposal runs there.
    record('foreign', 'refused:99:False')
    record('foreign-unregister-refused', 'skipped')
    # Three actual successful local disposals recover three complete owners.
    world.registrations.remove((first.identity, first.name))
    world.registrations.remove((second.identity, second.name))
    foreign.registrations.remove((twin.identity, twin.name))
    return rows, plans, first, second, twin, world, foreign


def render(namespace):
    rows, plans, first, second, twin, world, foreign = derive(namespace)
    text = 'twin-initial|' + base.show_capture(base.Capture.fresh(namespace + 1, 1, 'first', 500)) + '\n'
    for label, ns, steps, delta, fails, observations in plans:
        text += label + '=plan=' + str(ns) + ':capture:' + base.show_list(steps)
        text += ';args=' + str(delta) + ':' + ('True' if fails else 'False')
        text += ';observations=' + base.show_list(observations) + '\n'
    text += 'unregister=Refused\n' + base.show_rows(rows)
    text += 'first-returned|' + base.show_pack(first.cells) + '\n'
    text += 'second-returned|' + base.show_pack(second.cells) + '\n'
    text += 'twin-returned|' + base.show_pack(twin.cells) + '\n'
    return text + 'final-worlds|' + base.show_world(world) + '|' + base.show_world(foreign) + '\n'


def expected():
    return ('Workshop\n' + render(1) + 'Garden\n' + render(3) + '\n').encode()


def selftest():
    base.invariants()  # old model remains unchanged and independently grounded
    for namespace in [1, 3]:
        rows, plans, first, second, twin, world, foreign = derive(namespace)
        assert len(rows) == 9 and len(plans) == 6
        assert [r[2].counter for r in rows] == [10, 11, 21, 21, 21, 24, 44, 44, 44]
        assert rows[2][4].identity == rows[6][4].identity == 2
        assert rows[3][4].identity == rows[4][4].identity == 1
        assert rows[3][2:] == (rows[2][2], rows[2][3], rows[2][5], rows[2][4])
        assert rows[4][2] == rows[3][2]  # failure restores complete World
        assert rows[4][4].cells == [4, 5, 33, 34]
        assert plans[2][3:5] == (999, False)
        assert plans[2][-1] == ['Entered:capture', 'Skipped:1', 'Applied']
        assert plans[3][-1] == ['Entered:capture', 'Ran:1']
        assert plans[3][2] == ['Phase:capture', 'System:1:0', 'Barrier']
        assert rows[7][2:] == rows[8][2:]  # foreign dispose preserves all
        assert rows[7][2:] == (rows[6][2], rows[6][3], rows[6][5], rows[6][4])
        assert all(r[3] == base.World(namespace + 1, 900, [(1, 'first')], 2) for r in rows)
        assert first.cells == [7, 8, 63, 64]
        assert second.cells == [130, 131, 402, 403]
        assert twin.cells == [500, 501, 502, 503]
        assert not world.registrations and not foreign.registrations
        assert world.next_system == 3 and foreign.next_system == 2
        assert world.counter == 44 and foreign.counter == 900
    raw = expected()
    assert raw.count(b'\n') == 45 and raw.endswith(b'\n\n')
    assert not raw.endswith(b'\n\n\n')
    base.source_bindings()  # copied helper resolves this leaf's archive
    assert hashlib.sha256((HERE / 'base_model.py').read_bytes()).hexdigest() == BASE_MODEL_SHA


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
    print(json.dumps({'status': 'PASS', 'bytes': len(raw), 'sha256': base.digest(raw), 'rows': 18, 'plans': 12, 'recoveredPacks': 6}))


if __name__ == '__main__':
    main()
