"""Independent finite ECS outcome and detached copied trace delivery model."""
from dataclasses import dataclass, field


def listing(values):
    return '[' + ', '.join(values) + ']'


def array(first, second):
    return f'node(leaf:{first},leaf:{second})'


SCHEMA = listing(['Entry{Resource;key=' + k + ';name=' + k + '}' for k in ['Counter', 'Sibling']])
STEPS = ['Phase{observed}', 'System{1;condition=0}', 'Barrier', 'System{2;condition=1}', 'System{3;condition=0}', 'Barrier']
NAMES = {1: 'success', 2: 'skip', 3: 'failure'}
ERROR = 'expected-body-failure'
OBSERVATIONS = listing(['Entered{observed}', 'Ran{1}', 'Applied', 'Skipped{2}', 'Ran{3}'])


def plan(steps):
    entries = ['Entry{' + step + ';requirements=[]}' for step in steps]
    result = entries[-1]
    for item in reversed(entries[:-1]):
        result = 'Sequence{' + item + ';' + result + '}'
    return result


@dataclass
class Collector:
    first: int
    second: int
    calls: int = 0
    events: list = field(default_factory=list)

    def text(self):
        return f'collector{{calls={self.calls};events=' + listing(self.events) + ';owned=' + array(self.first, self.second) + '}'

    def deliver(self, batch):
        for event in batch:
            self.events.append(event)
            self.calls += 1
            self.first += 1


class Model:
    def __init__(self, namespace):
        self.namespace = namespace
        self.debug = False
        self.counter = 10
        self.clock = 0
        self.pending = 1
        self.cursors = [0, 0, 0]
        self.subscriber = Collector(100, 200)
        self.returned = []
        self.batch = None
        self.status = 'registered'

    def identity(self, ident):
        return f'namespace={self.namespace};id={ident};name={NAMES[ident]};access=[Counter];cursor={self.cursors[ident - 1]}'

    def fields(self, ident):
        return 'fields{' + self.identity(ident) + ';slot=Counter;clauses=[Clause{Counter;mode=Write}];kind=Field}'

    def world(self):
        registrations = listing([f'{i}:{NAMES[i]}:[Counter]' for i in [3, 2, 1]])
        return (f'world{{namespace={self.namespace};nextId=1;highWater=0;live=leaf:False;capacity=1;depth=0;store=' + array(700, 701)
                + ';resources={Counter=' + array(self.counter, self.counter + 1) + ';Sibling=' + array(900, 901)
                + f'}};events=[];pending={self.pending};registrations=' + registrations + f';nextSystemId=4;clock={self.clock}}}')

    def app(self):
        owners = 'owners{previous=Unit;' + ';'.join(label + '=owner{token=Token;' + self.fields(i) + '}'
                                                   for label, i in [('first', 1), ('second', 2), ('third', 3)]) + '}'
        return ('app{schema=' + SCHEMA + f';debug={self.debug};recipe=Recipe;plan=' + plan(STEPS)
                + f';namespace={self.namespace};name=deferred-trace;steps=' + listing(STEPS) + ';needs=[];' + self.world() + ';' + owners + '}')

    def snapshot(self):
        if not self.debug:
            return 'None'
        bindings = listing(['binding{' + self.identity(i) + ';slot=Counter;clauses=[Clause{Counter;mode=Write}]}' for i in [1, 2, 3]])
        v = str(self.counter)
        return ('Some{schema=' + SCHEMA + ';bindings=' + bindings + ';rows=Product{Product{Product{Unit,' + v + '},' + v + '},' + v
                + '};rendered=' + listing(['Counter=' + v] * 3) + f';namespace={self.namespace};name=deferred-trace;steps='
                + listing(['PlannedStep{' + step + ';requirements=[]}' for step in STEPS]) + '}')

    def events(self, first_before, first_after, failed_before, failed_after):
        def completed(ident, before, after, result):
            return (f'SystemCompleted{{identity{{namespace={self.namespace};id={ident};name=Some{{{NAMES[ident]}}}}};before={before};after={after};status=' + result + '}')
        return [f'ScheduleStarted{{namespace={self.namespace};name=deferred-trace}}', 'PhaseEntered{name=observed}',
                completed(1, first_before, first_after, 'SystemOk'), 'DeferredApplied', 'SystemSkipped{id=2}',
                completed(3, failed_before, failed_after, 'SystemError{error=' + ERROR + '}'),
                'ScheduleEnded{outcome=EndFailed{error=' + ERROR + '}}']

    def run(self):
        before = self.clock
        self.counter += 1
        self.cursors[0] = self.clock
        first_after = self.clock
        self.clock += self.pending
        self.pending = 0
        # Skipped ID2 never invokes body. ID3 replacement is undone on failure;
        # its tracked cursor remains previous0, while the first commit persists.
        failure_clock = self.clock
        self.batch = self.events(before, first_after, failure_clock, failure_clock) if self.debug else None
        self.status = 'Failed:' + ERROR + ':' + OBSERVATIONS
        return 'RunCompleted\n'

    def checkpoint(self, label):
        subscriber = 'None' if self.subscriber is None else 'Some(subscriber{' + self.subscriber.text() + '})'
        return (label + '\napp=' + self.app() + '\nsubscriber=' + subscriber
                + '\nreturned=' + ''.join(c.text() + ';' for c in self.returned) + '[]'
                + '\nbatch=' + ('Disabled' if self.batch is None else 'Ready{events=' + listing(self.batch) + '}')
                + '\nstatus=' + self.status + '\nsnapshot=' + self.snapshot() + '\n')


