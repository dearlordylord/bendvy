"""Independent finite lazy checked-reader owner/cursor/queue model and full wire."""


def listing(values):
    return '[' + ', '.join(values) + ']'


def cons(values):
    return '[]' if not values else 'cons(' + values[0] + ',' + cons(values[1:]) + ')'


def pair(seed):
    return f'node(leaf:{seed},leaf:{seed + 1})'


SCHEMA = listing(['Entry{Resource:' + key + ':' + key + '}' for key in ['Counter', 'Threshold', 'Sentinel']])
STEPS = ['Phase{readers}', 'System{1,0}', 'System{2,0}', 'Barrier']
PLAN = 'Sequence{Entry{Phase{readers};needs=[]},Sequence{Entry{System{1,0};needs=[]},Sequence{Entry{System{2,0};needs=[]},Entry{Barrier;needs=[]}}}}'
NAMES = {1: 'fast', 2: 'slow'}


class State:
    def __init__(self, namespace):
        self.namespace = namespace
        self.debug = False
        self.threshold = 0
        self.slots = []
        self.flags = [True, False]
        self.pending = 1
        self.world_clock = 0
        self.tick = 1
        self.positions = []
        self.receipts = []
        self.sync_calls = 0

    def slot(self, value):
        return 'Missing' if value is None else 'Present{' + pair(value) + '}'

    def identity(self, ident):
        return f'namespace={self.namespace};id={ident};name={NAMES[ident]};access=[Signal:read];cursor=0'

    def binding(self, ident):
        flag = self.flags[ident - 1]
        return (f'binding{{systemId={ident};description{{shape=And{{Constant{{{flag}}},Check{{Threshold-positive}}}};uses='
                + '[Resource{Threshold;mode=Read;required=True}]}}')

    def descriptions(self):
        return listing([self.binding(1), self.binding(2)])

    def world(self):
        return (f'world{{namespace={self.namespace};nextId=1;highWater=0;live=leaf:False;capacity=1;depth=0;store={pair(700)}'
                + ';resources={Counter=' + pair(10) + ';Threshold=' + self.slot(self.threshold) + ';Sentinel=' + pair(900)
                + f'}};events=[];pending={self.pending};registrations=[2:slow:[Signal:read], 1:fast:[Signal:read]];nextSystemId=3;clock={self.world_clock}}}')

    def owner(self, ident):
        return (f'owner{{declaration=Signal:Read;reader{{namespace={self.namespace};id={ident};registryId={ident}}};registry{{'
                + self.identity(ident) + '}}')

    def stream(self):
        positions = listing([f'Position{{{ident};cursor={cursor};registeredAt={registered}}}'
                             for ident, cursor, registered in self.positions])
        return ('stream{domain=Signal;batches=[Batch{1;values=[7, 8]}];positions=' + positions
                + ';nextReader=3;frameStart=0;boundary=0;capacity=8;dropped=0}')

    def receipt(self, ident, values):
        return (f'Receipt{{reader={ident};completion=Succeeded{{Callback{{owned={pair(70)};Reading{{values='
                + listing([str(value) for value in values]) + ';lagged=False}}}}')

    def packed(self):
        owners = 'owners{previous=Unit;first=' + self.owner(1) + ';second=' + self.owner(2) + '}'
        held = ('Held{owned=' + pair(600) + ';receipts=' + cons([self.receipt(ident, values) for ident, values in self.receipts])
                + f';syncCalls={self.sync_calls}}}')
        return f'packed{{tick={self.tick};' + owners + ';family{' + self.stream() + ';' + held + '}}'

    def guards(self):
        return (f'guards{{firstId=1;firstOwner=Bool({self.flags[0]})&Unit;secondId=2;secondOwner=Bool({self.flags[1]})&Unit;descriptions='
                + self.descriptions() + '}')

    def actual(self):
        return ('app{schema=' + SCHEMA + f';debug={self.debug};recipe=Recipe;plan=' + PLAN
                + f';namespace={self.namespace};name=checked-readers;steps=' + listing(STEPS)
                + ';needs=[];' + self.world() + ';' + self.packed() + ';' + self.guards() + '}')

    def snapshot(self):
        if not self.debug:
            return 'None'
        bindings = listing(['binding{' + self.identity(ident) + ';slot=Signal;clauses=[Signal:Read]}' for ident in [1, 2]])
        return ('Some{schema=' + SCHEMA + ';bindings=' + bindings + ';rows=Product{Product{Unit,Unit},Unit};rendered=[]'
                + f';namespace={self.namespace};name=checked-readers;steps=' + listing(['planned{' + step + ';needs=[]}' for step in STEPS])
                + ';checkedBindings=' + self.descriptions() + '}')

    def exchange(self, incoming):
        self.slots.insert(0, self.threshold)
        self.threshold = incoming

    def read(self, ident):
        previous = next((value for value in self.positions if value[0] == ident), None)
        cursor = 0 if previous is None else previous[1]
        values = [7, 8] if cursor < 1 else []
        old_tick = self.tick
        self.tick += 1
        if previous is None:
            self.positions.insert(0, (ident, self.tick, old_tick))
        else:
            self.positions = [(entry, self.tick if entry == ident else at, registered)
                              for entry, at, registered in self.positions]
        self.sync_calls += 1
        self.receipts.append((ident, values))

    def dispatch(self):
        observations = ['Entered{readers}']
        for ident, flag in enumerate(self.flags, start=1):
            if not flag:
                observations.append(f'Skipped{{{ident}}}')
                continue
            if self.threshold is None:
                return 'Failed:CheckError{MissingRuntimeRequirements{[Threshold]}}:' + listing(observations)
            if self.threshold > 0:
                self.read(ident)
                observations.append(f'Ran{{{ident}}}')
            else:
                observations.append(f'Skipped{{{ident}}}')
        self.world_clock += self.pending
        self.pending = 0
        observations.append('Applied')
        return 'Finished:' + listing(observations)


