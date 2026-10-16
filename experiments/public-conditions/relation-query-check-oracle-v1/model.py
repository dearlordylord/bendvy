"""Independent finite deferred relation graph/query condition state and full wire."""
import query_model as query
from query_model import listing


COMPONENT_USES = ['Component{' + selection + ';key=' + key + ';mode=Read;required=False}'
                  for selection, key in [('Required', 'Primary'), ('Optional', 'Bonus'), ('With', 'Active'), ('Without', 'Hidden')]]


def relation_use(direction='Outgoing', selection='Required', cell_key='targetAlias', hierarchy=False):
    identity = ('identity{id=9;name=Parent;inverseName=Children;kind=Hierarchy}' if hierarchy else
                'identity{id=7;name=Link;inverseName=LinkedBy;kind=Ordinary}')
    key = 'Parent' if hierarchy else 'Link'
    cell = 'None' if cell_key is None else 'Some{' + cell_key + '}'
    return (f'Relation{{{identity};direction={direction};selection={selection};cellKey={cell};key={key};mode=Read;required=False}}')


def modes():
    specs = [('Outgoing', 'Required', 'targetAlias'), ('Outgoing', 'Optional', 'optionalTarget'),
             ('Outgoing', 'Present', None), ('Outgoing', 'Absent', None),
             ('Incoming', 'Required', 'sourceAlias'), ('Incoming', 'Optional', 'optionalSource'),
             ('Incoming', 'Present', None), ('Incoming', 'Absent', None)]
    uses = [listing(COMPONENT_USES + [relation_use(*spec)]) for spec in specs]
    uses.append(listing(COMPONENT_USES + [relation_use('Incoming', 'Required', 'childAlias', True)]))
    return listing(uses)


class State(query.State):
    def __init__(self, namespace):
        super().__init__(namespace)
        self.edges = []
        self.inverses = []
        self.pending = []
        self.dispatches = []

    def binding(self):
        uses = ['Component{With;key=Active;mode=Read;required=False}'] + COMPONENT_USES
        uses += [relation_use(), 'Resource{Threshold;mode=Read;required=True}']
        return ('binding{systemId=1;description{shape=And{Check{any_with_Active},Check{joined-positive}};uses='
                + listing(uses) + '}}')

    def graph(self):
        edges = [f'7:Link:LinkedBy:ordinary:{source}>{target}' for source, target in self.edges]
        inverses = [f'7:Link:LinkedBy:ordinary:{target}:' + listing([str(source) for source in sources])
                    for target, sources in self.inverses]
        return listing(edges) + ';' + listing(inverses)

    def world(self):
        text = super().world()
        columns = ';'.join(family + '={' + self.column(family) + '}' for family in ['Primary', 'Bonus', 'Active', 'Hidden'])
        assert 'store={' + columns + '}' in text
        text = text.replace('store={' + columns + '}', 'store={columns={' + columns + '};graph={' + self.graph() + '}}')
        return text.replace(';pending=0;', ';pending=' + str(len(self.pending)) + ';')

    def joined(self):
        return [row for row in super().joined() if any(source == row[0] for source, target in self.edges)]

    def readout(self):
        rows = []
        for ident, primary, bonus in self.joined():
            bonus_text = 'ComponentAbsent' if bonus is None else 'Found{' + str(bonus[0]) + '}'
            target = next(target for source, target in self.edges if source == ident)
            cells = f'[Cell{{key=targetAlias;end=Outgoing;value=Target{{{self.namespace}:{target}}}}}]'
            rows.append(f'row{{handle={self.namespace}:{ident};Product{{RowView{{primary=Found{{{primary}}};bonus={bonus_text}}};cells={cells}}}}}')
        presence = [f'row{{handle={self.namespace}:{ident};value=Unit}}' for ident in self.presence()]
        threshold = 'None' if self.threshold is None else 'Some{' + str(self.threshold) + '}'
        return 'readout{joined=' + listing(rows) + ';presence=' + listing(presence) + ';threshold=' + threshold + '}'

    def queue(self, relate):
        assert all(ident in self.entities for ident in (1, 2))
        self.pending.append(('relate' if relate else 'unrelate', 1, 2))

    def barrier(self):
        for operation, source, target in self.pending:
            previous = next((old for entry, old in self.edges if entry == source), None)
            if operation == 'relate' and previous == target:
                continue
            self.edges = [(entry, old) for entry, old in self.edges if entry != source]
            self.inverses = [(old, [entry for entry in sources if entry != source]) for old, sources in self.inverses]
            self.inverses = [(old, sources) for old, sources in self.inverses if sources]
            if operation == 'relate':
                self.edges.append((source, target))
                for old, sources in self.inverses:
                    if old == target:
                        sources.append(source)
                        break
                else:
                    self.inverses.append((target, [source]))
        self.pending = []

    def dispatch(self):
        if self.presence() and self.threshold is None:
            return 'Failed:CheckError{MissingRuntimeRequirements{[Threshold]}}:[Entered{checked}]'
        rows = self.joined()
        allowed = bool(self.presence() and rows and rows[0][1] > self.threshold)
        if allowed:
            self.counter += 1
            self.cursor = self.clock
        self.barrier()
        self.dispatches.append(allowed)
        return 'Finished:[Entered{checked}, ' + ('Ran{1}' if allowed else 'Skipped{1}') + ', Applied]'

    def exchange(self, incoming):
        old = self.threshold
        self.threshold = incoming
        self.slots.insert(0, old)


