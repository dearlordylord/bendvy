"""No-child whole independent generic Report transport and semantic controls."""
import copy,json
from pathlib import Path
import transport
O=Path('/workspace/formal-proofs/bendvy-worktrees/parity-58-snapshot-research/experiments/public-owned-events/generic-scoped-read-v1/oracle-v1')
expected=json.loads((O/'expected.json').read_text());raw=(O/'expected.stdout').read_bytes()
assert transport.parse(raw)==expected and (transport.render('Report',expected)+'\n').encode()==raw
for malformed in (raw[:-1],raw+b'\n',raw.replace(b'Projection{',b'Unknown{',1),raw.replace(b'111,',b'0111,',1)):
 assert malformed!=raw
 try:transport.parse(malformed)
 except (AssertionError,ValueError):pass
 else:raise AssertionError('malformed transport accepted')
for field in ('payload','first','second'):
 changed=copy.deepcopy(expected);changed[field]['sentinel'][-1]+=1
 encoded=(transport.render('Report',changed)+'\n').encode()
 assert transport.parse(encoded)==changed and changed!=expected and encoded!=raw
changed=copy.deepcopy(expected);changed['first']['projection']['markers'].pop()
assert transport.parse((transport.render('Report',changed)+'\n').encode())!=expected
try:transport.render('Report',{**expected,'extra':0})
except AssertionError:pass
else:raise AssertionError('extra field accepted')
print('PASS full independent Report roundtrip, four malformed boundaries, four synthetic full-owner/request mutations and extra-field refusal; no child')
