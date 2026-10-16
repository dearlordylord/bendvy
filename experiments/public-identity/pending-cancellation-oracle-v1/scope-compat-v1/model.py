"""Independent complete two actual scoped spawn producers and post-barrier cleanup."""


def listing(values):
    return '[' + ', '.join(values) + ']'


def tree(values):
    if len(values) == 1:
        return 'L(' + str(values[0]) + ')'
    half = len(values) // 2
    return 'N(' + tree(values[:half]) + ',' + tree(values[half:]) + ')'


def payload(ident):
    return f'P(L({ident}),N(L({ident + 10}),L({ident + 20})))'


class Model:
    def __init__(self):
        self.next = 1
        self.capacity = 1
        self.dual = False
        self.live = set()
        self.marks = set()
        self.slots = [None] * 4
        self.members = []
        self.removed = []
        self.events = []
        self.pending = 0
        self.undo = 0
        self.commands = 0
        self.rows = []

    def world(self):
        bits = [str(i in self.live) for i in range(self.capacity)]
        if self.dual:
            bits += [str(i in self.marks) for i in range(self.capacity)]
        components = tree(['absent' if value is None else payload(value) for value in self.slots])
        return (f'world=1,{self.next},{self.next - 1},' + tree(bits) + f',{self.capacity},{self.capacity.bit_length() - 1}/'
                + components + '/removed=' + ''.join(payload(i) + ';' for i in self.removed)
                + '/graph=[]/[]/scopes=' + listing(['room:' + str(i) for i in self.members])
                + '/resource=N(L(900),L(901))/events=' + listing(self.events)
                + f'/pending={self.pending}/regs=[]/nextSystem=1/clock=0')

    def view(self, label, tx=False):
        prefix = label + ':'
        if tx:
            prefix += f'undo={self.undo};commands={self.commands};events=[];'
        self.rows.append(prefix + self.world())

    def spawn(self):
        ident = self.next
        self.next += 1
        while ident >= self.capacity:
            self.capacity *= 2
        self.dual = True
        self.marks.add(ident)
        self.undo += 1
        self.commands += 1
        self.rows.append(f'spawned=1:{ident}')


def render():
    s = Model()
    s.view('created')
    s.spawn()  # Sc.tx_spawn_in with component-only population.
    s.view('component-producer-staged', tx=True)
    s.spawn()  # Spawn.tx_spawn_in with actual whole World population.
    s.view('both-producers-staged', tx=True)
    s.pending = s.commands
    s.undo = s.commands = 0
    s.view('spawn-committed')
    # FIFO activation/population assigns each actual scope member after success.
    for ident in [1, 2]:
        s.marks.remove(ident)
        s.live.add(ident)
        s.slots[ident] = ident
        s.members.append(ident)
    s.pending = 0
    s.view('barrier')
    assert s.members == [1, 2] and s.slots == [None, 1, 2, None]
    s.commands = 1
    s.rows.append('cleanup=Queued')
    s.view('cleanup-staged', tx=True)
    s.pending = s.commands
    s.commands = 0
    s.view('cleanup-committed')
    # Scope selects members in stored order; each cleanup clears payload, removes
    # membership and publishes clear records followed by authored terminal record.
    for ident in list(s.members):
        s.slots[ident] = None
        s.removed.insert(0, ident)
        s.members.remove(ident)
        s.live.remove(ident)
        s.events.extend([f'removed:{ident}', f'original:{ident}'])
    s.pending = 0
    s.view('barrier')
    assert s.removed == [2, 1] and not s.members and not s.live and not s.marks
    assert s.dual and s.capacity == 4
    return ('scope{1:room};rows=' + listing(s.rows) + ';handles=[1:1, 1:2]\n').encode()


def selftest():
    raw = render()
    assert raw.count(b'spawned=1:') == 2
    assert b'component-producer-staged:undo=1;commands=1' in raw
    assert b'both-producers-staged:undo=2;commands=2' in raw
    assert b'cleanup-staged:undo=0;commands=1' in raw
    assert b'/events=[removed:1, original:1, removed:2, original:2]' in raw
    assert raw.endswith(b'handles=[1:1, 1:2]\n')


if __name__ == '__main__':
    import sys
    selftest()
    if '--selftest' not in sys.argv:
        sys.stdout.buffer.write(render())
