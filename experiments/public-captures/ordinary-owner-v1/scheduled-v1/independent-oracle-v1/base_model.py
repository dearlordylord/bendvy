"""Independent finite state model of the frozen ordinary captures consumer.

No Bend backend or candidate output is read. Executable state is represented by
ordinary Python values; rendering follows the pinned explicit format functions.
"""
from dataclasses import dataclass, field
from pathlib import Path
from copy import deepcopy
import gzip
import hashlib
import json
import tarfile

HERE = Path(__file__).resolve().parent


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


@dataclass
class Capture:
    namespace: int
    identity: int
    name: str
    cells: list

    @classmethod
    def fresh(cls, namespace, identity, name, seed):
        return cls(namespace, identity, name, [seed + k for k in range(4)])

    def add(self, delta):
        # Two independently owned depth-one arrays. Second field scales by ten.
        self.cells = [x + delta * scale for x, scale in zip(self.cells, [1, 1, 10, 10])]


@dataclass
class World:
    namespace: int
    counter: int
    registrations: list = field(default_factory=list)
    next_system: int = 1

    def register(self, name):
        identity = self.next_system
        self.next_system += 1
        self.registrations.insert(0, (identity, name))
        return identity

    def invoke(self, capture, delta, fails=False):
        assert capture.namespace == self.namespace
        assert (capture.identity, capture.name) in self.registrations
        capture.add(delta)
        # The capture is outside the World undo journal. Its changes survive
        # error; the single resource replacement is undone on failure.
        if not fails:
            self.counter += delta


def derive(namespace):
    world, foreign = World(namespace, 10), World(namespace + 1, 900)
    first = Capture.fresh(namespace, world.register('first'), 'first', 1)
    second = Capture.fresh(namespace, world.register('second'), 'second', 100)
    rows = []

    def record(label, status, a=first, b=second):
        rows.append(deepcopy((label, status, world, foreign, a, b)))

    record('registered', 'registered')
    world.invoke(first, 1)
    record('first', 'success')
    world.invoke(second, 10)
    # Actual call is swap(run(swap(state))); run records before the outer swap.
    record('second', 'success', second, first)
    record('skip', 'skipped')
    world.invoke(first, 2, fails=True)
    record('failed', 'failure:Failed')
    world.invoke(first, 3)
    record('retry', 'success')
    # Local namespace validation refuses before entering the callback.
    assert first.namespace != foreign.namespace
    record('foreign', 'refused:99:False')
    old_identity = first.identity
    recovered = deepcopy(first.cells)
    world.registrations.remove((old_identity, first.name))
    assert (old_identity, first.name) not in world.registrations
    first.identity = world.register('first')
    record('reregistered', 'removed:' + show_pack(recovered) + ':1:False')
    world.invoke(first, 4)
    record('returned-capture-run', 'success')
    return rows


def show_pack(cells):
    a, b, c, d = cells
    return '{(' + str(a) + ',' + str(b) + ');(' + str(c) + ',' + str(d) + ')}'


def show_list(values):
    # Base.List.show: comma followed by one space, no quotes added by text.
    return '[' + ', '.join(values) + ']'


def show_world(world):
    registrations = show_list([str(i) + ':' + name + ':[Counter]' for i, name in world.registrations])
    # No entity reservation/spawn, event, command or clock operation occurs.
    return 'W{' + ','.join(map(str, [world.namespace, 1, 0, 'False', 1, 0, world.counter, '[]', 0, registrations, world.next_system, 0])) + '}'


def show_capture(capture):
    return ':'.join(map(str, [capture.namespace, capture.identity, capture.name, '[Counter]', show_pack(capture.cells)]))


def show_rows(rows):
    return ''.join('|'.join([label, status, show_world(world), show_world(foreign), show_capture(a), show_capture(b)]) + '\n'
                   for label, status, world, foreign, a, b in rows)


def expected():
    # Main runs Workshop creation twice before Garden's two creations. One final
    # IO.print adds LF to an argument already terminated by its final trace row.
    return ('Workshop\n' + show_rows(derive(1)) + 'Garden\n' + show_rows(derive(3)) + '\n').encode()


def invariants():
    for namespace in [1, 3]:
        rows = derive(namespace)
        assert len(rows) == 9
        assert [r[0] for r in rows] == ['registered', 'first', 'second', 'skip', 'failed', 'retry', 'foreign', 'reregistered', 'returned-capture-run']
        assert [r[2].counter for r in rows] == [10, 11, 21, 21, 21, 24, 24, 24, 28]
        assert all(r[3] == World(namespace + 1, 900) for r in rows)
        assert rows[2][4].identity == 2 and rows[2][5].identity == 1
        assert rows[3][4].identity == 1 and rows[3][5].identity == 2
        assert rows[2][2:4] == rows[3][2:4]
        assert rows[3][4].cells == [2, 3, 13, 14]
        assert rows[4][4].cells == [4, 5, 33, 34]
        assert rows[4][2] == rows[3][2]  # exact World rollback
        assert rows[5][4].cells == [7, 8, 63, 64]
        assert rows[6][2:] == rows[5][2:]  # complete foreign refusal preservation
        assert rows[7][4].identity == 3
        assert rows[7][4].cells == rows[6][4].cells
        assert rows[7][2].registrations == [(3, 'first'), (2, 'second')]
        assert rows[7][2].next_system == 4
        assert rows[-1][4].cells == [11, 12, 103, 104]
        assert rows[-1][5].cells == [110, 111, 202, 203]
        assert all(r[2].registrations == [(2, 'second'), (1, 'first')] for r in rows[:7])
    raw = expected()
    assert raw.endswith(b'\n\n') and not raw.endswith(b'\n\n\n')
    assert raw.count(b'\n') == 21


def source_bindings():
    freeze = json.loads((HERE / 'source-freeze.json').read_text())
    with tarfile.open(HERE / 'source.tar.gz') as archive:
        observed = {m.name: digest(archive.extractfile(m).read()) for m in archive.getmembers()}
    assert observed == {row['snapshot']: row['sha256'] for row in freeze['bindings']}
    for row in freeze['bindings']:
        snapshot = Path(freeze['snapshotRoot']) / row['snapshot']
        if snapshot.exists():
            assert digest(snapshot.read_bytes()) == row['sha256']
    return len(observed)


def main():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    invariants()
    pins = source_bindings()
    raw = expected()
    if args.write:
        (HERE / 'normal.stdout').write_bytes(raw)
        (HERE / 'normal.stdout.gz').write_bytes(gzip.compress(raw, mtime=0))
    assert (HERE / 'normal.stdout').read_bytes() == raw
    assert gzip.decompress((HERE / 'normal.stdout.gz').read_bytes()) == raw
    print(json.dumps({'status': 'PASS', 'sourceBindings': pins, 'rows': 18, 'bytes': len(raw), 'sha256': digest(raw)}))


if __name__ == '__main__':
    main()
