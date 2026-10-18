"""Cheap LC1 grammar controls; no subject execution or runner changes."""
import unittest
from primitives import (Chars, InvalidLC1, Leaf, Node, Reader, U32_MAX,
                        encode_bool, encode_list, encode_nat, encode_option,
                        encode_string, encode_tree, encode_u32)


class Primitives(unittest.TestCase):
    def decode(self, raw, operation):
        reader = Reader(raw)
        value = operation(reader)
        reader.finish()
        return value

    def test_domains(self):
        for value in (0, 1, U32_MAX):
            self.assertEqual(self.decode(encode_u32(value), Reader.u32), value)
        value = 1 << 200
        self.assertEqual(self.decode(encode_nat(value), Reader.nat), value)
        value = 10 ** 4500
        self.assertEqual(self.decode(encode_nat(value), Reader.nat), value)
        for value in (-1, U32_MAX + 1, True):
            with self.assertRaises(InvalidLC1):
                encode_u32(value)

    def test_canonical_integer_rejections(self):
        for raw in (b'u;', b'u00;', b'u01;', b'u-1;', b'u+1;', b'u 1;',
                    b'u1', b'u4294967296;', b'n1;', b'u1;x'):
            with self.subTest(raw=raw), self.assertRaises(InvalidLC1):
                self.decode(raw, Reader.u32)

    def test_contextual_tags(self):
        self.assertTrue(self.decode(encode_bool(True), Reader.boolean))
        for value in (None, 0, 31):
            self.assertEqual(self.decode(encode_option(value, encode_u32),
                                         lambda r: r.option(r.u32)), value)
        for raw in (b'2', b'', b'1', b'0u1;'):
            with self.assertRaises(InvalidLC1):
                self.decode(raw, lambda r: r.option(r.u32))

    def test_actual_character_count(self):
        value = Chars((0, 59, 117, 0xD800, U32_MAX))
        self.assertEqual(self.decode(encode_string(value), Reader.string), value)
        self.assertEqual(Chars.from_ascii('s1;\n').ascii_bytes(), b's1;\n')
        with self.assertRaises(InvalidLC1):
            value.ascii_bytes()
        for raw in (b's2;u65;', b's1;u65;u66;', b's01;u65;', b's1;u4294967296;',
                    b's999999999999999999999999999;'):
            with self.assertRaises(InvalidLC1):
                self.decode(raw, Reader.string)

    def test_lists_and_shapes(self):
        values = [0, 2, 0]
        self.assertEqual(self.decode(encode_list(values, encode_u32),
                                     lambda r: r.sequence(r.u32)), values)
        tree = Node(Leaf(None), Node(Leaf(0), Leaf(9)))
        leaf = lambda value: encode_option(value, encode_u32)
        wire = encode_tree(tree, leaf)
        self.assertEqual(self.decode(wire, lambda r: r.tree(lambda: r.option(r.u32))), tree)
        for raw in (b'q4;u0;u2;u0;', b'q2;u0;u2;u0;',
                    b'q999999999999999999999999999;', b'al0', b'x', wire + b'l0'):
            with self.assertRaises(InvalidLC1):
                self.decode(raw, (lambda r: r.sequence(r.u32)) if raw.startswith(b'q')
                            else (lambda r: r.tree(lambda: r.option(r.u32))))

    def test_well_formed_change_is_not_grammar_failure(self):
        # Omission/reordering of valid values is detected by complete expected
        # observation equality, not by guessing a workload-specific list length.
        expected = [1, 2, 3]
        for changed in ([1, 3], [2, 1, 3], [1, 2, 2, 3]):
            actual = self.decode(encode_list(changed, encode_u32), lambda r: r.sequence(r.u32))
            self.assertNotEqual(actual, expected)


if __name__ == '__main__':
    unittest.main()
