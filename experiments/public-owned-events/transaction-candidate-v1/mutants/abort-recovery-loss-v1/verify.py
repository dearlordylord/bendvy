"""No-child frozen preparation join; does not claim the mutant was executed."""
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
HERE=Path(__file__).resolve().parent
BASE=HERE.parents[1]
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
join=json.loads((HERE/'SOURCE-JOIN.json').read_text())
for path,digest in join['files'].items():assert sha(Path(path))==digest
for name in ('adapter.bend','controls.bend','observation.bend','main.bend'):
 source=(BASE/name).read_text()
 if name=='adapter.bend':
  assert source.count(join['delta']['before'])==1
  source=source.replace(join['delta']['before'],join['delta']['after'])
 assert (HERE/name).read_text()==source
baseline=json.loads((HERE/'baseline.json').read_text())
expected=copy.deepcopy(baseline)
for case in ('failure','foreign'):expected[case]['recovered']=expected[case]['recovered'][1:]
assert json.loads((HERE/'counterfactual.json').read_text())==expected
raw_path=next(Path(p) for p in join['files'] if p.endswith('/oracle-v1/expected-raw.py'))
spec=importlib.util.spec_from_file_location('frozen_raw',raw_path)
raw=importlib.util.module_from_spec(spec);spec.loader.exec_module(raw)
raw.ENTRY=HERE/'main.bend'
assert (HERE/'baseline.stdout').read_text()==raw.render('Batch',baseline)+'\n'
assert (HERE/'counterfactual.stdout').read_text()==raw.render('Batch',expected)+'\n'
assert (HERE/'baseline.stdout').read_bytes()!=(HERE/'counterfactual.stdout').read_bytes()
print('PASS: exact abort-loss delta and complete pre-run baseline/counterfactual expectations; no backend')
