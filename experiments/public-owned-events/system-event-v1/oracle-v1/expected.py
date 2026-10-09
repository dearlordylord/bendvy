"""Complete pre-backend System.Owner read adapter oracle from pinned source."""
from pathlib import Path
import copy,json,hashlib,importlib.util
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
CANDIDATE=Path('/workspace/formal-proofs/bendvy-worktrees/parity-63-loader-resolver/experiments/public-owned-events/system-event-v1')
BASE=HERE.parent.parent/'declaration-read-v1/oracle-v1/registered-expected.json'
assert hashlib.sha256(BASE.read_bytes()).hexdigest()=='a3c252aa2776ddfa1aca5f103e29be787cb6e31a7fb83cb66cc33f11ae1d829e'
state=json.loads(BASE.read_text());expected=copy.deepcopy(state)
for category in ['standard','capacity']:
 expected[category]['Trace']['snapshots']=[{'fastOwner':{'slot':'fast-slot','clauses':[{'name':'owned-events','mode':{'Read':{}}}]},'slowOwner':{'slot':'slow-slot','clauses':[{'name':'owned-events','mode':{'Read':{}}}]},'state':copy.deepcopy(s)}for s in state[category]['Trace']['snapshots']]
renderer=HERE.parent.parent/'registered-read-v1/oracle-v1/expected-raw.py'
s=importlib.util.spec_from_file_location('source_renderer',renderer);r=importlib.util.module_from_spec(s);s.loader.exec_module(r)
r.ENTRY=CANDIDATE/'main.bend'
canon=ROOT/'experiments/public-owned-events/declaration-read-v1/registered-v1'
for k,(f,c,fields)in list(r.records.items()):
 if f not in ['main','Base'] and not f.startswith('/'):f=str(canon/f)
 r.records[k]=(f,c,fields)
for group,variants in r.sums.items():
 for tag,(f,fields)in list(variants.items()):
  if f not in ['main','Base'] and not f.startswith('/'):f=str(canon/f)
  variants[tag]=(f,fields)
r.records['StateSnapshot']=r.records['Snapshot']
r.records['Snapshot']=('main','Snapshot',[('fastOwner','OwnerMeta'),('slowOwner','OwnerMeta'),('state','StateSnapshot')])
r.records['OwnerMeta']=('main','OwnerMeta',[('slot','String'),('clauses',['Clause'])])
q=str(ROOT/'experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/declaration.bend')
r.records['Clause']=(q,'Clause',[('name','String'),('mode','Mode')]);r.sums['Mode']={'Read':(q,[])}
if __name__=='__main__':
 (HERE/'expected.json').write_text(json.dumps(expected,indent=2)+'\n')
 (HERE/'expected.stdout').write_text(r.render('Batch',expected)+'\n')
 print('Complete 24 wrapped snapshots plus unchanged direct controls source model frozen')
