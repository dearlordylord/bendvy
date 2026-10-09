import hashlib
import json
from pathlib import Path
import unittest

HERE = Path(__file__).resolve().parent
class FullSource(unittest.TestCase):
    def test_complete_inventory(self):
        pins = json.loads((HERE / 'SOURCE.json').read_text())
        for path, expected in pins.items():
            self.assertEqual(hashlib.sha256((HERE / path).read_bytes()).hexdigest(), expected)
        old = json.loads((HERE / 'PARENT-SOURCES.json').read_text())
        for path, value in old.items():
            self.assertEqual(hashlib.sha256((HERE / 'parent-sources' / (Path(path).name + '.source')).read_bytes()).hexdigest(), value['sha256'])
        for name in ('fixture.bend', 'phase-driver.bend', 'five-phase-driver.bend', 'retry-driver.bend', 'output-adapter.bend', 'world-observer.bend', 'owner-observer.bend'):
            original = (HERE / 'parent-sources' / (name + '.source')).read_text()
            self.assertEqual((HERE / 'stage' / name).read_text(), original.replace('import core-v1/src/ecs/', 'import ../../../../../src/ecs/'))

    def test_reached_mutation_only(self):
        normal = HERE / 'stage'
        changed = []
        for source in normal.glob('*.bend'):
            if source.read_bytes() != (HERE / 'mutant-reader' / source.name).read_bytes():
                changed.append(source.name)
        self.assertEqual(changed, ['families.bend'])
        mutant = (HERE / 'mutant-reader/families.bend').read_text()
        self.assertEqual(mutant.count('case I.Frame{world,cursor}:omitted_read('), 1)
        self.assertIn('case (world,_):(I.Frame{world,cursor},C.ComponentAbsent{})', mutant)
        self.assertIn('~V,cursor,C.get(', mutant)

    def test_current_source_results(self):
        cases = {'full23-03': (0, 'ALL PROOFS CHECK'), 'full23-reader-01': (0, 'ALL PROOFS CHECK'),
                 'full23-schema-02': (1, 'F.Workshop'), 'full23-write-01': (1, 'observed : bad~H'),
                 'full23-undeclared-01': (1, 'D.Read<bad~H'), 'full23-affine-02': (1, 'consumed more than once'),
                 'full23-escape-02': (1, 'observed : bad~H')}
        for name, (exit_code, diagnostic) in cases.items():
            directory = HERE.parent / 'source-attempts' / name
            receipt = json.loads((directory / 'result.json').read_text())
            self.assertEqual(receipt['exit'], exit_code)
            self.assertIsNone(receipt['failure'])
            self.assertTrue(json.loads((directory / 'post.json').read_text())['unchanged'])
            self.assertIn(diagnostic, (directory / 'stdout').read_text() + (directory / 'stderr').read_text())

if __name__ == '__main__':
    unittest.main()
