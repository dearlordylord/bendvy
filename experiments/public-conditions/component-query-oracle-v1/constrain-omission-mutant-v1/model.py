"""Independent component-query condition trace and physical tree projection."""
from state_model import State as Logical


def listing(xs):
    return '[' + ', '.join(xs) + ']'


def cons(xs):
    return '[]' if not xs else 'cons(' + xs[0] + ',' + cons(xs[1:]) + ')'


def tree(xs):
    if len(xs) == 1:
        return 'leaf:' + xs[0]
    middle = len(xs) // 2
    return 'node(' + tree(xs[:middle]) + ',' + tree(xs[middle:]) + ')'


def pair(value):
    return tree([str(value), str(value + 1)])


SCHEMA = listing(['Entry{Component:' + x + ':' + x + '}' for x in ['Primary', 'Bonus', 'Active', 'Hidden']]
                 + ['Entry{Resource:' + x + ':' + x + '}' for x in ['Counter', 'Threshold', 'Sentinel']])
STEPS = ['Phase{checked}', 'System{1,0}', 'Barrier']
PLAN = 'Sequence{Entry{Phase{checked};needs=[]},Sequence{Entry{System{1,0};needs=[]},Entry{Barrier;needs=[]}}}'


class State(Logical):
    def __init__(self, namespace):
        super().__init__()
        self.namespace = namespace
        self.debug = False
        self.threshold = 5
        self.slots = []

    def ident(self):
        return f'namespace={self.namespace};id=1;name=increment;access=[Counter];cursor={self.cursor}'

    def binding(self):
        uses = []
        for selection, key in [('With', 'Active'), ('Required', 'Primary'), ('Optional', 'Bonus'), ('With', 'Active'), ('Without', 'Hidden')]:
            uses.append('Component{' + selection + ';key=' + key + ';mode=Read;required=False}')
        uses.append('Resource{Threshold;mode=Read;required=True}')
        return ('binding{systemId=1;description{shape=And{Check{any_with_Active},Check{joined-positive}};uses='
                + listing(uses) + '}}')

    def column(self, family):
        entries = [(ident, row[family]) for ident, row in self.entities.items() if family in row]
        size = 1
        while entries and size < entries[-1][0]:
            size *= 2
        payloads = ['none'] * size
        stamps = []
        for ident, (value, clock) in entries:
            payloads[ident - 1] = 'some(' + ('Unit' if value is None else pair(value[0])) + ')'
            stamps.insert(0, f'{ident}:{clock}:{clock}')
        return 'Column{values=' + tree(payloads) + ';stamps=' + listing(stamps) + '}'

    def slot(self, value):
        return 'Missing' if value is None else 'Present{' + pair(value) + '}'

    def world(self):
        populated = bool(self.entities)
        live = tree(['False', 'True', 'True', 'True', 'True', 'True', 'False', 'False']) if populated else 'leaf:False'
        store = ';'.join(family + '={' + self.column(family) + '}' for family in ['Primary', 'Bonus', 'Active', 'Hidden'])
        return (f'world{{namespace={self.namespace};nextId={6 if populated else 1};highWater={5 if populated else 0};live={live};capacity={8 if populated else 1};depth={3 if populated else 0};store={{'
                + store + f'}};resources={{Counter={pair(self.counter)};Threshold={self.slot(self.threshold)};Sentinel={pair(900)}}};events=[];pending=0;registrations=[1:increment:[Counter]];nextSystemId=2;clock={self.clock}}}')

    def actual(self):
        fields = 'fields{' + self.ident() + ';slot=Counter;clauses=[Counter:Write];kind=Field}'
        return ('app{schema=' + SCHEMA + f';debug={self.debug};recipe=Recipe;plan=' + PLAN
                + f';namespace={self.namespace};name=guarded-counter;steps=' + listing(STEPS)
                + ';needs=[]|' + self.world() + '|owners{previous=Unit;token=Token;' + fields
                + '}|guards{systemId=1;presenceOwner=Unit;joinedOwner=Unit;descriptions=' + listing([self.binding()]) + '}}')

    def snapshot(self):
        if not self.debug:
            return 'None'
        binding = 'binding{' + self.ident() + ';slot=Counter;clauses=[Counter:Write]}'
        return ('Some{schema=' + SCHEMA + ';bindings=' + listing([binding])
                + f';rows=Product{{Unit,{self.counter}}};rendered=[Counter={self.counter}];namespace={self.namespace};name=guarded-counter;steps='
                + listing(['planned{' + x + ';needs=[]}' for x in STEPS]) + ';checkedBindings=' + listing([self.binding()]) + '}')

    def readout(self):
        joined = []
        for ident, value, bonus in self.joined():
            bonus_text = 'ComponentAbsent' if bonus is None else 'Found{' + str(bonus[0]) + '}'
            joined.append(f'row{{handle={self.namespace}:{ident};RowView{{primary=Found{{{value}}};bonus={bonus_text}}}}}')
        presence = [f'row{{handle={self.namespace}:{ident};value=Unit}}' for ident in self.presence()]
        threshold = 'None' if self.threshold is None else 'Some{' + str(self.threshold) + '}'
        return 'readout{joined=' + listing(joined) + ';presence=' + listing(presence) + ';threshold=' + threshold + '}'

    def setup(self):
        if not self.entities:
            return 'None'
        facts = []
        for tag, value in self.facts:
            if tag == 'Reserved':
                facts.append(f'Reserve:Reserved{{{self.namespace}:{value}}}')
            elif tag == 'Activated':
                facts.append('Activate:Accepted')
            else:
                facts.append('Replaced{' + value + '}')
        return ('Some{setup{handles=' + listing([f'{self.namespace}:{id}' for id in self.entities])
                + ';returnedArrays=' + cons(['none'] * len(self.array_receipts))
                + ';returnedUnits=' + cons(['none'] * len(self.unit_receipts)) + ';facts=' + listing(facts) + '}}')

    def exchange(self, incoming):
        previous = self.threshold
        self.threshold = incoming
        self.slots.insert(0, previous)

    def dispatch(self):
        if not self.presence():
            return 'Finished:[Entered{checked}, Skipped{1}, Applied]'
        if self.threshold is None:
            return 'Failed:CheckError{MissingRuntimeRequirements{[Threshold]}}:[Entered{checked}]'
        allowed = self.run(self.threshold)
        return 'Finished:[Entered{checked}, ' + ('Ran{1}' if allowed else 'Skipped{1}') + ', Applied]'


