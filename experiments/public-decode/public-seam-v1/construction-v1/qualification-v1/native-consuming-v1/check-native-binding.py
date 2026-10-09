"""No-child Native binding refusal controls; no Clang/runtime execution."""
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[5]
path = ROOT / 'experiments/public-decode/adoption-v1/qualification-v1/spine-report-v1/native-from-c.py'
spec = importlib.util.spec_from_file_location('native_consuming_binding_controls',path)
module = importlib.util.module_from_spec(spec)
exec(compile(path.read_bytes(),str(path),'exec'),module.__dict__)
binding_path = HERE / 'prepared-native-sequential-v1/binding.json'
sha = lambda data: hashlib.sha256(data).hexdigest()
original = json.loads(binding_path.read_text())
assert module.assembly_binding(binding_path,sha(binding_path.read_bytes())) == original
assert module.assembly_binding(None,None) is None
for change in ('source-drift','artifact-drift','mutant-entry'):
    bad=copy.deepcopy(original)
    if change=='source-drift':
        first=next(iter(bad['sourcePins']))
        bad['sourcePins'][first]='0'*64
    elif change=='artifact-drift':
        bad['cEmission']['artifact']['sha256']='0'*64
    else:
        entry=HERE/'mutant-sequential-spine.bend'
        bad['entry']={'path':str(entry),'sha256':sha(entry.read_bytes())}
    with tempfile.TemporaryDirectory() as directory:
        fixture=Path(directory)/'binding.json'
        fixture.write_text(json.dumps(bad))
        try:
            module.assembly_binding(fixture,sha(fixture.read_bytes()))
        except AssertionError:
            pass
        else:
            raise AssertionError('Native binding drift/refused source accepted')
print('PASS: exact positive artifact/source binding; historical absent binding; source/artifact drift and mutant Native entry refused')
