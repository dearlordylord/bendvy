"""Complete pre-output synthetic controls, not executable evidence."""
import copy
import importlib.util
import json
from pathlib import Path
import unittest
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('current_reader_transport', HERE / 'transport.py')
T = importlib.util.module_from_spec(spec); spec.loader.exec_module(T)
ORACLE = Path('/workspace/formal-proofs/bendvy-worktrees/parity-58-snapshot-research/experiments/public-relation-readers/current-adoption-v1/oracle-v1/declaration-adoption-v1')


def constructors(raw):
    if isinstance(raw, list):
        for item in raw: yield from constructors(item)
    elif isinstance(raw, dict) and set(raw) == {'constructor', 'fields'}:
        yield raw
        for item in raw['fields']: yield from constructors(item)


class Whole(unittest.TestCase):
    def setUp(self):
        self.transport = T.Transport(HERE.parent / 'main.bend')
        self.expected = json.loads((ORACLE / 'expected.json').read_text())
        self.kind = self.transport.resolve('Candidate', self.transport.entry, {})
        self.raw = self.transport.inverse(self.expected, self.kind)

    def gate(self, raw):
        T.TERM.strict_equal(self.transport.normalize(T.TERM.render_term(raw)), self.expected)

    def field(self, raw, name, suffix=None):
        result = []
        for node in constructors(raw):
            if node['constructor'] not in self.transport.constructors: continue
            _, ctor, fields = self.transport.constructors[node['constructor']]
            if suffix is not None and ctor != suffix: continue
            for index, (field, kind) in enumerate(fields):
                if field == name: result.append((node, index, kind))
        return result[-1]

    def test_entire_baseline_and_two_preoutput_counterfactuals(self):
        self.gate(self.raw)
        for mutant in ('wrong-reader-advance', 'premature-publication'):
            transport = T.Transport(HERE.parent / 'mutants' / mutant / 'main.bend')
            expected = json.loads((ORACLE / (mutant + '-expected.json')).read_text())
            raw = transport.inverse(expected, transport.resolve('Candidate', transport.entry, {}))
            text = T.TERM.render_term(raw) + '\n'
            T.TERM.strict_equal(transport.normalize(text), expected)
            with self.assertRaisesRegex(ValueError, 'Value mismatch|List length mismatch'):
                T.TERM.strict_equal(expected, self.expected)
            (HERE / (mutant + '-synthetic.stdout')).write_text(text)
            (HERE / (mutant + '-identities.json')).write_text(json.dumps(transport.inventory(), indent=2) + '\n')
        (HERE / 'synthetic.stdout').write_text(T.TERM.render_term(self.raw) + '\n')
        (HERE / 'constructor-identities.json').write_text(json.dumps(self.transport.inventory(), indent=2) + '\n')

    def test_missing_category_and_last_field(self):
        raw = copy.deepcopy(self.raw); raw['fields'].pop()
        with self.assertRaisesRegex(ValueError, 'Wrong nominal'): self.gate(raw)
        raw = copy.deepcopy(self.raw); node, _, _ = self.field(raw, 'clock', 'Final'); node['fields'].pop()
        with self.assertRaisesRegex(ValueError, 'Wrong nominal'): self.gate(raw)

    def test_queue_physical_fields_not_collapsed(self):
        node, index, _ = self.field(self.raw, 'back', 'Queue')
        self.assertTrue(node['fields'][index]); node['fields'][index] = []
        with self.assertRaisesRegex(ValueError, 'List length mismatch'): self.gate(self.raw)

    def test_last_world_clock_and_owner_cell(self):
        raw = copy.deepcopy(self.raw); node, index, _ = self.field(raw, 'clock', 'Final'); node['fields'][index] += 1
        with self.assertRaisesRegex(ValueError, 'Value mismatch'): self.gate(raw)
        raw = copy.deepcopy(self.raw); node, index, _ = self.field(raw, 'privateCells'); node['fields'][index][-1] += 1
        with self.assertRaisesRegex(ValueError, 'Value mismatch'): self.gate(raw)

    def test_exact_nominal_namespace_and_type(self):
        raw = copy.deepcopy(self.raw); raw['constructor'] = 'forged.Output'
        with self.assertRaisesRegex(ValueError, 'Unknown exact constructor'): self.gate(raw)
        raw = copy.deepcopy(self.raw); node, _, _ = self.field(raw, 'clock', 'Final')
        alternate = next(token for token, (_, name, _) in self.transport.constructors.items() if name == 'Final' and token != node['constructor'])
        node['constructor'] = alternate
        with self.assertRaisesRegex(ValueError, 'Wrong nominal'): self.gate(raw)

    def test_nat_u32_bool_and_some_arity(self):
        raw = copy.deepcopy(self.raw); node, index, kind = self.field(raw, 'cursor', 'Position'); self.assertEqual(kind, 'Nat'); node['fields'][index] = 0
        with self.assertRaisesRegex(ValueError, 'Expected exact Nat'): self.gate(raw)
        raw = copy.deepcopy(self.raw); node, index, _ = self.field(raw, 'clock', 'Final'); node['fields'][index] = {'constructor': 'True', 'fields': []}
        with self.assertRaisesRegex(ValueError, 'Expected exact U32'): self.gate(raw)
        raw = copy.deepcopy(self.raw); some = next(node for node in constructors(raw) if node['constructor'] == 'Some'); some['fields'].pop()
        with self.assertRaisesRegex(ValueError, 'Wrong builtin'): self.gate(raw)


if __name__ == '__main__': unittest.main()
