"""Source-derived complete scope trace; no subject/backend output is read."""
from pathlib import Path
import gzip
import hashlib
import json

HERE = Path(__file__).resolve().parent


def listing(values):
    return '[' + ', '.join(values) + ']'


def tree(values, leaf='L(', close=')', node='N('):
    if len(values) == 1:
        return leaf + str(values[0]) + close
    half = len(values) // 2
    return node + tree(values[:half], leaf, close, node) + ',' + tree(values[half:], leaf, close, node) + ')'


def allocator_tree(values):
    if len(values) == 1:
        generation, phase = values[0]
        return f'leaf:{generation}:{phase}'
    half = len(values) // 2
    return 'node(' + allocator_tree(values[:half]) + ',' + allocator_tree(values[half:]) + ')'


def key_text(key):
    index, generation = key
    return f'{index}:{generation}'


def handle_text(key):
    return '1/' + key_text(key)


def payload(ident):
    return f'P(L({ident}),N(L({ident + 10}),L({ident + 20})))'


class Model:
    def __init__(self):
        self.next = 1
        self.high = 0
        self.capacity = 1
        self.depth = 0
        self.allocator_slots = [(0, 'Consumed')]
        self.free = []
        self.order = []
        self.components = [None] * 4
        self.removed = []
        self.members = []
        self.events = []
        self.pending = []
        self.undo = []
        self.commands = []
        self.rows = []
        self.handles = []

    def valid(self, key, phase):
        index, generation = key
        return (0 < index < self.next and index < self.capacity
                and self.allocator_slots[index] == (generation, phase))

    def allocator(self):
        return (f'next={self.next};high={self.high};capacity={self.capacity};depth={self.depth};slots='
                + allocator_tree(self.allocator_slots) + ';free='
                + listing(map(str, self.free)) + ';order=' + listing(map(key_text, self.order)))

    def world(self):
        slots = tree(['absent' if owner is None else payload(owner) for owner in self.components])
        return ('world=1,allocator={' + self.allocator() + '}/' + slots
                + '/removed=' + ''.join(payload(owner) + ';' for owner in self.removed)
                + '/graph=[]/[]/scopes=' + listing(['room:' + key_text(key) for key in self.members])
                + '/resource=N(L(900),L(901))/events=' + listing(self.events)
                + f'/pending={len(self.pending)}/regs=[]/nextSystem=1/clock=0')

    def view(self, label, tx=False):
        prefix = label + ':'
        if tx:
            prefix += f'undo={len(self.undo)};commands={len(self.commands)};events=[];'
        self.rows.append(prefix + self.world())

    def spawn(self, producer, owner):
        if self.free:
            index = self.free.pop(0)
            generation, _ = self.allocator_slots[index]
        else:
            index = self.next
            generation = 0
            self.next += 1
            self.high = index
            if index >= self.capacity:
                self.allocator_slots.extend([(0, 'Consumed')] * self.capacity)
                self.capacity *= 2
                self.depth += 1
        key = (index, generation)
        self.allocator_slots[index] = (generation, 'Pending')
        self.order.append(key)
        self.undo.append(key)
        self.commands.append(('spawn', key, owner, producer))
        self.handles.append(key)
        self.rows.append('spawned=' + handle_text(key))

    def finish(self):
        # Transaction.finish transfers commands in authored FIFO order; it does
        # not run inverse closures. No Tx events occur in this source program.
        self.pending.extend(self.commands)
        self.commands = []
        self.undo = []

    def activate(self, key, owner):
        index, generation = key
        assert self.valid(key, 'Pending')
        self.allocator_slots[index] = (generation, 'Live')
        previous = self.components[index]
        if previous is not None:
            self.removed.insert(0, previous)
        self.components[index] = owner
        self.members = [member for member in self.members if member != key] + [key]

    def clear_member(self, key):
        # The candidate's full-key live checks precede schema cleanup. These
        # actual stored members remain live when each CleanupFinish is reached.
        assert self.valid(key, 'Live')
        index, generation = key
        owner = self.components[index]
        self.components[index] = None
        self.members.remove(key)
        notices = []
        if owner is not None:
            self.removed.insert(0, owner)
            notices.append('removed:' + key_text(key))
        self.allocator_slots[index] = (generation, 'DeadRetained')
        self.events.extend(notices + ['original:' + str(index)])
        # relation-cleanup.publish_final releases only after schema-owned clear.
        self.allocator_slots[index] = (generation + 1, 'Free')
        self.free.insert(0, index)
        self.order.remove(key)

    def barrier(self):
        commands, self.pending = self.pending, []
        for command in commands:
            if command[0] == 'spawn':
                _, key, owner, _producer = command
                self.activate(key, owner)
            else:
                assert command == ('cleanup',)
                for key in list(self.members):
                    self.clear_member(key)
        self.view('barrier')


def scenario():
    state = Model()
    state.view('created')
    state.spawn('component', 1)
    state.view('component-producer-staged', tx=True)
    state.spawn('world', 2)
    state.view('both-producers-staged', tx=True)
    state.finish()
    state.view('spawn-committed')
    state.barrier()
    assert state.members == [(1, 0), (2, 0)]
    assert state.components == [None, 1, 2, None]
    assert state.order == [(1, 0), (2, 0)]
    state.commands.append(('cleanup',))
    state.rows.append('cleanup=Queued')
    state.view('cleanup-staged', tx=True)
    state.finish()
    state.view('cleanup-committed')
    state.barrier()
    assert state.components == [None] * 4 and state.removed == [2, 1]
    assert not state.members and not state.order and state.free == [2, 1]
    assert state.allocator_slots == [(0, 'Consumed'), (1, 'Free'), (1, 'Free'), (0, 'Consumed')]
    assert state.events == ['removed:1:0', 'original:1', 'removed:2:0', 'original:2']
    assert (state.next, state.high, state.capacity, state.depth) == (3, 2, 4, 2)
    return 'scope{1:room};rows=' + listing(state.rows) + ';handles=' + listing(map(handle_text, state.handles))


def render():
    # Exactly one IO.print adds LF after the complete returned String.
    return (scenario() + '\n').encode()


def selftest():
    raw = render()
    assert raw.count(b'spawned=1/') == 2
    assert b'component-producer-staged:undo=1;commands=1;events=[];' in raw
    assert b'both-producers-staged:undo=2;commands=2;events=[];' in raw
    assert b'cleanup-staged:undo=0;commands=1;events=[];' in raw
    assert b'/scopes=[room:1:0, room:2:0]' in raw
    assert b';free=[2, 1];order=[]}' in raw
    assert b'/events=[removed:1:0, original:1, removed:2:0, original:2]' in raw
    assert raw.endswith(b'handles=[1/1:0, 1/2:0]\n') and not raw.endswith(b'\n\n')
    # A consumed/free slot and the now-stale generation-zero key are not live.
    state = Model()
    state.spawn('component', 1)
    state.finish()
    state.barrier()
    state.clear_member((1, 0))
    assert not state.valid((1, 0), 'Live') and state.allocator_slots[1] == (1, 'Free')


def verify_basis():
    basis = json.loads((HERE / 'SOURCE-BASIS.json').read_text())
    for name, expected in basis['sourcePins'].items():
        actual = hashlib.sha256(Path(name).read_bytes()).hexdigest()
        assert actual == expected, name
    freeze = basis['freeze']
    assert hashlib.sha256(Path(freeze['path']).read_bytes()).hexdigest() == freeze['sha256']


if __name__ == '__main__':
    import sys
    verify_basis()
    selftest()
    if '--selftest' not in sys.argv:
        sys.stdout.buffer.write(render())
