"""Portable no-child metadata admission and failure boundary controls."""
import hashlib
import importlib.util
import json
from pathlib import Path
import sys
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('collector',HERE/'collect-metadata.py');collector=importlib.util.module_from_spec(spec);spec.loader.exec_module(collector)
spec=importlib.util.spec_from_file_location('metadata',HERE/'prepare-metadata.py');metadata=importlib.util.module_from_spec(spec);spec.loader.exec_module(metadata)
class Controls(unittest.TestCase):
    def plan(self,directory):
        root=Path('/workspace/formal-proofs/bendvy');out=Path(directory)/'output'
        paths=[HERE/'collect-metadata.py',HERE/'prepare-metadata.py',root/'scripts/task_runner.py',root/'scripts/evidence_boundary.py',Path(sys.executable).resolve()]
        d={'scope':'TEST_ONLY_NO_CHILD','python':str(Path(sys.executable).resolve()),'pins':{str(p):collector.sha(p)for p in paths},'outputRoot':str(out),'namespaceLiterals':[],'namespace':metadata.namespace_state([]),'environment':{},'lock':str(Path(directory)/'lock'),'commands':[{'label':'probe','argv':['TEST_ONLY_NO_CHILD'],'capSeconds':5,'stdout':str(out/'probe.stdout'),'stderr':str(out/'probe.stderr')}]}
        path=Path(directory)/'plan.json';path.write_text(json.dumps(d));return path,collector.sha(path),d
    def test_invalid_pin_before_helper_execution(self):
        with tempfile.TemporaryDirectory()as directory:
            path,digest,d=self.plan(directory);d['pins'][str(HERE/'prepare-metadata.py')]='0'*64;path.write_text(json.dumps(d));digest=collector.sha(path)
            with patch.object(collector,'load')as load:
                with self.assertRaises(ValueError):collector.run(path,digest)
                load.assert_not_called()
    def test_wrong_interpreter_before_helper_execution(self):
        with tempfile.TemporaryDirectory()as directory:
            path,digest,d=self.plan(directory);d['python']='/wrong/python';path.write_text(json.dumps(d));digest=collector.sha(path)
            with patch.object(collector,'load')as load:
                with self.assertRaises(ValueError):collector.run(path,digest)
                load.assert_not_called()
    def test_nonzero_preserves_raw_and_terminal_receipt(self):
        with tempfile.TemporaryDirectory()as directory:
            path,digest,d=self.plan(directory);real_load=collector.load
            def loaded(name,path):
                if name=='simulation_metadata_runner':return SimpleNamespace(execute_result=lambda *args:{'stdout':b'partial metadata','stderr':b'refused','exit':7,'failure':None})
                return real_load(name,path)
            with patch.object(collector,'load',side_effect=loaded):
                with self.assertRaises(RuntimeError):collector.run(path,digest)
            out=Path(d['outputRoot']);receipt=json.loads((out/'receipt.json').read_text());self.assertEqual(receipt['status'],'INCOMPLETE');self.assertEqual((out/'probe.stdout').read_bytes(),b'partial metadata');self.assertEqual(len(receipt['guards']),4);self.assertEqual(receipt['commands'][0]['exit'],7)
    def test_second_stream_capture_failure_retains_process_and_first_raw(self):
        with tempfile.TemporaryDirectory()as directory:
            path,digest,d=self.plan(directory);real_load=collector.load;real_capture=collector.capture
            def loaded(name,path):
                if name=='simulation_metadata_runner':return SimpleNamespace(execute_result=lambda *args:{'stdout':b'completed stdout','stderr':b'refused','exit':7,'failure':None})
                return real_load(name,path)
            def captured(path,raw):
                if Path(path).name=='probe.stderr':raise OSError('test-only publication refusal')
                return real_capture(path,raw)
            with patch.object(collector,'load',side_effect=loaded),patch.object(collector,'capture',side_effect=captured):
                with self.assertRaises(OSError):collector.run(path,digest)
            out=Path(d['outputRoot']);receipt=json.loads((out/'receipt.json').read_text());row=receipt['commands'][0]
            self.assertEqual(receipt['status'],'INCOMPLETE');self.assertEqual(row['exit'],7);self.assertIsNone(row['failure'])
            self.assertEqual(row['stdout']['sha256'],hashlib.sha256(b'completed stdout').hexdigest());self.assertEqual(row['stdout']['publication'],'PUBLISHED')
            self.assertEqual((out/'probe.stdout').read_bytes(),b'completed stdout');self.assertFalse((out/'probe.stderr').exists())
            self.assertEqual(row['stderr']['publication'],'FAILED_ABSENT');self.assertEqual(row['captureFailure'],{'stream':'stderr','type':'OSError'})
            self.assertEqual(len(receipt['guards']),4);self.assertEqual(receipt['guardFailures'],[])
            guard=json.loads((out/'final.guard.json').read_text());self.assertEqual(guard['actualPins'][str(out/'probe.stdout')],row['stdout']['sha256'])
    def test_alias_target_chain_and_dotdot(self):
        with tempfile.TemporaryDirectory()as directory:
            root=Path(directory);(root/'real').mkdir();(root/'real/sub').mkdir();(root/'real/target').write_text('x');(root/'first').symlink_to('second');(root/'second').symlink_to('real/sub');view=metadata.aliases(root/'first/../target')
            self.assertEqual(view['resolved'],str(root/'real/target'));self.assertEqual([Path(x['path']).name for x in view['links']],['first','second'])
if __name__=='__main__':unittest.main()
