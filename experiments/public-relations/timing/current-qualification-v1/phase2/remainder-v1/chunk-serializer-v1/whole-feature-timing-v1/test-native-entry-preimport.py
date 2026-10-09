"""No-child alternate-interpreter/hash refusals before any repository helper import."""
from pathlib import Path
from unittest.mock import patch
import hashlib,importlib.util,json,sys,tempfile
sys.dont_write_bytecode=True
SOURCE=Path(__file__).resolve().parent/'last-leaf-native-execution.py'
spec=importlib.util.spec_from_file_location('entry',SOURCE);M=importlib.util.module_from_spec(spec);spec.loader.exec_module(M)
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
actual=str(Path(sys.executable).resolve(strict=True));alternate='/usr/bin/false'
with tempfile.TemporaryDirectory(prefix='bendvy42-entry-nochild-') as directory:
 for case,message in [('alternate','approved actual interpreter drift'),('hash','pre-import file pin drift')]:
  p={'cwd':str(SOURCE.parents[8]),'pins':{str(SOURCE):sha(SOURCE),actual:sha(actual),alternate:sha(alternate)},'executionPython':alternate if case=='alternate' else actual}
  if case=='hash':p['pins'][actual]='0'*64
  path=Path(directory)/(case+'.json');path.write_text(json.dumps(p))
  with patch.object(M,'load',side_effect=AssertionError('repository helper imported before refusal')) as loader:
   try:M.main(path,sha(path))
   except ValueError as error:assert str(error)==message
   else:raise AssertionError('must refuse exact bad interpreter/hash')
   assert loader.call_count==0
print(json.dumps({'status':'NO_CHILD_PREIMPORT_REFUSALS_PASS','cases':['alternate actual interpreter identity','actual interpreter file hash mismatch'],'repositoryHelperImports':0,'runtimeChildren':0}))
