"""Pre-output whole transport controls; no compiler or runtime child."""
import copy
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[6]
HERE = Path(__file__).resolve().parent
COLLECTOR = ROOT / 'experiments/public-decode/adoption-v1/qualification-v1/spine-report-v1/transport.py'

def load(name, source):
    spec = importlib.util.spec_from_file_location(name, COLLECTOR)
    module = importlib.util.module_from_spec(spec)
    exec(compile(source, str(COLLECTOR), 'exec'), module.__dict__)
    return module

current = load('native_current', COLLECTOR.read_bytes())
ORACLE = Path('/workspace/formal-proofs/bendvy-worktrees/parity-46-construction-oracle') / HERE.relative_to(ROOT) / 'oracle-v1'
for filename, entry in [('expected.json','main.bend'),('mutant-expected.json','mutant-main.bend')]:
    model = json.loads((ORACLE / filename).read_text())
    raw = current.render(model, HERE / entry, True, 'native-consuming')
    assert current.parse(raw, HERE / entry, True, 'native-consuming') == model
    assert current.render(current.parse(raw, HERE / entry, True, 'native-consuming'), HERE / entry, True, 'native-consuming') == raw
    for mutate in [lambda value: value['first'].pop('invalidSpawn'), lambda value: value['firstResource']['valid']['after'].__setitem__('pending', False), lambda value: value.__setitem__('$', 'WrongCandidate')]:
        bad = copy.deepcopy(model)
        mutate(bad)
        try:
            current.render(bad, HERE / entry, True, 'native-consuming')
        except (AssertionError, KeyError, TypeError):
            pass
        else:
            raise AssertionError('whole typed corruption accepted')
# Compare source-current old role against the pre-extension transport bytes.
runner_path = Path('/workspace/formal-proofs/bendvy/scripts/task_runner.py')
runner_spec = importlib.util.spec_from_file_location('native_control_task_runner', runner_path)
task_runner = importlib.util.module_from_spec(runner_spec)
exec(compile(runner_path.read_bytes(), str(runner_path), 'exec'), task_runner.__dict__)
git_result = task_runner.execute_result(['/usr/bin/git','show','737f3c65:experiments/public-decode/adoption-v1/qualification-v1/spine-report-v1/transport.py'],5,cwd=ROOT,capture='split')
assert git_result['exit']==0 and git_result['failure'] is None and git_result['stderr']==b''
old_bytes = git_result['stdout']
old = load('native_historical', old_bytes)
binding = json.loads((HERE.parent / 'canonical-v1/bindings-v1/input-codec-spine-binding.json').read_text())
entry = Path(binding['entry']['path'])
model = json.loads(Path(binding['oracle']['expected']['path']).read_text())
assert current.render(model,entry,True,'input-codec-spine') == old.render(model,entry,True,'input-codec-spine')
print('PASS: full22 and whole mutant roundtrips; missing-field/type/tag refusal; historical role unchanged')
default_oracle = Path('/workspace/formal-proofs/bendvy-worktrees/parity-58-snapshot-research/experiments/public-decode/adoption-v1/qualification-v1/oracle-v1/spine-report-v1/expected.json')
default_model = json.loads(default_oracle.read_text())
default_entry = COLLECTOR.parent / 'spine.bend'
assert current.render(default_model,default_entry) == old.render(default_model,default_entry)
assert current.whole(default_model) == old.whole(default_model)
print('PASS: historical default normal raw and whole mapping unchanged')
