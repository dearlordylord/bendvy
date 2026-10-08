"""Verify public TS supplement only; no children, extraction or backend replay."""
from pathlib import Path
import hashlib,json,runpy,tarfile
E=Path(__file__).resolve().parent;BASE=E.parent/'finite-evidence-v1';sha=lambda b:hashlib.sha256(b).hexdigest();index=json.loads((E/'index.json').read_text())
assert sha((BASE/'index.json').read_bytes())==index['baseIndexSHA256'];base=json.loads((BASE/'index.json').read_text());assert base['archiveSHA256']==index['baseArchiveSHA256']
runpy.run_path(str(BASE/'verify.py'));objects={}
for folder,expected in [(BASE,index['baseArchiveSHA256']),(E,index['archiveSHA256'])]:
 assert sha((folder/'objects.tar.gz').read_bytes())==expected
 members=set()
 with tarfile.open(folder/'objects.tar.gz','r:gz') as t:
  for m in t.getmembers():
   assert m.isfile() and m.name.startswith('objects/') and len(m.name)==72
   d=m.name[8:];b=t.extractfile(m).read();assert sha(b)==d and d not in objects;objects[d]=b;members.add(d)
 assert sorted(members)==(base['objects'] if folder==BASE else index['objects'])
assert all(d in objects for d in index['objects']);assert all(d in objects for d in index['records'].values())
p=json.loads(objects[index['plan']]);r=json.loads(objects[index['receipt']]);assert r['planSHA256']==index['plan'];assert r['status']=='DEVELOPMENT_ACTUAL_TS_FULL18_PLUS4_CHECK_SNAPSHOTS_PASS_NOT_FULL55'
assert {**index['retainedPins'],**index['excludedLocalPins']}==p['pins'];assert set(index['retainedPins']).isdisjoint(index['excludedLocalPins']);assert all(d in objects for d in index['retainedPins'].values());assert index['raw']==r['logs']
assert len(r['commands'])==1;c=p['command'];v=r['commands'][0];assert v['argv']==c['argv'] and v['seconds']==5 and v['exit']==0 and v['failure'] is None and v['fullOracleMatched']
assert objects[index['raw']['ts-supplement.stderr']]==b'';actual=json.loads(objects[index['raw']['ts-supplement.stdout']]);oracle=p['pins'][p['oracle']];assert v['oracleSHA256']==oracle;expected=json.loads(objects[oracle])
def strict(v):
 if isinstance(v,dict):return ('dict',tuple((k,strict(x)) for k,x in sorted(v.items())))
 if isinstance(v,list):return ('list',tuple(map(strict,v)))
 return (type(v).__name__,v)
assert strict(actual)==strict(expected);assert len(actual['observations'])==18 and len(actual['checks'])==4
assert all(v['before']==v['after'] for v in actual['checks'])
print('PASS actual TS18+four insideCheck public snapshots/body counts; not private cursor/wholeWorld/full55 qualification')
