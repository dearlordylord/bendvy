"""No-child current binding, interpreter and whole transport controls."""
import copy,hashlib,importlib.util,json,os,py_compile,sys,tempfile,unittest
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('canonical_reader_collector',HERE.parent/'development-run.py');R=importlib.util.module_from_spec(spec);spec.loader.exec_module(R)
spec=importlib.util.spec_from_file_location('canonical_reader_transport',HERE/'transport.py');T=importlib.util.module_from_spec(spec);spec.loader.exec_module(T)
class Preparation(unittest.TestCase):
 def test_current_whole_transport(self):
  for role in ['generic','registered']:
   expected=json.loads((HERE/'oracle-v1'/(role+'-expected.json')).read_bytes());raw=(HERE/'oracle-v1'/(role+'-expected.stdout')).read_bytes();self.assertEqual(T.parse(role,raw),expected);self.assertEqual((T.render(role,expected)+'\n').encode(),raw)
   with self.assertRaises(Exception):T.parse(role,raw+b'\n')
   mutant=copy.deepcopy(expected)
   if role=='generic':mutant['observations']['payload']['sentinel'][-1]=999
   else:mutant['standard']['Trace']['snapshots'][-1]['ok']=1
   with self.assertRaises(Exception):T.render(role,mutant) if role=='registered'else self.assertEqual(T.parse(role,(T.render(role,mutant)+'\n').encode()),expected)
 def test_exact_binding(self):
  for role in ['generic','registered']:
   p=HERE/(role+'-binding.json');digest=hashlib.sha256(p.read_bytes()).hexdigest();self.assertEqual(R.assembly_binding(p,digest,role)['role'],role)
   with self.assertRaises(AssertionError):R.assembly_binding(p,'0'*64,role)
 def test_actual_interpreter_before_helpers(self):
  paths=[HERE.parent/'development-run.py',R.ROOT/'scripts/task_runner.py',R.ROOT/'scripts/evidence_boundary.py',R.ROOT/'scripts/receipt-logs.py',R.ROOT/'experiments/public-simulation/delivery-v1/installed-config.py',Path(sys.executable).resolve()]
  plan={'tools':{'python':str(paths[-1])},'inputs':{str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}};R.interpreter_and_inputs(plan)
  wrong=copy.deepcopy(plan);wrong['tools']['python']='/wrong/interpreter'
  with self.assertRaises(AssertionError):R.interpreter_and_inputs(wrong)
  wrong=copy.deepcopy(plan);wrong['inputs'][plan['tools']['python']]='0'*64
  with self.assertRaises(AssertionError):R.interpreter_and_inputs(wrong)
 def test_timestamp_valid_cache_cannot_replace_source(self):
  with tempfile.TemporaryDirectory() as tmp:
   path=Path(tmp)/'helper.py';path.write_text("VALUE='stale'\n");py_compile.compile(str(path),doraise=True);stamp=path.stat().st_mtime_ns;path.write_text("VALUE='fresh'\n");os.utime(path,ns=(stamp,stamp))
   spec=importlib.util.spec_from_file_location('cached_control',path);cached=importlib.util.module_from_spec(spec);spec.loader.exec_module(cached);self.assertEqual(cached.VALUE,'stale')
   self.assertEqual(R.load('exact_control',path).VALUE,'fresh')
 def test_real_main_refuses_helper_drift_before_import(self):
  original=R.load;loaded=[]
  def refuse(name,path):loaded.append(name);raise RuntimeError('repository helper imported too soon')
  with tempfile.TemporaryDirectory() as tmp:
   plan=json.loads(Path('/tmp/bendvy53-canonical-generic-js03/plan.json').read_bytes())
   plan['inputs'][str(R.ROOT/'scripts/task_runner.py')]='0'*64
   path=Path(tmp)/'plan.json';path.write_text(json.dumps(plan)+'\n');digest=hashlib.sha256(path.read_bytes()).hexdigest();R.load=refuse
   try:
    with self.assertRaisesRegex(AssertionError,'admitted file drift'):R.main(Path(tmp),execute=True,plan_digest=digest)
   finally:R.load=original
   self.assertEqual(loaded,[]);self.assertFalse((Path(tmp)/'receipt.json').exists())
if __name__=='__main__':unittest.main()
