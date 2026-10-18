"""Additive typed captures from the unchanged independent operation model.

The verbose model remains immutable. Captures attach actual model states at its
existing observation points, rather than parsing any subject output or filling
physical state from the requested workload size.
"""
import copy
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import model as legacy
import program as old
from operations import Transaction


class SnapshotText(str):
    def __new__(cls, text, snapshot=None):
        value = super().__new__(cls, text)
        value.snapshot = snapshot
        return value


class World(old.World):
    def wire(self):
        return SnapshotText(super().wire(), copy.deepcopy(self))


class Program(old.Program):
    def __init__(self, *args):
        super().__init__(*args)
        self.typed_calls = []
        self.typed_logs = []

    def invoke(self, index):
        super().invoke(index)
        boundary = self.boundaries[-1] if index == 3 else None
        self.typed_calls.append({
            'operation': index, 'id': self.ids[index], 'status': 0,
            'namespace': self.world.namespace, 'name': 'Lifecycle/' +
            ['Select', 'Reserve', 'Dispose', 'Observe'][index],
            'access': old.access(['Select', 'Reserve', 'Dispose', 'Observe'][index]),
            'capture': [self.counts[index], 101 + index],
            'frame': copy.deepcopy(self.frame), 'boundary': boundary,
        })

    def schedule(self, name, steps):
        super().schedule(name, steps)
        self.typed_logs.append({
            'name': 'Lifecycle/' + name,
            'steps': [('Barrier',) if index is None else ('System', self.ids[index], False)
                      for index in steps],
            'status': 0,
            'observations': [('Applied',) if index is None else ('Ran', self.ids[index])
                             for index in steps],
        })


def run(count=64, iterations=64, primary_namespace=1, foreign_namespace=2):
    world, foreign = World(primary_namespace), World(foreign_namespace)
    tx = Transaction(world)
    reservations = []
    for index in range(count):
        reservations.append(tx.spawn([[index, index + 1, index + 2, index + 3],
                                      [1, 2, 3, 4] if index % 3 == 0 else None,
                                      8 if index % 3 == 1 else None]))
    tx.finish()
    captures = {'count': count, 'iterations': iterations, 'seed_outcome': 0,
                'reservations': reservations, 'seed_pending': copy.deepcopy(world)}
    world.barrier()
    captures['seed_applied'] = copy.deepcopy(world)
    tx = Transaction(foreign)
    foreign_handle = tx.spawn([[999, 1000, 1001, 1002], None, None])
    tx.finish()
    captures.update(foreign_outcome=0, foreign_reservation=foreign_handle,
                    foreign_pending=copy.deepcopy(foreign))
    foreign.barrier()
    captures['foreign_applied'] = copy.deepcopy(foreign)
    captures['own_lookup'] = {'MissingEntity': 0, 'ComponentAbsent': 1, 'Found': 2}[
        foreign.component(foreign_handle)[0]]
    captures['foreign_verified'] = copy.deepcopy(foreign)
    program = Program(world, foreign, foreign_handle, count)
    captures['registered'] = copy.deepcopy(program)
    for _ in range(iterations):
        program.step()
    captures['final'] = program
    return captures


def selftest():
    captures = run()
    expected, previous = legacy.report()
    current = captures['final']
    assert current.wire() == previous.wire()
    assert captures['registered'].typed_calls == []
    assert len(current.typed_calls) == 384
    assert len(current.typed_logs) == 384
    assert len(current.boundaries) == 192
    for boundary in current.boundaries:
        assert isinstance(boundary.before, SnapshotText)
        assert isinstance(boundary.after, SnapshotText)
        assert old.World.wire(boundary.before.snapshot) == boundary.before
        assert old.World.wire(boundary.after.snapshot) == boundary.after
    assert len(expected) == 14774371
    return True


if __name__ == '__main__':
    assert selftest()
    print('PASS typed Motion64 capture at unchanged observation points')
