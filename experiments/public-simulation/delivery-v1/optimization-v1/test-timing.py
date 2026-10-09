"""Portable timer inverse, full-output and admitted-path controls; no tools."""
import hashlib,json,runpy,sys,tempfile,types,unittest
from pathlib import Path
from unittest.mock import patch
H=Path(__file__).resolve().parent;T=H.parent/'timing-v1'

class Timing(unittest.TestCase):
    def test_inverse(self):
        module=runpy.run_path(str(T/'instrument.py'))
        for role,key in [('JS','JS'),('Native','C')]:
            original='prefix\n'+module[key+'_OLD']+'\nsuffix'
            changed=module['instrument'](role,original)
            self.assertEqual(changed.replace(module[key+'_NEW'],module[key+'_OLD']),original)
            with self.assertRaises(ValueError):module['instrument'](role,changed)

    def test_collector_passes_admitted_plan(self):
        dispatch=runpy.run_path(str(H.parent/'run-delivery.py'))['validate_control']
        plan={'stageRoot': 'actual-admitted-stage'};seen=[]
        bound=types.SimpleNamespace(PLAN_BOUND=True,validate=lambda *args,**kwargs:seen.append((args,kwargs)))
        legacy=types.SimpleNamespace(validate=lambda *args:seen.append((args,{})))
        dispatch(bound,'JS',b'output',b'clocks',plan)
        dispatch(legacy,'JS',b'output',b'clocks',plan)
        self.assertIs(seen[0][1]['plan'],plan)
        self.assertEqual(seen[1],(('JS',b'output',b'clocks'),{}))

    def test_plan_paths_and_full_output(self):
        validate=runpy.run_path(str(H/'validate-timing.py'))['validate']
        # The same gate must run in unrelated checkout/output locations.
        for label in ['first-checkout','relocated-checkout']:
            with tempfile.TemporaryDirectory(prefix=label) as temporary:
                directory=Path(temporary);raw='whole report: λ\n'.encode()
                expected=directory/'expected.stdout';expected.write_bytes(raw)
                stale=directory/'old.stdout';stale.write_bytes(b'old report\n')
                stage=directory/'source-stage';stage.mkdir();seen=[]
                plan={'stageRoot':str(stage),'pins':{str(expected):hashlib.sha256(raw).hexdigest()},
                      'validationInputs':{'expectedOutputs':{role:str(expected) for role in ['TS','JS','Native']}}}
                comparator=types.SimpleNamespace(stage_joins=lambda p:seen.append(p),validate_report=lambda *a:None)
                with patch.dict(sys.modules,simulation_delivery_compare=comparator):
                    for role in ['TS','JS','Native']:
                        metric={'simulationNs':'1','transportNs':'2'}
                        if role!='Native':metric['bytes']=len(raw)
                        encoded=json.dumps(metric).encode()+b'\n'
                        validate(role,raw,encoded,plan=plan)
                        with self.assertRaises(ValueError):validate(role,stale.read_bytes(),encoded,plan=plan)
                        metric['simulationNs']=True
                        with self.assertRaises(ValueError):validate(role,raw,json.dumps(metric).encode()+b'\n',plan=plan)
                    self.assertEqual(seen,[stage,stage])
                    expected.write_bytes(b'changed after admission\n')
                    with self.assertRaises(ValueError):validate('Native',expected.read_bytes(),b'{"simulationNs":"1","transportNs":"2"}\n',plan=plan)
                    expected.write_bytes(raw)
                    plan['validationInputs']['expectedOutputs']['Native']=str(stale)
                    with self.assertRaises(ValueError):validate('Native',stale.read_bytes(),b'{"simulationNs":"1","transportNs":"2"}\n',plan=plan)

if __name__=='__main__':unittest.main()