def schema(namespace):
    s = State(namespace)
    rows = []

    def checkpoint(label):
        slots = ''.join(s.slot(value) + ';' for value in s.slots) + '[]'
        rows.append(label + '\nreadout=' + s.readout() + '\napp=' + s.actual()
                    + '\nsetup=' + s.setup() + '\nreturnedThresholdSlots=' + slots
                    + '\nsnapshot=' + s.snapshot() + '\n')

    def dispatch():
        rows.append(s.dispatch() + '\n')

    def exchange(value):
        s.exchange(value)
        rows.append('ThresholdExchanged\n')

    def restore():
        value = s.slots.pop(0)
        exchange(value)

    checkpoint('empty-disabled')
    s.debug = True
    rows.append('Enabled\n')
    checkpoint('empty-enabled')
    checkpoint('empty-enabled-repeat')
    dispatch()
    checkpoint('empty-skipped')
    exchange(50)
    s.populate()
    rows.append('Populated\n')
    checkpoint('populated-high-threshold')
    dispatch()
    checkpoint('threshold-false')
    restore()
    checkpoint('returned-threshold-restored')
    dispatch()
    checkpoint('threshold-true')
    dispatch()
    checkpoint('threshold-true-repeat')
    exchange(None)
    checkpoint('threshold-missing')
    dispatch()
    checkpoint('missing-refused')
    restore()
    checkpoint('returned-threshold-recovered')
    dispatch()
    checkpoint('terminal')
    assert (s.counter, s.cursor, s.clock, s.threshold, s.slots) == (13, 12, 12, 5, [None, 50])
    return ''.join(rows)


def render():
    return ('Workshop\n' + schema(1) + 'Garden\n' + schema(2) + '\n').encode()


def selftest():
    from state_model import selftest as logical_checks
    logical_checks()
    raw = render()
    assert raw.endswith(b'\n\n')
    assert raw.count(b'Failed:CheckError{MissingRuntimeRequirements{[Threshold]}}:[Entered{checked}]') == 2
    assert raw.count(b'Finished:[Entered{checked}, Ran{1}, Applied]') == 6
    assert raw.count(b'snapshot=None') == 2


if __name__ == '__main__':
    import sys
    selftest()
    if '--selftest' not in sys.argv:
        sys.stdout.buffer.write(render())
