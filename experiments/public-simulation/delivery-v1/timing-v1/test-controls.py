"""No-child type/full-witness gates; reached controls require actual JS/C later."""
import json,runpy,unittest
from pathlib import Path
HERE=Path(__file__).resolve().parent
V=runpy.run_path(str(HERE/'validate-controls.py'))
M=runpy.run_path(str(HERE/'instrument.py'))
class Controls(unittest.TestCase):
    def test_complete_models(self):
        raw=json.dumps({'status':'CONTROL_PASS','positive':V['JS_ORDER'],'refused':['hoisted-main','included-printer'],'stdout':'Complete{17}\n'}).encode()
        V['validate']('JS',raw,b'')
        value=json.loads(raw);value['positive'].remove('teardown')
        with self.assertRaises(ValueError):V['validate']('JS',json.dumps(value).encode(),b'')
        for name,order in V['C_ORDERS'].items():
            label='CONTROL_PASS:'if name=='positive'else'CONTROL_REFUSED:'
            stderr=(json.dumps({'simulationNs':'1','transportNs':'2'})+'\n'+(''if name=='positive'else'\n')+label+order+'\n').encode()
            V['validate'](name,b'Complete{17}\n',stderr)
            with self.assertRaises(ValueError):V['validate'](name,b'Complete{18}\n',stderr)
            with self.assertRaises(ValueError):V['validate'](name,b'Complete{17}\n',stderr.replace(b'teardown,',b''))
            with self.assertRaises(ValueError):V['validate'](name,b'Complete{17}\n',stderr.replace(b'"1"',b'true'))
    def test_exact_fragment_and_unique_seam(self):
        for kind,suffix in [('JS','js'),('Native','c')]:
            original=Path('/tmp/bendvy63-ordinary-delivery-v6/simulation.'+suffix).read_text()
            changed=M['instrument'](kind,original)
            old,new=(M['JS_OLD'],M['JS_NEW'])if kind=='JS'else(M['C_OLD'],M['C_NEW'])
            self.assertEqual(changed.replace(new,old),original)
            with self.assertRaises(ValueError):M['instrument'](kind,original+old)
        self.assertIn(M['C_NEW'],(HERE/'control-positive.c').read_text())
        self.assertIn(json.dumps(M['JS_NEW']),(HERE/'controls.mjs').read_text())
if __name__=='__main__':unittest.main()
