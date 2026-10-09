"""No-child complete qualified outputs and clock protocol type controls."""
import json,runpy,unittest
from pathlib import Path
HERE=Path(__file__).resolve().parent
R=runpy.run_path(str(HERE.parent/'run-delivery.py'))
PLAN=Path('/tmp/bendvy63-timing-application-plan-v1.json')
DIGEST='f6544dc88f59e8a633d8938988c050418a8710b646555c2f936e264f6a6f5ab6'
class Qualified(unittest.TestCase):
    def test_complete_original_outputs_and_corruptions(self):
        plan,pins=R['admitted'](PLAN,DIGEST)
        for name,file in plan['helpers'].items():R['load'](name,file,pins)
        comparator=R['load']('simulation_delivery_compare',plan['comparator'],pins)
        parser=R['load']('simulation_delivery_parser',plan['parser'],pins)
        comparator.parser_functions=lambda:(parser.parse,parser.render)
        validator=R['load']('timing_application_validator',plan['qualificationValidator'],pins)
        for role,filename in [('TS','TS.stdout'),('JS','JS-run.stdout'),('Native','Native-run.stdout')]:
            raw=(Path('/tmp/bendvy63-ordinary-delivery-v6')/filename).read_bytes()
            metric={'simulationNs':'1','transportNs':'2'}
            if role!='Native':metric['bytes']=len(raw)
            validator.validate(role,raw,(json.dumps(metric)+'\n').encode())
            bad=dict(metric,simulationNs=True)
            with self.assertRaises(ValueError):validator.validate(role,raw,(json.dumps(bad)+'\n').encode())
            with self.assertRaises(ValueError):validator.validate(role,raw[:-1],(json.dumps(metric)+'\n').encode())
            with self.assertRaises(ValueError):validator.validate(role,raw,(json.dumps(metric)+'\nextra\n').encode())
    def test_exact_inverse_transformation(self):
        model=json.loads(Path('/tmp/bendvy63-timing-application-input-v1/TRANSFORMATIONS.json').read_bytes())
        tool=runpy.run_path(str(HERE/'instrument.py'));ts=runpy.run_path(str(HERE/'prepare-application.py'))
        for role,row in model.items():
            original=Path(row['source']).read_text();changed=Path(row['target']).read_text()
            if role=='TS':self.assertEqual(changed.replace(ts['TS_NEW'],ts['TS_OLD']),original)
            else:self.assertEqual(tool['instrument'](role,original),changed)
if __name__=='__main__':unittest.main()
