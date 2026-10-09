#!/usr/bin/env python3
"""No-child exact current C/oracle binding drift controls."""
import hashlib,importlib.util,json,tempfile
from pathlib import Path
home=Path(__file__).resolve().parent;collector=home.parents[1]/'adoption-v1/qualification-v1/spine-report-v1/native-from-c.py'
spec=importlib.util.spec_from_file_location('native_bindings_control',collector);module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
assert module.assembly_binding(None,None) is None
assert module.ORACLE_FILES['normal']['sha256']=='26e965901c73e89804b69c1d3d13d10e512478955cb0541f6ccbe8e49693766d' and module.ORACLE_COMMIT=='220251bc'
manifest=home/'prepared-native-assembly-v1/normal-binding.json';raw=manifest.read_bytes();binding=module.assembly_binding(manifest,hashlib.sha256(raw).hexdigest());assert binding['role']=='normal'
with tempfile.TemporaryDirectory() as directory:
 path=Path(directory).resolve()/'binding.json'
 for field in ('artifact','receipt','plan'):
  bad=json.loads(raw);bad['cEmission'][field]['sha256']='0'*64;path.write_text(json.dumps(bad));digest=hashlib.sha256(path.read_bytes()).hexdigest()
  try:module.assembly_binding(path,digest)
  except AssertionError:pass
  else:raise AssertionError('C '+field+' drift accepted')
 bad=json.loads(raw);bad['oracle']['expected']['sha256']='0'*64;path.write_text(json.dumps(bad));digest=hashlib.sha256(path.read_bytes()).hexdigest()
 try:module.assembly_binding(path,digest)
 except AssertionError:pass
 else:raise AssertionError('obsolete/wrong oracle accepted')
print(json.dumps({'status':'PASS','historicalDefaultsPreserved':True,'exactCurrentBindingAccepted':True,'artifactReceiptPlanDriftRejected':True,'wrongOracleRejected':True,'backendChildren':0}))
