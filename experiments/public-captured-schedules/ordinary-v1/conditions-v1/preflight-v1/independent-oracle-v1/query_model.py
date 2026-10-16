"""Independent finite captured component-query state and complete wire model."""
from dataclasses import dataclass, field
from copy import deepcopy
from pathlib import Path
import argparse
import gzip
import json
import hashlib
import base_model as base

HERE = Path(__file__).resolve().parent


@dataclass
class World:
    namespace: int
    high: int = 0
    clock: int = 0
    values: dict = field(default_factory=dict)
    stamps: dict = field(default_factory=dict)
    registered: bool = True

    def replace(self, identity, value):
        assert 1 <= identity <= self.high
        self.clock += 1
        old = self.stamps.get(identity)
        self.values[identity] = value
        self.stamps[identity] = (old[0] if old else self.clock, self.clock)


@dataclass
class Owner:
    namespace: int
    cursor: int = 0
    cells: list = field(default_factory=lambda: [1, 2, 3, 4])

    def entered(self, delta):
        self.cells = [value + delta * scale for value, scale in zip(self.cells, [1, 1, 10, 10])]


def invoke(world, owner, delta, fail_value):
    assert owner.namespace == world.namespace and world.registered
    before_values, before_stamps = deepcopy(world.values), deepcopy(world.stamps)
    output = []
    # World.handles returns ascending live identities. Write's required selector
    # excludes live ID3; Changed observes the pre-invocation success cursor.
    for identity in range(1, world.high + 1):
        if identity not in world.values or world.stamps[identity][1] <= owner.cursor:
            continue
        old = world.values[identity]
        world.replace(identity, old + delta)
        owner.entered(delta)
        if old == fail_value:
            # Undo restores each payload and lifecycle stamp, never World.clock.
            world.values, world.stamps = before_values, before_stamps
            return 'failure:' + str(old)
        output.append(old)
    owner.cursor = world.clock
    return 'success:' + base.show_list([str(value) for value in output])


def derive(namespace):
    world, foreign = World(namespace), World(namespace + 1)
    owner, twin = Owner(namespace), Owner(namespace + 1)
    rows = []

    def record(label):
        rows.append(deepcopy((label, world, foreign, owner, twin)))

    record('registered')
    record('empty:' + invoke(world, owner, 1, 0))
    world.high = 3  # Three actual reserve+activate operations, none tick clock.
    world.replace(1, 10)
    world.replace(2, 20)
    record('populated')
    record('late-failure:' + invoke(world, owner, 1, 20))
    record('retry:' + invoke(world, owner, 2, 0))
    record('no-changes:' + invoke(world, owner, 9, 0))
    world.replace(1, 30)
    record('external')
    record('changed-one:' + invoke(world, owner, 3, 0))
    record('skip')
    assert owner.namespace != foreign.namespace
    record('foreign-refused:99:0')
    world.registered = foreign.registered = False
    return rows, world, foreign, owner, twin


def world_text(world):
    slots = ''.join(('-' if identity not in world.values else str(world.values[identity])) + '@' + ':'.join(map(str, world.stamps.get(identity, (0, 0)))) + ';' for identity in range(4))
    live, capacity, depth = ('False', 1, 0) if world.high == 0 else ('((False,True),(True,True))', 4, 2)
    regs = '[1:captured-query:[Value, Value]]' if world.registered else '[]'
    return 'W{' + ','.join(map(str, [world.namespace, world.high + 1, world.high, live, capacity, depth, slots, 'Unit', '[]', 'pending=0', regs, 2, world.clock])) + '}'


def owner_text(owner):
    return str(owner.namespace) + ':1:captured-query:[Value, Value]:cursor=' + str(owner.cursor) + ':' + base.show_pack(owner.cells)


def render(namespace):
    rows, world, foreign, owner, twin = derive(namespace)
    text = ''.join('|'.join([label, world_text(w), world_text(f), owner_text(o), owner_text(t)]) + '\n' for label, w, f, o, t in rows)
    return text + '|'.join(['removed', world_text(world), world_text(foreign), base.show_pack(owner.cells), base.show_pack(twin.cells)]) + '\n'


def expected():
    return ('Workshop\n' + render(1) + 'Garden\n' + render(3) + '\n').encode()


def selftest():
    for namespace in [1, 3]:
        rows, world, foreign, owner, twin = derive(namespace)
        assert len(rows) == 10
        assert [r[1].clock for r in rows] == [0, 0, 2, 4, 6, 6, 7, 8, 8, 8]
        assert [r[3].cursor for r in rows] == [0, 0, 0, 0, 6, 6, 6, 8, 8, 8]
        assert rows[3][1].values == rows[2][1].values == {1: 10, 2: 20}
        assert rows[3][1].stamps == rows[2][1].stamps == {1: (1, 1), 2: (2, 2)}
        assert rows[3][3].cells == [3, 4, 23, 24]
        assert rows[4][3].cells == [7, 8, 63, 64]
        assert rows[4][1].values == {1: 12, 2: 22}
        assert rows[4][1].stamps == {1: (1, 5), 2: (2, 6)}
        assert rows[4][1:] == rows[5][1:]  # nonmatching selection changes nothing
        assert rows[5][0] == 'no-changes:success:[]'
        assert rows[4][0] == 'retry:success:[10, 20]'
        assert rows[7][0] == 'changed-one:success:[30]'
        assert rows[7][1:] == rows[8][1:] == rows[9][1:]
        assert world.values == {1: 33, 2: 22}
        assert world.stamps == {1: (1, 8), 2: (2, 6)}
        assert world.clock == owner.cursor == 8 and owner.cells == [10, 11, 93, 94]
        assert twin == Owner(namespace + 1)
        assert foreign == World(namespace + 1, registered=False)
        assert not world.registered and not foreign.registered
        assert all(3 not in row[1].values and 0 not in row[1].values for row in rows)
    raw = expected()
    assert raw.count(b'\n') == 25 and raw.endswith(b'\n\n') and not raw.endswith(b'\n\n\n')
    base.source_bindings()
    assert hashlib.sha256((HERE / 'base_model.py').read_bytes()).hexdigest() == json.loads((HERE / 'model-basis.json').read_text())['baseModelSHA256']


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
    print(json.dumps({'status': 'PASS', 'bytes': len(raw), 'sha256': base.digest(raw), 'worldSnapshots': 22, 'matchingRowEntriesPerSchema': 5}))


if __name__ == '__main__':
    main()
