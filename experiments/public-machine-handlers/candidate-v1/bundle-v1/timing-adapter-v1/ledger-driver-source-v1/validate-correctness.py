"""Read/hash-only full ledger output validation; never executes a backend or clock."""
import json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
FIELDS=['component','resource','extraPresent','extraPayload','current','previous','locals','attempts','prefix','pendingStructural','structuralApplied','deliveries','requirements','missing','outcome']
def canonical(value):return json.dumps(value,sort_keys=True,separators=(',',':'),ensure_ascii=False)
def validate(raw):
 ledger=json.loads((HERE.parent/'operations.json').read_text())
 expected=json.loads((HERE.parent/'common-expected.json').read_text())['comparable']
 physical_expected=json.loads((HERE/'physical-expected-before-output.json').read_text())['rows']
 actual=json.loads(raw)
 assert set(actual)==set(ledger['schemas'])
 projected={}
 for schema in ledger['schemas']:
  assert len(actual[schema])==len(ledger['scenarios'])
  common={}
  for descriptor,result in zip(ledger['scenarios'],actual[schema],strict=True):
   assert set(result)=={'rows','sampleKinds'},'actual construction refusal or incomplete result'
   assert result['sampleKinds']==['setup']+[step['kind'] for step in descriptor['steps']]
   names=[step['checkpoint'] for step in descriptor['steps'] if 'checkpoint' in step]
   assert [row['name'] for row in result['rows']]==names
   for row in result['rows']:
    assert set(row)=={'name','values'} and len(row['values'])==1
    value=row['values'][0]
    assert canonical(value)==canonical(physical_expected[schema][row['name']]),'complete independently modeled physical owner mismatch'
    dto={field:value[field] for field in FIELDS}
    dto['pending']=None if value['pending'] is None else value['pending']['value']
    assert row['name'] not in common
    common[row['name']]=dto
  assert list(common)==list(expected[schema])
  assert canonical(common)==canonical(expected[schema]),'complete type-sensitive common oracle mismatch'
  projected[schema]=common
 return {'status':'FULL42_SAME_OWNER_IO_LEDGER_CORRECTNESS_PASS_NO_TIMING_CREDIT','common':projected,'physical':actual}
if __name__=='__main__':
 print(json.dumps(validate(Path(sys.argv[1]).read_text()),separators=(',',':')))