def schema(namespace):
    s = State(namespace)
    chunks = []

    def checkpoint(label):
        slots = ''.join(s.slot(value) + ';' for value in s.slots) + '[]'
        chunks.append(label + '\napp=' + s.actual() + '\nreturnedThresholdSlots=' + slots + '\nsnapshot=' + s.snapshot() + '\n')

    def dispatch():
        chunks.append(s.dispatch() + '\n')

    def guards(first, second):
        s.flags = [first, second]
        chunks.append(f'Guards={first},{second}\n')

    def exchange(value):
        s.exchange(value)
        chunks.append('ThresholdExchanged\n')

    checkpoint('disabled')
    s.debug = True
    chunks.append('Enabled\n')
    checkpoint('enabled')
    dispatch()
    checkpoint('false-before-reader-barrier-applied')
    dispatch()
    checkpoint('false-repeat')
    exchange(None)
    guards(False, False)
    dispatch()
    checkpoint('lazy-missing-skipped')
    guards(True, False)
    dispatch()
    checkpoint('reached-missing-refused')
    exchange(s.slots.pop(0))
    exchange(5)
    dispatch()
    checkpoint('fast-read-slow-unentered')
    guards(False, False)
    dispatch()
    checkpoint('false-after-fast-preserves')
    guards(True, True)
    dispatch()
    checkpoint('slow-admitted-fast-empty')
    dispatch()
    checkpoint('both-repeat')
    checkpoint('terminal-repeat-snapshot')
    assert s.positions == [(2, 6, 3), (1, 5, 1)]
    assert s.receipts == [(1, [7, 8]), (1, []), (2, [7, 8]), (1, []), (2, [])]
    assert (s.world_clock, s.tick, s.sync_calls, s.threshold, s.slots) == (1, 6, 5, 5, [0, None])
    return ''.join(chunks)


def render():
    return ('Workshop\n' + schema(1) + 'Garden\n' + schema(2) + '\n').encode()


def selftest():
    s = State(77)
    assert s.positions == [] and s.tick == 1 and s.sync_calls == 0
    s.dispatch()
    assert (s.world_clock, s.pending, s.tick, s.positions, s.receipts) == (1, 0, 1, [], [])
    s.threshold = None
    s.flags = [False, False]
    assert s.dispatch() == 'Finished:[Entered{readers}, Skipped{1}, Skipped{2}, Applied]'
    s.flags = [True, False]
    assert s.dispatch() == 'Failed:CheckError{MissingRuntimeRequirements{[Threshold]}}:[Entered{readers}]'
    assert s.tick == 1 and s.positions == []
    s.threshold = 5
    s.dispatch()
    before = (s.tick, list(s.positions), list(s.receipts), s.sync_calls)
    s.flags = [False, False]
    s.dispatch()
    assert before == (s.tick, s.positions, s.receipts, s.sync_calls)
    s.flags = [True, True]
    s.dispatch()
    assert s.positions == [(2, 4, 3), (1, 3, 1)]
    assert s.receipts[-2:] == [(1, []), (2, [7, 8])]
    raw = render()
    assert raw.endswith(b'\n\n')
    assert raw.count(b'Failed:CheckError{MissingRuntimeRequirements{[Threshold]}}:[Entered{readers}]') == 2
    assert raw.count(b'\napp=') == 22 and raw.count(b'snapshot=None') == 2
    assert all(line.count(b'{') == line.count(b'}') for line in raw.splitlines())


if __name__ == '__main__':
    import sys
    selftest()
    if '--selftest' not in sys.argv:
        sys.stdout.buffer.write(render())
