"""Independent finite canonical Readers model. No subject outputs are inputs."""
import argparse
import copy
import json
from dataclasses import dataclass, field
from physical import World as PhysicalWorld, Column as LegacyColumn, Transaction, Handle, Key, selftest as physical_selftest


def listing(values):
    return '[' + ', '.join(map(str, values)) + ']'


def tree(values):
    if len(values) == 1:
        return 'leaf:' + str(values[0])
    n = len(values) // 2
    return 'node(' + tree(values[:n]) + ',' + tree(values[n:]) + ')'


def handle(value):
    return f'{value.namespace}:{value.key.index}:{value.key.generation}'


def reservation(value):
    return 'Reserved(' + handle(value) + ')'


def maybe_handle(value):
    return 'None' if value is None else 'Some(' + handle(value) + ')'


def publication(value):
    kind, item = value
    return kind + '{' + (str(item) if kind == 'Ping' else handle(item)) + '}'


def event(value):
    return 'Original{' + publication(value) + '}'


class IndexedColumn(LegacyColumn):
    def __init__(self):
        super().__init__()
        self.added = [0]
        self.changed = [0]
        self.exceptional = []
    def metadata_set(self, index, stamp):
        assert 1 <= index <= 131072
        while len(self.added) < index:
            self.added += [0] * len(self.added)
            self.changed += [0] * len(self.changed)
        self.added[index-1], self.changed[index-1] = stamp
    def replace(self, index, incoming, tick):
        prior = super().replace(index, incoming, tick)
        self.metadata_set(index, self.stamps[index])
        return prior
    def clear(self, index):
        prior = super().clear(index)
        if 0 < index <= len(self.added):
            self.added[index-1] = self.changed[index-1] = 0
        return prior
    def metadata_wire(self):
        return ('added=' + tree(self.added) + ';changed=' + tree(self.changed)
                + f';capacity={len(self.added)};depth={len(self.added).bit_length()-1};exceptional=[]')


class World(PhysicalWorld):
    def __init__(self, namespace):
        super().__init__(namespace)
        self.columns = [IndexedColumn() for _ in range(3)]
        self.events = []
        self.registrations = []
        self.next_system = 1

    def register(self, name, access):
        identity = self.next_system
        self.next_system += 1
        self.registrations.insert(0, (identity, name, list(access)))
        return identity

    def barrier(self):
        commands, self.pending = self.pending, []
        for kind, actor, payload in reversed(commands):
            if kind == 'spawn':
                assert self.valid(actor, 'metadata')
                self.allocator.set_phase(actor.key, 'Live')
                for i, value in enumerate(payload):
                    if value is not None:
                        assert self.replace(actor, i, value)[0]
            elif kind == 'remove':
                assert self.valid(actor)
                accepted, old = self.replace(actor, 0, None)
                assert accepted and old is not None
                self.events.append(('Removed', actor))
            elif kind == 'despawn':
                assert self.valid(actor)
                self.allocator.set_phase(actor.key, 'DeadRetained')
                for column in self.columns:
                    column.clear(actor.key.index)
                self.events.append(('Despawned', actor))
                self.allocator.release(actor.key)
            else:
                raise AssertionError(kind)

    def rows(self, cursor=None, stamp=None):
        actors = self.main_handles()
        if stamp is not None:
            actors = [a for a in actors if self.columns[0].stamps[a.key.index][stamp] > cursor]
        return [(a, *[self.component(a, i)[1] for i in range(3)]) for a in actors]

    def wire(self):
        a = self.allocator
        av = (f'next={a.next};high={a.high};capacity={len(a.slots)};depth={len(a.slots).bit_length()-1};slots='
              + tree([f'{s.generation}:{s.phase}' for s in a.slots]) + ';free=' + listing(a.free)
              + ';order=' + listing(f'{k.index}:{k.generation}' for k in a.order))
        renders = [lambda x: 'Position{' + tree(x) + ';7}',
                   lambda x: 'Velocity{' + tree(x) + ';True}',
                   lambda x: 'Selected{' + str(x) + '}']
        columns = []
        for name, column, render in zip(['main', 'aux', 'flag'], self.columns, renders):
            vals = ['none' if v is None else 'some(' + render(v) + ')' for v in column.values]
            stamps = listing(f'{i}:{column.stamps[i][0]}:{column.stamps[i][1]}' for i in column.order)
            columns.append(name + '={Indexed{owned(values=' + tree(vals) + ';metadata={' + column.metadata_wire() + '})}}')
        regs = listing(f'{i}:{n}:' + listing(a) for i, n, a in self.registrations)
        return (f'namespace={self.namespace}|allocator={{' + av + '}|store={' + ';'.join(columns)
                + '}|resource={MotionLedger{' + tree(self.ledger) + ';4};sibling=Unit}|events='
                + listing(map(event, self.events)) + '|pending=' + str(len(self.pending)) + ':'
                + 'Raw;' * len(self.pending) + 'end|registrations=' + regs
                + f'|nextSystem={self.next_system}|clock={self.clock}')


