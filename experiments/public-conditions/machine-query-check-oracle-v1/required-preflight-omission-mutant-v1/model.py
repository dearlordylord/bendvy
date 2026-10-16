"""Independent required-machine preflight omission countermodel and full wire."""
from dataclasses import dataclass, field
import query_model as query
from query_model import listing, cons


@dataclass
class Machine:
    current: int | None = None
    pending: int | None = None
    previous: int | None = None
    revision: int = 0
    batches: list = field(default_factory=list)

    def text(self):
        if self.current is None:
            slot = 'Missing'
        else:
            pending = 'none' if self.pending is None else f'queued:{self.pending}:False'
            previous = 'none' if self.previous is None else str(self.previous)
            slot = f'Present{{current={self.current};next={pending};previous={previous};changed=True}}'
        back = listing([f'{tick}:1:[{event}]' for tick, event in reversed(self.batches)])
        count = len(self.batches)
        return (f'MachineState{{slot={slot};stream=[]:{back}:{count}:0:{count}:[]:0;revision={self.revision}}}')


OWNERS = 'transitionOwners{exit=[];transition=[];enter=[]}'


class State(query.State):
    def __init__(self, namespace):
        super().__init__(namespace)
        self.machine = Machine()
        self.states = []
        self.bypass = False
        self.history = []

    def binding(self):
        uses = ['Machine{Mode;mode=Read;required=False}']
        for selection, key in [('Required', 'Primary'), ('Optional', 'Bonus'), ('With', 'Active'), ('Without', 'Hidden')]:
            uses.append('Component{' + selection + ';key=' + key + ';mode=Read;required=False}')
        uses.extend(['Resource{Threshold;mode=Read;required=True}', 'Machine{Mode;mode=Read;required=True}'])
        return ('binding{systemId=1;description{shape=And{Check{machine-presence-or-bypass},Check{query-threshold-mode}};uses='
                + listing(uses) + '}}')

    def world(self):
        text = super().world()
        base = f'Counter={query.pair(self.counter)};Threshold={self.slot(self.threshold)};Sentinel={query.pair(900)}'
        old = 'resources={' + base + '}'
        new = 'resources={Base={' + base + '};machine={' + self.machine.text() + '}}'
        assert old in text
        return text.replace(old, new)

    def actual(self):
        text = super().actual()
        old = 'presenceOwner=Unit;joinedOwner=Unit;'
        new = f'optionalMachineOwner={self.bypass};requiredJoinedOwner=Unit;'
        assert old in text
        return text.replace(old, new)

    def views(self):
        view = 'Unavailable' if self.machine.current is None else f'Current{{{self.machine.current}}}'
        return 'views{query=' + self.readout() + ';machine=' + view + '}'

    def dispatch(self):
        if self.machine.current is None and not self.bypass:
            allowed = False
        elif self.machine.current is None:
            allowed = False  # Reached body reads Unavailable after omitted admission.
        else:
            rows = self.joined()
            allowed = bool(rows and rows[0][1] > self.threshold and self.machine.current == 0)
        if allowed:
            self.counter += 1
            self.cursor = self.clock
        self.history.append((self.counter, self.cursor, self.clock, allowed))
        return 'Finished:[Entered{checked}, ' + ('Ran{1}' if allowed else 'Skipped{1}') + ', Applied]'

    def insert(self, value):
        self.clock += 1
        self.machine.current = value
        self.machine.revision += 1
        self.machine.batches.append((self.clock, 'initial:' + str(value)))

    def queue(self, value):
        assert self.machine.current is not None
        self.machine.pending = value

    def apply(self):
        current, pending = self.machine.current, self.machine.pending
        assert current is not None and pending is not None
        self.machine.previous = current
        self.machine.current = pending
        self.machine.pending = None
        self.machine.revision += int(current != pending)
        self.clock += 1
        self.machine.batches.append((self.clock, f'{current}>{pending}'))
        captured = f'Scheduled{{value={pending};skipSame=False}}'
        return f'transition{{captured={captured};Completed|{OWNERS}|' + self.world() + '}'

    def exchange(self, incoming):
        previous = self.machine
        self.machine = incoming
        self.states.insert(0, previous)


