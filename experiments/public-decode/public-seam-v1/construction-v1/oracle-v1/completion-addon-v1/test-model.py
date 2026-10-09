import copy,json
from pathlib import Path
import expected as M
v=M.expected()
for n,x in v.items():assert x==json.loads(Path(__file__).with_name(n+'-expected.json').read_text())
assert len(v['complete-spine'])==16
cases=v['materialization']['first']
assert cases['insert']['before']['column']['slots'][0]['value']['raw']==M.B.number(99)
assert cases['insert']['barrier']['column']['slots'][0]['value']['raw']==M.B.number(7)
assert cases['invalid']['result']['output']['error']==M.c('Construction',error=M.c('Validation',error=M.B.invalid(M.B.text('wrong'))))
for key in ('first','second'):
 a=v['resource-admission'][key];assert a['before']==a['after'] and a['frameBefore']==a['frameAfter'] and a['frameAfter']['$']=='EmptyFrame' and a['result']['owner']==M.B.incoming(M.B.number(7))
before=copy.deepcopy(v['materialization']['second']);v['materialization']['first'].clear();assert v['materialization']['second']==before
print('full16 source-model, canonical barrier, seed/input separation, typedAdmission/exactframe/undo and detachment controls PASS; no backend')