def row(value):
    actor, main, aux, flag = value
    compact = lambda x: json.dumps(x, separators=(',', ':'))
    main_text = compact({'coordinates': dict(zip('abcd', main)), 'frame': 7})
    aux_text = 'ComponentAbsent' if aux is None else 'Found(' + compact({'rates': dict(zip('abcd', aux)), 'moving': True}) + ')'
    flag_text = 'ComponentAbsent' if flag is None else 'Found(' + compact({'group': flag}) + ')'
    return 'handle=' + handle(actor) + ';main=Found(' + main_text + ');aux=' + aux_text + ';flag=' + flag_text


@dataclass
class Stream:
    name: str
    batches: list = field(default_factory=list)
    positions: list = field(default_factory=list)
    next_reader: int = 3
    frame_start: int = 0
    boundary: int = 0
    capacity: int = 65536
    dropped: int = 0

    def reading(self, identity, tick):
        found = next((p for p in self.positions if p[0] == identity), (identity, 0, tick))
        _, cursor, registered = found
        values = [value for at, batch in self.batches if at > cursor for value in batch]
        return values, max(cursor, registered) < self.dropped

    def activate(self, identity, tick):
        if not any(p[0] == identity for p in self.positions):
            self.positions.insert(0, (identity, 0, max(0, tick - 1)))

    def advance(self, identity, tick):
        self.activate(identity, tick)
        self.positions = [(i, tick if i == identity else cursor, registered)
                          for i, cursor, registered in self.positions]

    def frame(self, tick):
        old_start = self.frame_start
        hold = min([old_start] + [p[1] for p in self.positions])
        while self.batches and self.batches[0][0] <= hold:
            self.dropped = max(self.dropped, self.batches.pop(0)[0])
        assert sum(len(xs) for _, xs in self.batches) <= self.capacity
        self.frame_start, self.boundary = tick, old_start

    def wire(self):
        batches = listing('tick=' + str(t) + ';values=' + listing(map(event, xs)) for t, xs in self.batches)
        positions = listing(f'id={i};cursor={c};registered={r}' for i, c, r in self.positions)
        return (f'domain={self.name};batches=' + batches + ';positions=' + positions
                + f';nextReader={self.next_reader};frameStart={self.frame_start};boundary={self.boundary};capacity={self.capacity};dropped={self.dropped}')


class Runtime:
    def __init__(self, world):
        self.world = world
        self.streams = {n: Stream(n) for n in ['ping', 'removed', 'despawned']}
        self.journal = []
        self.tick = 0
        self.failure_tick = world.clock
        self.frame_start = 0

    def ingest(self, tick):
        published = self.world.events[sum(len(xs) for _, xs in self.journal):]
        if published:
            for name, stream in self.streams.items():
                selected = [v for v in published if v[0].lower() == name]
                if selected:
                    stream.batches.append((tick, list(selected)))
            self.journal.append((tick, list(published)))
        self.tick = self.failure_tick = tick

    def before(self):
        epoch = max(1, self.tick, self.failure_tick, self.world.clock)
        self.ingest(epoch)
        self.world.clock += 1
        self.tick = epoch + 1

    def frame(self):
        self.before()
        for stream in self.streams.values():
            stream.frame(self.tick)
        self.journal = [(at, kept) for at, values in self.journal
                        if (kept := [v for v in values if self.streams[v[0].lower()].dropped < at])]
        self.world.events = [v for _, xs in self.journal for v in xs]
        self.frame_start = self.tick

    def meta(self):
        family = ';'.join(n + '={' + s.wire() + '}' for n, s in self.streams.items())
        journal = listing('tick=' + str(t) + ';values=' + listing(map(publication, xs)) for t, xs in self.journal)
        return ('typed={family={' + family + '};owner=Unit;journal=' + journal
                + f';frameStart={self.frame_start}' + '};failures={domains=[];positions=[];tick='
                + str(self.failure_tick) + ';frameStart=0;boundary=0;capacity=65536;nextReader=1}')

    def wire(self):
        return f'tick={self.tick};world={{' + self.world.wire() + '};meta={' + self.meta() + '}'

