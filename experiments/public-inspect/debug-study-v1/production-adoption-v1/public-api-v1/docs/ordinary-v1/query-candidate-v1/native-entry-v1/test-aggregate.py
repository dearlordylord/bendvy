#!/usr/bin/env python3
"""Whole synthetic aggregate and owned-stage/guard rejection controls."""
import importlib.util
import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import aggregate
spec = importlib.util.spec_from_file_location('synthetic_transport', HERE / 'test-transport.py')
S = importlib.util.module_from_spec(spec)
spec.loader.exec_module(S)


class Gate(unittest.TestCase):
    def check(self, mutation=None):
        fixture = S.Transport('test_full_unchanged_45_phase_oracle')
        fixture.setUp()
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            cohorts = []
            for category in aggregate.transport.CATEGORIES:
                out = root / category
                out.mkdir()
                cohorts.append(out)
                identity = out / 'identities.json'
                identity.write_text(json.dumps(fixture.inventories[category]))
                plan = {'category': category, 'pins': {}, 'constructorInventory': str(identity), 'commands': []}
                receipt = {'status': 'CATEGORY_DEVELOPMENT_PASS', 'category': category, 'wholeOracleSHA256': aggregate.EXPECTED, 'commands': [], 'guards': []}
                for label, cap in zip(('emit', 'build', 'consumer'), (30, 120, 5)):
                    argv = ['/usr/bin/taskset', '-c', '5', 'synthetic-' + label]
                    plan['commands'].append({'label': label, 'argv': argv, 'capSeconds': cap})
                    row = {'label': label, 'argv': argv, 'capSeconds': cap, 'exit': 0, 'failure': None}
                    for stream in ('stdout', 'stderr'):
                        path = out / (label + '.' + stream)
                        path.write_text(fixture.raw[category] if label == 'consumer' and stream == 'stdout' else '')
                        row[stream] = {'path': str(path), 'sha256': aggregate.sha(path)}
                    receipt['commands'].append(row)
                for label in [a + '-' + b for a in ('emit', 'build', 'consumer') for b in ('pre', 'acquired', 'post')] + ['final']:
                    path = out / (label + '.json')
                    path.write_text(json.dumps({'label': label, 'unchanged': True}))
                    receipt['guards'].append({'path': str(path), 'sha256': aggregate.sha(path)})
                if category == 'plain' and mutation:
                    mutation(receipt)
                planpath = out / 'plan.json'
                planpath.write_text(json.dumps(plan))
                receipt['planSHA256'] = aggregate.sha(planpath)
                (out / 'receipt.json').write_text(json.dumps(receipt))
            with patch.object(sys, 'argv', ['aggregate', str(S.ORACLE), str(root / 'aggregate.json'), *map(str, cohorts)]):
                aggregate.main()

    def test_complete_synthetic(self): self.check()

    def test_stage_and_guard_rejections(self):
        mutations = [lambda r: r['commands'][1].update(exit=1),
                     lambda r: r['commands'][0].update(capSeconds=31),
                     lambda r: r['commands'][2].update(argv=['/usr/bin/taskset', '-c', '4', 'wrong']),
                     lambda r: r['guards'].pop(),
                     lambda r: r['guards'][0].update(sha256='0' * 64)]
        for mutation in mutations:
            with self.subTest(mutation=mutation):
                with self.assertRaises(ValueError): self.check(mutation)


if __name__ == '__main__': unittest.main()
