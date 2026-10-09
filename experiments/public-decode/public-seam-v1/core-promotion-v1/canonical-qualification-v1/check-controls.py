"""No-child checks of full canonical transport and reached completion witness."""
import copy,hashlib,json,types
from pathlib import Path
HERE=Path(__file__).resolve().parent
WORKTREE=HERE.parents[4]
COLLECTOR=WORKTREE/'experiments/public-decode/adoption-v1/qualification-v1/spine-report-v1/development-run.py'
def load(path):
 module=types.ModuleType(path.stem);module.__file__=str(path)
 exec(compile(path.read_bytes(),str(path),'exec'),module.__dict__)
 return module
runner=load(COLLECTOR);transport=load(COLLECTOR.parent/'transport.py')
checks=[]
for role in ('generic-spine','deferred-spine','completion-omission'):
 binding=json.loads((HERE/'prepared-v1'/f'{role}-binding.json').read_text());entry=Path(binding['entry']['path']);expected=json.loads(Path(binding['oracle']['expected']['path']).read_text())
 raw=transport.render(expected,entry,True,role)
 assert transport.parse(raw,entry,True,role)==expected
 assert transport.whole(expected,role)==json.loads(Path(binding['oracle']['whole']['path']).read_text())
 assert raw==(HERE/'prepared-v1'/f'{role}-js/expected.stdout').read_bytes()
 # Full strict transport must retain actual rejected ownership fields.
 if role=='completion-omission':
  altered=copy.deepcopy(expected);altered['second']['failure']['instance']['state']['recovery'][0]['owners']=[]
  assert runner.mutant_witness(role,altered,expected)
  assert transport.parse(transport.render(altered,entry,True,role),entry,True,role)==altered
  unrelated=copy.deepcopy(expected);unrelated['second']['failure']['after']['meta']['clock']+=1
  assert not runner.mutant_witness(role,unrelated,expected)
  bad=copy.deepcopy(altered);bad['second']['failure']['result']={'$':'FactoryRefusedView'}
  assert not runner.mutant_witness(role,bad,expected)
  pending=copy.deepcopy(altered);pending['second']['failure']['instance']['state']['recovery'][0]['pending']=[{'$':'unexpected'}]
  assert not runner.mutant_witness(role,pending,expected)
 checks.append({'role':role,'fullRawBytes':len(raw),'fullRawSha256':hashlib.sha256(raw).hexdigest(),'modelSha256':binding['oracle']['expected']['sha256'],'status':'PASS'})
# Historical role's exact output shape must remain unchanged.
old=WORKTREE/'experiments/public-decode/public-seam-v1/list-spine-v1/prepared-v1/generic-binding.json';b=json.loads(old.read_text());e=json.loads(Path(b['oracle']['expected']['path']).read_text());raw=transport.render(e,Path(b['entry']['path']),True,'generic-spine');assert raw==(old.parent/'generic-js/expected.stdout').read_bytes()
(HERE/'transport-controls.json').write_text(json.dumps({'scope':'no child; full models and reached witness + historical spine bytes','checks':checks},indent=2)+'\n');print('PASS full23/canonical roles + reached witness controls + historical bytes')
