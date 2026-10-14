from pathlib import Path
import runpy,json,zipfile,copy,unittest
E=Path(__file__).resolve().parent
ns=runpy.run_path(str(E/'verify.py'))
check=ns['validate_execution'];root=ns['x']['producerLeaf'];p=ns['p'];r=ns['r'];gs=ns['guard_objects']
class RetainedEvidence(unittest.TestCase):
 def test_complete_actual_evidence(self):check(p,r,gs,root)
 def rejects(self,change):
  a,b,c=copy.deepcopy(p),copy.deepcopy(r),copy.deepcopy(gs);change(a,b,c)
  with self.assertRaises((AssertionError,KeyError,StopIteration)):check(a,b,c,root)
 def test_absent_consumer(self):self.rejects(lambda a,b,c:b['commands'].pop())
 def test_duplicate_command(self):self.rejects(lambda a,b,c:b['commands'].__setitem__(2,copy.deepcopy(b['commands'][1])))
 def test_reordered_commands(self):self.rejects(lambda a,b,c:b['commands'].reverse())
 def test_changed_argv(self):self.rejects(lambda a,b,c:b['commands'][1]['argv'].append('-O0'))
 def test_changed_cap(self):self.rejects(lambda a,b,c:b['commands'][1].__setitem__('capSeconds',121))
 def test_missing_guard(self):self.rejects(lambda a,b,c:b['guards'].pop())
 def test_duplicate_guard(self):self.rejects(lambda a,b,c:b['guards'].__setitem__(9,copy.deepcopy(b['guards'][8])))
 def test_changed_guard_label(self):self.rejects(lambda a,b,c:c[0].__setitem__('label','final'))
 def test_changed_guard_state(self):self.rejects(lambda a,b,c:c[5].__setitem__('unchanged',False))
 def test_early_output_pin(self):self.rejects(lambda a,b,c:c[0]['actualPins'].__setitem__(a['generated'],b['emitArtifactSHA256']))
 def test_missing_final_output_pin(self):self.rejects(lambda a,b,c:c[-1]['actualPins'].pop(a['native']))
if __name__=='__main__':unittest.main()
