"""Validate retained source gates, without replaying compiler children."""
import json
from pathlib import Path
import unittest

HERE = Path(__file__).resolve().parent
class SourceResults(unittest.TestCase):
    def test_retained_gates(self):
        expected = {'caller-06': (0, None), 'mutant-01': (0, None),
                    'wrong-schema-01': (1, 'Caller.Other'),
                    'undeclared-01': (1, 'Absent'),
                    'read-write-01': (1, 'Cap.Write'),
                    'affine-01': (1, 'consumed more than once')}
        for name, (exit_code, diagnostic) in expected.items():
            with self.subTest(name=name):
                directory = HERE / 'source-attempts' / name
                result = json.loads((directory / 'result.json').read_text())
                self.assertEqual(result['exit'], exit_code)
                self.assertIsNone(result['failure'])
                self.assertTrue(json.loads((directory / 'post.json').read_text())['unchanged'])
                text = (directory / 'stdout').read_text() + (directory / 'stderr').read_text()
                if diagnostic is None:
                    self.assertIn('ALL PROOFS CHECK', text)
                else:
                    self.assertIn(diagnostic, text)
                    self.assertNotIn('ALL PROOFS CHECK', text)
    def test_sole_mutation(self):
        normal = (HERE / 'ordinary-inspector-declaration.bend').read_text()
        mutated = (HERE / 'mutant-drop-read-clause.bend').read_text()
        clause = '[D.Clause{Identity.key(~S,~P,B.identity(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding)),D.Read{}}]'
        self.assertEqual(normal.count(clause), 1)
        self.assertEqual(mutated, normal.replace(clause, '[]', 1))
        caller = (HERE / 'caller.bend').read_text()
        self.assertEqual((HERE / 'mutant-caller.bend').read_text(), caller.replace('import ./ordinary-inspector-declaration.bend as D', 'import ./mutant-drop-read-clause.bend as D'))

if __name__ == '__main__':
    unittest.main()
