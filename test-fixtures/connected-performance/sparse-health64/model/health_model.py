"""Health specialization of the independently derived Sparse operation model."""
import argparse
import copy
import json
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "sparse-motion64/model"))
from model import World as MotionWorld, MASK
from base_state import listing


class World(MotionWorld):
    def __init__(self, count=64, namespace=1):
        super().__init__(count, namespace)
        self.schema = 'Health'

    def row(self, entity):
        j = entity - 1
        main = {'levels': dict(zip('abcd', self.columns[0].values[j])), 'reserve': 9, 'class': 2}
        aux = self.columns[1].values[j] if j < len(self.columns[1].values) else None
        aux_text = ('ComponentAbsent' if aux is None else 'Found('
                    + json.dumps({'layers': dict(zip('abcd', aux)), 'grade': 3}, separators=(',', ':')) + ')')
        flag = self.columns[2].values[j] if j < len(self.columns[2].values) else None
        return (f'handle={self.namespace}:{entity}:0;main=Found('
                + json.dumps(main, separators=(',', ':')) + ');aux=' + aux_text
                + ';flag=' + ('ComponentAbsent' if flag is None else 'Found({"group":8})'))

    def row_sum(self, entity):
        j = entity - 1
        return (self.namespace + entity + sum(self.columns[0].values[j]) + 9 + 2
                + (14 if j % 3 == 0 else 0) + (9 if j % 3 == 1 else 0)) & MASK


def report(count=64, iterations=64, namespace=1):
    world = World(count, namespace)
    world.reserve_all()
    reservations = listing(f'Reserved({namespace}:{entity}:0)' for entity in world.order)
    text = (f'SparseRuntime Health\ncount={count};iterations={iterations}\n'
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
    assert [sum(values) for values in world.audit] == [944 + 8 * i for i in range(64)]
    expected_total = 0
    for iteration in range(64):
        row_values = {j: 5 * j + 20 + iteration + (14 if j % 3 == 0 else 0)
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
