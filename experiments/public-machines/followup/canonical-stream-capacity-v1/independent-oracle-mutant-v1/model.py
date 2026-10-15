"""Source-only full 65,537-publication no-capacity-eviction counter oracle.

No observed TS JSON, backend stdout, generated code or historical golden is an
input. Every complete payload is rendered from the actual finite operation loop.
"""
import ast
from collections import deque
from dataclasses import dataclass, field
import gzip
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
COUNT = 65537
CAPACITY = 65536
PUBLISH_ACCESS = ['machine.Flow.read', 'machine.Flow.next', 'component.cells.write', 'commands.spawn']
READ_ACCESS = ['transition.Flow.read']


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
    batch_count: int = 0

    def publish(self, tick, values, compatibility=False):
        values = tuple(values)
        if values or compatibility:
            self.back.appendleft((tick, values))
            self.size += len(values)
            self.batch_count += 1

    def normalize(self):
        if not self.front:
            self.front = deque(reversed(self.back))
            self.back.clear()

    def prefix(self, remove):
        # Source fuel is batchCount+1, including raw empty compatibility batches.
        fuel = self.batch_count + 1
        while fuel:
            fuel -= 1
            self.normalize()
            if not self.front or not remove(self.front[0][0]):
                return
            tick, values = self.front.popleft()
            self.size -= len(values)
            self.batch_count -= 1
            self.dropped = max(self.dropped, tick)
        raise AssertionError('source batch-count fuel exhausted')

    def trim(self, boundary, capacity=CAPACITY):
        self.prefix(lambda tick: tick <= boundary)
        self.prefix(lambda tick: False)

    def snapshot(self):
        return list(self.front) + list(reversed(self.back))

    def read(self, cursor):
        return tuple(value for tick, values in self.snapshot() if cursor < tick for value in values)

    def invariant(self):
        batches = self.snapshot()
        assert len(batches) == self.batch_count
        assert sum(len(values) for _, values in batches) == self.size


@dataclass
class Runtime:
    queue: Queue = field(default_factory=Queue)
    frame_start: int = 0
    frames: int = 0
    tick: int = 0
    current: int = 0
    previous: int | None = None
    changed: bool = False
    position: tuple | None = None
    deliveries: list = field(default_factory=list)
    status: str = 'ok'

    def frame(self):
        boundary = min(self.frame_start, self.position[1]) if self.position else self.frame_start
        self.queue.trim(boundary)
        self.frame_start = self.tick
        self.frames += 1
        self.changed = False

    def seed(self):
        self.frame()
        self.tick += 2  # publisher pulse, then seed's post-barrier pulse
        # Real deferred spawn reserves/activates id1 and stores [10,99] at stamp1.

    def publish(self):
        self.frame()
        self.tick += 3  # publisher pulse, marker pulse, applied publication
        self.previous = self.current
        self.current += 1
        self.changed = True
        self.queue.publish(self.tick, [(self.previous, self.current)])
        self.status = 'ok'

    def read(self, fails):
        self.frame()
        cursor, registered = (self.position[1], self.position[2]) if self.position else (0, self.tick)
        values = self.queue.read(cursor)
        lagged = max(cursor, registered) < self.queue.dropped
        if self.position is None:
            self.position = (2, 0, self.tick)
        self.tick += 1  # pulse before Tx.begin; failure does not undo this pulse
        if not fails:
            self.position = (2, self.tick, registered)
        self.deliveries.append((values, lagged))
        self.status = 'failed:reader-failed' if fails else 'ok'


def transition(value):
    return f'{value[0]}>{value[1]}'


def stream(runtime):
    batches = listing(f'{tick}:' + listing(transition(value) for value in values)
                      for tick, values in runtime.queue.snapshot())
    positions = listing([':'.join(map(str, runtime.position))] if runtime.position else [])
    return f'batches={batches},positions={positions},dropped={runtime.queue.dropped},frameStart={runtime.frame_start}'


