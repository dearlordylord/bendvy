"""No-child transport controls; authored bytes are synthetic, not execution evidence."""
import unittest
import aggregate


class Transport(unittest.TestCase):
    def test_exact_synthetic_aggregate(self):
        self.assertEqual(len(aggregate.compare(aggregate.expected_members())), 5077477)

    def test_incomplete_or_changed_members_rejected(self):
        original = aggregate.expected_members()
        cases = [original[:1], original + original[:1], list(reversed(original)),
                 [(original[0][0], original[0][1][:-1]), original[1]],
                 [original[0], (original[1][0], original[1][1][:-1] + b'X')]]
        for case in cases:
            with self.assertRaises(ValueError):
                aggregate.compare(case)


if __name__ == '__main__':
    unittest.main()
