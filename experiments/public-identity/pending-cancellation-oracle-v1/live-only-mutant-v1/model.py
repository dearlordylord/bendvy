"""Independent ordered command/reservation model with full physical bitmap wire."""
from dataclasses import dataclass


def listing(values):
    return '[' + ', '.join(values) + ']'


def tree(values):
    if len(values) == 1:
        return 'L(' + str(values[0]) + ')'
    half = len(values) // 2
    return 'N(' + tree(values[:half]) + ',' + tree(values[half:]) + ')'


def pair(seed):
    return tree([seed, seed + 1])


def owners(values):
    return '[]' if not values else 'cons(' + pair(values[0]) + ',' + owners(values[1:]) + ')'


@dataclass(frozen=True)
class Command:
    kind: str
    ident: int
    payload: object = None


class Model:
    def __init__(self):
        self.namespace = 1  # Each nominal scene uses its own actual W.factory().
        self.next = 1
        self.capacity = 1
        self.dual = False
        self.live = set()
        self.reserved_pending = set()
        self.commands = []
        self.payload = None
        self.returned = []
        self.trace = []
        self.rows = []
        self.handles = []
        self.local = []
        self.undo = []

    def world(self):
        visible = [str(i in self.live) for i in range(self.capacity)]
        physical = visible + ([str(i in self.reserved_pending) for i in range(self.capacity)] if self.dual else [])
        store = ('store{payload=' + ('None' if self.payload is None else 'Some{' + pair(self.payload) + '}')
                 + ';returned=' + owners(self.returned) + ';trace=' + listing([str(i) for i in self.trace]) + '}')
        return (f'world{{ns=1;next={self.next};high={self.next - 1};physicalLive=' + tree(physical)
                + f';capacity={self.capacity};depth={self.capacity.bit_length() - 1};' + store
                + ';resource=' + pair(900) + f';events=[];pending={len(self.commands)};registrations=[];nextSystem=1;clock=0}}'
                + ';visible=' + listing(['1:' + str(i) for i in sorted(self.live)]))

    def snapshot(self, label):
        self.rows.append(label + ':' + self.world())

    def begin(self):
        self.local = []
        self.undo = []

    def tx_view(self, label):
        self.rows.append(f'{label}:tx{{undo={len(self.undo)};commands={len(self.local)};events=[];' + self.world() + '}')

    def reserve(self, payload, record=True):
        ident = self.next
        self.next += 1
        while ident >= self.capacity:
            self.capacity *= 2
        self.dual = True
        self.reserved_pending.add(ident)
        self.undo.append(ident)
        self.local.append(Command('spawn', ident, payload))
        self.handles.append(ident)
        if record:
            self.rows += [f'incoming={payload},{payload + 1}', f'spawn=1:{ident}']
        return ident

    def despawn(self, ident):
        allowed = ident in self.live
        self.rows.append('despawn=' + ('Accepted' if allowed else 'MissingEntity'))
        if allowed:
            self.local.append(Command('despawn', ident))
        return allowed

    def finish(self, success=True, batch=False):
        if success:
            self.commands.extend(self.local)
        else:
            for ident in reversed(self.undo):
                self.reserved_pending.discard(ident)
        self.local = []
        self.undo = []
        self.rows.append('batch-finish=Committed' if batch else 'finish=' + ('Success' if success else 'Failure'))

    def populate(self, ident, payload):
        if self.payload is not None:
            self.returned.append(self.payload)
        self.payload = payload
        self.trace.append(100 + ident)

    def apply(self):
        for command in self.commands:
            if command.kind == 'spawn':
                self.reserved_pending.discard(command.ident)
                self.live.add(command.ident)
                if command.payload is not None:
                    self.populate(command.ident, command.payload)
            elif command.kind == 'delivery':
                assert command.ident in self.live
                self.populate(command.ident, command.payload)
            else:
                assert command.kind == 'despawn' and command.ident in self.live
                self.live.remove(command.ident)
                if self.payload is not None:
                    self.returned.append(self.payload)
                self.payload = None
                self.trace.append(200 + command.ident)
        self.commands = []
        self.snapshot('barrier')


def scenario():
    s = Model()
    s.snapshot('created')
    s.begin()
    s.reserve(10)
    s.tx_view('direct-staged')
    s.despawn(1)
    s.tx_view('direct-cancelled')
    s.finish()
    s.snapshot('direct-committed')
    s.apply()
    s.begin()
    s.rows.append('batch-incoming=20,21')
    s.reserve(None, record=False)
    s.rows.append('batch-prepared=cons(Prepared{target=1:2;position=1;payload=' + pair(20) + '},cons(ReservationReceipt{1:2},[]))')
    s.tx_view('batch-staged')
    s.despawn(2)
    s.tx_view('batch-cancelled')
    # Prepared position1 inserts delivery after actual activation and before clear.
    s.local.insert(1, Command('delivery', 2, 20))
    s.finish(batch=True)
    s.snapshot('batch-committed')
    s.apply()
    s.begin()
    s.reserve(30)
    s.tx_view('cross-staged')
    s.finish()
    s.snapshot('cross-pending')
    s.begin()
    s.despawn(3)
    s.tx_view('cross-cancelled')
    s.finish()
    s.snapshot('cross-cancel-committed')
    s.apply()
    s.begin()
    s.reserve(40)
    s.tx_view('prior-staged')
    s.finish()
    s.snapshot('prior-pending')
    s.begin()
    for seed in [50, 60, 70, 80]:
        s.reserve(seed)
    s.tx_view('abort-staged')
    assert s.capacity == 16 and s.reserved_pending == {4, 5, 6, 7, 8}
    s.finish(success=False)
    s.snapshot('after-abort-growth')
    assert s.reserved_pending == {4} and s.next == 9 and len(s.commands) == 1
    s.begin()
    assert not s.despawn(5)
    s.tx_view('failed-id-refusal')
    s.finish()
    s.snapshot('failed-id-refused')
    s.apply()
    s.begin()
    s.despawn(4)
    s.tx_view('prior-live-despawn')
    s.finish()
    s.apply()
    return 'rows=' + listing(s.rows) + ';handles=' + listing(['1:' + str(i) for i in s.handles])


def render():
    # Independently created W.Factory1 per nominal schema, rather than WorldIO.
    return ('Workshop{' + scenario() + '}\nGarden{' + scenario() + '}\n').encode()


def selftest():
    raw = render()
    assert raw.count(b'despawn=Accepted') == 2
    assert raw.count(b'despawn=MissingEntity') == 8
    assert raw.count(b'finish=Failure') == 2
    assert b'trace=[101, 102, 103, 104, 204]' in raw
    assert raw.count(b';visible=[1:1, 1:2, 1:3]') >= 2
    assert b'returned=cons(N(L(10),L(11)),cons(N(L(20),L(21)),cons(N(L(30),L(31)),cons(N(L(40),L(41)),[]))))' in raw
    assert raw.endswith(b'}\n') and not raw.endswith(b'\n\n')


if __name__ == '__main__':
    import sys
    selftest()
    if '--selftest' not in sys.argv:
        sys.stdout.buffer.write(render())
