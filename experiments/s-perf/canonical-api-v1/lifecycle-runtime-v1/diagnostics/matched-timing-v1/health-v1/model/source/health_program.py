"""Source model of typed Lifecycle units; bootstrap is evaluated by model.py."""
import copy
from dataclasses import dataclass, field
import json
from operations import World as PhysicalWorld, Handle, Key, Transaction, U32_MAX


def listing(values):
    return '[' + ', '.join(map(str, values)) + ']'


def tree(values):
    if len(values) == 1:
        return 'leaf:' + str(values[0])
    middle = len(values) // 2
    return 'node(' + tree(values[:middle]) + ',' + tree(values[middle:]) + ')'


def mix(left, right):
    return (left * 65599 + right) & U32_MAX


def fields(values, seed=1):
    for value in values:
        seed = mix(seed, value)
    return seed


def handle(value):
    return f'{value.namespace}:{value.key.index}:{value.key.generation}'


def maybe(value):
    return 'None' if value is None else 'Some(' + handle(value) + ')'


@dataclass
class World(PhysicalWorld):
    registrations: list = field(default_factory=list)
    next_system: int = 1

    def main(self, value):
        return 'Vitals{' + tree(value) + ';9,2}'

    def aux(self, value):
        return 'Armor{' + tree(value) + ';3}'

    def flag(self, value):
        return 'Tracked{' + str(value) + '}'

    def wire(self):
        allocator = self.allocator
        allocated = (f'next={allocator.next};high={allocator.high};capacity={len(allocator.slots)};'
                     + f'depth={len(allocator.slots).bit_length() - 1};slots='
                     + tree([f'{slot.generation}:{slot.phase}' for slot in allocator.slots])
                     + ';free=' + listing(allocator.free) + ';order='
                     + listing(f'{key.index}:{key.generation}' for key in allocator.order))
        stored = []
        for name, column, render in zip(['main', 'aux', 'flag'], self.columns, [self.main, self.aux, self.flag]):
            values = ['none' if value is None else 'some(' + render(value) + ')' for value in column.values]
            stamps = [f'{index}:{column.stamps[index][0]}:{column.stamps[index][1]}' for index in column.order]
            stored.append(name + '={Column{values=' + tree(values) + ';stamps=' + listing(stamps) + '}}')
        resource = 'HealthLedger{' + tree(self.ledger) + ';4};sibling=Unit'
        registrations = listing(str(identity) + ':' + name + ':' + listing(access)
                                for identity, name, access in self.registrations)
        return (f'namespace={self.namespace}|allocator={{' + allocated + '}|store={'
                + ';'.join(stored) + '}|resource={' + resource + '}|events=[]|pending='
                + str(len(self.pending)) + ':' + 'Raw;' * len(self.pending)
                + 'end|registrations=' + registrations + f'|nextSystem={self.next_system}|clock={self.clock}')

    def row_data(self, entity):
        return (entity, self.component(entity, 0)[1], self.component(entity, 1)[1], self.component(entity, 2)[1])

    def rows(self):
        return [self.row_data(entity) for entity in self.main_handles()]


def row_wire(row):
    entity, main, aux, flag = row
    main_text = json.dumps({'levels': dict(zip('abcd', main)), 'reserve': 9, 'class': 2}, separators=(',', ':'))
    aux_text = ('ComponentAbsent' if aux is None else 'Found('
                + json.dumps({'layers': dict(zip('abcd', aux)), 'grade': 3}, separators=(',', ':')) + ')')
    flag_text = 'ComponentAbsent' if flag is None else 'Found({"group":' + str(flag) + '})'
    return 'handle=' + handle(entity) + ';main=Found(' + main_text + ');aux=' + aux_text + ';flag=' + flag_text


def rows_hash(rows):
    hashes = []
    for entity, main, aux, flag in rows:
        hashes.append(fields([entity.namespace, entity.key.index, mix(mix(fields(main), 9), 2),
                              0 if aux is None else mix(fields(aux), 3),
                              0 if flag is None else mix(1, flag)]))
    return mix(fields(hashes), 0)


