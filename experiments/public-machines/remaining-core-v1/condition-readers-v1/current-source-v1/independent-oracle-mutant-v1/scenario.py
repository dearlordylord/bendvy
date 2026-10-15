"""Operation-level groundwork for the selected three-run ordinary consumer.

No final source binding, registry IDs, serializer or stdout is assumed here.
The final interpreter must derive these from the frozen entry/helper sources.
"""
from dataclasses import dataclass, field
from conditions import Changed, Result, and_then, negate, or_else
from stream import Stream


@dataclass
class Machine:
    value: str | None = None
    revision: int = 0
    defaults: int = 0
    pending: str | None = None
    previous: str | None = None
    changed: bool = False
    stream: Stream = field(default_factory=Stream)

    def insert(self, value, tick):
        occupied = self.value is not None
        if occupied:
            self.stream.batches.clear()
        else:
            self.pending = self.previous = None
        self.value = value
        self.changed = True
        self.revision += 1
        self.stream.batches.append((tick, 'initial:' + value))


@dataclass
class Scenario:
    flow: Machine = field(default_factory=Machine)
    level: Machine = field(default_factory=Machine)
    fast_changed_level: Changed = field(default_factory=Changed)
    slow_changed_flow: Changed = field(default_factory=Changed)
    clock: int = 0

    def insert(self, machine, value):
        self.clock += 1
        getattr(self, machine).insert(value, self.clock)

    def initialize(self, machine, value):
        target = getattr(self, machine)
        if target.value is None:
            target.defaults += 1
            self.insert(machine, value)

    def fast_guard(self):
        return and_then(lambda: Result('Value', self.flow.value == 'Play'),
                        lambda: self.fast_changed_level.run(self.level.revision, self.level.value is not None, self.clock))

    def slow_guard(self):
        return or_else(lambda: negate(Result('Value', self.level.value == 'High')),
                       lambda: self.slow_changed_flow.run(self.flow.revision, self.flow.value is not None, self.clock))
