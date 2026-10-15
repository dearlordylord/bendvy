"""Source-only complete queue/stream affected-control oracle, no backend input."""
from collections import deque
from copy import deepcopy
from dataclasses import dataclass, field
import gzip
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent


def listing(values):
    return '[' + ', '.join(map(str, values)) + ']'


def boolean(value):
    return str(value).lower()


@dataclass
class Queue:
    front: deque = field(default_factory=deque)
    back: deque = field(default_factory=deque)
    size: int = 0
    dropped: int = 0
    count: int = 0

    def load(self, batches):
        for tick, values in batches:
            # St.trimmed/loaded use publish_nonempty directly, including empties.
            self.back.appendleft((tick, len(values), tuple(values)))
            self.size += len(values)
            self.count += 1

    def normalize(self):
        if not self.front:
            self.front = deque(reversed(self.back))
            self.back.clear()

    def prefix(self, predicate):
        fuel = self.count + 1
        while fuel:
            fuel -= 1
            self.normalize()
            if not self.front or not predicate(self.front[0][0]):
                return
            tick, count, _ = self.front.popleft()
            self.size -= count
            self.dropped = max(self.dropped, tick)
            self.count -= 1
        raise AssertionError('batch-count fuel exhausted')

    def trim(self, boundary, capacity):
        self.prefix(lambda tick: tick <= boundary)
        self.prefix(lambda tick: self.size > capacity)

    def batches(self):
        return [(tick, values) for tick, _, values in list(self.front) + list(reversed(self.back))]

    def read(self, cursor):
        return [value for tick, values in self.batches() if cursor < tick for value in values]

    def validate(self):
        all_batches = list(self.front) + list(self.back)
        assert self.count == len(all_batches)
        assert self.size == sum(len(values) for _, _, values in all_batches)
        assert all(count == len(values) for _, count, values in all_batches)


def reference(batches, boundary, capacity, dropped):
    # Independent Ev list implementation, without Queue/cache/fuel machinery.
    remaining = list(batches)
    while remaining and remaining[0][0] <= boundary:
        tick, _ = remaining.pop(0)
        dropped = max(dropped, tick)
    while remaining and sum(len(values) for _, values in remaining) > capacity:
        tick, _ = remaining.pop(0)
        dropped = max(dropped, tick)
    return remaining, dropped


def batch_text(batch):
    tick, values = batch
    return str(tick) + ':' + listing(values)


def queue_text(queue):
    def queued(batch):
        tick, count, values = batch
        return f'{tick}:{count}:' + listing(values)
    return ('front=' + listing(map(queued, queue.front)) + ';back=' + listing(map(queued, queue.back))
            + f';size={queue.size};batchCount={queue.count};dropped={queue.dropped};values=' + listing(queue.read(0)))


def trim_case(label, batches, boundary, capacity, dropped):
    retained, lost = reference(batches, boundary, capacity, dropped)
    queue = Queue(dropped=dropped)
    queue.load(batches)
    queue.trim(boundary, capacity)
    queue.validate()
    assert queue.batches() == [(tick, tuple(values)) for tick, values in retained]
    assert queue.dropped == lost
    assert queue.size == sum(len(values) for _, values in retained)
    assert queue.count == len(retained)
    return (label + '|input=' + listing(map(batch_text, batches))
            + f';boundary={boundary};capacity={capacity};dropped={dropped}\nreference|batches='
            + listing(map(batch_text, retained))
            + f';size={sum(len(values) for _, values in retained)};batchCount={len(retained)};dropped={lost}'
            + '\nactual|' + queue_text(queue)), queue


@dataclass
class Stream:
    queue: Queue
    positions: list
    start: int

    def observe(self, identity, tick):
        position = next((position for position in self.positions if position[0] == identity), (identity, 0, tick))
        _, cursor, registered = position
        return self.queue.read(cursor), max(cursor, registered) < self.queue.dropped

    def initial(self, tick, value):
        new = Queue(dropped=self.queue.dropped)
        new.load([(tick, ['initial>' + str(value)])])
        self.queue = new

    def skip(self, identity, tick):
        pass

    def complete(self, identity, tick, success):
        if success:
            self.positions = [(actual, tick if actual == identity else cursor, registered)
                              for actual, cursor, registered in self.positions]

    def dispose(self, identity):
        self.positions = [position for position in self.positions if position[0] != identity]

    def show(self, label):
        self.queue.validate()
        def reading(identity):
            values, lagged = self.observe(identity, 35)
            return listing(values) + ':lagged=' + boolean(lagged)
        return (label + '|batches=' + listing(map(batch_text, self.queue.batches()))
                + ';positions=' + listing(':'.join(map(str, position)) for position in self.positions)
                + f';dropped={self.queue.dropped};frameStart={self.start};size={self.queue.size}'
                + f';batchCount={self.queue.count};queueDropped={self.queue.dropped}'
                + ';read7=' + reading(7) + ';read9=' + reading(9))