def schema(namespace):
    s = State(namespace)
    output = []

    def checkpoint(label):
        returned = ''.join(s.slot(value) + ';' for value in s.slots) + '[]'
        output.append(label + '\nreadout=' + s.readout() + '\napp=' + s.actual()
                      + '\nsetup=' + s.setup() + '\nreturnedThresholdSlots=' + returned
                      + '\nmodeUses=' + modes() + '\nsnapshot=' + s.snapshot() + '\n')

    def dispatch():
        output.append(s.dispatch() + '\n')

    def exchange(value):
        s.exchange(value)
        output.append('ThresholdExchanged\n')

    def queue(relate):
        s.queue(relate)
        output.append('Queue:Queued:Success\n')

    checkpoint('empty-disabled')
    s.debug = True
    output.append('Enabled\n')
    checkpoint('empty-enabled')
    dispatch()
    checkpoint('empty-lazy-skipped')
    s.populate()
    output.append('Populated\n')
    checkpoint('populated-no-links')
    dispatch()
    checkpoint('relation-false')
    queue(True)
    checkpoint('relate-pending')
    dispatch()
    checkpoint('relate-applied-after-false')
    dispatch()
    checkpoint('relation-true')
    dispatch()
    checkpoint('relation-true-repeat')
    exchange(50)
    dispatch()
    checkpoint('threshold-false')
    exchange(s.slots.pop(0))
    dispatch()
    checkpoint('threshold-restored-true')
    queue(False)
    checkpoint('unrelate-pending')
    dispatch()
    checkpoint('unrelate-applied-after-true')
    dispatch()
    checkpoint('terminal-relation-false')
    assert (s.counter, s.cursor, s.clock, s.threshold, s.slots) == (14, 12, 12, 5, [50])
    assert s.dispatches == [False, False, False, True, True, False, True, True, False]
    assert s.edges == s.inverses == s.pending == []
    return ''.join(output)


def render():
    return ('Workshop\n' + schema(1) + 'Garden\n' + schema(2) + '\n').encode()


def selftest():
    from state_model import selftest as setup_checks
    setup_checks()
    s = State(77)
    s.populate()
    assert s.clock == 12 and s.joined() == []
    s.queue(True)
    assert s.graph() == '[];[]' and len(s.pending) == 1
    assert 'Skipped{1}' in s.dispatch()
    assert s.graph() == '[7:Link:LinkedBy:ordinary:1>2];[7:Link:LinkedBy:ordinary:2:[1]]'
    assert [row[0] for row in s.joined()] == [1]
    assert s.clock == 12 and s.counter == 10
    s.queue(False)
    assert s.joined()
    assert 'Ran{1}' in s.dispatch() and s.counter == 11
    assert s.graph() == '[];[]' and s.joined() == []
    assert modes().count('Relation{') == 9 and modes().count('required=False') == 45
    raw = render()
    assert raw.endswith(b'\n\n')
    assert raw.count(b'Queue:Queued:Success\n') == 4
    assert raw.count(b'Finished:[Entered{checked}, Ran{1}, Applied]') == 8
    assert raw.count(b'Finished:[Entered{checked}, Skipped{1}, Applied]') == 10
    assert raw.count(b'\nmodeUses=') == 28
    assert raw.count(b'snapshot=None') == 2


if __name__ == '__main__':
    import sys
    selftest()
    if '--selftest' not in sys.argv:
        sys.stdout.buffer.write(render())
