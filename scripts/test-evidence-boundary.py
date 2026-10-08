"""Failure injection for postguard ownership and honest persisted receipts."""
import json
from pathlib import Path
import tempfile
import unittest
from evidence_boundary import GuardBoundary, ReceiptBoundary


def fail(error):
    def check():
        raise error
    return check


class Boundaries(unittest.TestCase):
    def test_primary_and_all_secondary_checks(self):
        primary = TimeoutError('child deadline')
        called = []
        with self.assertRaises(TimeoutError) as got:
            with GuardBoundary([('first', fail(ValueError('source drift'))),
                                ('last', lambda: called.append('checked'))]):
                raise primary
        self.assertIs(got.exception, primary)
        self.assertEqual(called, ['checked'])
        self.assertIn('source drift', primary.__notes__[0])

    def test_multiple_guards_and_write_failure_keep_first_failure(self):
        first = ValueError('first guard')
        with tempfile.TemporaryDirectory() as folder:
            with self.assertRaises(ValueError) as got:
                with ReceiptBoundary({}, Path(folder) / 'absent' / 'receipt.json',
                                     [('first', fail(first)),
                                      ('second', fail(RuntimeError('second guard')))]):
                    pass
        self.assertIs(got.exception, first)
        self.assertTrue(any('receipt write' in note for note in first.__notes__))
        self.assertTrue(any('second guard' in note for note in first.__notes__))

    def test_success_waits_for_guards(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / 'receipt.json'
            receipt = {}
            with ReceiptBoundary(receipt, path, [('last', lambda: None)]):
                self.assertEqual(receipt['status'], 'INCOMPLETE')
                receipt['status'] = 'PASS'
            self.assertEqual(json.loads(path.read_text())['status'], 'PASS')

    def test_failed_final_guard_persists_incomplete(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / 'receipt.json'
            with self.assertRaisesRegex(ValueError, 'log membership'):
                with ReceiptBoundary({}, path, [('logs', fail(ValueError('log membership')))]) as scope:
                    scope.receipt['status'] = 'PASS'
            raw = json.loads(path.read_text())
            self.assertEqual(raw['status'], 'INCOMPLETE')
            self.assertEqual(raw['guardFailures'][0]['guard'], 'logs')

    def test_child_and_guard_failure_preserve_receipt_and_primary(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / 'receipt.json'
            primary = RuntimeError('child failed')
            with self.assertRaises(RuntimeError) as got:
                with ReceiptBoundary({}, path, [('tools', fail(ValueError('tool drift')))]):
                    raise primary
            self.assertIs(got.exception, primary)
            raw = json.loads(path.read_text())
            self.assertEqual(raw['status'], 'INCOMPLETE')
            self.assertEqual(raw['error'], 'RuntimeError: child failed')
            self.assertIn('tool drift', raw['guardFailures'][0]['error'])

    def test_cancellation_still_finalizes(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / 'receipt.json'
            with self.assertRaises(KeyboardInterrupt):
                with ReceiptBoundary({}, path, []):
                    raise KeyboardInterrupt('cancelled')
            self.assertEqual(json.loads(path.read_text())['status'], 'INCOMPLETE')

    def test_write_failure_never_hides_primary(self):
        primary = TimeoutError('child deadline')
        with tempfile.TemporaryDirectory() as folder:
            with self.assertRaises(TimeoutError) as got:
                with ReceiptBoundary({}, Path(folder) / 'absent' / 'receipt.json', []):
                    raise primary
        self.assertIs(got.exception, primary)
        self.assertIn('receipt write', primary.__notes__[0])


if __name__ == '__main__':
    unittest.main()
