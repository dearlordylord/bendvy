"""No backend: exact whole changed fields and mixed nominal transport."""
import importlib.util
import unittest
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('independent_grant_zero',HERE/'expected.py')
M=importlib.util.module_from_spec(spec)
exec(compile((HERE/'expected.py').read_bytes(),str(HERE/'expected.py'),'exec'),M.__dict__)

def differences(a,b,path=()):
    if type(a) is dict:
        assert type(b) is dict and set(a)==set(b)
        return sum((differences(a[k],b[k],path+(k,)) for k in a),[])
    if type(a) is list:
        assert type(b) is list and len(a)==len(b)
        return sum((differences(v,b[i],path+(i,)) for i,v in enumerate(a)),[])
    return [path] if a!=b else []

class Models(unittest.TestCase):
    def test_only_reached_read_cells_change(self):
        baseline=M.baseline();counter=M.countermodel();diff=differences(baseline,counter)
        self.assertTrue(diff)
        for path in diff:
            self.assertIn(path[0],('standard','capacity'))
            self.assertIn('reads',path)
            self.assertIn('packets',path)
            self.assertEqual(path[-2],'cells')
            self.assertIn(path[-1],(1,2,3))
        for key in ('missing','duplicateRows','duplicatePublication','ownedOutput'):
            self.assertEqual(baseline[key],counter[key])
    def test_complete_failure_and_retry(self):
        snapshots=M.countermodel()['standard']['Trace']['snapshots']
        failed=next(s for s in snapshots if s['label']=='slow-failed')
        view=failed['reads'][-1]['ReadBodyFailed']['error']['ReadFailed']['view']
        self.assertEqual(view['packets'],[{'key':1,'cells':[11]*4},{'key':2,'cells':[21]*4}])
        self.assertEqual(failed['runtime']['log'],M.baseline()['standard']['Trace']['snapshots'][5]['runtime']['log'])
    def test_full_roundtrips_and_nominal_split(self):
        for value in (M.baseline(),M.countermodel()):
            raw,_=M.render(value)
            self.assertIn(b'fixture.PacketView',raw)
            self.assertIn(b'../../source/declaration-read-v1/registered-v1/observation.LogView',raw)
            self.assertIn(b'../../source/declaration-read-v1/registered-v1/log.MissingKey',raw)
        self.assertNotEqual(M.render(M.baseline())[0],M.render(M.countermodel())[0])

if __name__=='__main__':unittest.main()
