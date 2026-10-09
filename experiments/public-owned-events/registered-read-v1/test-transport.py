"""Cheap whole-oracle and malformed/semantic transport controls; no backend."""
import copy
import json
from pathlib import Path
import transport

ORACLE=Path('/workspace/formal-proofs/bendvy-worktrees/parity-58-snapshot-research/experiments/public-owned-events/registered-read-v1/oracle-v1')
expected=json.loads((ORACLE/'expected.json').read_text())
raw=(ORACLE/'expected.stdout').read_bytes()
assert transport.parse(raw)==expected
assert (transport.render('Batch',expected)+'\n').encode()==raw
for malformed in (raw[:-1],raw+b'\n',raw.replace(b'ReadRejected{',b'ReadUnknown{',1),raw.replace(b'999,',b'0999,',1)):
 assert malformed!=raw
 try:transport.parse(malformed)
 except (AssertionError,ValueError):pass
 else:raise AssertionError('malformed transport accepted')
# Valid syntax must still fail the complete semantic join on any owner/request loss.
owner=copy.deepcopy(expected)
owner['standard']['Trace']['snapshots'][-1]['refused'][0]['payload']['sentinel'][-1]+=1
request=copy.deepcopy(expected)
request['standard']['Trace']['snapshots'][-1]['reads'][-1]['ReadRejected']['request']['fail']=True
for changed in (owner,request):
 changed_raw=(transport.render('Batch',changed)+'\n').encode()
 assert transport.parse(changed_raw)==changed and transport.parse(changed_raw)!=expected and changed_raw!=raw
try:transport.render('Batch',{**expected,'unknown':0})
except AssertionError:pass
else:raise AssertionError('extra DTO field accepted')
print('PASS whole 35254-byte independent oracle, four malformed boundaries, two synthetic semantic DTO mutations, extra-field refusal; no child')
