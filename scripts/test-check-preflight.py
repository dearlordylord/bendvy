"""Real consumer execution and stale/refused preflight controls."""
import json
import os
from pathlib import Path
import sys
import tempfile
import unittest
import check_preflight as preflight


class Checks(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        (self.root/'fixture.py').write_text('print("complete")\n')
        (self.root/'expected').write_text('complete\n')
        self.cfg = dict(root=self.root, files=['fixture.py', 'expected', sys.executable], directories=[],
                        checks=[dict(label='consumer', argv=[sys.executable, str(self.root/'fixture.py')], seconds=5, stdout='expected')], env=dict(os.environ))

    def test_actual_consumer_and_stale_source_or_output(self):
        receipt = preflight.run(self.root/'pass', **self.cfg)
        preflight.verify(receipt, **self.cfg)
        (receipt.parent/'consumer.stdout').write_text('partial\n')
        with self.assertRaises(RuntimeError): preflight.verify(receipt, **self.cfg)
        (receipt.parent/'consumer.stdout').write_text('complete\n')
        (self.root/'fixture.py').write_text('print("changed")\n')
        with self.assertRaises(RuntimeError): preflight.verify(receipt, **self.cfg)

    def test_wrong_oracle_retains_failure_and_blocks_admission(self):
        (self.root/'expected').write_text('wrong\n')
        with self.assertRaises(RuntimeError): preflight.run(self.root/'fail', **self.cfg)
        receipt = self.root/'fail/receipt.json'
        self.assertEqual(json.loads(receipt.read_text())['status'], 'INCOMPLETE')
        self.assertEqual((receipt.parent/'consumer.stdout').read_text(), 'complete\n')
        with self.assertRaises(RuntimeError): preflight.verify(receipt, **self.cfg)

    def test_timeout_retains_failure_and_blocks_admission(self):
        (self.root/"fixture.py").write_text("import time; print(\"started\", flush=True); time.sleep(10)\n")
        cfg = dict(self.cfg, checks=[dict(self.cfg["checks"][0], seconds=0.1)])
        with self.assertRaises(RuntimeError): preflight.run(self.root/"timeout", **cfg)
        receipt = self.root/"timeout/receipt.json"
        self.assertEqual(json.loads(receipt.read_text())["status"], "INCOMPLETE")
        with self.assertRaises(RuntimeError): preflight.verify(receipt, **cfg)

    def test_environment_command_and_membership_change(self):
        folder = self.root/'inputs'; folder.mkdir()
        cfg = dict(self.cfg, directories=['inputs'])
        receipt = preflight.run(self.root/'pass', **cfg)
        for changed in [dict(cfg, env=dict(cfg['env'], PREFLIGHT_CHANGED='yes')),
                        dict(cfg, checks=[dict(cfg['checks'][0], seconds=4)])]:
            with self.assertRaises(RuntimeError): preflight.verify(receipt, **changed)
        (folder/'new').write_text('new')
        with self.assertRaises(RuntimeError): preflight.verify(receipt, **cfg)


if __name__ == '__main__': unittest.main()
