import copy,json
import expected as M
from pathlib import Path
models=M.expected()
for name,value in models.items():assert value==json.loads(Path(__file__).with_name(name+'-expected.json').read_text())
assert len(models['complete-spine'])==20
r=models['local-refusal']['foreignFirst'];assert r['suppliedAfter']['meta']['namespace']==2 and r['primaryAfter']['meta']['namespace']==1
for r in models['local-refusal'].values():
 if isinstance(r,dict):assert r['incoming']==r['returned'] and r['primaryBefore']==r['primaryAfter'] and r['suppliedBefore']==r['suppliedAfter'] and r['instanceBefore']==r['instanceAfter']
a=models['resource']['first']['abort'];assert a['after']['resource']==M.B.owner(M.number(100))
assert models['request']['first']['foreignInsert']['result']['error']['$']=='Operation'
assert models['request']['first']['invalidSpawn']['result']['error']['error']['$']=='Validation'
for x in models['complete-spine']:
 before=copy.deepcopy(models['request']);x['value'].clear();assert models['request']==before
print('complete20 ordering, typed error nesting, real Refused owners/worlds, detached model controls PASS; no backend')
