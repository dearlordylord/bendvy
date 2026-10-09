"""No-child exact source/authority preservation controls."""
import hashlib,json,runpy,unittest
from pathlib import Path
H=Path(__file__).resolve().parent
class Overlay(unittest.TestCase):
 def test_exact_overlay(self):
  m=runpy.run_path(str(H/'prepare.py'));old=(m['OLD']/m['REL']).read_text();new=(H/'scenario.bend').read_text();self.assertEqual(m['transform'](old),new)
  self.assertNotIn('next:',new);self.assertNotIn('=>',new);self.assertIn('loop(~S,rest,command(~S,head,app,trace))',new)
 def test_all_other_sources_same(self):
  p=json.loads(Path('/tmp/bendvy63-ordinary-delivery-plan-v6.json').read_bytes());stage=Path('/tmp/bendvy63-named-loop-stage-v1')
  for path in p['stagePins']:
   if path not in ['stage.json','experiments/public-simulation/bend-v1/scenario.bend']:self.assertEqual((stage/path).read_bytes(),(Path(p['stageRoot'])/path).read_bytes())
 def test_full_operation_authority_preserved(self):
  s=(H/'scenario.bend').read_text()
  for call in ['Actions.execute(~S,operation,Barrier.frame(~S,app))','App.observe(~S,label,app)','List.reverse(&2,Phase<S>,trace)','Start.initialize(~S,factory,capacity)']:self.assertEqual(s.count(call),1)
  self.assertIn('state: App.Application<S> & List<&2,Phase<S>>',s);self.assertIn('ScenarioInitializationRefused{result}',s)
if __name__=='__main__':unittest.main()