QUERY = ['Position', 'Velocity', 'Selected']
ACCESS = QUERY + ['Position'] + QUERY + ['Position'] + QUERY + ['ping:read', 'removed:read', 'despawned:read']
LOCAL_ACCESS = [['command:spawn'], ['Position', 'event:ping'], ['Position', 'command:remove', 'command:despawn']]


class Provider:
    def __init__(self, identity, name, stream_id):
        self.identity, self.name, self.stream_id, self.cursor = identity, name, stream_id, 0

    def wire(self):
        access = listing(ACCESS)
        facts = f'ns=1;id={self.identity};name={self.name};access=' + access
        child = 'facts={' + facts + f'}};reader={{namespace=1;id={self.stream_id};registryId={self.identity}' + '}'
        owners = 'queryOwners=(Unit,Unit,Unit);ping={' + child + '};removed={' + child + '};despawned={' + child + '}'
        return (f'registry={{ns=1;id={self.identity};name={self.name};access=' + access
                + f';cursor={self.cursor}' + '};parameter=' + access + ';declaration=Unit;owners={' + owners + '}')


@dataclass
class Frame:
    count: int
    iteration: int = 0
    transient: object = None
    reservations: list = field(default_factory=list)
    facts: list = field(default_factory=list)

    def wire(self):
        return (f'count={self.count};iteration={self.iteration};transient=' + maybe_handle(self.transient)
                + ';reservations=' + listing(map(reservation, self.reservations))
                + ';activeTransactions=' + listing(self.facts))


def transaction_fact(operation, undo, commands, events, world):
    return (f'operation={operation};undo={undo};commands={commands};events=' + listing(map(event, events))
            + ';traceEnabled=False;world={' + world.wire() + '}')


