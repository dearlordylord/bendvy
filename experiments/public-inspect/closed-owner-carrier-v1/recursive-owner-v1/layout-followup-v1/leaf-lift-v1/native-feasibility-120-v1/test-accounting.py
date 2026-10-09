import types
import unittest
from unittest.mock import patch
from pathlib import Path
p=Path(__file__).with_name('development.py')
# Execute captured source in one namespace so function globals are retained.
m=types.ModuleType('diagnostic');m.__file__=str(p)
exec(compile(p.read_bytes(),str(p),'exec'),m.__dict__)
class Accounting(unittest.TestCase):
 def test_completed_deadline_facts_and_cpu_are_distinct(self):
  before=types.SimpleNamespace(ru_utime=10.0,ru_stime=2.0)
  after=types.SimpleNamespace(ru_utime=12.5,ru_stime=2.25)
  original={'exit':None,'failure':'child deadline','stdout':b'partial','stderr':b''}
  with patch.object(m.resource,'getrusage',side_effect=[before,after]),patch.object(m.time,'monotonic_ns',side_effect=[100,900]):
   got=m.accounted_child(lambda *a:dict(original),[],120,{},'.','split')
  self.assertEqual({k:got[k] for k in original},original)
  self.assertEqual(got['childAccounting']['wallNs'],800)
  self.assertEqual(got['childAccounting']['userSeconds'],2.5)
  self.assertEqual(got['childAccounting']['systemSeconds'],.25)
 def test_exception_is_not_relabelled_as_completed_child(self):
  with self.assertRaisesRegex(OSError,'primary'):
   m.accounted_child(lambda *a:(_ for _ in ()).throw(OSError('primary')))
if __name__=='__main__':unittest.main()