def derive():
    rows = []
    case, nonmonotonic = trim_case('nonmonotonic', [(10, [1]), (2, [2]), (9, [3])], 3, 2, 0)
    rows.append(case)
    assert nonmonotonic.batches() == [(2, (2,)), (9, (3,))]
    assert nonmonotonic.dropped == 10
    case, empty = trim_case('empty-prefix', [(2, []), (1, []), (3, []), (7, [70])], 3, 5, 0)
    rows.append(case)
    assert empty.count == empty.size == 1 and empty.dropped == 3
    case, multi = trim_case('whole-multievent', [(4, [1, 2]), (9, [3, 4, 5]), (7, [])], 0, 3, 1)
    rows.append(case)
    assert multi.batches() == [(9, (3, 4, 5)), (7, ())] and multi.count == 2 and multi.size == 3
    queue = Queue(dropped=5)
    queue.load([(20, ['0>1']), (21, ['initial>2'])])
    value = Stream(queue, [(7, 3, 2), (9, 5, 4)], 12)
    rows.append(value.show('seed'))
    assert value.observe(7, 35) == (['0>1', 'initial>2'], True)
    assert value.observe(9, 35) == (['0>1', 'initial>2'], False)
    value.initial(30, 9)
    rows.append(value.show('initial'))
    before = deepcopy(value)
    value.skip(7, 31)
    rows.append(value.show('skip'))
    assert value == before
    value.complete(7, 32, False)
    rows.append(value.show('complete-false'))
    assert value == before
    value.complete(7, 32, True)
    rows.append(value.show('complete-true'))
    assert value.observe(7, 35) == ([], False)
    assert value.positions == [(7, 32, 2), (9, 5, 4)]
    value.dispose(7)
    rows.append(value.show('disposed'))
    assert value.positions == [(9, 5, 4)]
    assert value.observe(7, 35) == (['initial>9'], False)
    assert value.queue.batches() == [(30, ('initial>9',))]
    assert value.queue.size == value.queue.count == 1 and value.queue.dropped == 5 and value.start == 12
    wire = ('\n'.join(rows) + '\n').encode()
    assert len(wire.splitlines()) == 15 and not wire.endswith(b'\n\n')
    return wire


def selftest():
    freeze = json.loads((HERE / 'source-freeze.json').read_text())
    for path, expected in json.loads((HERE / 'source-pins.json').read_text()).items():
        assert hashlib.sha256(Path(path).read_bytes()).hexdigest() == expected, path
    source = (Path(freeze['snapshot']) / freeze['entrypoint']).read_text()
    assert 'def main() -> IO(Unit):IO.print(run())' in source
    assert 'Q.trim(~U32,loaded(batches,Q.Queue{[],[],0n,dropped,0n}),boundary,capacity)' in source
    assert 'Ev.trim_capacity(~U32,Ev.past_window(~U32,batches,boundary,dropped),capacity)' in source
    assert 'St.initial(~U32,value,30n,9)' in source and 'St.skip(~U32,value,7,31n)' in source
    assert 'St.complete(~U32,value,7,32n,False{})' in source and 'St.complete(~U32,value,7,32n,True{})' in source
    assert 'St.dispose(~U32,value,7)' in source
    return derive()


if __name__ == '__main__':
    wire = selftest()
    (HERE / 'expected.stdout').write_bytes(wire)
    (HERE / 'expected.stdout.gz').write_bytes(gzip.compress(wire, mtime=0))
    digest = hashlib.sha256(wire).hexdigest()
    (HERE / 'expected.sha256').write_text(digest + '  expected.stdout\n')
    print('PASS', len(wire), digest)
