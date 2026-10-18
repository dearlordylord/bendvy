"""Cheap controls for the Health-specific fields; generic grammar is unchanged."""
import unittest
from codec import emit, parse
from primitives import Leaf, Node, Reader
import verbose


class HealthDelta(unittest.TestCase):
    def roundtrip(self, schema, value):
        reader = Reader(b''.join(emit(schema, value)))
        actual = parse(reader, schema)
        reader.finish()
        self.assertEqual(actual, value)
        return actual

    def test_all_vitals_physical_fields_are_retained(self):
        value = {'kind': 'Vitals', 'levels': Node(Leaf(1), Leaf(2)), 'reserve': 99, 'class': 42}
        self.assertEqual(verbose.payload(self.roundtrip('Vitals', value)),
                         'Vitals{node(leaf:1,leaf:2);99,42}')

    def test_armor_grade_is_retained(self):
        value = {'kind': 'Armor', 'layers': Leaf(7), 'grade': 314}
        self.assertEqual(verbose.payload(self.roundtrip('Armor', value)), 'Armor{leaf:7;314}')

    def test_complete_logical_view_fields(self):
        vitals = {'kind': 'Vitals', 'levels': [1, 2, 3, 4], 'reserve': 99, 'class': 42}
        armor = {'kind': 'Armor', 'layers': [4, 3, 2, 1], 'grade': 314}
        self.assertEqual(verbose.view(self.roundtrip('VitalsView', vitals)),
                         {'levels': dict(zip('abcd', [1, 2, 3, 4])), 'reserve': 99, 'class': 42})
        self.assertEqual(verbose.view(self.roundtrip('ArmorView', armor)),
                         {'layers': dict(zip('abcd', [4, 3, 2, 1])), 'grade': 314})


if __name__ == '__main__':
    unittest.main()
