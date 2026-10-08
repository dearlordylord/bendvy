"""Independent diagnostic Check normal/defect oracles, authored before outputs."""
from pathlib import Path
import json,runpy,copy,hashlib
H=Path(__file__).resolve().parent;V=H.parent;D=V.parent.parent;J=D.parents[1]
complete=runpy.run_path(str(D/'author-complete-oracle.py'),run_name='independent_check_control_model')
normal=copy.deepcopy(complete['oracle'])
assert normal==json.loads((V/'expected-complete.json').read_text())
for schema in normal['schemas']:schema['phaseChecks']=[{'done':True} for _ in range(3)]
defects=runpy.run_path(str(J/'next-qualification/mutants/author-defects.py'),run_name='independent_approved_query_defect_model')
variants={'normal':normal}
for name,changed in defects['variants'].items():
 value=copy.deepcopy(normal)
 for schema,rows in zip(value['schemas'],changed['schemas']):
  assert schema['schema']==rows['schema']
  for phase,query in zip(schema['phases'],rows['phases']):phase['queries']=copy.deepcopy(query['queries'])
  for field in ('retainedInitialInverse','currentInverse2','currentInverse4'):schema[field]=copy.deepcopy(rows[field])
  # Every approved defect changes each complete matrix compared by actual K.run.
  assert all(p['queries']!=n['queries'] for p,n in zip(schema['phases'],normal['schemas'][value['schemas'].index(schema)]['phases']))
  schema['phaseChecks']=[{'done':False} for _ in range(3)]
  # The nominal true gate checks the unchanged independent barrier matrix and
  # therefore returns false. Its body does not run; the false-prefixed gate also
  # returns false. Neither readonly check changes World/foreign owned snapshots.
  schema['gate']['bodyMarkers']=0;schema['gate']['allowed']=[{'skipped':1}]
 variants[name]=value
if __name__=='__main__':
 for name,value in variants.items():
  path=H/name;path.mkdir(exist_ok=True);target=path/'expected-complete.json';assert not target.exists();target.write_text(json.dumps(value,indent=2)+'\n')
  if name!='normal':(path/'expected-witnesses.json').write_text(json.dumps(defects['differences'](normal,value),indent=2)+'\n')