class Program:
    def __init__(self, count=64):
        self.world = World(1)
        for name, access in zip(['Spawn', 'Update', 'Dispose'], LOCAL_ACCESS):
            self.world.register(name, access)
        self.runtime = Runtime(self.world)
        self.fast = Provider(self.world.register('Fast', ACCESS), 'Fast', 1)
        self.slow = Provider(self.world.register('Slow', ACCESS), 'Slow', 2)
        self.frame = Frame(count)
        self.phase = 0
        self.captures = [0, 0, 0]
        self.locals = []
        self.reads = []
        self.logs = []
        self.audit = []
        self.actor_map = []

    def local_wire(self, index):
        return (f'namespace=1;id={index+1};name=' + ['Spawn', 'Update', 'Dispose'][index]
                + ';access=' + listing(LOCAL_ACCESS[index]) + ';capture=' + tree([self.captures[index], 101+index]))

    def owners_wire(self):
        return ('ids={spawn=1;update=2;dispose=3;fast=4;slow=5};tick=' + str(self.runtime.tick)
                + f';phase={self.phase};frame={{' + self.frame.wire() + '};spawn={' + self.local_wire(0)
                + '};update={' + self.local_wire(1) + '};dispose={' + self.local_wire(2)
                + '};fast={' + self.fast.wire() + '};slow={' + self.slow.wire()
                + '};runtimeMeta={' + self.runtime.meta() + '};localCalls=' + listing(self.locals)
                + ';readerCalls=' + listing(self.reads))

    def wire(self):
        return ('namespace=1;status=Complete;world={' + self.world.wire() + '};owners={' + self.owners_wire()
                + '};schedules=' + listing(self.logs))

    def mutation(self, operation):
        self.captures[operation] += 1
        f = self.frame
        f.facts = []
        if operation == 0:
            tx = Transaction(self.world)
            actor = tx.spawn([[f.iteration+j for j in range(4)], None, None])
            assert actor is not None
            f.facts.append(transaction_fact(0, 1, 1, [], self.world))
            tx.finish()
            f.transient = actor
            f.reservations.append(actor)
            self.actor_map.append((f.count+f.iteration+1, actor))
        elif operation == 1:
            actor = f.transient
            found, value = self.world.component(actor)
            assert found == 'Found'
            value[0] += 1
            assert self.world.replace(actor, 0, value)[0]
            published = [('Ping', f.iteration)]
            f.facts.append(transaction_fact(1, 1, 0, published, self.world))
            self.world.events.extend(published)
        else:
            tx = Transaction(self.world)
            assert tx.remove(f.transient) and tx.despawn(f.transient)
            f.facts.append(transaction_fact(2, 0, 2, [], self.world))
            tx.finish()
        self.locals.append(f'id={operation+1};operation={operation};status=0;output=Some(' + f.wire() + ')')

    def read(self, provider):
        before = 'provider={' + provider.wire() + '};context={' + self.runtime.wire() + '}'
        prior_cursor = provider.cursor
        self.runtime.before()
        tick = self.runtime.tick
        views = {}
        for name, stream in self.runtime.streams.items():
            views[name] = stream.reading(provider.stream_id, tick)
            stream.activate(provider.stream_id, max(0, tick-1))
        running = self.runtime.wire()
        rows = self.world.rows()
        added = self.world.rows(prior_cursor, 0)
        changed = self.world.rows(prior_cursor, 1)
        args = f'who={provider.stream_id-1};phase={self.phase};iteration={self.frame.iteration};'
        prepared = (f'queryCursor={prior_cursor};readThroughPing={tick-1};readThroughRemoved={tick-1};readThroughDespawned={tick-1};runningContext={{'
                    + running + '};rows=' + listing(map(row, rows)) + ';added=' + listing(map(row, added))
                    + ';changed=' + listing(map(row, changed)))
        for name in ['ping', 'removed', 'despawned']:
            values, lagged = views[name]
            prepared += ';' + name + '={values=' + listing(map(event, values)) + ';lagged=' + str(lagged) + '}'
        for stream in self.runtime.streams.values():
            stream.advance(provider.stream_id, tick-1)
        self.runtime.ingest(tick)
        provider.cursor = self.world.clock
        after = 'provider={' + provider.wire() + '};context={' + self.runtime.wire() + '}'
        self.reads.append(f'Read{{id={provider.identity};tick={tick};before={{' + before + '};output=Some(' + args + prepared
                          + f')}};ReadDone{{id={provider.identity};status=0;after={{' + after + '}}')
        self.audit.append(dict(who=provider.name, phase=self.phase, iteration=self.frame.iteration,
                               rows=copy.deepcopy(rows), added=copy.deepcopy(added), changed=copy.deepcopy(changed),
                               events=copy.deepcopy(views), queryCursor=prior_cursor, readThrough=tick-1,
                               cursor=provider.cursor, tick=tick))

    def schedule(self, name, ids, barrier=False):
        for identity in ids:
            if identity <= 3:
                self.mutation(identity-1)
            else:
                self.read(self.fast if identity == 4 else self.slow)
        if barrier:
            self.world.barrier()
        steps = [f'System({i},0)' for i in ids] + (['Barrier'] if barrier else [])
        observations = [f'Ran({i})' for i in ids] + (['Applied'] if barrier else [])
        self.logs.append('Log{' + name + ';steps=' + listing(steps) + ';status=Complete;observations=Some(' + listing(observations) + ')}')

    def prime(self):
        self.schedule('Prime', [4, 5])
        self.runtime.frame()
        self.phase = 1

    def step(self):
        self.schedule('SpawnBarrier', [1], True)
        self.runtime.frame()
        self.schedule('UpdateReaders', [2, 4] + ([5] if self.frame.iteration % 4 == 3 else []))
        self.runtime.frame()
        self.schedule('DisposeBarrier', [3], True)
        self.runtime.frame()
        self.frame.iteration += 1

    def drain(self):
        self.phase = 2
        self.schedule('Drain', [4, 5])
        self.runtime.frame()


def report(count=64, iterations=64):
    p = Program(count)
    chunks = [f'ReadersRuntime Motion\ncount={count};iterations={iterations}\n', 'registered={' + p.wire() + '}\n']
    tx = Transaction(p.world)
    seed = [tx.spawn([[j+i for i in range(4)], [1,2,3,4] if j%3 == 0 else None, 8 if j%3 == 1 else None]) for j in range(count)]
    seed_frame = Frame(count, reservations=seed, facts=[transaction_fact(3, count, count, [], p.world)])
    tx.finish()
    chunks.extend(['seedOutcome=Success;seedFrame={' + seed_frame.wire() + '}\n', 'seedPending={' + p.world.wire() + '}\n'])
    p.world.barrier()
    chunks.append('seedApplied={' + p.world.wire() + '}\n')
    chunks.append('seededRegistered={' + p.wire() + '}\n')
    p.prime()
    for _ in range(iterations):
        p.step()
    p.drain()
    chunks.append('final={' + p.wire() + '};finalLogicalRows=' + listing(map(row, p.world.rows()))
                  + ';afterLogicalWorld={' + p.world.wire() + '}\n\n')
    p.actor_map = [(j+1, actor) for j, actor in enumerate(seed)] + p.actor_map
    return ''.join(chunks).encode(), p


