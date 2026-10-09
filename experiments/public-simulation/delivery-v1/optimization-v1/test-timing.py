"""No-child exact artifact inverse and current-stage whole-output controls."""
import json,runpy,sys,types,unittest
from pathlib import Path
H=Path(__file__).resolve().parent;T=H.parent/'timing-v1'
class Timing(unittest.TestCase):
 def test_inverse(self):
  m=runpy.run_path(str(T/'instrument.py'));i=Path('/tmp/bendvy63-named-loop-timing-input-v2');e=Path('/tmp/bendvy63-named-loop-qualification-v1')
  for role,suffix in [('JS','js'),('C','c')]:
   key='C'if role=='C'else'JS';self.assertEqual((i/('simulation.'+suffix)).read_text().replace(m[key+'_NEW'],m[key+'_OLD']),(e/('simulation.'+suffix)).read_text())
 def test_current_full_output(self):
  relocation=types.ModuleType('prepare');relocation.__file__=str(H.parent/'prepare.py');sys.modules['prepare']=relocation;exec(compile(Path(relocation.__file__).read_bytes(),relocation.__file__,'exec'),relocation.__dict__)
  comparator=types.ModuleType('simulation_delivery_compare');comparator.__file__=str(H/'compare.py');sys.modules[comparator.__name__]=comparator;exec(compile((H/'compare.py').read_bytes(),comparator.__file__,'exec'),comparator.__dict__)
  validate=runpy.run_path(str(H/'validate-timing.py'))['validate'];root=Path('/tmp/bendvy63-named-loop-qualification-v1')
  for role in ['TS','JS','Native']:
   raw=(root/('TS.stdout'if role=='TS'else'JS-run.stdout')).read_bytes();metric={'simulationNs':'1','transportNs':'2'}
   if role!='Native':metric['bytes']=len(raw)
   encoded=json.dumps(metric).encode()+b'\n';validate(role,raw,encoded)
   with self.assertRaises(ValueError):validate(role,raw[:-2]+b'X\n',encoded)
   metric['simulationNs']=True
   with self.assertRaises(ValueError):validate(role,raw,json.dumps(metric).encode()+b'\n')
if __name__=='__main__':unittest.main()
