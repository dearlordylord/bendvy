#!/usr/bin/env python3
import pathlib
import tempfile
import unittest
from task_runner import run

ROOT = pathlib.Path(__file__).resolve().parents[1]
namespace = {'__name__': 'coordination_test'}
exec(compile((ROOT / 'scripts/check-coordination.py').read_bytes(), 'check-coordination.py', 'exec'), namespace)

class Controls(unittest.TestCase):
    def test_current_table(self):
        self.assertEqual(namespace['check']((ROOT / 'docs/parity/README.md').read_text()), [])
    def test_missing_or_malformed(self):
        self.assertTrue(namespace['check']('No table'))
        self.assertTrue(namespace['check']('| Task | A | B | C | D |\n| wrong | cells |'))
    def test_historical_sprawl(self):
        self.assertTrue(namespace['check']('| Task | A | B | C | D |\n| X | Y | Z | '+ 'a'*1300 +' | N |'))
    def test_pinned_wrapper_ignores_alias(self):
        with tempfile.TemporaryDirectory() as directory:
            base=pathlib.Path(directory)
            (base/'scripts').mkdir(); (base/'experiments/public-simulation/delivery-v1').mkdir(parents=True)
            wrapper=base/'scripts/bend-check'; wrapper.write_bytes((ROOT/'scripts/bend-check').read_bytes())
            compiler=base/'pinned'; compiler.write_text('#!/bin/sh\n[ "$1" = sample.bend ] && [ "$2" = --check-only ]\n'); compiler.chmod(0o755)
            (base/'experiments/public-simulation/delivery-v1/installed-config.py').write_text("TOOL_PATHS={'bend':"+repr(str(compiler))+"}\nraise RuntimeError('must not execute config')\n")
            result=run(['/bin/sh',str(wrapper),'sample.bend'],timeout=5,capture_output=True)
            self.assertEqual(result.returncode,0,result.stderr)

if __name__=='__main__': unittest.main()
