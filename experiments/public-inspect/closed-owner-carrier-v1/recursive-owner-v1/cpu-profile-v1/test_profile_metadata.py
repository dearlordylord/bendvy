"""No-child CPU profile structure controls."""
import importlib.util
from pathlib import Path
import unittest
import copy

spec = importlib.util.spec_from_file_location('profile_runner', Path(__file__).with_name('diagnostic-run.py'))
M = importlib.util.module_from_spec(spec)
spec.loader.exec_module(M)


class ProfileMetadata(unittest.TestCase):
    def test_profile_structure_and_censored_invalid_capture(self):
        normal = {'nodes':[{'id':1}], 'samples':[1], 'timeDeltas':[100], 'startTime':0, 'endTime':100}
        M.validate_profile(normal)
        signed = dict(normal, samples=[1,1], timeDeltas=[-1,0])
        unchanged = copy.deepcopy(signed)
        M.validate_profile(signed)
        self.assertEqual(signed, unchanged)
        mutations = [dict(normal, samples=[]), dict(normal, samples=[99]),
                     dict(normal, timeDeltas=[1.0]), dict(normal, timeDeltas=[True]),
                     dict(normal, nodes=[]), dict(normal, endTime=-1),
                     dict(normal, nodes=[{'id':1},{'id':1}])]
        for candidate in mutations:
            with self.assertRaises(ValueError):
                M.validate_profile(copy.deepcopy(candidate))


if __name__ == '__main__':
    unittest.main()
