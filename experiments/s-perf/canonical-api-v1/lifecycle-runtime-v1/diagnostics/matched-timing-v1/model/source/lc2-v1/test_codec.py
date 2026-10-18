"""LC2 canonical/domain controls; no subject execution or ECS model calls."""
import unittest
from legacy import Chars, InvalidLC1, U32_MAX
from varint import Reader, encode_nat, encode_u32, encode_string
from codec import LC1, emit


class Canonical(unittest.TestCase):
    def complete(self, raw, method):
        reader = Reader(raw)
        value = method(reader)
        reader.finish()
        return value

    def test_exact_required_boundaries(self):
        expected = [(0, b' '), (31, b'?'), (32, b'@!'), (1023, b'_?'),
                    (1024, b'@@!'), (U32_MAX, b'______#')]
        for value, wire in expected:
            self.assertEqual(encode_u32(value), wire)
            self.assertEqual(self.complete(wire, Reader.u32), value)

    def test_malformed_and_noncanonical(self):
        for wire in (b'', b'@', b'@ ', b'A ', b'______$', b'@@@@@@@!',
                     b'\x1f', b'`', b'~', b'\x7f', b' !'):
            with self.subTest(wire=wire), self.assertRaises(InvalidLC1):
                self.complete(wire, Reader.u32)

    def test_nat_has_no_u32_or_decimal_digit_limit(self):
        for value in (1 << 70, 10 ** 4500):
            self.assertEqual(self.complete(encode_nat(value), Reader.nat), value)
        with self.assertRaises(InvalidLC1):
            self.complete(encode_nat(1 << 35), Reader.u32)

    def test_full_char_u32_domain(self):
        value = Chars((0, 31, 32, 0xD800, U32_MAX))
        self.assertEqual(self.complete(encode_string(value), Reader.string), value)
        with self.assertRaises(InvalidLC1):
            self.complete(b's" ', Reader.string)

    def test_typed_bool_and_option_are_not_varints(self):
        self.assertFalse(self.complete(b'0', Reader.boolean))
        self.assertTrue(self.complete(b'1', Reader.boolean))
        self.assertEqual(self.complete(b'1 ', lambda r: r.option(r.u32)), 0)
        self.assertIsNone(self.complete(b'0', lambda r: r.option(r.u32)))
        for wire in (b' ', b'!', b'2'):
            with self.assertRaises(InvalidLC1):
                self.complete(wire, Reader.boolean)

    def test_count_is_read_from_wire(self):
        self.assertEqual(self.complete(b'q" !', lambda r: r.sequence(r.u32)), [0, 1])
        for wire in (b'q# !', b'q! !', b's!'):
            with self.assertRaises(InvalidLC1):
                self.complete(wire, (lambda r: r.sequence(r.u32)) if wire.startswith(b'q') else Reader.string)

    def test_closed_schema_retains_all_handle_fields(self):
        value = {'namespace': 0, 'index': U32_MAX, 'generation': 32}
        wire = b''.join(emit('Handle', value))
        reader = Reader(wire)
        actual = LC1.parse(reader, 'Handle')
        reader.finish()
        self.assertEqual(actual, value)
        self.assertEqual(b''.join(LC1.emit('Handle', actual)), b'Ku0;u4294967295;u32;')
        with self.assertRaises(InvalidLC1):
            LC1.parse(Reader(b'X' + wire[1:]), 'Handle')

    def test_closed_enum_bounds_and_u32_condition(self):
        value = {'variant': 0, 'id': 32, 'condition': 17}
        reader = Reader(b''.join(emit('Step', value)))
        self.assertEqual(LC1.parse(reader, 'Step'), value)
        reader.finish()
        with self.assertRaises(InvalidLC1):
            LC1.parse(Reader(encode_u32(5)), LC1.enum(4))


if __name__ == '__main__':
    unittest.main()
