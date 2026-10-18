"""Independent canonical operation model; consumer registrations/wire not yet bound.

Sources: entity-allocator.{reserve,checked,release,abandon,visible},
commands.{tx_spawn,tx_finish,tx_despawn_with}, structural.tx_remove,
component.replace, column.{mark,clear}, World.barrier at Gitcc951.
No subject output, fixed wire oracle or runtime qualification is asserted here.
"""
from dataclasses import dataclass, field
import copy

U32_MAX = (1 << 32) - 1


@dataclass(frozen=True)
class Key:
    index: int
    generation: int


@dataclass(frozen=True)
class Handle:
    namespace: int
    key: Key


@dataclass
class Slot:
    generation: int = 0
    phase: str = 'Consumed'


@dataclass
class Allocator:
    next: int = 1
    high: int = 0
    slots: list = field(default_factory=lambda: [Slot()])
    free: list = field(default_factory=list)
    order: list = field(default_factory=list)

    def checked(self, key, mode='metadata'):
        if not (0 < key.index < self.next and key.index < len(self.slots)):
            return False
        slot = self.slots[key.index]
        if slot.generation != key.generation:
            return False
        return (slot.phase != 'Free' if mode == 'metadata' else
                slot.phase == ('Live' if mode == 'live' else 'Pending'))

    def reserve(self):
        if self.free:
            index = self.free.pop(0)
            key = Key(index, self.slots[index].generation)
        else:
            if self.next >= 131073:
                return None
            index = self.next
            if index >= len(self.slots):
                self.slots += [Slot() for _ in self.slots]
            self.next += 1
            self.high = index
            key = Key(index, 0)
        self.slots[index] = Slot(key.generation, 'Consumed')
        self.order.append(key)
        return key

    def set_phase(self, key, phase):
        if not self.checked(key):
            return False
        self.slots[key.index] = Slot(key.generation, phase)
        return True

    def abandon(self, key):
        if self.checked(key, 'pending'):
            self.slots[key.index] = Slot(key.generation, 'Consumed')
            self.order = [current for current in self.order if current != key]

    def release(self, key):
        if self.checked(key):
            self.slots[key.index] = Slot((key.generation + 1) & U32_MAX, 'Free')
            self.free.insert(0, key.index)
            self.order = [current for current in self.order if current != key]

    def visible(self):
        return [key for key in self.order if self.checked(key, 'live')]


@dataclass
class Column:
    values: list = field(default_factory=lambda: [None])
    stamps: dict = field(default_factory=dict)
    order: list = field(default_factory=list)

    def replace(self, index, incoming, tick):
        while len(self.values) < index:
            self.values += [None] * len(self.values)
        previous = self.values[index - 1]
        self.values[index - 1] = copy.deepcopy(incoming)
        old_stamp = self.stamps.get(index, (0, 0))
        self.stamps[index] = ((tick if previous is None else old_stamp[0]), tick) if incoming is not None else (0, 0)
        self.order = [index] + [old for old in self.order if old != index]
        return previous

    def clear(self, index):
        # Raw Col.clear does not ensure or grow a shorter unrelated family.
        if not 0 < index <= len(self.values):
            return None
        previous = self.values[index - 1]
        self.values[index - 1] = None
        self.stamps.pop(index, None)
        self.order = [old for old in self.order if old != index]
        return previous


@dataclass
class World:
    namespace: int
    allocator: Allocator = field(default_factory=Allocator)
    columns: list = field(default_factory=lambda: [Column(), Column(), Column()])
    pending: list = field(default_factory=list)
    clock: int = 0
    ledger: list = field(default_factory=lambda: [0, 101, 102, 103])

    def valid(self, handle, mode='live'):
        return handle.namespace == self.namespace and self.allocator.checked(handle.key, mode)

    def command_valid(self, handle):
        return self.valid(handle) or self.valid(handle, 'pending')

    def component(self, handle, index=0):
        if not self.valid(handle):
            return 'MissingEntity', None
        values = self.columns[index].values
        value = values[handle.key.index - 1] if handle.key.index <= len(values) else None
        return ('ComponentAbsent', None) if value is None else ('Found', copy.deepcopy(value))

    def replace(self, handle, index, incoming):
        if not self.valid(handle):
            return False, incoming
        if handle.key.index > 131072:
            return False, incoming
        if self.clock >= U32_MAX:
            return False, incoming
        tick = self.clock + 1
        self.clock = tick
        return True, self.columns[index].replace(handle.key.index, incoming, tick)

    def main_handles(self):
        return [Handle(self.namespace, key) for key in self.allocator.visible()
                if self.component(Handle(self.namespace, key))[0] == 'Found']

    def enqueue(self, command):
        self.pending.insert(0, command)

    def barrier(self):
        commands, self.pending = self.pending, []
        for kind, handle, payload in reversed(commands):
            if kind == 'spawn':
                if self.valid(handle, 'metadata'):
                    self.allocator.set_phase(handle.key, 'Live')
                    for index, value in enumerate(payload):
                        if value is not None:
                            self.replace(handle, index, value)
            elif kind == 'remove':
                self.replace(handle, payload, None)
            elif kind == 'despawn':
                if self.valid(handle, 'metadata'):
                    self.allocator.set_phase(handle.key, 'DeadRetained')
                    for column in self.columns:
                        column.clear(handle.key.index)
                    self.allocator.release(handle.key)
            else:
                raise AssertionError(kind)


