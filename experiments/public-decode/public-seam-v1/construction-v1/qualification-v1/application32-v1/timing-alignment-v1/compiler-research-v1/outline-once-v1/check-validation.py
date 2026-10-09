"""Mock cost validator controls only; no compiler/runtime child."""
from pathlib import Path
import types,json,copy
HERE=Path(__file__).resolve().parent
module=types.ModuleType('outline_validator');module.__file__=str(HERE/'development.py');exec(compile((HERE/'development.py').read_bytes(),module.__file__,'exec'),module.__dict__)
plan=json.loads((HERE/'plan.json').read_text());data=json.loads(Path('/tmp/bendvy-inspect54-lowering-cost01/cost.json').read_text())
key='owner-carrier:check_target~32'
data['observed']['rows']=[row for row in data['observed']['rows'] if row['key']==key]
data['mapping']=[row for row in data['mapping'] if row['definition']==key]
data['observed']['suppressedOnce']=[{'root':key,'caller':key,'callee':key,'segment':'testSegment','count':2}]
summary=module.validate_cost(data,plan);assert summary['suppressedOnceSites']==1 and summary['suppressedOnceCount']==2
mutations=[lambda x:x['observed']['suppressedOnce'][0].update(count=True),lambda x:x['observed']['suppressedOnce'][0].update(callee='not-mapped'),lambda x:x['observed']['suppressedOnce'][0].update(segment=1),lambda x:x['observed']['suppressedOnce'].append(dict(x['observed']['suppressedOnce'][0]))]
for mutation in mutations:
 changed=copy.deepcopy(data);mutation(changed)
 try:module.validate_cost(changed,plan)
 except ValueError:pass
 else:raise AssertionError('suppression corruption accepted')
assert not Path(plan['generated']).exists() and not Path(plan['costArtifact']).exists()
print('mock complete-source cost join/suppression count-bool/unknowncallee/segmenttype/duplicate controls PASS; no compiler')
