"""Full offline wire expansion plus concrete LC1 closed-schema controls."""
import copy
import gzip
import hashlib
from pathlib import Path
import unittest
import codec
import records
import verbose
from primitives import InvalidLC1


class Records(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.value = records.report()
        cls.raw = codec.encode_report(cls.value)

    def test_complete_old_wire(self):
        decoded = codec.decode_report(self.raw)
        self.assertEqual(decoded, self.value)
        expanded = verbose.report(decoded)
        original = gzip.decompress((Path(__file__).parent.parent.parent / 'health/expected.stdout.gz').read_bytes())
        self.assertEqual(expanded, original)
        self.assertEqual(len(expanded), 14844490)
        self.assertEqual(hashlib.sha256(expanded).hexdigest(),
                         'dce258d9da2f9168fa21c41f50ac8c148715be004bbecda79750b75ad23e0f66')

    def test_bad_root_truncation_and_trailing(self):
        for raw in (b'XX' + self.raw[2:], self.raw[:-1], self.raw + b'x',
                    self.raw.replace(b'u64;', b'u064;', 1)):
            with self.subTest(prefix=raw[:20]), self.assertRaises(InvalidLC1):
                codec.decode_report(raw)

    def test_unknown_record_and_variant(self):
        for raw in (self.raw.replace(b'Eu0;', b'Eu2;', 1),
                    self.raw.replace(b'W', b'X', 1)):
            with self.assertRaises(InvalidLC1):
                codec.decode_report(raw)

    def test_well_formed_record_omission_changes_full_observation(self):
        changed = copy.deepcopy(self.value)
        changed['final']['owners']['calls'].pop()
        parsed = codec.decode_report(codec.encode_report(changed))
        self.assertNotEqual(verbose.report(parsed), verbose.report(self.value))

    def test_well_formed_dynamic_field_change_is_not_masked(self):
        changed = copy.deepcopy(self.value)
        changed['final']['owners']['boundaries'][0]['before']['main']['stamps'][0]['changed'] += 1
        parsed = codec.decode_report(codec.encode_report(changed))
        self.assertNotEqual(verbose.report(parsed), verbose.report(self.value))


if __name__ == '__main__':
    unittest.main()
