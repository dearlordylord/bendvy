#!/usr/bin/env python3
"""No-child recipe controls using independently authored complete synthetic terms."""
import importlib.util
import json
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

HERE = Path(__file__).resolve().parent

class Recipes(unittest.TestCase):
    def test_full_counterfactual_and_baseline_gate_all_recipes(self):
        for variant in ('wrong-reader-advance', 'premature-publication'):
            for backend in ('js', 'native'):
                with self.subTest(variant=variant, backend=backend), tempfile.TemporaryDirectory() as tmp:
                    folder = HERE / 'mutants' / variant
                    spec = importlib.util.spec_from_file_location('recipe', folder / ('development-' + backend + '.py'))
                    module = importlib.util.module_from_spec(spec)
                    spec.loader.exec_module(module)
                    plan = json.loads((folder / ('development-' + backend + ('-v2' if backend == 'native' else '-v1')) / 'plan.json').read_text())
                    plan['generated'] = str(Path(tmp) / ('scenario.js' if backend == 'js' else 'scenario.c'))
                    if backend == 'native': plan['native'] = str(Path(tmp) / 'scenario.native')
                    target = Path(tmp) / 'plan.json'
                    target.write_text(json.dumps(plan))
                    calls = []
                    def child(*args):
                        command = plan['commands'][len(calls)]
                        calls.append(args)
                        if command['label'] in ('emit', 'build'):
                            Path(plan['generated'] if command['label'] == 'emit' else plan['native']).write_bytes(b'mock artifact')
                            output = b''
                        else:
                            output = (HERE / 'transport-v1' / (variant + '-synthetic.stdout')).read_bytes()
                        return {'exit': 0, 'failure': None, 'stdout': output, 'stderr': b''}
                    real_load = module.load
                    with patch.object(module, 'load', lambda name, path: SimpleNamespace(execute_result=child, Inputs=real_load(name, path).Inputs) if name == 'task_runner' else real_load(name, path)):
                        module.run(target, module.sha(target))
                    receipt = json.loads((Path(tmp) / 'receipt.json').read_text())
                    self.assertEqual(receipt['status'], 'DEVELOPMENT_PASS')
                    self.assertTrue(receipt['wholeBaselineRejected'])
                    self.assertEqual(receipt['wholeOracleSHA256'], module.EXPECTED)
                    self.assertEqual(len(calls), 2 if backend == 'js' else 3)

if __name__ == '__main__': unittest.main()
