"""Source-derived canonical Sparse report; no consumer output is consulted."""
import argparse
import copy
import json
import sys
from base_state import World as DenseWorld, listing

MASK = (1 << 32) - 1


class World(DenseWorld):
    def __init__(self, count=64):
        super().__init__('Motion', count)
        self.cumulative = 0
        self.scan_audits = []

    def populate(self):
        for entity in reversed(self.pending):
            j = entity - 1
            self.phases[entity] = 'Live'
            values = [[j, j + 1, j + 2, j + 3], [1, 2, 3, 4], 8]
            for index, present in enumerate([j % 8 == 0, j % 3 == 0, j % 3 == 1]):
                if present:
                    self.clock += 1
                    self.columns[index].write(entity, values[index], self.clock)
        self.pending = []

    def row_entities(self):
        return [entity for entity in self.order
                if entity <= len(self.columns[0].values)
                and self.columns[0].values[entity - 1] is not None]

    def row(self, entity):
        j = entity - 1
        main = {'coordinates': dict(zip('abcd', self.columns[0].values[j])), 'frame': 7}
        aux = self.columns[1].values[j] if j < len(self.columns[1].values) else None
        aux_text = ('ComponentAbsent' if aux is None else 'Found('
                    + json.dumps({'rates': dict(zip('abcd', aux)), 'moving': True}, separators=(',', ':')) + ')')
        flag = self.columns[2].values[j] if j < len(self.columns[2].values) else None
        return (f'handle=1:{entity}:0;main=Found('
                + json.dumps(main, separators=(',', ':')) + ');aux=' + aux_text
                + ';flag=' + ('ComponentAbsent' if flag is None else 'Found({"group":8})'))

    def logical_rows(self):
        return listing(self.row(entity) for entity in self.row_entities())

    def row_sum(self, entity):
        j = entity - 1
        return (1 + entity + sum(self.columns[0].values[j]) + 7
                + (12 if j % 3 == 0 else 0) + (9 if j % 3 == 1 else 0)) & MASK

    def scan(self, kind):
        # Every call freshly projects ALL Main rows before Data-only inclusion.
        rows = self.row_entities()
        included = [entity for entity in rows
                    if kind == 0 or ((entity - 1) % 3 == 0) == (kind == 1)]
        score = (sum(rank * self.row_sum(entity)
                     for rank, entity in enumerate(included, 1)) + len(included) + 1) & MASK
        wire = ('rows=' + listing(self.row(entity) for entity in rows)
                + ';included=' + listing(self.row(entity) for entity in included)
                + ';score=' + str(score))
        return wire, score

    def update(self):
        values = []
        for entity in self.row_entities():
            old = self.columns[0].values[entity - 1]
            values.append(sum(old) & MASK)
            replacement = [(old[0] + 1) & MASK, *old[1:]]
            self.clock += 1
            self.columns[0].write(entity, replacement, self.clock)
            self.ledger = [(self.ledger[0] + 1) & MASK, *self.ledger[1:]]
        self.cursor = self.clock
        all_rows, all_score = self.scan(0)
        present, present_score = self.scan(1)
        absent, absent_score = self.scan(2)
        weighted = (all_score + 3 * present_score + 5 * absent_score) & MASK
        self.cumulative = (self.cumulative + sum(values) + weighted) & MASK
        self.audit.append(values)
        self.statuses.append('Succeeded')
        self.scan_audits.append('all={' + all_rows + '};present={' + present
                                + '};absent={' + absent + '};weighted=' + str(weighted))

    def state(self):
        cumulative = 0
        audits = []
        for values, scans in zip(self.audit, self.scan_audits):
            weighted = int(scans.rsplit('=', 1)[1])
            cumulative = (cumulative + sum(values) + weighted) & MASK
            audits.append('values=' + listing(values) + ';readsum=' + str(sum(values) & MASK)
                          + ';updated=' + str(len(values)) + ';scans={' + scans
                          + '};cumulative=' + str(cumulative))
        assert cumulative == self.cumulative
        return ('world={' + self.world() + '}|owner={' + self.owner() + '}|audit='
                + listing(audits) + '|statuses=' + listing(self.statuses)
                + '|cumulative=' + str(self.cumulative))


def report(count=64, iterations=64):
    world = World(count)
    world.reserve_all()
    reservations = listing(f'Reserved(1:{entity}:0)' for entity in world.order)
    text = (f'SparseRuntime Motion\ncount={count};iterations={iterations}\n'
            + 'seedOutcome=Success|reservations=' + reservations + '\n')
    text += 'seedPending=' + world.world() + '\n'
    world.populate()
    text += 'seedApplied=' + world.world() + '\n'
    world.registered = True
    text += 'registered=' + world.state() + '\n'
    for _ in range(iterations):
        world.update()
    text += 'final=' + world.state() + '\n'
    before = copy.deepcopy(world)
    text += 'logicalRows=' + world.logical_rows() + '\n'
    assert before == world
    text += 'afterLogicalRead=' + world.world() + '\n'
    return (text + '\n').encode(), world


def selftest():
    raw, world = report()
    assert world.clock == world.cursor == 563
    assert world.ledger == [512, 101, 102, 103]
    assert world.row_entities() == [1, 9, 17, 25, 33, 41, 49, 57]
    assert [sum(values) for values in world.audit] == [944 + 8 * i for i in range(64)]
    assert len(world.phases) == 128 and world.phases.count('Live') == 64
    assert [len(col.stamps) for col in world.columns] == [8, 22, 21]
    assert all(len(col.values) == 64 for col in world.columns)
    assert len(world.scan_audits) == 64
    # Independently closed-form each post-update weighted rank sum.
    expected_total = 0
    for iteration in range(64):
        row_values = {j: 5 * j + 16 + iteration + (12 if j % 3 == 0 else 0)
                      + (9 if j % 3 == 1 else 0) for j in range(0, 64, 8)}
        subsets = [list(row_values), [j for j in row_values if j % 3 == 0],
                   [j for j in row_values if j % 3 != 0]]
        scores = [sum(rank * row_values[j] for rank, j in enumerate(rows, 1)) + len(rows) + 1
                  for rows in subsets]
        weighted = sum(weight * score for weight, score in zip([1, 3, 5], scores))
        assert world.scan_audits[iteration].endswith(';weighted=' + str(weighted))
        expected_total += 944 + 8 * iteration + weighted
    assert world.cumulative == expected_total & MASK
    assert raw.endswith(b'\n\n') and b'UNSUPPORTED' not in raw
    assert report(64, 1)[1].ledger[0] == 8
    assert report(0, 0)[1].clock == 0
    return True


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('count', nargs='?', type=int, default=64)
    parser.add_argument('iterations', nargs='?', type=int, default=64)
    parser.add_argument('--self-test', action='store_true')
    args = parser.parse_args()
    if args.self_test:
        assert selftest()
        print('PASS')
    else:
        sys.stdout.buffer.write(report(args.count, args.iterations)[0])
