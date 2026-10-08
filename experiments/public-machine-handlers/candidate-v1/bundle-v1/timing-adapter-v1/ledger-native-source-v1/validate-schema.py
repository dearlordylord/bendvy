"""Independent read-only complete21 physical/common schema partition; no full42 credit."""
import json
from pathlib import Path
H=Path(__file__).resolve().parent.parent
FIELDS=['component','resource','extraPresent','extraPayload','current','previous','locals','attempts','prefix','pendingStructural','structuralApplied','deliveries','requirements','missing','outcome']
def canonical(value):return json.dumps(value,sort_keys=True,separators=(',',':'),ensure_ascii=False)
def validate(schema,raw):
 assert schema in ['A','B']
 ledger=json.loads((H/'operations.json').read_text())
 expected=json.loads((H/'common-expected.json').read_text())['comparable'][schema]
 physical=json.loads((H/'ledger-driver-source-v1/physical-expected-before-output.json').read_text())['rows'][schema]
 actual=json.loads(raw);assert set(actual)=={schema}
 assert len(actual[schema])==len(ledger['scenarios'])==13
 common={}
 for descriptor,result in zip(ledger['scenarios'],actual[schema],strict=True):
  assert set(result)=={'rows','sampleKinds'}
  assert result['sampleKinds']==['setup']+[step['kind'] for step in descriptor['steps']]
  names=[step['checkpoint'] for step in descriptor['steps'] if 'checkpoint' in step]
  assert [row['name'] for row in result['rows']]==names
  for row in result['rows']:
   assert set(row)=={'name','values'} and len(row['values'])==1
   value=row['values'][0];assert canonical(value)==canonical(physical[row['name']])
   assert row['name'] not in common
   common[row['name']]={field:value[field] for field in FIELDS}|{'pending':None if value['pending'] is None else value['pending']['value']}
 assert list(common)==list(expected) and len(common)==21 and canonical(common)==canonical(expected)
 return {'status':'SCHEMA_'+schema+'_COMPLETE21_PHYSICAL_COMMON_CORRECTNESS_PASS_NO_FULL42_CREDIT','physical':actual,'common':{schema:common}}

# Full Native42 requires both actualqualified A/B partitions and a separate
# literalplan/raw/config/source/probe-bound union. Never fill another schema
# with expected data or project away physical fields to obtain acceptance.