def row(namespace, label, runtime):
    previous = 'none' if runtime.previous is None else str(runtime.previous)
    fields = [f'ns={namespace}', 'next=2', 'high=1', 'capacity=2', 'depth=1', 'live=[false, true]',
              'cells=[[10, 99]]:stamps=[1:1:1]', 'owned=[30, 130]',
              f'flow={runtime.current}(pending=none,previous={previous},changed={boolean(runtime.changed)})',
              'flowStream=' + stream(runtime), f'frame={runtime.frames}', f'tick={runtime.tick}',
              'error=none', 'queue=0',
              'registrations=' + listing(['2:reader:' + listing(READ_ACCESS), '1:publisher:' + listing(PUBLISH_ACCESS)]),
              'nextSystem=3', 'componentClock=1', 'busEvents=0',
              f'publisherOwner={namespace}:1:publisher:' + listing(PUBLISH_ACCESS) + ':0',
              f'readerOwner={namespace}:2:reader:' + listing(READ_ACCESS) + ':0', f'readerCap={namespace}:2',
              'deliveries=' + listing('values=' + listing(map(transition, values)) + ',lagged=' + boolean(lagged)
                                      for values, lagged in runtime.deliveries)]
    return label + '|' + runtime.status + '|' + ';'.join(fields)


def derive(namespace):
    runtime, rows, timeline = Runtime(), [], []

    def checkpoint(label):
        runtime.queue.invariant()
        rows.append(row(namespace, label, runtime))
        timeline.append(dict(label=label, tick=runtime.tick, frame=runtime.frames, current=runtime.current,
                             previous=runtime.previous, changed=runtime.changed, queueSize=runtime.queue.size,
                             batchCount=runtime.queue.batch_count, dropped=runtime.queue.dropped,
                             frameStart=runtime.frame_start, position=runtime.position,
                             deliveryLengths=[len(values) for values, _ in runtime.deliveries],
                             deliveryLagged=[lagged for _, lagged in runtime.deliveries]))

    runtime.seed()
    checkpoint('initial')
    runtime.read(True)
    checkpoint('activated-failed')
    for _ in range(COUNT):
        runtime.publish()
    assert runtime.queue.read(0) == tuple((index, index + 1) for index in range(COUNT))
    checkpoint('65537-published')
    runtime.frame()
    assert runtime.queue.read(0) == tuple((index, index + 1) for index in range(COUNT))
    checkpoint('capacity-frame')
    runtime.read(True)
    checkpoint('overflow-failed-reader')
    assert runtime.position == (2, 0, 2)
    runtime.read(False)
    checkpoint('overflow-successful-retry')
    assert runtime.deliveries[1] == runtime.deliveries[2]
    assert runtime.deliveries[1] == (tuple((index, index + 1) for index in range(COUNT)), False)
    runtime.read(False)
    checkpoint('empty-repeat')
    assert runtime.deliveries[-1] == ((), False)
    assert [item['tick'] for item in timeline] == [2, 3, 196614, 196614, 196615, 196616, 196617]
    assert [item['frame'] for item in timeline] == [1, 2, 65539, 65540, 65541, 65542, 65543]
    assert [item['queueSize'] for item in timeline] == [0, 0, 65537, 65537, 65537, 65537, 0]
    assert [item['dropped'] for item in timeline] == [0, 0, 0, 0, 0, 0, 196614]
    assert [item['frameStart'] for item in timeline] == [0, 2, 196611, 196614, 196614, 196615, 196616]
    assert runtime.position == (2, 196617, 2)
    return '\n'.join(rows), timeline


def queue_selftest():
    queue = Queue()
    for tick in [10, 1, 11]:
        queue.publish(tick, [(tick, tick + 1)])
    queue.trim(2, 2)
    assert [tick for tick, _ in queue.snapshot()] == [10, 1, 11]
    assert queue.size == 3 and queue.dropped == 0, 'capacity predicate is disabled'
    queue.trim(10, 2)
    assert [tick for tick, _ in queue.snapshot()] == [11]
    assert queue.dropped == 10, 'expiry prefix still operates'
    queue.invariant()