def schema(namespace):
    s = State(namespace)
    rows = []

    def checkpoint(label):
        rows.append(label + '\nreadout=' + s.views() + '\napp=' + s.actual()
                    + '\nsetup=' + s.setup() + '\nreturnedStates=' + cons([m.text() for m in s.states])
                    + '\ntransitionOwners=' + OWNERS + '\nsnapshot=' + s.snapshot() + '\n')

    def dispatch():
        rows.append(s.dispatch() + '\n')

    def queue(value):
        s.queue(value)
        rows.append('QueueSuccess\n')

    def apply():
        rows.append('Applied:' + s.apply() + '\n')

    checkpoint('missing-disabled')
    s.debug = True
    rows.append('Enabled\n')
    s.populate()
    rows.append('Populated\n')
    dispatch()
    checkpoint('missing-lazy-skipped')
    s.insert(0)
    rows.append('Inserted:0\n')
    dispatch()
    checkpoint('mode0-true')
    queue(1)
    checkpoint('queued1-current0')
    dispatch()
    checkpoint('queued1-still-true')
    apply()
    checkpoint('mode1-applied')
    dispatch()
    checkpoint('mode1-false')
    queue(0)
    checkpoint('queued0-current1')
    apply()
    checkpoint('mode0-applied')
    dispatch()
    checkpoint('mode0-true-again')
    s.exchange(Machine())
    rows.append('MachineStateExchanged\n')
    checkpoint('removed-state-returned')
    dispatch()
    s.bypass = True
    rows.append('ExplicitRequiredBypassEnabled\n')
    dispatch()
    checkpoint('required-missing-refused')
    s.exchange(s.states.pop(0))
    rows.append('MachineStateExchanged\n')
    dispatch()
    checkpoint('terminal-restored-mode0')
    assert (s.counter, s.cursor, s.clock) == (14, 15, 15)
    assert (s.machine.current, s.machine.previous, s.machine.revision) == (0, 1, 3)
    assert s.machine.batches == [(13, 'initial:0'), (14, '0>1'), (15, '1>0')]
    assert s.states == [Machine()]
    assert [row[3] for row in s.history] == [False, True, True, False, True, False, False, True]
    return ''.join(rows)


def render():
    return ('Workshop\n' + schema(1) + 'Garden\n' + schema(2) + '\n').encode()


def selftest():
    from state_model import selftest as query_checks
    query_checks()
    m = Machine()
    assert m.text() == 'MachineState{slot=Missing;stream=[]:[]:0:0:0:[]:0;revision=0}'
    s = State(77)
    s.populate()
    assert s.clock == 12
    s.insert(0)
    before = (s.clock, s.machine.revision, s.machine.current)
    s.queue(1)
    assert before == (s.clock, s.machine.revision, s.machine.current)
    assert s.machine.pending == 1
    s.apply()
    assert (s.clock, s.machine.revision, s.machine.current, s.machine.pending) == (14, 2, 1, None)
    raw = render()
    assert raw.endswith(b'\n\n')
    assert raw.count(b'Failed:CheckError{MissingRuntimeRequirements{[Mode]}}:[Entered{checked}]') == 0
    assert raw.count(b'Finished:[Entered{checked}, Ran{1}, Applied]') == 8
    assert raw.count(b'Finished:[Entered{checked}, Skipped{1}, Applied]') == 8
    assert raw.count(b'Applied:transition{captured=Scheduled{') == 4
    assert raw.count(b'snapshot=None') == 2


if __name__ == '__main__':
    import sys
    selftest()
    if '--selftest' not in sys.argv:
        sys.stdout.buffer.write(render())