@dataclass
class Transaction:
    world: World
    commands: list = field(default_factory=list)
    reserved: list = field(default_factory=list)

    def spawn(self, payload):
        key = self.world.allocator.reserve()
        if key is None:
            return None
        handle = Handle(self.world.namespace, key)
        self.commands.insert(0, ('spawn', handle, copy.deepcopy(payload)))
        self.world.allocator.set_phase(key, 'Pending')
        self.reserved.insert(0, handle)
        return handle

    def remove(self, handle, index=0):
        if not self.world.valid(handle):
            return False
        self.commands.insert(0, ('remove', handle, index))
        return True

    def despawn(self, handle):
        if not self.world.command_valid(handle):
            return False
        self.commands.insert(0, ('despawn', handle, None))
        return True

    def finish(self, success=True):
        if success:
            # T.finish reverses Tx commands to FIFO; enqueue prepends each.
            for command in reversed(self.commands):
                self.world.enqueue(command)
        else:
            for handle in self.reserved:
                if handle.namespace == self.world.namespace:
                    self.world.allocator.abandon(handle.key)
        self.commands = []
        self.reserved = []
        return self.world


def selftest():
    world = World(1)
    tx = Transaction(world)
    first = tx.spawn([[0, 1, 2, 3], [1, 2, 3, 4], 8])
    second = tx.spawn([[4, 5, 6, 7], None, None])
    tx.finish()
    assert world.component(first)[0] == 'MissingEntity' and len(world.pending) == 2
    world.barrier()
    assert world.main_handles() == [first, second] and world.clock == 4
    tx = Transaction(world)
    assert tx.remove(first) and tx.despawn(first)
    tx.finish()
    assert world.component(first)[0] == 'Found'
    world.barrier()
    assert world.clock == 5 and world.allocator.free == [1]
    assert world.component(first)[0] == 'MissingEntity'
    assert all(1 not in column.stamps for column in world.columns)
    tx = Transaction(world)
    reused = tx.spawn([[8, 9, 10, 11], None, None])
    assert reused == Handle(1, Key(1, 1))
    tx.finish()
    world.barrier()
    assert world.main_handles() == [second, reused]
    assert not world.valid(first) and not world.valid(Handle(2, reused.key))
    before = copy.deepcopy(world)
    tx = Transaction(world)
    assert not tx.remove(first) and not tx.despawn(Handle(2, reused.key))
    tx.finish()
    assert before == world
    tx = Transaction(world)
    failed = tx.spawn([[12, 13, 14, 15], None, None])
    tx.finish(False)
    assert world.allocator.slots[failed.key.index].phase == 'Consumed'
    assert failed.key not in world.allocator.order and failed.key.index not in world.allocator.free
    assert world.allocator.next == 4 and world.allocator.high == 3
    assert not world.command_valid(failed)
    assert world.allocator.set_phase(reused.key, 'DeadRetained')
    next_key = world.allocator.reserve()
    assert next_key.index == 4 and world.allocator.slots[reused.key.index].phase == 'DeadRetained'
    assert len(world.allocator.slots) == 8
    boundary = World(3)
    key = boundary.allocator.reserve()
    boundary.allocator.set_phase(key, 'Live')
    handle = Handle(3, key)
    boundary.clock = U32_MAX - 1
    assert boundary.replace(handle, 0, [77, 78]) == (True, None)
    assert boundary.clock == U32_MAX
    assert boundary.columns[0].stamps[key.index] == (U32_MAX, U32_MAX)
    before = copy.deepcopy(boundary)
    assert boundary.replace(handle, 0, [88, 89]) == (False, [88, 89])
    assert boundary == before
    return True


if __name__ == '__main__':
    assert selftest()
    print('PASS operation-model selftests; consumer wire/Local registration not frozen')
