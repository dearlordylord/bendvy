"""Independent finite lazy checked-predicate state and full source projection."""

def listing(values):
    return '[' + ', '.join(values) + ']'


def boolean(value):
    return str(bool(value))


def pair(value):
    return f'node(leaf:{value},leaf:{value + 1})'


SCHEMA = listing(['Entry{Resource:' + name + ':' + name + '}' for name in ['Counter', 'Input', 'Sentinel']])
STEPS = ['Phase{checked}', 'System{1,0}', 'Barrier']
PLAN = 'Sequence{Entry{Phase{checked};needs=[]},Sequence{Entry{System{1,0};needs=[]},Entry{Barrier;needs=[]}}}'
OPTIONAL = 'Resource{Input;mode=Read;required=False}'
REQUIRED = 'Resource{Input;mode=Read;required=True}'
GUARD_SHAPE = 'And{Existing{name=True;access=[];leaves=[Constant{True}]},And{Check{presence-or-bypass},Check{required-positive}}}'
ERROR = 'CheckError{MissingRuntimeRequirements{[Input]}}'


def description(shape, uses):
    return 'description{shape=' + shape + ';uses=' + listing(uses) + '}'


def bound_description():
    return 'binding{systemId=1;' + description(GUARD_SHAPE, [OPTIONAL, REQUIRED]) + '}'


def probes():
    return ('probes{negOwner=False;neg=' + description('Not{Check{presence-or-bypass}}', [OPTIONAL])
            + ';skipOwner=True;skipRequiredOwner=Unit;skip='
            + description('Or{Constant{True},Check{required-positive}}', [REQUIRED])
            + ';reachedOwner=False;reachedRequiredOwner=Unit;reached='
            + description('Or{Constant{False},Check{required-positive}}', [REQUIRED]) + '}')


class State:
    def __init__(self, namespace, value, bypass):
        self.namespace = namespace
        self.value = value
        self.bypass = bypass
        self.counter = 10
        self.debug = False

    def identity(self):
        return f'namespace={self.namespace};id=1;name=increment;access=[Counter];cursor=0'

    def world(self):
        input_text = 'Missing' if self.value is None else 'Present{' + pair(self.value) + '}'
        return (f'world{{namespace={self.namespace};nextId=1;highWater=0;live=leaf:False;capacity=1;depth=0;store=Unit;resources={{Counter={pair(self.counter)};Input={input_text};Sentinel={pair(900)}}};events=[];pending=0;registrations=[1:increment:[Counter]];nextSystemId=2;clock=0}}')

    def guards(self):
        return ('guards{systemId=1;oldOwner=True;bypass=' + boolean(self.bypass)
                + ';requiredOwner=Unit;descriptions=' + listing([bound_description()]) + '}')

    def actual(self):
        fields = 'fields{' + self.identity() + ';slot=Counter;clauses=[Counter:Write];kind=Field}'
        return ('app{schema=' + SCHEMA + ';debug=' + boolean(self.debug)
                + ';recipe=Recipe;plan=' + PLAN + f';namespace={self.namespace};name=guarded-counter;steps='
                + listing(STEPS) + ';needs=[]|' + self.world()
                + '|owners{previous=Unit;token=Token;' + fields + '}|' + self.guards() + '}')

    def snapshot(self):
        if not self.debug:
            return 'None'
        binding = 'binding{' + self.identity() + ';slot=Counter;clauses=[Counter:Write]}'
        planned = ['planned{' + step + ';needs=[]}' for step in STEPS]
        return ('Some{schema=' + SCHEMA + ';bindings=' + listing([binding])
                + f';rows=Product{{Unit,{self.counter}}};rendered=[Counter={self.counter}];namespace={self.namespace};name=guarded-counter;steps='
                + listing(planned) + ';checkedBindings=' + listing([bound_description()]) + '}')

    def probe_results(self):
        neg = 'Done{' + boolean(self.value is None) + '}'
        reached = 'Fail{' + ERROR + '}' if self.value is None else 'Done{' + boolean(self.value > 0) + '}'
        return listing(['not(exists):' + neg, 'true.or(required):Done{True}', 'false.or(required):' + reached])

    def run(self):
        # Lifted true evaluates first. The optional existence leaf may short-circuit.
        if self.value is None:
            if self.bypass:
                return 'Failed:' + ERROR + ':[Entered{checked}]'
            return 'Finished:[Entered{checked}, Skipped{1}, Applied]'
        if self.value == 0:
            return 'Finished:[Entered{checked}, Skipped{1}, Applied]'
        self.counter += 1
        return 'Finished:[Entered{checked}, Ran{1}, Applied]'


def case(namespace, value, bypass):
    state = State(namespace, value, bypass)
    rows = []

    def snapshot(label):
        rows.append(label + '\n' + state.actual() + '\nprobes=' + probes() + '\nsnapshot=' + state.snapshot() + '\n')

    snapshot('disabled')
    state.debug = True
    snapshot('enabled')
    snapshot('enabled-repeat')
    rows.append('initial-probe-results=' + state.probe_results() + '\n')
    rows.append('run1=' + state.run() + '\n')
    snapshot('after-run1')
    rows.append('after-run1-probe-results=' + state.probe_results() + '\n')
    rows.append('run2=' + state.run() + '\n')
    snapshot('after-run2')
    rows.append('final-probe-results=' + state.probe_results() + '\n')
    snapshot('terminal')
    return ''.join(rows)


def render():
    sections = []
    for name, base in [('Workshop', 1), ('Garden', 5)]:
        sections.append(name + '\n')
        for offset, (label, value, bypass) in enumerate([
                ('missing-skipped', None, False), ('zero', 0, False),
                ('positive', 5, False), ('missing-reached', None, True)]):
            sections.append(label + '\n' + case(base + offset, value, bypass))
    return (''.join(sections) + '\n').encode()


def selftest():
    raw = render()
    assert raw.endswith(b'\n\n')
    assert raw.count(b'run1=Finished:[Entered{checked}, Ran{1}, Applied]') == 2
    assert raw.count(b'run2=Failed:' + ERROR.encode() + b':[Entered{checked}]') == 2
    assert raw.count(b'false.or(required):Fail{') == 12
    assert raw.count(b'snapshot=None') == 8
    assert raw.count(b'rows=Product{Unit,12}') == 4


if __name__ == '__main__':
    import sys
    selftest()
    if '--selftest' not in sys.argv:
        sys.stdout.buffer.write(render())