def selftest():
    queue_selftest()
    for path, expected in json.loads((HERE / 'source-pins.json').read_text()).items():
        assert hashlib.sha256(Path(path).read_bytes()).hexdigest() == expected, path
    freeze = json.loads((HERE / 'source-freeze.json').read_text())
    normal = json.loads((HERE.parent / 'independent-oracle-v1/source-freeze.json').read_text())
    mutation = freeze['singleMutation']
    assert len(freeze['sourceInventory']) == len(freeze['importClosure']) == 30
    for relative, digest in freeze['sourceInventory'].items():
        old = (Path(normal['snapshot']) / relative).read_bytes()
        current = (Path(freeze['snapshot']) / relative).read_bytes()
        if relative == mutation['path']:
            assert old.count(mutation['before'].encode()) == 1
            assert current == old.replace(mutation['before'].encode(), mutation['after'].encode())
            assert hashlib.sha256(old).hexdigest() == mutation['beforeSHA']
        else:
            assert current == old, relative
    snapshot = Path(freeze['snapshot'])
    entry = (snapshot / freeze['entrypoint']).read_text()
    assert 'def main() -> IO(Unit):' in entry and 'Overflow.parsed(Some{65537})' in entry
    prefix = snapshot / 'experiments/public-machines/followup/canonical-stream-capacity-v1'
    core = (prefix / 'overflow-core.bend').read_text()
    execute = core.split('def execute(', 1)[1].split('def finish(', 1)[0]
    assert execute.index('publish(~S,runtime,Seed{})') < execute.index('read(~S,runtime,True{})') < execute.index('loop(~S,count,runtime)')
    assert execute.count('checkpoint(') == 7
    assert 'case 1n+rest: loop(~S,rest,publish(~S,runtime,Publish{}))' in core
    strip_imports = lambda text: '\n'.join(line for line in text.splitlines() if not line.startswith('import '))
    for join in json.loads((HERE / 'source-join.json').read_text())['operationAndFormatJoins']:
        old = strip_imports(Path(join['old']).read_text())
        current = strip_imports((snapshot / join['current']).read_text())
        assert old == current
        assert hashlib.sha256(old.encode()).hexdigest() == join['nonImportSHA']
    legacy = snapshot / 'experiments/public-machines/followup/overflow-model.py'
    # The historical model isn't imported or executed: it would read observed
    # TS JSON. Only its literal field inventory is checked against source model.
    original_legacy = Path(freeze['producerRoot']) / legacy.relative_to(snapshot)
    syntax = ast.parse(original_legacy.read_text())
    names = next(ast.literal_eval(node.value) for node in syntax.body
                 if isinstance(node, ast.Assign) and any(isinstance(target, ast.Name) and target.id == 'FIELD_NAMES' for target in node.targets))
    sample = Runtime()
    sample.seed()
    assert [field.split('=', 1)[0] for field in row(1, 'initial', sample).split('|', 2)[2].split(';')] == names
    first, timeline = derive(1)
    second, second_timeline = derive(2)
    assert timeline == second_timeline
    wire = ('SCHEMA=A\n' + first + '\nSCHEMA=B\n' + second + '\n').encode()
    assert len(wire.splitlines()) == 16 and wire.endswith(b'\n') and not wire.endswith(b'\n\n')
    assert wire != gzip.decompress((HERE.parent / 'independent-oracle-v1/expected.stdout.gz').read_bytes())
    return wire, timeline


if __name__ == '__main__':
    wire, timeline = selftest()
    (HERE / 'expected.stdout').write_bytes(wire)
    (HERE / 'expected.stdout.gz').write_bytes(gzip.compress(wire, mtime=0))
    digest = hashlib.sha256(wire).hexdigest()
    (HERE / 'expected.sha256').write_text(digest + '  expected.stdout\n')
    (HERE / 'timeline.json').write_text(json.dumps(timeline, indent=2) + '\n')
    print('PASS', len(wire), digest)
