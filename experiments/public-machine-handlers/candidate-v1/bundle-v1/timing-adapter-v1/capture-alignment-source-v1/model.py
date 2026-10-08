"""Independent every-operation state model, authored before aligned Bend/TS outputs."""
import copy,hashlib,importlib.util,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
H=Path(__file__).resolve().parent.parent
spec=importlib.util.spec_from_file_location('independent_handler_bundle_model',H.parent/'oracle.py')
M=importlib.util.module_from_spec(spec);spec.loader.exec_module(M)
FIELDS=['component','resource','extraPresent','extraPayload','current','previous','locals','attempts','prefix','pendingStructural','structuralApplied','deliveries','requirements','missing','outcome']
def canonical(v):return json.dumps(v,sort_keys=True,separators=(',',':'),ensure_ascii=False)
def common(value):return {f:copy.deepcopy(value[f]) for f in FIELDS}|{'pending':None if value['pending'] is None else value['pending']['value']}
def expected():
 ledger=json.loads((H/'operations.json').read_text());physical=json.loads((H/'ledger-driver-source-v1/physical-expected-before-output.json').read_text())['rows'];prior=json.loads((H/'common-expected.json').read_text())['comparable']
 result={};checkpoints={};commonRows={}
 for schema in ledger['schemas']:
  scenarios=[];named={};dto={};captureCount=0
  for descriptor in ledger['scenarios']:
   state=M.initial(1,descriptor['current'],descriptor['extra'])
   failure=next((e['name'] for e in M.ENTRIES if e['id']==descriptor['failureId']),None)
   captures=[{'kind':'setup','checkpoint':None,'values':[copy.deepcopy(state)]}]
   firstMarker=True
   for step in descriptor['steps']:
    if step['kind']=='queue':M.request(state,step['value'],step['skip'])
    elif step['kind']=='marker':M.marker(state,failure if firstMarker else None);firstMarker=False
    else:assert step['kind']=='read';M.read(state)
    name=step.get('checkpoint');captures.append({'kind':step['kind'],'checkpoint':name,'values':[copy.deepcopy(state)]})
    if name is not None:
     assert name not in named;named[name]=copy.deepcopy(state);dto[name]=common(state)
   captureCount+=len(captures);scenarios.append({'scenario':descriptor['scenario'],'captures':captures})
  assert len(scenarios)==13 and captureCount==58 and len(named)==21
  assert canonical(named)==canonical(physical[schema]) and canonical(dto)==canonical(prior[schema])
  result[schema]=scenarios;checkpoints[schema]=named;commonRows[schema]=dto
 return {'status':'INDEPENDENT_ALIGNED_CAPTURE_MODEL_BEFORE_EXECUTABLE_OUTPUT','captures':result,'physicalCheckpoints':checkpoints,'commonCheckpoints':commonRows}
if __name__=='__main__':
 p=Path(__file__).with_name('expected-before-output.json');assert not p.exists();p.write_text(json.dumps(expected(),indent=2)+'\n');print(hashlib.sha256(p.read_bytes()).hexdigest())
