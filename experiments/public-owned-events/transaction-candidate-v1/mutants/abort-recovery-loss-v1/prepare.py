"""Freeze source-derived mutation and complete expectations BEFORE any backend."""
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
HERE=Path(__file__).resolve().parent
BASE=HERE.parents[1]
ROOT=Path('/workspace/formal-proofs/bendvy')
ORACLE=ROOT/'experiments/public-owned-events/transaction-candidate-v1/oracle-v1'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
before='case Stage.Aborted{owners}: Returned{world,T.Failure{error},owners}'
after='case Stage.Aborted{owners}: Returned{world,T.Failure{error},List.tail(&1,Payload,owners)}'
assert sha(ORACLE/'expected-v2.json')=='88a831432428c592da2d3e2029233c22ba31a12b56e5dbb25722868103431faf'
for name in ('adapter.bend','controls.bend','observation.bend','main.bend'):
 source=(BASE/name).read_text()
 if name=='adapter.bend':
  assert source.count(before)==1
  source=source.replace(before,after)
 (HERE/name).write_text(source)
original=json.loads((ORACLE/'expected-v2.json').read_text())
mutant=copy.deepcopy(original)
for case in ('failure','foreign'):
 assert [event['tag'] for event in mutant[case]['recovered']]==['first','second']
 mutant[case]['recovered']=mutant[case]['recovered'][1:]
(HERE/'baseline.json').write_bytes((ORACLE/'expected-v2.json').read_bytes())
(HERE/'counterfactual.json').write_text(json.dumps(mutant,indent=2)+'\n')
spec=importlib.util.spec_from_file_location('independent_raw',ORACLE/'expected-raw.py')
raw=importlib.util.module_from_spec(spec);spec.loader.exec_module(raw)
# Only source-derived namespace binding changes: files are copied beside main,
# while every root canonical import remains exactly the same absolute path.
raw.ENTRY=HERE/'main.bend'
(HERE/'baseline.stdout').write_text(raw.render('Batch',original)+'\n')
(HERE/'counterfactual.stdout').write_text(raw.render('Batch',mutant)+'\n')
paths=[Path(__file__).resolve(),ORACLE/'expected-v2.json',ORACLE/'expected-raw.py',*[BASE/n for n in ('adapter.bend','controls.bend','observation.bend','main.bend')],*[HERE/n for n in ('adapter.bend','controls.bend','observation.bend','main.bend','baseline.json','counterfactual.json','baseline.stdout','counterfactual.stdout')]]
(HERE/'SOURCE-JOIN.json').write_text(json.dumps({'scope':'source-only pre-run whole mutation expectations; no backend','entry':str(HERE/'main.bend'),'delta':{'file':'adapter.bend','before':before,'after':after},'files':{str(p):sha(p) for p in paths}},indent=2)+'\n')