@dataclass
class Frame:
    count: int
    foreign: Handle
    iteration: int = 0
    phase: int = 0
    target: object = None
    pending: object = None
    stale: list = field(default_factory=list)
    reservations: list = field(default_factory=list)

    def wire(self):
        return (f'count={self.count};iteration={self.iteration};phase={self.phase};target='
                + maybe(self.target) + ';pending=' + maybe(self.pending) + ';foreign=' + handle(self.foreign)
                + ';stale=' + listing(handle(value) for value in self.stale)
                + ';reservations=' + listing('Reserved(' + handle(value) + ')' for value in self.reservations))


@dataclass
class Boundary:
    frame: Frame
    rows: list
    ledger: list
    lookups: list
    stale: list
    before: str
    after: str

    def wire(self):
        ledger = json.dumps({'totals': dict(zip('abcd', self.ledger)), 'epoch': 4}, separators=(',', ':'))
        lookups = json.dumps(dict(zip('abcd', self.lookups)), separators=(',', ':'))
        return ('Boundary{' + self.frame.wire() + ';query=' + listing(row_wire(row) for row in self.rows)
                + ';ledger=' + ledger + ';lookups=' + lookups + ';staleQueries='
                + listing(handle(value) + '=' + str(kind) for value, kind in self.stale)
                + ';before={' + self.before + '};after={' + self.after + '}}')

    def digest(self):
        stale_hash = mix(fields(fields([value.namespace, value.key.index, kind]) for value, kind in self.stale), 0)
        return fields([self.frame.iteration, self.frame.phase, rows_hash(self.rows),
                       mix(fields(self.ledger), 4), fields(self.lookups), stale_hash])


def output_wire(frame, boundary):
    return 'Some{' + frame.wire() + ';boundary=' + ('None' if boundary is None else boundary.wire()) + '}'


def access(kind):
    return {'Select': ['Vitals'], 'Reserve': ['command:spawn'],
            'Dispose': ['Vitals', 'command:remove', 'command:despawn'],
            'Observe': ['Vitals', 'Armor', 'Tracked', 'HealthLedger']}[kind]


