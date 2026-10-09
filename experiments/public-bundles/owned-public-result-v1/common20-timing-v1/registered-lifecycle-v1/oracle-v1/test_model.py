import expected as o
import json
from pathlib import Path
ms=o.models()
assert len(ms)==10 and [m['namespace'] for m in ms]==list(range(1,11))
for m in ms:
 assert m['before']['clock']==6
 assert [r['id'] for r in m['teardown']['registrations']]==[4,3,2,1]
 assert m['teardown']['nextSystemId']==5
 if m['mode']=='cleanup':
  assert len(m['teardown']['mail']['quarantine'])==1 and m['teardown']['clock']==11
 if m['mode']=='rollback':
  assert m['registry'].endswith(':0') and len(m['teardown']['mail']['returned'])==3
 if m['mode']=='invalid-return':
  assert all(c['values']==[None] and c['stamps']==[[1,0,0]] for c in m['teardown']['columns'].values())
 if m['mode'] in ['spawn-insert','invalid-retry']:
  assert m['teardown']['clock']==16 and len(m['teardown']['mail']['installed'])==2
here=Path(__file__).parent
assert json.loads((here/'expected.json').read_text())==(here/'expected.stdout').read_text()==o.expected()
assert o.expected().count('\n')==10 and 'UNEXPECTED' not in o.expected()
print('PASS: complete literal, ten worlds, registries, retained clocks, inverse/refusal owners')