def selftest():
    assert physical_selftest()
    raw, p = report()
    assert p.world.clock == p.runtime.tick == 577
    assert p.runtime.failure_tick == 576
    assert len(p.audit) == 84 and [len([a for a in p.audit if a['who']==who]) for who in ['Fast','Slow']] == [66,18]
    assert raw.count(b'Read{id=') == raw.count(b'ReadDone{id=') == 84
    assert len(p.locals) == 192 and len(p.logs) == 194
    assert b'Entered(' not in raw  # No Phase step is authored; schedule names do not emit Entered.
    assert p.captures == [64,64,64]
    assert p.fast.cursor == 575 and p.slow.cursor == 576
    assert p.world.allocator.next == 66 and p.world.allocator.high == 65
    assert p.world.allocator.slots[65].generation == 64 and p.world.allocator.free == [65]
    assert len(p.world.rows()) == 64 and p.world.ledger == [0,101,102,103]
    assert p.world.events == [] and p.runtime.journal == []
    assert [x[1] for x in p.runtime.streams['ping'].positions] == [575,574]
    assert [s.dropped for s in p.runtime.streams.values()] == [569,573,573]
    assert all(not lag for a in p.audit for _,lag in a['events'].values())
    slow = [a for a in p.audit if a['who']=='Slow' and a['phase']==1]
    assert [v[1] for v in slow[0]['events']['ping'][0]] == [0,1,2,3]
    assert len(slow[0]['events']['removed'][0]) == 3
    assert len(slow[1]['events']['removed'][0]) == 4
    assert all(a['rows'][-1][0].key.index == 65 for a in p.audit if a['phase']==1)
    assert raw.endswith(b'\n\n')
    assert len(p.actor_map) == 128 and len(set(a for _,a in p.actor_map)) == 128
    assert p.actor_map[64][1] == Handle(1, Key(65,0))
    assert p.actor_map[-1][1] == Handle(1, Key(65,63))
    # Non-vacuity: complete owner/payload/runtime metadata are observable.
    old = p.wire()
    p.world.columns[2].values[1] = 9
    assert p.wire() != old and row(p.world.rows()[1]).endswith('Found({"group":9})')
    p.world.columns[2].values[1] = 8
    assert p.wire() == old
    p.runtime.streams['ping'].dropped = 0
    assert p.wire() != old
    p.runtime.streams['ping'].dropped = 569
    assert p.wire() == old
    # Every callback view has exact live Added/Changed rows, not historical IDs.
    assert all(len(a['added']) == len(a['changed']) == (64 if a['phase']==0 else 1 if a['phase']==1 else 0)
               for a in p.audit)
    assert all(len(a['rows']) == (65 if a['phase']==1 else 64) for a in p.audit)
    assert [len(c.added) for c in p.world.columns] == [128,64,64]
    assert [len(c.values) for c in p.world.columns] == [128,64,64]
    assert all(c.exceptional == [] for c in p.world.columns)
    assert p.world.columns[0].added[64] == p.world.columns[0].changed[64] == 0
    physical = p.wire()
    p.world.columns[0].added[100] = 77
    assert p.wire() != physical
    p.world.columns[0].added[100] = 0
    assert p.wire() == physical
    # Metadata absence/clear outside capacity never grows; set grows separately
    # from values, and clear keeps the enlarged physical arrays.
    c = IndexedColumn()
    assert c.clear(65) is None and len(c.added) == len(c.values) == 1
    c.metadata_set(65,(4,5))
    assert len(c.added) == 128 and len(c.values) == 1
    c.clear(65)
    assert len(c.added) == 128 and c.added[64] == c.changed[64] == 0
    return raw, p


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--render-stdout', action='store_true')
    parser.add_argument('--self-test', action='store_true')
    args = parser.parse_args()
    if args.self_test:
        data, program = selftest()
        print('PASS independent source-model selftests; no subject execution')
    elif args.render_stdout:
        import sys
        sys.stdout.buffer.write(report()[0])
