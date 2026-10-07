"""Controls for previously missed command log corruption and label collisions."""
import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('receipt_logs', Path(__file__).with_name('receipt-logs.py'))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class LogControls(unittest.TestCase):
    def test_duplicate_plan_refused_before_capture(self):
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaises(ValueError):
                module.CommandLogs(directory, ['runtime-check', 'runtime-check'])
            self.assertEqual(list(Path(directory).iterdir()), [])

    def test_raw_channels_and_overwrite(self):
        with tempfile.TemporaryDirectory() as directory:
            logs = module.CommandLogs(directory, ['normal'])
            logs.record('normal', b'\x00\xff\n', b'diagnostic\n')
            self.assertEqual((Path(directory) / 'normal.stdout').read_bytes(), b'\x00\xff\n')
            self.assertEqual((Path(directory) / 'normal.stderr').read_bytes(), b'diagnostic\n')
            with self.assertRaises(AssertionError):
                logs.record('normal', b'', b'')

    def test_tampered_deleted_and_extra_logs(self):
        for mutation in ('tamper', 'delete', 'extra'):
            with self.subTest(mutation=mutation), tempfile.TemporaryDirectory() as directory:
                logs = module.CommandLogs(directory, ['normal'])
                logs.record('normal', b'complete observation', b'')
                path = Path(directory) / 'normal.stdout'
                if mutation == 'tamper':
                    path.write_bytes(b'replacement')
                elif mutation == 'delete':
                    path.unlink()
                else:
                    (Path(directory) / 'unrecorded.stderr').write_bytes(b'')
                with self.assertRaises(AssertionError):
                    logs.guard()

    def test_unplanned_label_and_text_refused(self):
        with tempfile.TemporaryDirectory() as directory:
            logs = module.CommandLogs(directory, ['normal'])
            with self.assertRaises(ValueError):
                logs.record('unplanned', b'', b'')
            with self.assertRaises(TypeError):
                logs.record('normal', 'decoded', b'')
            self.assertEqual(list(Path(directory).iterdir()), [])


if __name__ == '__main__':
    unittest.main()