class Program:
    def __init__(self, world, foreign_world, foreign_handle, count):
        self.world = world
        self.foreign_world = foreign_world
        self.frame = Frame(count, foreign_handle)
        self.initial_handles = world.main_handles()
        self.digest = 1
        self.boundaries = []
        self.calls = []
        self.logs = []
        self.counts = [0, 0, 0, 0]
        self.ids = []
        for kind in ['Select', 'Reserve', 'Dispose', 'Observe']:
            identity = world.next_system
            world.next_system += 1
            world.registrations.insert(0, (identity, 'Lifecycle/' + kind, access(kind)))
            self.ids.append(identity)

    def local(self, index):
        kind = ['Select', 'Reserve', 'Dispose', 'Observe'][index]
        return (f'namespace={self.world.namespace};id={self.ids[index]};name=Lifecycle/{kind};access='
                + listing(access(kind)) + ';owner=' + tree([self.counts[index], 101 + index]))

    def lookup(self, value):
        return 0 if value is None else {'MissingEntity': 0, 'ComponentAbsent': 1, 'Found': 2}[self.world.component(value)[0]]

    def invoke(self, index):
        kind = ['Select', 'Reserve', 'Dispose', 'Observe'][index]
        self.counts[index] += 1
        boundary = None
        if index == 0:
            handles = self.world.main_handles()
            position = [0, self.frame.count // 2, self.frame.count - 1][self.frame.iteration % 3]
            self.frame.target = handles[position] if 0 <= position < len(handles) else None
        elif index == 1:
            iteration = self.frame.iteration
            tx = Transaction(self.world)
            self.frame.pending = tx.spawn([[iteration, iteration + 1, iteration + 2, iteration + 3], None, None])
            tx.finish()
            self.frame.reservations.append(self.frame.pending)
        elif index == 2:
            assert self.frame.target is not None
            self.frame.stale.append(self.frame.target)
            tx = Transaction(self.world)
            assert tx.remove(self.frame.target) and tx.despawn(self.frame.target)
            tx.finish()
        else:
            before = self.world.wire()
            boundary = Boundary(copy.deepcopy(self.frame), self.world.rows(), self.world.ledger.copy(),
                                [self.lookup(self.frame.pending), self.lookup(self.frame.target), self.lookup(self.frame.foreign), 0],
                                [(value, self.lookup(value)) for value in self.frame.stale], before, self.world.wire())
            assert boundary.before == boundary.after
            self.boundaries.append(boundary)
            self.digest = mix(self.digest, boundary.digest())
        self.calls.append('Call{' + kind + f';id={self.ids[index]};status=Succeeded;local={{'
                          + self.local(index) + '};output=' + output_wire(self.frame, boundary) + '}')

    def schedule(self, name, steps):
        rendered = []
        observations = []
        for index in steps:
            if index is None:
                self.world.barrier()
                rendered.append('Barrier')
                observations.append('Applied')
            else:
                self.invoke(index)
                rendered.append(f'System({self.ids[index]},0)')
                observations.append(f'Ran({self.ids[index]})')
        self.logs.append('Log{Lifecycle/' + name + ';steps=' + listing(rendered)
                         + ';status=Complete;observations=Some(' + listing(observations) + ')}')

    def step(self):
        self.frame.phase = 0
        self.schedule('SelectReserve', [0, 1])
        self.schedule('ObservePending', [3])
        self.schedule('Apply', [None])
        self.frame.phase = 1
        self.schedule('ObserveApplied', [3])
        self.schedule('DisposeBarrier', [2, None])
        self.frame.phase = 2
        self.schedule('ObserveAfter', [3])
        self.frame.iteration += 1

    def wire(self):
        owners = ('select={' + self.local(0) + '};reserve={' + self.local(1)
                  + '};dispose={' + self.local(2) + '};observe={' + self.local(3)
                  + '};frame={' + self.frame.wire() + '};digest=' + str(self.digest)
                  + ';boundaries=' + listing(value.wire() for value in self.boundaries)
                  + ';calls=' + listing(self.calls))
        return (f'namespace={self.world.namespace};ids=' + ','.join(map(str, self.ids))
                + ';status=Complete;world={' + self.world.wire() + '};foreignWorld={'
                + self.foreign_world.wire() + '};owners={' + owners + '};scheduleRuns=' + listing(self.logs))


def seed_model(world, count):
    """Current reused Dense seed route; bootstrap choice still awaits host source."""
    tx = Transaction(world)
    for index in range(count):
        tx.spawn([[index, index + 1, index + 2, index + 3],
                  [1, 2, 3, 4] if index % 3 == 0 else None, 8 if index % 3 == 1 else None])
    tx.finish()
    world.barrier()


def selftest():
    world, foreign = World(1), World(2)
    seed_model(world, 64)
    tx = Transaction(foreign)
    foreign_handle = tx.spawn([[999, 1000, 1001, 1002], None, None])
    tx.finish()
    foreign.barrier()
    assert foreign.component(foreign_handle)[0] == 'Found'
    before_foreign = copy.deepcopy(foreign)
    program = Program(world, foreign, foreign_handle, 64)
    for _ in range(64):
        program.step()
    assert program.counts == [64, 64, 64, 192]
    assert len(program.logs) == 384 and len(program.calls) == 384 and len(program.boundaries) == 192
    assert sum(len(value.stale) for value in program.boundaries) == 6112
    assert sum(len(value.rows) for value in program.boundaries) == 64 * (64 + 65 + 64)
    assert world.clock == 235 and world.ledger == [0, 101, 102, 103]
    assert world.allocator.high == 65 and world.allocator.next == 66
    assert len(world.allocator.slots) == 128 and len(world.main_handles()) == 64
    assert len(world.allocator.free) == 1
    assert [len(column.values) for column in world.columns] == [128, 64, 64]
    assert world.pending == [] and before_foreign == foreign
    assert all(boundary.before == boundary.after for boundary in program.boundaries)
    assert [boundary.lookups for boundary in program.boundaries[:3]] == [[0, 2, 0, 0], [2, 2, 0, 0], [2, 0, 0, 0]]
    assert all(value.key.generation > 0 for value in program.frame.reservations[1:])
    assert all(program.lookup(value) == 0 for value in program.frame.stale)
    return True


if __name__ == '__main__':
    assert selftest()
    print('PASS typed-unit model; bootstrap/header and final expected bytes remain unfrozen')
