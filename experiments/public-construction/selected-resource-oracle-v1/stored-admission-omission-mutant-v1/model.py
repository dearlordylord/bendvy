"""Source-derived final-admission omission counter and full fallback trace."""
from dataclasses import dataclass


def listing(values):
    return '[' + ', '.join(values) + ']'


def tree(seed):
    return f'node(leaf:{seed},leaf:{seed + 1})'


def raw(namespace, value):
    atom = f'Number{{{value}}}' if isinstance(value, int) else 'Text{' + value + '}'
    return 'Object{value:' + atom + f',handle:Handle{{{namespace},1}},' + '}'


@dataclass(frozen=True)
class Input:
    namespace: int
    value: object
    mode: str
    seed: int

    def text(self):
        return 'Input{raw=' + raw(self.namespace, self.value) + ';mode=' + self.mode + ';owned=' + tree(self.seed) + '}'


@dataclass(frozen=True)
class Payload:
    namespace: int
    value: object
    origin: object
    mode: str
    seed: int

    def text(self):
        return ('Payload{raw=' + raw(self.namespace, self.value) + ';origin=' + raw(self.namespace, self.origin)
                + ';mode=' + self.mode + ';owned=' + tree(self.seed) + '}')


@dataclass(frozen=True)
class Output:
    tag: str
    owner: object
    error: str = ''

    def text(self):
        if self.tag == 'Refused':
            return 'Refused{' + self.owner.text() + ';error=' + self.error + '}'
        if self.tag == 'AdmissionRefused':
            return 'AdmissionRefused{cooked=' + self.owner.text() + ';undo=opaque-retained;error=' + self.error + '}'
        return 'Applied{canonical=' + self.owner + ';undo=opaque-retained}'


def invalid(actual):
    return 'Invalid{path=$.value;expected=integer;actual=Text{' + actual + '}}'


SCHEMA = listing(['Entry{Resource:' + key + ':' + key + '}' for key in ['Target', 'Sibling', 'Other']])


class Model:
    def __init__(self, namespace):
        self.namespace = namespace
        self.debug = False
        self.target = Payload(namespace, 100, 100, 'Valid', 100)
        self.sibling = Payload(namespace, 800, 800, 'Valid', 800)
        self.inputs = []
        self.outputs = []
        self.clock = 0
        self.cursor = 0
        self.pending = 1
        self.construct_calls = 0
        self.install_calls = 0

    def context(self):
        codec = 'Struct{value:Integer,handle:HandleValue{' + str(self.namespace) + '},}'
        return f'Context{{namespace={self.namespace};factory{{identityKey=Target;storedCodec=' + codec + ';inputCodec=' + codec + '}}'

    def identity(self):
        return f'namespace={self.namespace};id=1;name=construct-target;access=[Target];cursor={self.cursor}'

    def world(self):
        return (f'world{{namespace={self.namespace};nextId=1;highWater=0;live=leaf:False;capacity=1;depth=0;store={tree(700)}'
                + ';resources={Target=' + self.target.text() + ';Sibling=' + self.sibling.text()
                + ';Other=Other{owned=node(leaf:True,leaf:False);label=unlike}};events=[];pending='
                + str(self.pending) + ';registrations=[1:construct-target:[Target]];nextSystemId=2;clock=' + str(self.clock) + '}')

    def app(self):
        return ('app{schema=' + SCHEMA + f';debug={self.debug};recipe=Recipe;' + self.world()
                + ';owners{previous=Unit;token=Token;fields{' + self.identity() + ';slot=constructed;clauses=[Target:Write];kind=Field}}}')

    def snapshot(self):
        if not self.debug:
            return 'None'
        binding = 'binding{' + self.identity() + ';slot=constructed;clauses=[Target:Write]}'
        return ('Some{schema=' + SCHEMA + ';bindings=' + listing([binding]) + ';rows=Product{Unit,'
                + str(self.target.value if isinstance(self.target.value, int) else 0) + '};rendered=' + listing(['Target=' + str(self.target.value if isinstance(self.target.value, int) else 0)]) + '}')

    def dispatch(self, request):
        # Decode validates the original owner before invoking the constructor.
        if not isinstance(request.value, int):
            result = Output('Refused', request, 'Validation{' + invalid(request.value) + '}')
        else:
            self.construct_calls += 1
            if request.mode == 'ConstructorReject':
                result = Output('Refused', request, 'Constructor{ConstructorStopped}')
            else:
                cooked = Payload(request.namespace, 'invalid-stored' if request.mode == 'AdmissionReject' else request.value,
                                 request.value, request.mode, request.seed)
                # Actual mutant projects the same cooked owner directly into Accepted.
                self.target = cooked
                self.install_calls += 1
                result = Output('Applied', raw(cooked.namespace, cooked.value))
        self.outputs.insert(0, result)
        # run_tracked copies the current clock; this body never advances it.
        self.cursor = self.clock
        return 'Completed\n'

    def checkpoint(self, label):
        assert self.pending == 1 and self.clock == self.cursor == 0
        return (label + '\ncontext=' + self.context() + '\napp=' + self.app()
                + '\ninputs=' + ''.join(value.text() + ';' for value in self.inputs) + '[]'
                + '\noutputs=' + ''.join(value.text() + ';' for value in self.outputs) + '[]'
                + '\nsnapshot=' + self.snapshot() + '\n')


def schema(namespace):
    s = Model(namespace)
    report = [s.checkpoint('disabled')]
    s.debug = True
    report += ['Enabled\n', s.checkpoint('enabled')]
    report += [s.dispatch(Input(namespace, 'invalid-input', 'Valid', 10)), s.checkpoint('invalid-input-returned')]
    report += [s.dispatch(Input(namespace, 20, 'ConstructorReject', 20)), s.checkpoint('constructor-refused-input-returned')]
    report += [s.dispatch(Input(namespace, 30, 'AdmissionReject', 30)), s.checkpoint('stored-admission-refused-cooked-before-undo')]
    # Scenario undo only accepts AdmissionRefused at the head. Applied falls back
    # without consuming any owner; retry sees the actual empty input list.
    assert s.outputs[0].tag == 'Applied' and s.inputs == []
    report += ['UnexpectedUndoShape\n', s.checkpoint('actual-original-input-after-undo')]
    report += ['UnexpectedRetryShape\n', s.checkpoint('actual-returned-owner-retry-success'), s.checkpoint('terminal-repeat-snapshot')]
    assert s.target == Payload(namespace, 'invalid-stored', 30, 'AdmissionReject', 30)
    assert s.inputs == [] and [o.tag for o in s.outputs] == ['Applied', 'Refused', 'Refused']
    assert s.construct_calls == 2 and s.install_calls == 1
    return ''.join(report)


def render():
    return ('Workshop\n' + schema(1) + 'Garden\n' + schema(2) + '\n').encode()


def selftest():
    raw_output = render()
    assert raw_output.endswith(b'\n\n')
    assert raw_output.count(b'\napp=') == 16
    assert raw_output.count(b'Completed\n') == 6
    assert raw_output.count(b'UnexpectedUndoShape\n') == 2
    assert raw_output.count(b'UnexpectedRetryShape\n') == 2
    assert raw_output.count(b'snapshot=None') == 2
    assert raw_output.count(b'pending=1;') == 16
    assert raw_output.count(b';clock=0}') == 16
    assert b'RegistrationRejected\n' not in raw_output
    assert all(line.count(b'{') == line.count(b'}') for line in raw_output.splitlines())


if __name__ == '__main__':
    import sys
    selftest()
    if '--selftest' not in sys.argv:
        sys.stdout.buffer.write(render())
