"""Finite notice contract model using an audit log and completed-update ages.

The audit log retains model history; visible retention is derived by age instead
of copying the implementation's previous/current buffers. No Bend source or
backend observations are read.
"""
from dataclasses import dataclass, field


def shown(values):
    return "[" + ", ".join(values) + "]"


def tick_text(value):
    return f"{value // (1 << 32)}:{value % (1 << 32)}"


@dataclass(frozen=True)
class Identity:
    namespace: int
    index: int
    generation: int

    def text(self):
        return f"{self.namespace}:{self.index}:{self.generation}"


@dataclass(frozen=True)
class Entry:
    sequence: int
    identity: Identity
    tick: int
    update: int

    def text(self):
        return f"{self.sequence}:{self.identity.text()}@{tick_text(self.tick)}"


@dataclass
class Reader:
    namespace: int
    identifier: int
    selector: str
    cursor: int

    def text(self):
        return f"{self.namespace}:{self.identifier}:{self.cursor}"


@dataclass
class Journal:
    namespace: int
    completed: int = 0
    next_reader: int = 1
    channels: dict = field(default_factory=dict)
    active: dict = field(default_factory=dict)

    def floor(self, selector):
        expired = [entry.sequence for entry in self.channels.get(selector, [])
                   if entry.update < self.completed - 1]
        return max(expired, default=0)

    def register(self, selector, future=False):
        if self.next_reader >= (1 << 32) - 1:
            return None, "reader-limit"
        entries = self.channels.setdefault(selector, [])
        identifier = self.next_reader
        self.next_reader += 1
        self.active[identifier] = selector
        cursor = len(entries) if future else self.floor(selector)
        return Reader(self.namespace, identifier, selector, cursor), "registered"

    def append(self, selector, identity, tick):
        entries = self.channels.setdefault(selector, [])
        entries.append(Entry(len(entries) + 1, identity, tick, self.completed))

    def finish(self, outcome="finished"):
        if outcome == "finished":
            self.completed += 1

    def refusal(self, reader):
        if reader.namespace != self.namespace:
            return "foreign-world"
        if self.active.get(reader.identifier) != reader.selector:
            return "inactive"
        return None

    def retire(self, reader):
        reason = self.refusal(reader)
        if reason:
            return reader, reason
        del self.active[reader.identifier]
        return None, "retired"

    def read(self, reader):
        reason = self.refusal(reader)
        if reason:
            return "refused/" + reason
        floor = self.floor(reader.selector)
        missed = max(floor - reader.cursor, 0)
        reader.cursor = max(reader.cursor, floor)
        retained = [entry for entry in self.channels.get(reader.selector, [])
                    if entry.update >= self.completed - 1
                    and entry.sequence > reader.cursor]
        if not retained:
            return f"empty/{missed}"
        entry = retained[0]
        reader.cursor = entry.sequence
        return f"item/{entry.text()}/{missed}"

    def text(self):
        channels = []
        for selector, entries in self.channels.items():
            previous = [entry.text() for entry in entries
                        if entry.update == self.completed - 1]
            current = [entry.text() for entry in entries
                       if entry.update == self.completed]
            channels.append("{" + selector + f",next={len(entries) + 1},"
                            f"floor={self.floor(selector)},"
                            f"previous={shown(previous)},current={shown(current)}" + "}")
        active = [f"{identifier}:{selector}"
                  for identifier, selector in self.active.items()]
        return (f"namespace={self.namespace};next-reader={self.next_reader};"
                f"active={shown(active)};channels={shown(channels)}")
