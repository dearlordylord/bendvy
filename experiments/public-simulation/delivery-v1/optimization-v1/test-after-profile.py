"""Portable current-profile and stale-path refusal controls; no tools."""
import hashlib,json,runpy,sys,tempfile,types,unittest
from pathlib import Path
from unittest.mock import patch
H=Path(__file__).resolve().parent

class Profile(unittest.TestCase):
    def test_plan_paths(self):
        validate=runpy.run_path(str(H/'validate-after-profile.py'))['validate']
        for label in ['first-checkout','relocated-checkout']:
            with tempfile.TemporaryDirectory(prefix=label) as temporary:
                root=Path(temporary);current=root/'current';current.mkdir();old=root/'old';old.mkdir()
                expected=root/'expected.stdout';raw=b'complete application\n';expected.write_bytes(raw)
                stage=root/'stage';stage.mkdir();seen=[]
                shapes={'CPU':{'nodes':[{'id':1}],'samples':[1],'timeDeltas':[100]},'allocation':{'head':{},'samples':[]}}
                names={'CPU':'current.cpuprofile','allocation':'current.heapprofile'}
                for role,name in names.items():
                    (current/name).write_text(json.dumps(shapes[role]));(old/name).write_text(json.dumps(shapes[role]))
                plan={'outputRoot':str(current),'stageRoot':str(stage),'pins':{str(expected):hashlib.sha256(raw).hexdigest()},
                      'validationInputs':{'expectedOutputs':{'JS':str(expected)}},
                      'commands':[{'control':role,'emits':name} for role,name in names.items()]}
                comparator=types.SimpleNamespace(stage_joins=lambda p:seen.append(p),validate_report=lambda *a:None)
                with patch.dict(sys.modules,simulation_delivery_compare=comparator):
                    for role,name in names.items():
                        validate(role,raw,b'',plan=plan)
                        with self.assertRaises(ValueError):validate(role,raw[:-1],b'',plan=plan)
                        (current/name).write_text('{}')
                        # Valid old profiles cannot rescue the active invalid artifact.
                        with self.assertRaises(ValueError):validate(role,raw,b'',plan=plan)
                        (current/name).unlink();(current/name).symlink_to(old/name)
                        with self.assertRaises(ValueError):validate(role,raw,b'',plan=plan)
                        (current/name).unlink();(current/name).write_text(json.dumps(shapes[role]))
                    expected.write_bytes(b'drift\n')
                    with self.assertRaises(ValueError):validate('CPU',b'drift\n',b'',plan=plan)
                    self.assertTrue(seen);self.assertTrue(all(p==stage for p in seen))

if __name__=='__main__':unittest.main()
