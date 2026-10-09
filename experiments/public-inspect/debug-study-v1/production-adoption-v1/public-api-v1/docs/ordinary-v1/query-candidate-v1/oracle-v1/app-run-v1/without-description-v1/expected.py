"""Complete source-derived planted-debug-defect oracle; no runtime inputs."""
from pathlib import Path
import copy,hashlib,importlib.util,json,re
HERE=Path(__file__).resolve().parent
PARENT=HERE.parent
CANDIDATE=Path('/workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal') / str(PARENT.relative_to(Path('/workspace/formal-proofs/bendvy-worktrees/parity-58-snapshot-research'))).replace('oracle-v1/app-run-v1','app-run-v1/nominal-carrier-v1/accumulated-v1/without-description-mutant-v1')
def load(name,path):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
baseline=json.loads((PARENT/'expected.json').read_text())
assert hashlib.sha256((PARENT/'expected.json').read_bytes()).hexdigest()=='3ac85c490f3f861ef62bbebf5400d2e3c754b16e2bcd9a7373e96c234260f37f'
changed=copy.deepcopy(baseline);paths=[]
for category in ['plain','transient','constructed']:
 report=changed[category]['Report']
 snapshots=[report['baseline']['phases'][12],report['phases'][0]['snapshot'],report['phases'][1]['snapshot']]
 for i,snapshot in enumerate(snapshots):
  assert len(snapshot['descriptions'])==2
  for j,description in enumerate(snapshot['descriptions']):
   entries=description['Some']['systems'];entry=entries[3]
   assert entry['name']=='withoutHealth' and entry['clauses'][-1]=={'name':'Health','mode':'Without'}
   entry['clauses']=[clause for clause in entry['clauses'] if clause['mode']!='Without']
   paths.append([category,i,j])
assert len(paths)==18
render=load('independent_synthetic',PARENT/'synthetic-raw.py');parser=load('source_parser',CANDIDATE/'parse-app.py')
original_parser=load('original_source_parser',CANDIDATE.parent.parent.parent/'parse-app.py')
old=original_parser.build_identities(str(render.B.ENTRY));new=parser.build_identities(str(CANDIDATE/'main.bend'))
reverse={semantic:token for token,semantic in new['constructors'].items()}
assert len(new['constructors'])==68
mapping={token:reverse[semantic] for token,semantic in old['constructors'].items()}
def raw(value):
 original=render.B.render('Report',value)+'\n'
 return re.sub(r'([^\s{},\[\]]+)(?=\{)',lambda m:mapping[m.group(1)],original)
if __name__=='__main__':
 (HERE/'expected.json').write_text(json.dumps(changed,indent=2)+'\n')
 (HERE/'baseline-relocated.stdout').write_text(raw(baseline))
 (HERE/'expected.stdout').write_text(raw(changed))
 (HERE/'constructor-identities.json').write_text(json.dumps(new,indent=2)+'\n')
 join=json.loads((PARENT/'CONSTRUCTOR-JOIN.json').read_text())
 parser.BASE.strict_equal(parser.normalize(raw(changed),new,join),changed)
 parser.BASE.strict_equal(parser.normalize(raw(baseline),new,join),baseline)
 print('Complete source-derived eighteen-clause mutant and relocated baseline typed roundtrip PASS')
