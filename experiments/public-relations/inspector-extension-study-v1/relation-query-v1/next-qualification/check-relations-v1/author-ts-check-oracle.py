"""Author actual Check callback DTO expectations before execution.
Immutable independently authored Inspector row expectations are reused only for
identical read-only query results. Actual Check execution is a fresh gate.
The two scheduled checks repeat the complete barrier matrix, then allow/skip the
marker body. TS foreign raw IDs intentionally alias; Bend namespace rejection
is a separate already-approved contract, not an equivalence assertion.
"""
from pathlib import Path
import json,copy
H=Path(__file__).resolve().parent
source=H.parents[1]/'expected-ts-relations.json'
def oracle():
 value=json.loads(source.read_text())
 for schema in value['schemas']:
  schema['bodyMarkers']=1
  schema['gateChecks']=[copy.deepcopy(schema['phases'][2]),copy.deepcopy(schema['phases'][2])]
 value['scope']='finite TS relation actual Check counterpart; foreign raw-ID aliasing is recorded separately'
 return value
if __name__=='__main__':
 target=H/'expected-ts-check.json';assert not target.exists();target.write_text(json.dumps(oracle(),indent=2)+'\n')
