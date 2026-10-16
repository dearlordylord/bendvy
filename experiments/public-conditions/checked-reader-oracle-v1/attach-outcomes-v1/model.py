"""Independent finite attach-refusal ownership model; no schedule execution."""
import reader_model as prior

class State(prior.State):
    def __init__(self, namespace):
        super().__init__(namespace)
        self.flags = [True, True]
        self.ids = [1, 2]
        self.debug = True

    def descriptions(self):
        return prior.listing([
            f'binding{{systemId={ident};description{{shape=And{{Constant{{{flag}}},Check{{Threshold-positive}}}};uses=[Resource{{Threshold;mode=Read;required=True}}]}}}}'
            for ident, flag in zip(self.ids, self.flags)
        ])

    def guards(self):
        return (f'guards{{firstId={self.ids[0]};firstOwner=Bool({self.flags[0]})&Unit;secondId={self.ids[1]};secondOwner=Bool({self.flags[1]})&Unit;descriptions='
                + self.descriptions() + '}')

    def snapshot(self):
        bindings = prior.listing(['binding{' + self.identity(i) + ';slot=Signal;clauses=[Signal:Read]}' for i in [1, 2]])
        return 'Some{schema=' + prior.SCHEMA + ';bindings=' + bindings + ';rows=Product{Product{Unit,Unit},Unit};rendered=[]}'

    def original(self):
        return 'original{schema=' + prior.SCHEMA + ';debug=True;recipe=Recipe;' + self.world() + ';' + self.packed() + ';' + self.guards() + '}'


def schema(namespace):
    s = State(namespace)
    chunks = []
    def checkpoint(label):
        chunks.append(label + '\n' + s.original() + '\nsnapshot=' + s.snapshot() + '\n')
        assert (s.pending, s.world_clock, s.tick, s.positions, s.receipts, s.sync_calls) == (1, 0, 1, [], [], 0)
    for category, ids in [('unsupported-plan', [1, 2]), ('missing-member', [1, 99]), ('duplicate-binding', [1, 1])]:
        if category != 'unsupported-plan':
            s.ids = ids
            s.flags = [False, True]
            chunks.append('BindingsReplaced\n')
        checkpoint('before-' + category)
        chunks.append('Invalid\n')
        checkpoint(category + '-returned')
        chunks.append('Invalid\n')
        checkpoint('terminal-duplicate-repeat' if category == 'duplicate-binding' else category + '-repeat')
    return ''.join(chunks)


def render():
    return ('Workshop\n' + schema(1) + 'Garden\n' + schema(2) + '\n').encode()


def selftest():
    raw = render()
    assert raw.count(b'Invalid\n') == 12
    assert raw.count(b'\noriginal{') == 18
    assert raw.count(b'BindingsReplaced\n') == 4
    assert raw.count(b'pending=1;') == 18
    assert raw.count(b'packed{tick=1;') == 18
    assert b'UnexpectedAttached' not in raw and raw.endswith(b'\n\n')
    assert all(line.count(b'{') == line.count(b'}') for line in raw.splitlines())

if __name__ == '__main__':
    import sys
    selftest()
    if '--selftest' not in sys.argv:
        sys.stdout.buffer.write(render())
