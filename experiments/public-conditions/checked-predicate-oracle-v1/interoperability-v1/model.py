"""Independent finite machine/checked-predicate interoperability trace."""

def listing(values):
    return '[' + ', '.join(values) + ']'


def pair(value):
    return f'node(leaf:{value},leaf:{value + 1})'


SCHEMA = listing(['Entry{Resource:' + x + ':' + x + '}' for x in ['Counter', 'Input', 'MachineBacking']])
STEPS = ['Phase{checked}', 'System{1,0}', 'System{2,0}', 'Barrier']
PLAN = 'Sequence{Entry{Phase{checked};needs=[]},Sequence{Entry{System{1,0};needs=[]},Sequence{Entry{System{2,0};needs=[]},Entry{Barrier;needs=[]}}}}'


class State:
    def __init__(self, namespace):
        self.namespace = namespace
        self.counter = 10
        self.debug = False
        self.clock = 0
        self.current = None
        self.revision = 0
        self.condition_revision = 0
        self.condition_cursor = 0
        self.a_cursor = 0
        self.b_cursor = 0
        self.stale = False

    def identity(self, id, name, cursor):
        return f'namespace={self.namespace};id={id};name={name};access=[Counter];cursor={cursor}'

    def condition_description(self):
        old = (f'name=mode-changed;access=[machine.Mode.changed];leaves=[StateChanged{{namespace={self.namespace};id=3;name=mode-changed;access=[machine.Mode.changed]}}]')
        return ('description{shape=And{Existing{' + old
                + '},And{Check{presence-or-bypass},Check{required-positive}}};uses=[Resource{Input;mode=Read;required=False}, Resource{Input;mode=Read;required=True}]}')

    def binding(self):
        return 'binding{systemId=1;' + self.condition_description() + '}'

    def machine(self):
        if self.current is None:
            slot = 'Missing'
            stream = '[]:[]:0:0:0:[]:0'
        else:
            slot = f'Present{{current={self.current};next=none;previous=none;changed=True}}'
            stream = f'[]:[{self.clock}:1:[initial:{self.current}]]:1:0:1:[]:0'
        return 'Machine{slot=' + slot + ';stream=' + stream + f';revision={self.revision}}}'

    def world(self):
        registrations = ['2:unbound-B:[Counter]', '1:bound-A:[Counter]']
        if not self.stale:
            registrations.insert(0, '3:mode-changed:[machine.Mode.changed]')
        return (f'world{{namespace={self.namespace};nextId=1;highWater=0;live=leaf:False;capacity=1;depth=0;store=Unit;resources={{Counter={pair(self.counter)};Input=Present{{{pair(5)}}};'
                + self.machine() + '};events=[];pending=0;registrations=' + listing(registrations)
                + f';nextSystemId=4;clock={self.clock}}}')

    def fields(self, id, name, cursor):
        return 'fields{' + self.identity(id, name, cursor) + ';slot=Counter;clauses=[Counter:Write];kind=Field}'

    def actual(self):
        own = ('owners{previous=Unit;A=' + self.fields(1, 'bound-A', self.a_cursor)
               + ';B=' + self.fields(2, 'unbound-B', self.b_cursor) + ';tokens=Token,Token}')
        guard = (f'guards{{systemId=1;machineRegistry={self.namespace}:3:mode-changed:[machine.Mode.changed];cursor={self.condition_cursor};revision={self.condition_revision};bypass=False;requiredOwner=Unit;descriptions='
                 + listing([self.binding()]) + '}')
        return ('app{schema=' + SCHEMA + f';debug={self.debug};recipe=Recipe;plan=' + PLAN
                + f';namespace={self.namespace};name=machine-check-unbound;steps=' + listing(STEPS)
                + ';needs=[]|' + self.world() + '|' + own + '|' + guard + '}')

    def snapshot(self):
        if not self.debug:
            return 'None'
        bindings = ['binding{' + self.identity(id, name, cursor) + ';slot=Counter;clauses=[Counter:Write]}'
                    for id, name, cursor in [(1, 'bound-A', self.a_cursor), (2, 'unbound-B', self.b_cursor)]]
        return ('Some{schema=' + SCHEMA + ';bindings=' + listing(bindings)
                + f';rows=Product{{Product{{Unit,{self.counter}}},{self.counter}}};rendered=[Counter={self.counter}, Counter={self.counter}];namespace={self.namespace};name=machine-check-unbound;steps='
                + listing(['planned{' + x + ';needs=[]}' for x in STEPS])
                + ';checkedBindings=' + listing([self.binding()]) + '}')

    def insert(self, value):
        self.clock += 1
        self.current = value
        self.revision += 1

    def run(self):
        if self.stale:
            return 'Failed:ConditionRegistrationRejected:[Entered{checked}]'
        allowed = self.current is not None and self.condition_revision < self.revision
        self.condition_revision = self.revision
        self.condition_cursor = self.clock
        if allowed:
            # Input exists and its value is five, so both checked leaves pass.
            self.counter += 1
            self.a_cursor = self.clock
        self.counter += 1
        self.b_cursor = self.clock
        return 'Finished:' + listing(['Entered{checked}', 'Ran{1}' if allowed else 'Skipped{1}', 'Ran{2}', 'Applied'])


def schema(namespace):
    state = State(namespace)
    rows = []

    def snapshot(label):
        rows.append(label + '|' + state.actual() + '\nsnapshot=' + state.snapshot() + '\n')

    def run(label):
        snapshot(label + ':' + state.run())

    snapshot('disabled')
    state.debug = True
    snapshot('enabled')
    run('missing-machine-A-skips-B-runs')
    state.insert(0)
    snapshot('insert:0')
    run('changed-A-and-B')
    run('unchanged-A-skips-B-runs')
    state.insert(1)
    snapshot('insert:1')
    run('changed-again')
    state.stale = True
    snapshot('remove-actual-condition:True')
    run('stale-lifted-registration')
    assert (state.counter, state.clock, state.a_cursor, state.b_cursor,
            state.condition_cursor, state.condition_revision) == (16, 2, 2, 2, 2, 2)
    return ''.join(rows)


def render():
    return ('Workshop\n' + schema(1) + 'Garden\n' + schema(2) + '\n').encode()


def selftest():
    raw = render()
    assert raw.endswith(b'\n\n') and raw.count(b'\n') == 43
    assert raw.count(b'stale-lifted-registration:Failed:ConditionRegistrationRejected:[Entered{checked}]') == 2
    assert raw.count(b'snapshot=None') == 2
    assert b'NoValue' not in raw


if __name__ == '__main__':
    import sys
    selftest()
    if '--selftest' not in sys.argv:
        sys.stdout.buffer.write(render())