def schema(namespace):
    s = Model(namespace)
    report = [s.checkpoint('disabled-before'), s.run(), s.checkpoint('disabled-ECS-completed-before-delivery')]
    assert s.subscriber.calls == 0 and s.counter == 11 and s.clock == 1 and s.cursors == [0, 0, 0]
    report += ['DeliveryReturned\n', s.checkpoint('disabled-delivery-bypassed')]
    s.debug = True
    report += ['Enabled\n', s.checkpoint('enabled-before'), s.run(), s.checkpoint('enabled-ECS-completed-before-delivery')]
    before_world = s.world(), list(s.cursors)
    s.subscriber.deliver(s.batch)
    assert before_world == (s.world(), s.cursors)
    report += ['DeliveryReturned\n', s.checkpoint('enabled-delivery-returned')]
    s.returned.insert(0, s.subscriber)
    s.subscriber = Collector(300, 400)
    s.status = 'ResetReturnedOwner'
    report += ['ResetReturnedOwner\n', s.checkpoint('reset-displaced-owner'), s.run(), s.checkpoint('repeated-ECS-completed-before-delivery')]
    s.subscriber.deliver(s.batch)
    report += ['DeliveryReturned\n', s.checkpoint('repeated-delivery-returned')]
    s.returned.insert(0, s.subscriber)
    s.subscriber = None
    s.status = 'UnsubscribeReturnedOwner'
    report += ['UnsubscribeReturnedOwner\n', s.checkpoint('unsubscribe-returned-owner'), s.checkpoint('terminal-repeat')]
    assert s.counter == 13 and s.clock == 1 and s.pending == 0 and s.cursors == [1, 0, 0]
    assert [(c.first, c.second, c.calls) for c in s.returned] == [(307, 400, 7), (107, 200, 7)]
    assert all(c.events == s.batch for c in s.returned)
    return ''.join(report)


def render():
    return ('Workshop\n' + schema(1) + 'Garden\n' + schema(2) + '\n').encode()


def selftest():
    raw = render()
    assert raw.count(b'\napp=') == 22
    assert raw.count(b'RunCompleted\n') == 6
    assert raw.count(b'snapshot=None') == 6
    assert raw.count(b'DeliveryReturned\n') == 6
    assert raw.endswith(b'\n\n')
    assert b'EndFailed{error=expected-body-failure}' in raw
    assert b'EndOk' not in raw and b'Ran{3}' in raw
    assert all(line.count(b'{') == line.count(b'}') for line in raw.splitlines())


if __name__ == '__main__':
    import sys
    selftest()
    if '--selftest' not in sys.argv:
        sys.stdout.buffer.write(render())
