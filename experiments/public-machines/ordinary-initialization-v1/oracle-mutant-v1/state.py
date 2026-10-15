"""Finite source-only interpreter for the ordinary initialization fixture.

Operational bases: ordinary-machine-initialization.{inserted,replaced},
machine-stream.{open,finish}, ordinary-machine-initialization-marker.{apply,
opened,transition_returned}, and machine-handler-phases.{transition,enter}.
No backend result is an input. The final consumer action list is bound separately.
"""
from copy import deepcopy
from dataclasses import dataclass, field


def listing(values):
    return '[' + ', '.join(map(str, values)) + ']'


def boolean(value):
    return str(value).lower()


@dataclass
class State:
    clock: int = 0
    current: str | None = None
    pending: str | None = None
    previous: str | None = None
    changed: bool = False
    revision: int = 0
    defaults: int = 0
    failure: bool = False
    events: list = field(default_factory=list)
    batches: list = field(default_factory=list)
    positions: list = field(default_factory=list)
    dropped: int = 0
    frame_start: int = 0
    watch_cursors: list = field(default_factory=lambda: [0, 0])
    watch_revisions: list = field(default_factory=lambda: [0, 0])

    def insert(self, value):
        occupied = self.current is not None
        self.clock += 1
        if not occupied:
            self.pending = self.previous = None
        self.current, self.changed = value, True
        self.revision += 1
        if occupied:
            self.batches.clear()
        self.batches.append((self.clock, 'initial:' + value))

    def initialize(self):
        if self.current is None:
            self.defaults += 1
            self.insert('A')

    def queue(self, value):
        if self.current is not None:
            self.pending = value

    def remove(self):
        if self.current is not None:
            self.revision += 1
        self.current = self.pending = self.previous = None
        self.changed = False

    def open_reader(self, reader_id):
        position = next((p for p in self.positions if p[0] == reader_id), None)
        if position is None:
            position = [reader_id, 0, self.clock]
            self.positions.insert(0, position)
        return [value for tick, value in self.batches if tick > position[1]], max(position[1], position[2]) < self.dropped

    def complete_reader(self, reader_id, success=True):
        if success:
            for position in self.positions:
                if position[0] == reader_id:
                    position[1] = self.clock

    def marker(self, engine_id=4):
        # The fixture's marker_frame advances World.clock, never St.frame.
        self.clock += 1
        if self.current is None:
            return 'MachineUnavailable'
        normal = self.pending is not None
        target = self.pending if normal else None
        old = self.current
        self.changed = False
        if normal:
            self.pending, self.previous = None, old
            # Existing #49 commits transition before Enter, even on Enter failure.
            self.current, self.changed = target, True
            self.revision += int(old != target)
            self.clock += 1
            self.batches.append((self.clock, old + '->' + target))
        values, _ = self.open_reader(engine_id)
        self.complete_reader(engine_id)
        if not normal:
            target = values[-1][8:] if values and values[-1].startswith('initial:') else None
        if target in ('A', 'B', 'C'):
            ordinal = {'A': 1, 'B': 2, 'C': 3}[target]
            if not normal and self.failure:
                return 'HandlerFailed:enter:injected-enter-failure'
            prefix = 'enter#' if normal else 'initial-enter#'
            self.events.append(prefix + str(ordinal) + ':' + (old + '->' if normal else '') + target)
        return 'Completed'

    def conditions(self, enabled=True):
        if not enabled:
            return ('run_if(false)', 'skipped-or-failed')
        result = []
        for index in range(2):
            result.append(boolean(self.current is not None and self.watch_revisions[index] < self.revision))
            self.watch_revisions[index] = self.revision
            self.watch_cursors[index] = self.clock
        return tuple(result)

    def snapshot(self):
        return deepcopy(self.__dict__)


def selftest():
    state = State()
    state.initialize()
    state.queue('B')
    state.insert('C')
    assert state.pending == 'B' and state.revision == 2
    state.marker()
    assert state.events == ['enter#2:C->B']
    assert state.batches == [(2, 'initial:C'), (4, 'C->B')]
    assert state.previous == 'C' and state.revision == 3
    state.insert('C')
    state.failure = True
    assert state.marker().startswith('HandlerFailed:enter:')
    committed = deepcopy(state.positions)
    state.failure = False
    events = state.events[:]
    state.marker()
    assert state.positions[0][1] > committed[0][1]
    assert state.events == events, 'committed internal selection must not replay'
    state.open_reader(7)
    before = deepcopy(state.positions)
    state.complete_reader(7, False)
    assert state.positions == before, 'user failed reader preserves cursor'
    state.complete_reader(7)
    state.insert('C')
    assert state.open_reader(7)[0] == ['initial:C'], 'clear preserves cursor and fresh publication is visible'
    revision = state.revision
    state.initialize()
    assert state.revision == revision and state.defaults == 1
    state.remove()
    assert state.conditions() == ('false', 'false')
    retained = state.batches[:]
    state.initialize()
    assert state.batches[:-1] == retained and state.defaults == 2


if __name__ == '__main__':
    selftest()
    print('state invariants PASS; final source binding not supplied')
