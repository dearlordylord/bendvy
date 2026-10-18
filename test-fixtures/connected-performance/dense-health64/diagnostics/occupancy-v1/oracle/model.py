"""Independent Dense Health occupancy; no subject/compiler/output inputs."""
from pathlib import Path
import argparse, copy, gzip, hashlib, importlib.util, json, sys, subprocess

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[5]
MODELS = ROOT / 'test-fixtures/connected-performance/dense-motion64/model'
sys.path.insert(0, str(MODELS))
import state as S
import model as Dense
spec = importlib.util.spec_from_file_location('dense_streams', MODELS / 'seal_gold.py')
Streams = importlib.util.module_from_spec(spec)
spec.loader.exec_module(Streams)
sha = lambda raw: hashlib.sha256(raw).hexdigest()
compact = lambda value: json.dumps(value, separators=(',', ':'))


def shape(values):
    n = len(values)
    assert n > 0 and n & (n - 1) == 0
    return [n, n - 1]


def snapshot(column):
    m = column.metadata
    a, c = m.added, m.changed
    exceptional = m.exceptional
    return dict(kind='indexed', values=shape(column.values), metadata=dict(
        added=shape(a) + [sum(v != 0 for v in a)],
        changed=shape(c) + [sum(v != 0 for v in c)], capacity=m.capacity, depth=m.depth,
        exceptional=[len(exceptional), sum(v[0] != 0 for _, v in exceptional),
                     sum(v[1] != 0 for _, v in exceptional), sum(any(v) for _, v in exceptional)],
        populated=sum(x != 0 or y != 0 for x, y in zip(a, c))))


class Meter:
    def __init__(self):
        self.current = [0, 0, 0]
        self.rows = []

    def append(self, site, delta):
        self.current = [a + b for a, b in zip(self.current, delta)]
        self.rows.append(dict(site=site, delta=delta, current=self.current.copy(), peak=self.current.copy()))

    def render(self, kind, namespace, begin, end, iteration):
        return dict(iteration=iteration, completion='committed', tx=dict(
            kind=kind, namespace=namespace, beginTick=begin, endTick=end, appendTick=None,
            boundaries=self.rows, terminal=self.current, consistent=True))


class Column(S.IndexedColumn):
    def __init__(self):
        super().__init__()
        self.history = [dict(site='empty', snapshot=snapshot(self))]
        self.parent = None

    def write(self, entity, value, tick):
        super().write(entity, value, tick)
        self.history.append(dict(site='mark', snapshot=snapshot(self)))
        if self.parent is not None and self.parent.active is not None:
            self.parent.active.append('component.tx_written', [1, 0, 0])


WORLD_RESULTS = []


class World(S.World):
    def __init__(self, *args, **kwargs):
        self.active = None
        super().__init__(*args, **kwargs)
        self.reports = []
        for column in self.columns:
            column.parent = self
        WORLD_RESULTS.append(self)

    def __setattr__(self, key, value):
        super().__setattr__(key, value)
        if key == 'ledger' and getattr(self, 'active', None) is not None:
            self.active.append('resource-field.journaled', [1, 0, 0])

    def vector(self):
        columns = {name: snapshot(c) for name, c in zip(['main', 'aux', 'flag'], self.columns)}
        total = sum(c['metadata']['populated'] + c['metadata']['exceptional'][3] for c in columns.values())
        return dict(namespace=self.namespace, tick=self.clock,
                    columns=dict(populatedTotal=total, **columns))

    def reserve_all(self):
        super().reserve_all()
        meter = Meter()
        for _ in self.order:
            meter.append('commands.spawn_reserved', [0, 1, 0])
            meter.append('commands.track_pending', [1, 0, 0])
        self.reports.append(dict(sample=meter.render('seed', self.namespace, self.clock, self.clock, None),
                                 prefinish=self.vector()))

    def update(self):
        begin = self.clock
        self.active = Meter()
        super().update()
        meter, self.active = self.active, None
        assert len(meter.rows) == 2 * len(self.audit[-1])
        self.reports.append(dict(sample=meter.render('query-loop', self.namespace, begin, self.clock,
                                                    len(self.audit) - 1), prefinish=self.vector()))

    def result(self, phase):
        histories = dict(namespace=self.namespace, tick=self.clock,
                         columns={name: c.history for name, c in zip(['main', 'aux', 'flag'], self.columns)})
        return dict(schema='Health', workload='Dense', phase=phase, count=self.count, iterations=64,
                    frame=None, reports=self.reports, columnHistories=histories)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    assert not args.output.exists(), 'fresh output required'
    basis = json.loads((HERE / 'SOURCE-BASIS.json').read_text())
    for path, digest in basis['sourcePins'].items():
        assert sha((ROOT / path).read_bytes()) == digest, path
    for path, digest in basis['gitPins'].items():
        raw = subprocess.check_output(['git', '-C', str(ROOT), 'show', basis['finalSubjectSourceCommit'] + ':' + path])
        assert sha(raw) == digest, path
    normal, phases = Streams.streams('Health', 64, 64)
    health = ROOT / 'test-fixtures/connected-performance/dense-health64/model'
    for name, raw in normal.items():
        retained = (health / name).read_bytes()
        assert raw == (gzip.decompress(retained) if name.endswith('.gz') else retained)
    old_column, old_world = S.IndexedColumn, Dense.World
    S.IndexedColumn, Dense.World = Column, World
    try:
        observed, observed_phases = Streams.streams('Health', 64, 64)
    finally:
        S.IndexedColumn, Dense.World = old_column, old_world
    assert observed == normal and observed_phases == phases
    # expected_common validates its projection with one independent ns1 report;
    # streams then emits the actual warmup ns1 and sample ns2 reports in order.
    assert len(WORLD_RESULTS) == 3
    assert [w.namespace for w in WORLD_RESULTS] == [1, 1, 2]
    helper, warmup, sample = WORLD_RESULTS
    assert helper.result('warmup') == warmup.result('warmup')
    assert helper.state() == warmup.state()
    records = [warmup.result('warmup'), sample.result('sample')]
    counter = copy.deepcopy(records)
    changed = 0
    for record in counter:
        for report in record['reports']:
            report['prefinish']['columns']['populatedTotal'] += 1
            changed += 1
    assert changed == sum(len(r['reports']) for r in records) == 130
    args.output.mkdir(parents=True)
    outputs = {}
    for name, rows in [('expected.stats.json', records), ('counter.stats.json', counter)]:
        raw = ('[' + compact(rows[0]) + '\n,\n' + compact(rows[1]) + '\n]\n').encode()
        (args.output / name).write_bytes(raw)
        outputs[name] = dict(bytes=len(raw), sha256=sha(raw))
    receipt = dict(status='PASS', sourceBasisSHA256=sha((HERE / 'SOURCE-BASIS.json').read_bytes()),
                   fullNormalIdentical=True, normalOutputs={k: dict(bytes=len(v), sha256=sha(v)) for k, v in normal.items()},
                   reportsPerWorld=[len(r['reports']) for r in records],
                   appendRecordsPerWorld=[sum(len(r['sample']['tx']['boundaries']) for r in w['reports']) for w in records],
                   columnHistoryCounts=[{k: len(v) for k, v in w['columnHistories']['columns'].items()} for w in records],
                   counterChangedFields=changed, outputs=outputs,
                   scope='Actual finite prefinish simultaneous vectors and completed-column hook histories; structural references exclude payload/evacuated owners, allocator bytes and unique cells. No sampled-global-peak or timing claim.')
    (args.output / 'GENERATION-RECEIPT.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps(receipt))


if __name__ == '__main__':
    main()
